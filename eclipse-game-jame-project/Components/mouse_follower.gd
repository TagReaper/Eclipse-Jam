extends Node2D

@export var ZoneArea: Area2D
@export var CollArea: Area2D
@export var Cooldown: Timer
@export var sandbox: bool = false
@export var RedArea: Area2D
@export var UIArea: Area2D

@export_category("UI Controllers")
@export var ActAlways: Control
@export var ActBefore: Control
@export var EndState: Control


var blue_count: int = 0
var red_count: int = 0

var selected_unit: PackedScene
var summon_num: int = 0
var selected_faction: Global.Faction
var level_started: bool = false
var Unit_State: PackedScene = null
var Unit: Dictionary
var level_over: bool = false
var exitVal: int = 0
var music: Array[String] = ["res://Assets/Sound/Music/Wav/Lentikula - 02 The Dancing Dead.wav", 
"res://Assets/Sound/Music/Wav/Lentikula - 03 Pharaoh's Curse.wav", 
"res://Assets/Sound/Music/Wav/Lentikula - 04 Red Dungeon.wav",
"res://Assets/Sound/Music/Wav/Lentikula - 05 The Forgotten Library.wav",
"res://Assets/Sound/Music/Wav/Lentikula - 06 Madness.wav",
"res://Assets/Sound/Music/Wav/Lentikula - 07 Blood Moon.wav"]
@export_category("Level Specific")
@export var Unlocked_Units: Array = [0,0,0,0,0,0]
@export var Next_Level: String


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
	$"CanvasLayer/UI Controller/Blend".visible = true
	_set_unit("BS1")
	level_started = false
	Global.paused = true
	ActAlways._update_pause(Global.paused)
	
	if sandbox:
		Music._swap_track("res://Assets/Sound/Music/Wav/Lentikula - 01 Flame of Death.wav")
	
	if resources.get("Bones") > 0:
			ActBefore.Bones.visible = true
			ActBefore.BonesLabel.text = str(resources.get("Bones"))
	else:
			ActBefore.Bones.visible = false
	
	if resources.get("Flesh") > 0:
			ActBefore.Flesh.visible = true
			ActBefore.FleshLabel.text = str(resources.get("Flesh"))
	else:
			ActBefore.Flesh.visible = false
	
	if resources.get("Mossy Bones") > 0:
			ActBefore.MossyBones.visible = true
			ActBefore.MossyBonesLabel.text = str(resources.get("Mossy Bones"))
	else:
			ActBefore.MossyBones.visible = false
	
	if resources.get("Gilded Bones") > 0:
			ActBefore.GildedBones.visible = true
			ActBefore.GildedBonesLabel.text = str(resources.get("Gilded Bones"))
	else:
			ActBefore.GildedBones.visible = false
	
	if resources.get("Mythril Scrap") > 0:
			ActBefore.MythrilScrap.visible = true
			ActBefore.MythrilScrapLabel.text = str(resources.get("Mythril Scrap"))
	else:
			ActBefore.MythrilScrap.visible = false
	
	if resources.get("Tantalum Scrap") > 0:
			ActBefore.TantalumScrap.visible = true
			ActBefore.TantalumScrapLabel.text = str(resources.get("Tantalum Scrap"))
	else:
			ActBefore.TantalumScrap.visible = false
	
	for i in 6:
		if Unlocked_Units[i] > 0:
			for j in Unlocked_Units[i]:
				ActBefore.get_child(0).get_child(i).get_child(0).get_child(j).disabled = false
		else:
			var pat: String = "tab_"+str(i)+"/disabled"
			ActBefore.get_child(0).set(pat, true)

