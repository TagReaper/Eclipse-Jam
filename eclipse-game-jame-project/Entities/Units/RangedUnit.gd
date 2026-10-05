extends BasicUnit

@export var flight_speed: float = 25
@export var projectile_scene: PackedScene
@export var BowSFX: AudioStreamPlayer

func _attack() -> void:
	var projectile_instance = load("res://Entities/Arrow.tscn").instantiate()
	if direction != Vector2.ZERO:
		projectile_instance._set_initial(HitboxSpawn.global_position, HitboxSpawn.global_rotation, direction, flight_speed, faction, damage, knockback_force, penetration)
		get_parent().get_parent().add_child(projectile_instance)
		BowSFX.pitch_scale = randf_range(0.7,1.3)
		BowSFX.play()
