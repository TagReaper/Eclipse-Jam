class_name BasicUnit extends CharacterBody2D

@export_category("Identifier")
@export var faction: Global.Faction

@export_category("Movement")
@export var speed: float
@export var acceleration: float

@export_category("Combat")
@export var max_health: float
@export var damage: float
@export var cooldown_min: float
@export var cooldown_max: float
@export var knockback_force: float

@export_category("Node References")
@export var Sprite: Sprite2D
@export var HitboxSpawn: Node2D
@export var CooldownTimer: Timer
@export var RangeCast: RayCast2D

@export_category("Hit/Hurt Components")
@export var Hurt: Hurtbox
@export var HitboxShape: Shape2D

# Internal Variables
var can_move: bool = true
var health: float
var current_state: int
var dmg_multiplier: float = 1
var speed_multiplier: float = 1
var effects: Array[Global.Effect]
var direction: Vector2 = Vector2.ZERO
var target: CharacterBody2D
var tick: int = 0
var wobble_time: float = 0

# Constants
# May be unecessary: const MOVEMENT_MULTIPLIER: int = 32
enum State{
	CHASE,
	ATTACK,
	FLEE,
	FREEZE,
	CELEBRATE
}

func _ready() -> void:
	# Sets Faction Specific Values
	match faction:
		Global.Faction.BLUE:
			set_collision_layer_value(2, true)
			Hurt.set_collision_layer_value(3, true)
			
			RangeCast.set_collision_mask_value(5, true)
			RangeCast.set_collision_mask_value(7, true)
			Sprite.modulate = "00a4ff"
		Global.Faction.RED:
			set_collision_layer_value(4, true)
			Hurt.set_collision_layer_value(5, true)
			
			RangeCast.set_collision_mask_value(3, true)
			RangeCast.set_collision_mask_value(7, true)
			Sprite.modulate = "ff0000"
		Global.Faction.YELLOW:
			set_collision_layer_value(6, true)			
			Hurt.set_collision_layer_value(7, true)
			
			RangeCast.set_collision_mask_value(3, true)
			RangeCast.set_collision_mask_value(5, true)
			Sprite.modulate = "ffff00"
	
	# Sets initial values
	health = max_health
	current_state = State.CHASE
	
	pass

@warning_ignore("unused_parameter")
func _process(delta: float) -> void:
	# Sets values changed by effects
	# Manages Particles
	
	
	pass

@warning_ignore("unused_parameter")
func _physics_process(delta: float) -> void:
	# Manages movement and direction
	# State management
	
	# Self Validation check
	if health <= 0:
		_death()
		return
	
	# Target Validation check
	if target and target.health <= 0:
		target = null
	
	if !Global.paused:
		# Setting Direction
		direction = get_direction()
		RangeCast.rotation = atan2(direction.y,direction.x)
		
		if RangeCast.is_colliding():
			if RangeCast.get_collider():
				if RangeCast.get_collider().get_parent() == target:
					velocity = velocity.move_toward(Vector2.ZERO, acceleration)
				else:
					target = RangeCast.get_collider().get_parent()
				_within_range()
		else:
			# Setting Velocity
			velocity = velocity.move_toward(direction * speed * speed_multiplier, acceleration)
		
		# End of function
		tick += 1
		_animate_wobble(delta)
		move_and_slide()

func _within_range() -> void:
	# Code for what happens when the Unit get's within range
	if CooldownTimer.is_stopped():
		_attack()
		var tween = create_tween()
		tween.tween_property(Sprite, "scale", Vector2(1.1,1.1), 0.03)
		tween.tween_property(Sprite, "scale", Vector2(0.9,0.9), 0.03)
		tween.tween_property(Sprite, "scale", Vector2(1,1), 0.03)
		CooldownTimer.start(randf_range(cooldown_min,cooldown_max))

func _attack() -> void:
	var hitbox = Hitbox.new(damage, knockback_force, HitboxShape, faction)
	HitboxSpawn.add_child(hitbox)

func get_direction() -> Vector2:
	# Uses target location to get direction
	if tick % (faction+1) == 0:
		match current_state:
			State.CHASE:
				if target:
					return (target.global_position - global_position).normalized()
				else:
					_find_target()
					return (target.global_position - global_position).normalized()
			State.CELEBRATE:
				pass
	return direction

func _find_target() -> void:
	# Searches for nearest Unit of a different faction
	var loc: Vector2 = Vector2(1000,1000)
	var glob_pos: Vector2 = global_position
	target = null
	
	for child in get_parent().get_children():
		if child.faction != faction:
			var child_glob_pos: Vector2 = child.global_position
			if (child_glob_pos - glob_pos).length() < loc.length():
				loc = child_glob_pos - glob_pos
				target = child
	
	if !target:
		target = self
		current_state = State.CELEBRATE

# Animating the little guy moving back and forth
func _animate_wobble(delta: float) -> void:
	# Check if the character is actively moving on the ground
	var vel: float
	if current_state == State.CHASE:
		vel = velocity.length()
	else:
		vel = 10
	# Advance time scaled by speed
	wobble_time += delta * vel
	# Generate a smooth wave between -1 and 1
	var angle_sin = sin(wobble_time) 
	# Apply rotation in radians (converting from our degree export)
	Sprite.rotation = angle_sin * deg_to_rad(vel/5)
	if direction.x < 0 and !Sprite.flip_h:
		Sprite.flip_h = true
	elif direction.x > 0 and Sprite.flip_h:
		Sprite.flip_h = false

func _animation_finished(anim_name: StringName) -> void:
	if anim_name == "Attack":
		pass

func _death():
	queue_free()
