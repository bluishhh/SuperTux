extends CanvasLayer

export var title = ""
export var author = ""

onready var title_text = $Control/VBoxContainer/Title
onready var author_text = $Control/VBoxContainer/Author
onready var lives_counter = $Control/VBoxContainer/HBoxContainer/LivesCount

func _ready():
	Scoreboard.hide()
	title_text.bbcode_text = str("[center][wave]" + title)
	author_text.text = str("by " + author)
	lives_counter.text = str(Scoreboard.lives)

func _process(_delta):
	if Input.is_action_just_pressed("ui_cancel"):
		$Timer.stop()
		_dissapear()

func _input(event):
	if event is InputEventScreenTouch:
		if event.pressed:
			$Timer.stop()
			_dissapear()

func _on_Timer_timeout():
	_dissapear()

func _dissapear():
	queue_free()
	Scoreboard.show()
