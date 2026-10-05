class_name BasicUnit extends CharacterBody2D

@export_category("Identifier")
@export var faction: Global.Faction
@export var unit_id: String

@export_category("Movement")
@export var speed: float
@export var acceleration: float

@export_category("Combat")
@export var max_health: float
@export var damage: float
@export var cooldown_min: float
@export var cooldown_max: float
@export var knockback_force: float
@export var penetration: int = 1

@export_category("Sprite")
@export var Sprite: Sprite2D
@export var shadow_offset: int = 0
@export var Shadow: Sprite2D
@export var SearchTimer: Timer

@export_category("Node References")
@export var CooldownTimer: Timer
@export var RangeCast: RayCast2D

@export_category("Hit/Hurt Components")
@export var HitboxSpawn: Node2D
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
var Mouse_Follower: Node2D
var dead: bool = false


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
			Sprite.get_child(0).modulate = "00a4ff"
		Global.Faction.RED:
			set_collision_layer_value(4, true)
			Hurt.set_collision_layer_value(5, true)
			
			RangeCast.set_collision_mask_value(3, true)
			RangeCast.set_collision_mask_value(7, true)
			Sprite.get_child(0).modulate = "ff0000"
		Global.Faction.YELLOW:
			set_collision_layer_value(6, true)			
			Hurt.set_collision_layer_value(7, true)
			
			RangeCast.set_collision_mask_value(3, true)
			RangeCast.set_collision_mask_value(5, true)
			Sprite.get_child(0).modulate = "ffff00"
	
	Mouse_Follower = get_parent().get_parent().find_child("Mouse Follower")
	
	# Sets initial values
	health = max_health
	current_state = State.CHASE
	
	SearchTimer.start(5)
	
	Sprite.flip_h = sign(global_position.x) > 0
	Sprite.get_child(0).flip_h = Sprite.flip_h
	if Sprite.flip_h:
		Shadow.position.x = shadow_offset
	else:
		Shadow.position.x = -shadow_offset
	
	Mouse_Follower._change_unit_count(faction, 1)


@warning_ignore("unused_parameter")
func _process(delta: float) -> void:
	# Sets values changed by effects
	# Manages Particles
	
	
	pass

@warning_ignore("unused_parameter")
func _physics_process(delta: float) -> void:
	# Manages movement and direction
	# State management
	match faction:
		Global.Faction.BLUE:
			if Mouse_Follower.red_count <= 0:
				current_state = State.CELEBRATE
			else:
				current_state = State.CHASE
		Global.Faction.RED:
			if Mouse_Follower.blue_count <= 0:
				current_state = State.CELEBRATE
			else:
				current_state = State.CHASE
	
	# Self Validation check
	if health <= 0:
		if !dead:
			_death()
		return
	
	# Target Validation check
	if target and target.dead:
		_find_target()
	
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
		tween.tween_property(Sprite, "scale", Vector2(1 + 0.05*damage/2,1 + 0.05*damage/2), 0.03)
		tween.tween_property(Sprite, "scale", Vector2(0.9,0.9), 0.02)
		tween.tween_property(Sprite, "scale", Vector2(1,1), 0.03)
		CooldownTimer.start(randf_range(cooldown_min,cooldown_max))

func _attack() -> void:
	var hitbox = Hitbox.new(damage, knockback_force, HitboxShape, faction, penetration)
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
			State.FLEE:
				if target:
					return -(target.global_position - global_position).normalized()
				else:
					_find_target()
			State.CELEBRATE:
				_find_target()
				return Vector2.ZERO
	return direction

func _find_target() -> void:
	# Searches for nearest Unit of a different faction
	var loc: Vector2 = Vector2(1000,1000)
	var glob_pos: Vector2 = global_position
	target = null
	
	for child in get_parent().get_children():
		if child.faction != faction and !child.dead:
			var child_glob_pos: Vector2 = child.global_position
			if (child_glob_pos - glob_pos).length() < loc.length():
				loc = child_glob_pos - glob_pos
				target = child
	if !target:
		target = self

# Animating the little guy moving back and forth
func _animate_wobble(delta: float) -> void:
	# Check if the character is actively moving on the ground
	var vel: float
	if current_state != State.CELEBRATE:
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
		Sprite.get_child(0).flip_h = Sprite.flip_h
		Shadow.position.x = shadow_offset
	elif direction.x > 0 and Sprite.flip_h:
		Sprite.flip_h = false
		Sprite.get_child(0).flip_h = Sprite.flip_h
		Shadow.position.x = -shadow_offset
	
	if current_state == State.CELEBRATE:
		Sprite.scale = Vector2(1.2 - abs(angle_sin) * 0.2, 1 + abs(angle_sin) * 0.15)

func _animation_finished(anim_name: StringName) -> void:
	if anim_name == "Attack":
		pass

func _death():
	dead = true
	Mouse_Follower._change_unit_count(faction,-1)
	get_child(0).disabled = true
	Hurt.get_child(1).disabled = true
	$"Death Particles/GPUParticles2D".emitting = true
	$"Death Particles/DeathSFX".pitch_scale = randf_range(0.7,1.3)
	$"Death Particles/DeathSFX".play()
	Sprite.visible = false
	Shadow.visible = false
	velocity = Vector2.ZERO
	await get_tree().create_timer(1.5).timeout
	var tween = get_tree().create_tween()
	tween.tween_property($"Death Particles", "modulate:a", 0, 0.5)
	await get_tree().create_timer(0.5).timeout
	queue_free()

func _on_search_timer_timeout() -> void:
	_find_target()
	SearchTimer.start(5)
