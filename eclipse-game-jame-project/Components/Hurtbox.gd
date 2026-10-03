class_name Hurtbox extends Area2D

@export var knockback_resisitance: float = 1

func _ready() -> void:
	#Sets the Area to only be monitorable
	monitoring = false

func _recieve_hit(_damage: float, _knockback: float, _direction: Vector2):
	# Check if the damage is not zero and if the owner isnt dead
	if _damage > 0 and owner.health > 0:
		owner.health -= _damage
		
		# Knockback
		owner.velocity = _direction * _knockback * 32 / knockback_resisitance
