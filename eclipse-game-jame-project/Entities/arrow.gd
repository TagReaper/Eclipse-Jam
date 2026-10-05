class_name Arrow extends CharacterBody2D

var faction: Global.Faction
var dmg
var knockback
var penetration
@export var hit: Hitbox2

func _ready() -> void:
	hit._timer()

func _set_initial(_pos: Vector2, _rot: float, _dir: Vector2, _speed: float, _faction: Global.Faction, _dmg:float, knock:float, pen:int) -> void:
	global_position = _pos
	global_rotation = _rot
	velocity = _dir * _speed
	faction = _faction
	dmg = _dmg
	knockback = knock
	penetration = pen
	_set_child()

func _set_child() -> void:
	hit.faction = faction
	hit.damage = dmg
	hit.knockback = knockback
	hit.penetration = penetration

@warning_ignore("unused_parameter")
func _physics_process(delta: float) -> void:
	if Input.is_action_just_pressed("End"):
		queue_free()
	global_rotation = atan2(velocity.y,velocity.x)
	if !Global.paused:
		if hit.DurTimer.paused:
			hit.DurTimer.paused = false
		move_and_slide()
	else:
		if !hit.DurTimer.paused:
			hit.DurTimer.paused = true
