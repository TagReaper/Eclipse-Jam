extends Control




func _select_level(_str: String):
	$Blend/AnimationPlayer.play_backwards("Start")
	await get_tree().create_timer(1).timeout
	get_tree().change_scene_to_file(_str)
