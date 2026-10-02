class_name BasicUnit extends CharacterBody2D

@export_category("Identifier")
@export var faction: Global.Faction

@export_category("Movement")
@export var speed: float
@export var acceleration: float
@export var wobble_speed: float = 15.0
@export var wobble_angle: float = 12.0

@export_category("Combat")
@export var max_health: float
@export var damage: float
@export var cooldown_min: float
@export var cooldown_max: float

@export_category("Node References")
@export var Sprite: Sprite2D
@export var Animator: AnimationPlayer
@export var HitboxSpawn: Node2D
@export var CooldownTimer: Timer
@export var RangeCast: RayCast2D

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
const MOVEMENT_MULTIPLIER: int = 32
enum State{
	CHASE,
	ATTACK,
	FLEE,
	FREEZE,
	CELEBRATE
}

func _init() -> void:
	# Sets initial non-node values
	pass

func _ready() -> void:
	# Sets initial node values
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
	
	# End of function
	tick += 1
	_animate_wobble(delta)
	move_and_slide()

func _within_range() -> void:
	# Code for what happens when the Unit get's within range
	pass

func get_direction() -> Vector2:
	# Uses target location to get direction
	if tick % faction:
		if target != null:
			return (target.global_position - global_position).normalized()
	return Vector2.ZERO # If the target is null

func _find_target() -> void:
	# Searches for nearest Unit of a different faction
	pass

# Animating the little guy moving back and forth
func _animate_wobble(delta: float) -> void:
	# Check if the character is actively moving on the ground
	if current_state == State.CHASE:
		# Advance time scaled by speed
		wobble_time += delta * wobble_speed
		
		# Generate a smooth wave between -1 and 1
		var angle_sin = sin(wobble_time) 
		
		# Apply rotation in radians (converting from our degree export)
		Sprite.rotation = angle_sin * deg_to_rad(wobble_angle)
	else:
		# Reset smoothly back to standing straight when stopped
		wobble_time = 0.0
		Sprite.rotation = move_toward(Sprite.rotation, 0.0, delta * 5.0)

func _animation_finished(anim_name: StringName) -> void:
	if anim_name == "Attack":
		pass
