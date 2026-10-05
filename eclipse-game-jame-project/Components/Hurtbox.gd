class_name Hurtbox extends Area2D

@export var knockback_resisitance: float = 1
@export var SFX: AudioStreamPlayer

func _ready() -> void:
	#Sets the Area to only be monitorable
	monitoring = false

func _recieve_hit(_damage: float, _knockback: float, _direction: Vector2):
	# Check if the damage is not zero and if the owner isnt dead
	if _damage > 0 and owner.health > 0:
		owner.health -= _damage
		
		SFX.pitch_scale = randf_range(0.7,1.3)
		SFX.play()
		
		# Knockback
		owner.velocity = _direction * _knockback * 32 / knockback_resisitance
		
		owner.Sprite.frame = 1
		await get_tree().create_timer(0.1).timeout
		owner.Sprite.frame = 0
