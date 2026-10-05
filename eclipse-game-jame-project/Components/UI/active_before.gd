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
	var tween = create_tween()
	match _resource:
		"Bones":
			BonesLabel.text = str(_qty)
			tween.tween_property(Bones, "scale", Vector2(1.1,1.1), 0.05)
			tween.tween_property(Bones, "scale", Vector2(1,1), 0.05)
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

func _on_unarmed_skeleton_pressed() -> void:
	get_parent().get_parent().get_parent()._set_unit("BS1")

func _on_dagger_skeleton_pressed() -> void:
	get_parent().get_parent().get_parent()._set_unit("BS2")

func _on_spear_skeleton_pressed() -> void:
	get_parent().get_parent().get_parent()._set_unit("BS3")

func _on_bow_skeleton_pressed() -> void:
	get_parent().get_parent().get_parent()._set_unit("BS4")

func _on_sword_skeleton_pressed() -> void:
	get_parent().get_parent().get_parent()._set_unit("BS5")

func _on_halberd_skeleton_pressed() -> void:
	get_parent().get_parent().get_parent()._set_unit("BS6")
