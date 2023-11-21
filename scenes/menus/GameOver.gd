extends Control

func appear():
	$AnimationPlayer.play("GameOver")

func hide_text():
	$AnimationPlayer.play("HideText")

func hide():
	$AnimationPlayer.play("default")
