extends CanvasLayer

onready var menu = $Control
onready var menu_items = $Control/CenterContainer
onready var options_menu = $Control/OptionsMenu

onready var button_continue = $Control/CenterContainer/VBoxContainer/Continue
onready var button_restart = $Control/CenterContainer/VBoxContainer/Restart
onready var button_options = $Control/CenterContainer/VBoxContainer/Options
onready var button_abort = $Control/CenterContainer/VBoxContainer/Abort
onready var button_quit = $Control/CenterContainer/VBoxContainer/Quit

var in_editor = false

var paused = false setget _set_paused

func _ready():
	if WorldmapManager.is_level_worldmap or in_editor:
		button_restart.hide()
		button_abort.hide()
	
	if in_editor:
		button_quit.hide()
	
	if WorldmapManager.worldmap_level == null:
		button_abort.hide()
	
	# Make the music mute if we pause the game.
	Music.pause_mode = PAUSE_MODE_INHERIT
	menu.hide()
	Global.can_pause = true

func _input(event):
	if !Global.can_pause: return
	if Global.is_popup_visible(): return
	if Input.is_action_just_pressed("ui_cancel"):
		self.paused = !paused

#func _input(event):
#	#print(event.is_action_pressed("ui_cancel"))
#	if !Global.can_pause: return
#
#	if event.is_action_pressed("ui_cancel"):
#		self.paused = !paused

func _set_paused(new_value):
	paused = new_value
	get_tree().paused = paused
	Scoreboard.level_timer.paused = paused
	menu.visible = paused

func _on_Continue_pressed():
	self.paused = false

func _on_Restart_pressed():
	Global.respawn_player()

func _on_Quit_pressed():
	Global.goto_title_screen()

# Focus signals

func _on_Continue_mouse_entered():
	button_continue.grab_focus()

func _on_Restart_mouse_entered():
	button_restart.grab_focus()

func _on_Options_mouse_entered():
	button_options.grab_focus()

func _on_Abort_mouse_entered():
	button_abort.grab_focus()

func _on_Quit_mouse_entered():
	button_quit.grab_focus()

#Grabbing focus when not hidden

func _on_Control_visibility_changed():
	if $Control.visible == true:
		button_continue.grab_focus()

func _on_Options_pressed():
	menu_items.modulate.a = 0
	options_menu.popup()

func _on_OptionsMenu_popup_hide():
	menu_items.modulate.a = 1
	button_options.grab_focus()

func _on_Abort_pressed():
	if WorldmapManager.is_level_worldmap: return
	
	WorldmapManager.return_to_worldmap()


