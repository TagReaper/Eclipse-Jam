extends Control

@export var BlueCountDisplay: Label
@export var RedCountDisplay: Label
@export var PauseIndicator: Sprite2D

func _update_count(x: int, y: int) -> void:
	BlueCountDisplay.text = str(x)
	RedCountDisplay.text = str(y)

func _update_pause(paused: bool) -> void:
	if paused:
		PauseIndicator.frame = 112
	else:
		PauseIndicator.frame = 113
