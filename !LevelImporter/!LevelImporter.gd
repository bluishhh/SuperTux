extends Node2D

export var level_data = ""
export var export_file_path = "res://IMPORTS/Level.tscn"
export var default_tile = "Placeholder"

# EXPAND TILEMAPS: If this option is enabled for a tilemap,
# Every tile at the bottom will be copied downwards a number of times
# Effectively filling the bottom of the level.
export var expand_interactive_tilemap = true
export var expand_background_tilemap = true 
export var expand_foreground_tilemap = false

var level_width = 0
var object_list = ""
var checkpoint_list = ""
var tiles_worldmap = ""
var tiles_interactive = ""
var tiles_background = ""
var tiles_foreground = ""

onready var tile_importer = $TileImporter
onready var object_importer = $ObjectImporter
onready var import = $ImportFunctions
onready var music = $MusicImporter.music

onready var level = $Level
onready var level_intact = $Level/TileMap
onready var level_bg = $Level/Background
onready var level_fg = $Level/Foreground
onready var level_water = $Level/Water
onready var objectmap = $Level/ObjectMap
onready var worldmap_objects = get_node("Level/Objects")
onready var gradient_background = get_node_or_null("Level/GradientBG")

export var is_worldmap_importer = false

# Returns only the portion of a string between beginning_phrase and end_phrase.
func _get_section_of_string(string, beginning_phrase, end_phrase):
	var start_pos = string.find(beginning_phrase)
	if start_pos == -1: return null
	start_pos += beginning_phrase.length()
	
	var end_pos = string.find(end_phrase, start_pos)
	if end_pos == -1: return null
	
	var length = end_pos - start_pos
	
	return string.substr(start_pos, length)

func _get_section_of_string_as_int(string, beginning_phrase, end_phrase):
	var string_section = _get_section_of_string(string, beginning_phrase, end_phrase)
	if string_section: return int(string_section)
	else: return null

func _ready():
	var is_level_worldmap = "supertux-worldmap" in level_data
	
	if is_worldmap_importer != is_level_worldmap:
		push_error("Wrong level type! Use LevelImporter to import levels, and WorldmapImporter to import worldmaps.")
		print("Wrong level type! Use LevelImporter to import levels, and WorldmapImporter to import worldmaps.")
		get_tree().quit()
		return
	
	if !is_level_worldmap:
		import_level()
	else:
		import_worldmap()

func import_worldmap():
	_get_level_attributes(level_data, true)
	
	tiles_interactive = _get_worldmap_tile_data(level_data)
	object_list = _get_objects_from_leveldata(level_data, "levels")
	
	_import_level(true)

func import_level():
	_get_level_attributes(level_data)
	object_list = _get_objects_from_leveldata(level_data)
	checkpoint_list = _get_reset_points_from_leveldata(level_data)
	tiles_interactive = _get_tilemap_from_leveldata(level_data, "interactive")
	tiles_background = _get_tilemap_from_leveldata(level_data, "background")
	tiles_foreground = _get_tilemap_from_leveldata(level_data, "foreground")
	
	_import_level()

func _import_level(is_worldmap = false):
	tile_importer.import = import
	object_importer.import = import
	
	tile_importer.tilemap = level_intact
	tile_importer.level_width = level_width
	tile_importer.default_tile = default_tile
	
	if is_worldmap:
		tile_importer.import_worldmap_tiles(tiles_interactive, level_intact, level_fg)
		object_importer.import_worldmap_objects(object_list, worldmap_objects)
		
		var player_x = int(_get_section_of_string(level_data, "(start_pos_x ", ")"))
		var player_y = int(_get_section_of_string(level_data, "(start_pos_y ", ")"))
		
		level.spawn_position = Vector2(player_x, player_y)
		level.is_worldmap = true
	else:
		tile_importer.import_tilemap(tiles_interactive, level_intact, objectmap, expand_interactive_tilemap, level_water)
		tile_importer.import_tilemap(tiles_background, level_bg, objectmap, expand_background_tilemap)
		tile_importer.import_tilemap(tiles_foreground, level_fg, objectmap, expand_foreground_tilemap)
		
		object_importer.import_objects(object_list, objectmap)
		object_importer.import_objects(checkpoint_list, objectmap)
		
		objectmap.enabled = true
	
	import.save_node_to_directory(level, export_file_path)

func _get_level_attributes(leveldata, is_worldmap = false):
	level_width = int(_get_section_of_string(leveldata, "width ", ")"))
	
	if !is_worldmap:
		level.level_title = _get_section_of_string(leveldata, "name \"", "\")")
		level.gravity = int(_get_section_of_string(leveldata, "gravity ", ")"))
		level.level_author = _get_section_of_string(leveldata, "author \"", "\")")
		level.particle_system = _get_section_of_string(leveldata, "particle_system \"", "\")")
		level.time = _get_section_of_string_as_int(leveldata, "time ", ")")
		
		if gradient_background:
			var top_colour = Color(1,1,1)
			var bottom_colour = Color(1,1,1)
			
			top_colour.r = _get_section_of_string_as_int(leveldata, "bkgd_red_top", ")")
			top_colour.g = _get_section_of_string_as_int(leveldata, "bkgd_green_top", ")")
			top_colour.b = _get_section_of_string_as_int(leveldata, "bkgd_blue_top", ")")
			bottom_colour.r = _get_section_of_string_as_int(leveldata, "bkgd_red_bottom", ")")
			bottom_colour.g = _get_section_of_string_as_int(leveldata, "bkgd_green_bottom", ")")
			bottom_colour.b = _get_section_of_string_as_int(leveldata, "bkgd_blue_bottom", ")")
			
			gradient_background.top_colour = top_colour / 255
			gradient_background.bottom_colour = bottom_colour / 255
			gradient_background.top_colour.a = 1
			gradient_background.bottom_colour.a = 1
			
		
		
		
		var autoscroll_speed = _get_section_of_string_as_int(leveldata, "hor_autoscroll_speed ", ")")
		if autoscroll_speed == null: autoscroll_speed = 0
		level.autoscroll_speed = autoscroll_speed
	
	var level_music = _get_section_of_string(leveldata, "music \"", "\")")
	if level_music:
		if music.has(level_music):
			level_music = music.get(level_music)
		level.music = level_music

func _get_objects_from_leveldata(leveldata, string = "objects"):
	var get = "(" + string + "    "
	get = _get_section_of_string(leveldata, get, "))  )")
	if get: return get
	
	get = "(" + string
	get = _get_section_of_string(leveldata, get, ")))")
	if get: return get
	
	get = "(" + string + "      "
	get = _get_section_of_string(leveldata, get, ")   ))")
	return get

func _get_reset_points_from_leveldata(leveldata):
	var check_1 = _get_section_of_string(leveldata, "(reset-points", "))   )")
	if check_1: return check_1
	else: return _get_section_of_string(leveldata, "(reset-points", ")))")

func _get_tilemap_from_leveldata(leveldata, tilemap_name):
	return _get_section_of_string(leveldata, "(" + tilemap_name + "-tm", ")")

func _get_worldmap_tile_data(leveldata):
	return _get_section_of_string(leveldata, "(data", ")")
