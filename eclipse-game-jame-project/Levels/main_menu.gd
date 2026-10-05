extends Control

func _ready() -> void:
	Music._swap_track("res://Assets/Sound/Music/Wav/Lentikula - 08 The Final Descent.wav")

func _on_level_pressed() -> void:
	$Blend/AnimationPlayer.play_backwards("Start")
	Music._swap_track("res://Assets/Sound/Music/Wav/Lentikula - 02 The Dancing Dead.wav")
	await get_tree().create_timer(1).timeout
	get_tree().change_scene_to_file("res://Levels/Level_1.tscn")

func _on_sand_pressed() -> void:
	$Blend/AnimationPlayer.play_backwards("Start")
	Music._swap_track("res://Assets/Sound/Music/Wav/Lentikula - 01 Flame of Death.wav")
	await get_tree().create_timer(1).timeout
	get_tree().change_scene_to_file("res://Levels/sandbox.tscn")

func _on_exit_pressed() -> void:
	get_tree().quit()
