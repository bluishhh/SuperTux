extends Control

export var autostart = true
export var music = "TuxRacer - Credits"
export var stop_music = false
export var return_scene = ""

var title_scene = "res://scenes/menus/TitleScreen.tscn"

var scroll_speed = 50
var move_speed = 250

var new_position = null
var is_moving = false

func _ready():
	# I don't know why we have to do this but Godot is a silly goose
	yield(self, "draw")
	
	if autostart: start()

func start():
	if stop_music:
		Music.stop_all()
	if music != "" or music == null:
		Music.continue(music)
	Scoreboard.hide()
	
	# If we use an onready var to set this it just returns 0!! whyy!!! grah!!
	new_position = rect_global_position.y
	
	is_moving = true

func _process(delta):
	if !is_moving: return
	
	var move_direction = int(Input.is_action_pressed("move_up")) - int(Input.is_action_pressed("duck"))
	if move_direction != 0:
		new_position += move_direction * move_speed * delta
	else:
		new_position -= scroll_speed * delta
	
	if Input.is_action_just_pressed("ui_accept"):
		new_position -= move_speed * 0.5
	elif Input.is_action_just_pressed("ui_cancel"):
		_return_to_menu()
	
	rect_global_position.y = lerp(rect_global_position.y, new_position, 0.5)

func _on_VisibilityNotifier2D_screen_exited():
	if is_moving: _return_to_menu()

func _return_to_menu():
	if return_scene == "":
		return_scene = title_scene
	Global.goto_scene(return_scene)

func _input(event):
	if event is InputEventScreenTouch:
		if event.pressed:
			Input.action_press("ui_accept")
		else:
			Input.action_release("ui_accept")
