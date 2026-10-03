class_name Hitbox extends Area2D

# Internal Variables
var damage: float
var knockback: float
var shape: Shape2D
var hostile: bool
var faction: Global.Faction

# Assignments for the initial hitbox spawning
func _init(_damage:float, _knockback: float, _shape:Shape2D, _faction: Global.Faction) -> void:
	damage = _damage
	knockback = _knockback
	shape = _shape
	faction = _faction

func _ready() -> void:
	# Sets to monitering only
	monitorable = false
	area_entered.connect(_on_area_entered)
	
	var new_timer = Timer.new()
	add_child(new_timer)
	new_timer.timeout.connect(queue_free)
	new_timer.call_deferred("start", 0.1)
	
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
	if !area.has_method("_recieve_hit"):
		return
	area._recieve_hit(damage, knockback, (area.global_position - get_parent().get_parent().global_position).normalized())
	queue_free()
