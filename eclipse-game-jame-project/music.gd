extends AudioStreamPlayer

func _swap_track(_path: String):
	var tween = get_tree().create_tween()
	tween.tween_property(self, "volume_db", -30, 1)
	await get_tree().create_timer(1).timeout
	stream = load(_path)
	play(0)
	tween.stop()
	var tween2 = get_tree().create_tween()
	tween2.tween_property(self, "volume_db", 0, 1)
