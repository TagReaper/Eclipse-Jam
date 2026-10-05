class_name Hitbox2 extends Area2D

# Internal Variables
@export var damage: float
@export var knockback: float
@export var shape: Shape2D
@export var faction: Global.Faction
@export var penetration: int
@export var duration: float = 0.1
@export var DurTimer: Timer

func _ready() -> void:
	# Sets to monitering only
	monitorable = false
	area_entered.connect(_on_area_entered)
	
	# Setting the shape
	if shape:
		var collision_shape = CollisionShape2D.new()
		collision_shape.shape = shape
		add_child(collision_shape)
	
	# Setting Collision Layers
	set_collision_layer_value(1,false)
	set_collision_mask_value(1, false)
	
	#Sets the appropriate values based on hostility
	match faction:
		Global.Faction.BLUE:
			set_collision_mask_value(5, true)
			set_collision_mask_value(7, true)
		Global.Faction.RED:
			set_collision_mask_value(3, true)
			set_collision_mask_value(7, true)
		Global.Faction.YELLOW:
			set_collision_mask_value(3, true)
			set_collision_mask_value(5, true)

func _on_area_entered(area: Area2D):
	if penetration > 0:
		penetration -= 1
		if !area.has_method("_recieve_hit"):
			return
		area._recieve_hit(damage, knockback, (area.global_position - get_parent().get_parent().global_position).normalized())
		if penetration == 0:
			_del()

func _timer() -> void:
	DurTimer.start(duration)

func _del() -> void:
	get_parent().queue_free()

func _on_timer_timeout() -> void:
	get_parent().queue_free()
