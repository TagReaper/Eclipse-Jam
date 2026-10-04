extends Node2D

@export var ZoneArea: Area2D
@export var CollArea: Area2D
@export var Cooldown: Timer
@export var sandbox: bool = false
@export var RedArea: Area2D
var blue_count: int = 0
var red_count: int = 0

var selected_unit: PackedScene
var summon_num: int = 0
var selected_faction: Global.Faction
var level_started: bool = false
var Unit_State: PackedScene = null
var Unit: Dictionary


@export var resources: Dictionary[String, int] = {
	"Bones": 5,
	"Flesh": 0,
	"Mossy Bones": 0,
	"Gilded Bones": 0,
	"Mythril Scrap": 0,
	"Tantalum Scrap": 0
}

var resourse_cpy: Dictionary[String, int]

func _ready() -> void:
	# Input.mouse_mode = Input.MOUSE_MODE_CONFINED_HIDDEN
	_set_unit("BS1")
	level_started = false
	Global.paused = true
	for unit in get_parent().find_child("Units", false, false).get_children():
		_change_unit_count(unit.faction, 1)

@warning_ignore("unused_parameter")
func _process(delta: float) -> void:
	global_position = get_global_mouse_position()
	
	if Input.is_action_just_pressed("Pause"):
		if Global.paused:
			Global.paused = false
		else:
			Global.paused = true
		if !level_started:
			level_started = true
			_save_node_state()
			get_parent().find_child("Boundary").visible = false
	
	if Input.is_action_just_pressed("End"):
		if level_started:
			level_started = false
			Global.paused = true
			get_parent().find_child("Boundary").visible = true
			_load_node_state()
		else:
			get_tree().reload_current_scene()
	
	if Input.is_action_pressed("SpeedUp"):
		Engine.time_scale = 2.5
	else:
		Engine.time_scale = 1.0
	
	if Input.is_action_pressed("Summon") and Cooldown.is_stopped() and Global.paused and !level_started:
		if !sandbox:
			if !CollArea.has_overlapping_areas() and !ZoneArea.has_overlapping_areas():
				var cost: Array = Unit.Cost
				if resources[cost[0]] < cost[1]:
					pass
				else:
					var g_pos: Vector2 = global_position
					if g_pos.x > get_parent().find_child("Boundary").position.x:
						g_pos.x = get_parent().find_child("Boundary").position.x - 8
					resources[cost[0]] -= cost[1]
					var summon = selected_unit.instantiate()
					summon.faction = Global.Faction.BLUE
					summon.global_position = g_pos + Vector2(0,-8)
					summon.name = "BLUE-" + Unit.Shorthand + "-" + str(summon_num)
					summon.unit_id = Unit.ID
					get_parent().find_child("Units", false, false).add_child(summon)
					_change_unit_count(Global.Faction.BLUE, 1)
					summon_num += 1
					Cooldown.start(0.05)
		else:
			var g_pos: Vector2 = global_position
			if !ZoneArea.has_overlapping_areas():
				selected_faction = Global.Faction.BLUE
				if g_pos.x > get_parent().find_child("Boundary").position.x:
					g_pos.x = get_parent().find_child("Boundary").position.x - 8
			elif ZoneArea.overlaps_area(RedArea):
				selected_faction = Global.Faction.RED
				if g_pos.x < get_parent().find_child("Boundary").position.x:
					g_pos.x = get_parent().find_child("Boundary").position.x + 8
			if !CollArea.has_overlapping_areas():
				selected_unit = load(Unit.Path)
				var summon = selected_unit.instantiate()
				summon.faction = selected_faction
				summon.global_position = g_pos + Vector2(0,-8)
				summon.name = Global.Faction.find_key(selected_faction) + "-" + Unit.Shorthand + "-" + str(summon_num)
				summon.unit_id = Unit.ID
				get_parent().find_child("Units", false, false).add_child(summon)
				_change_unit_count(summon.faction, 1)
				summon_num += 1
				Cooldown.start(0.05)
	
	if Input.is_action_pressed("RemoveSummon") and CollArea.has_overlapping_areas() and Global.paused and !level_started:
		if !sandbox:
			if !ZoneArea.has_overlapping_areas():
				var colls = CollArea.get_overlapping_areas()
				
				for unit in colls:
					var cost: Array = Global.Units.get(unit.get_parent().unit_id).Cost
					resources[cost[0]] += cost[1]
					_change_unit_count(Global.Faction.BLUE, -1)
					unit.get_parent().queue_free()
		else:
			var colls = CollArea.get_overlapping_areas()
			
			for unit in colls:
				_change_unit_count(unit.get_parent().faction, -1)
				unit.get_parent().queue_free()

func _set_unit(_name: String) -> void:
	Unit = Global.Units.get(_name)
	selected_unit = load(Unit.Path)

func _save_node_state() -> void:
	resourse_cpy = resources
	var temp_root = Node2D.new()
	
	for child in get_parent().find_child("Units", false, false).get_children():
		var duplicate_child = child.duplicate()
		temp_root.add_child(duplicate_child)
		# Set the owner so PackedScene knows to save it
		duplicate_child.owner = temp_root 
	
	# Pack the temporary structure into memory
	Unit_State = PackedScene.new()
	Unit_State.pack(temp_root)
	
	# Free the temporary root from memory (it's safely inside backup_scene now)
	temp_root.free()

func _load_node_state() -> void:
	resources = resourse_cpy
	get_parent().find_child("Units", false, false).free()
	var restored = Unit_State.instantiate()
	restored.name = "Units"
	restored.y_sort_enabled = true
	get_parent().add_child(restored)

func _change_unit_count(_faction: Global.Faction,_qty: int):
	match _faction:
		Global.Faction.BLUE:
			blue_count += _qty
		Global.Faction.RED:
			red_count += _qty
	print("\nBlue Count: ", blue_count, "\nRed Count: ", red_count)
