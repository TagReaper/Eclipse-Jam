extends Control

@export var Bones: HBoxContainer
@export var BonesLabel: Label

@export var Flesh: HBoxContainer
@export var FleshLabel: Label

@export var MossyBones: HBoxContainer
@export var MossyBonesLabel: Label

@export var GildedBones: HBoxContainer
@export var GildedBonesLabel: Label

@export var MythrilScrap: HBoxContainer
@export var MythrilScrapLabel: Label

@export var TantalumScrap: HBoxContainer
@export var TantalumScrapLabel: Label

func _update_resources(_resource:String,_qty:int) -> void:
	match _resource:
		"Bones":
			BonesLabel.text = str(_qty)
		"Flesh":
			FleshLabel.text = str(_qty)
		"Mossy Bones":
			MossyBonesLabel.text = str(_qty)
		"Gilded Bones":
			GildedBonesLabel.text = str(_qty)
		"Mythril Scrap":
			MythrilScrapLabel.text = str(_qty)
		"Tantalum Scrap":
			TantalumScrapLabel.text = str(_qty)

func _disable() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	visible = false

func _enable() -> void:
	mouse_filter = Control.MOUSE_FILTER_STOP
	visible = true