@warning_ignore("unused_parameter")
func _process(delta: float) -> void:
	if !is_node_ready():
		return
	global_position = get_global_mouse_position()
	
	if Input.is_action_just_pressed("Pause"):
		if Global.paused:
			Global.paused = false
			$PlaySFX.play()
		else:
			$PauseSFX.play()
			Global.paused = true
		if !level_started:
			ActBefore._disable()
			level_started = true
			_save_node_state()
			get_parent().find_child("Boundary").visible = false
		ActAlways._update_pause(Global.paused)
	
	if !level_over and level_started:
		if blue_count <= 0 and red_count > 0:
			level_over = true
			$LossSFX.play()
		elif blue_count > 0 and red_count <= 0:
			level_over = true
			if !sandbox:
				EndState.visible = true
			$WinSFX.play()
	
	if Input.is_action_pressed("ui_cancel"):
		if exitVal >= 1000:
			$"CanvasLayer/UI Controller/Blend/AnimationPlayer".play_backwards("Start")
			Music._swap_track("res://Assets/Sound/Music/Wav/Lentikula - 08 The Final Descent.wav")
			await get_tree().create_timer(1).timeout
			get_tree().change_scene_to_file("res://Levels/main_menu.tscn")
		exitVal += 4
	else:
		exitVal = 0
	
	$"CanvasLayer/UI Controller/PauseMenu".modulate = Color(1.0, 1.0, 1.0, float(exitVal/1000.0))
	
	if Input.is_action_just_pressed("End"):
		if !sandbox and blue_count > 0 and red_count <= 0 and Next_Level != "":
			$"CanvasLayer/UI Controller/Blend/AnimationPlayer".play_backwards("Start")
			Music._swap_track(music[randi_range(0,5)])
			await get_tree().create_timer(1).timeout
			get_tree().change_scene_to_file(Next_Level)
		blue_count = 0
		red_count = 0
		if level_started:
			ActBefore._enable()
			level_started = false
			level_over = false
			Global.paused = true
			get_parent().find_child("Boundary").visible = true
			ActAlways._update_pause(Global.paused)
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
					ActBefore._update_resources(cost[0],resources[cost[0]])
					$PlacmentSFX.pitch_scale = randf_range(0.5,0.8)
					$PlacmentSFX.play()
					var summon = selected_unit.instantiate()
					summon.faction = Global.Faction.BLUE
					summon.global_position = g_pos + Vector2(0,-8)
					summon.name = "BLUE-" + Unit.Shorthand + "-" + str(summon_num)
					summon.unit_id = Unit.ID
					get_parent().find_child("Units", false, false).add_child(summon)
					summon_num += 1
					Cooldown.start(0.05)
		else:
			if blue_count + red_count < 1000:
				var g_pos: Vector2 = global_position
				if !ZoneArea.has_overlapping_areas():
					selected_faction = Global.Faction.BLUE
					if g_pos.x > get_parent().find_child("Boundary").position.x:
						g_pos.x = get_parent().find_child("Boundary").position.x - 8
				elif ZoneArea.overlaps_area(UIArea):
					return
				elif ZoneArea.overlaps_area(RedArea):
					selected_faction = Global.Faction.RED
					if g_pos.x < get_parent().find_child("Boundary").position.x:
						g_pos.x = get_parent().find_child("Boundary").position.x + 8
				if !CollArea.has_overlapping_areas():
					$PlacmentSFX.pitch_scale = randf_range(0.7,1.3)
					$PlacmentSFX.play()
					var summon = selected_unit.instantiate()
					summon.faction = selected_faction
					summon.global_position = g_pos + Vector2(0,-8)
					summon.name = Global.Faction.find_key(selected_faction) + "-" + Unit.Shorthand + "-" + str(summon_num)
					summon.unit_id = Unit.ID
					get_parent().find_child("Units", false, false).add_child(summon)
					summon_num += 1
					Cooldown.start(0.02)
	
	if Input.is_action_pressed("RemoveSummon") and CollArea.has_overlapping_areas() and Global.paused and !level_started:
		if !sandbox:
			if !ZoneArea.has_overlapping_areas():
				var colls = CollArea.get_overlapping_areas()
				
				for unit in colls:
					var cost: Array = Global.Units.get(unit.get_parent().unit_id).Cost
					resources[cost[0]] += cost[1]
					ActBefore._update_resources(cost[0],resources[cost[0]])
					unit.get_parent()._death()
		else:
			var colls = CollArea.get_overlapping_areas()
			
			for unit in colls:
				unit.get_parent()._death()

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
	ActAlways._update_count(blue_count, red_count)
