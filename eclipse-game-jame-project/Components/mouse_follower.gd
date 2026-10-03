extends Node2D

@export var ZoneArea: Area2D
@export var CollArea: Area2D
@export var Cooldown: Timer
@export var sandbox: bool = false
@export var RedArea: Area2D

var selected_unit: PackedScene
var summon_num: int = 0
var selected_faction: Global.Faction
var unit: String = "Basic Skeleton"
var level_started: bool = false

@export var resources: Dictionary[String, int] = {
	"Bones": 5,
	"Flesh": 0,
	"Mossy Bones": 0,
	"Gilded Bones": 0,
	"Mythril Scrap": 0,
	"Tantalum Scrap": 0
}

func _ready() -> void:
	# Input.mouse_mode = Input.MOUSE_MODE_CONFINED_HIDDEN
	level_started = false
	Global.paused = true
	print(resources)

func _process(delta: float) -> void:
	global_position = get_global_mouse_position()
	
	if Input.is_action_just_pressed("Pause"):
		if Global.paused:
			Global.paused = false
			level_started = true
		else:
			Global.paused = true
	
	if Input.is_action_just_pressed("End"):
		get_tree().reload_current_scene()
	
	if Input.is_action_pressed("SpeedUp"):
		Engine.time_scale = 2.5
	else:
		Engine.time_scale = 1.0
	
	if Input.is_action_pressed("Summon") and Cooldown.is_stopped() and Global.paused and !level_started:
		if !sandbox:
			if !CollArea.has_overlapping_areas() and !ZoneArea.has_overlapping_areas():
				var Unit: Dictionary = Global.Units.get(unit)
				var cost: Array = Unit.Cost
				if resources[cost[0]] < cost[1]:
					print("Not Enough Resources to summon ", unit)
				else:
					print("\nSummoning ", Global.Faction.find_key(selected_faction), " ", unit, ": ", cost[1], " ", cost[0], " used...")
					resources[cost[0]] -= cost[1]
					print("You now have ", resources[cost[0]], " ", cost[0], " remaining.")
					selected_unit = load(Unit.Path)
					var summon = selected_unit.instantiate()
					summon.faction = Global.Faction.BLUE
					summon.global_position = global_position + Vector2(0,-8)
					summon.name = "BLUE-" + Unit.Shorthand + "-" + str(summon_num)
					get_parent().find_child("Units").add_child(summon)
					summon_num += 1
					Cooldown.start(0.05)
		else:
			if !ZoneArea.has_overlapping_areas():
				selected_faction = Global.Faction.BLUE
			elif ZoneArea.overlaps_area(RedArea):
				selected_faction = Global.Faction.RED
			if !CollArea.has_overlapping_areas():
				var Unit: Dictionary = Global.Units.get(unit)
				print("\nSummoning ", Global.Faction.find_key(selected_faction), " ", unit, ": No resources used...")
				print("Sandbox mode is enabled.")
				selected_unit = load(Unit.Path)
				var summon = selected_unit.instantiate()
				summon.faction = selected_faction
				summon.global_position = global_position + Vector2(0,-8)
				summon.name = Global.Faction.find_key(selected_faction) + "-" + Unit.Shorthand + "-" + str(summon_num)
				get_parent().find_child("Units").add_child(summon)
				summon_num += 1
				Cooldown.start(0.05)
