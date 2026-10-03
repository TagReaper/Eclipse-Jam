extends Node2D

@export var ZoneArea: Area2D
@export var CollArea: Area2D
@export var Cooldown: Timer
@export var multiple_factions: bool = false
@export var RedArea: Area2D

var selected_unit: PackedScene
var summon_num: int = 0
var selected_faction: Global.Faction
var unit: Dictionary = Global.Units.get("Basic Skeleton")

func _process(delta: float) -> void:
	global_position = get_global_mouse_position()
	
	if Input.is_action_just_pressed("Pause"):
		if Global.paused:
			Global.paused = false
		else:
			Global.paused = true
	
	if Input.is_action_pressed("Summon") and Cooldown.is_stopped() and Global.paused:
		if !multiple_factions:
			if !CollArea.has_overlapping_areas() and !ZoneArea.has_overlapping_areas():
				selected_unit = load(unit.get("Path"))
				var summon = selected_unit.instantiate()
				summon.faction = Global.Faction.BLUE
				summon.global_position = global_position
				summon.name = "BLUE-" + unit.get("Shorthand") + "-" + str(summon_num)
				get_parent().find_child("Units").add_child(summon)
				summon_num += 1
				Cooldown.start(0.05)
		else:
			if !ZoneArea.has_overlapping_areas():
				selected_faction = Global.Faction.BLUE
			elif ZoneArea.overlaps_area(RedArea):
				selected_faction = Global.Faction.RED
			if !CollArea.has_overlapping_areas():
				selected_unit = load(unit.get("Path"))
				var summon = selected_unit.instantiate()
				summon.faction = selected_faction
				summon.global_position = global_position
				summon.name = Global.Faction.find_key(selected_faction) + "-" + unit.get("Shorthand") + "-" + str(summon_num)
				get_parent().find_child("Units").add_child(summon)
				summon_num += 1
				Cooldown.start(0.05)
