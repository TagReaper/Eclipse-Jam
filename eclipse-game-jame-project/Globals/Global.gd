extends Node

var paused: bool = true

enum Faction{
	BLUE,
	RED,
	YELLOW
}

enum Effect{
	POISONED,
	SLOWED,
	FROZEN,
	HASTE,
	REGENERATION,
	COWARDLY
}


var Units: Dictionary = {
	"BS1": {
		"ID": "BS1",
		"Name": "Basic Unarmed Skeleton",
		"Shorthand": "BUS",
		"Path": "res://Entities/Units/Basic Skeletons/Basic_Unarmed_Skeleton.tscn",
		"Cost": ["Bones", 10]
	},
	"BS2": {
		"ID": "BS2",
		"Name": "Basic Dagger Skeleton",
		"Shorthand": "BDS",
		"Path": "res://Entities/Units/Basic Skeletons/Basic_Dagger_Skeleton.tscn",
		"Cost": ["Bones", 20]
	},
	"BS3": {
		"ID": "BS3",
		"Name": "Basic Spear Skeleton",
		"Shorthand": "BSpS",
		"Path":"res://Entities/Units/Basic Skeletons/Basic_Spear_Skeleton.tscn" ,
		"Cost": ["Bones", 25]
	},
	"BS4": {
		"ID": "BS4",
		"Name": "Basic Bow Skeleton",
		"Shorthand": "BBS",
		"Path": "res://Entities/Units/basic_unit_test.tscn",
		"Cost": ["Bones", 40]
	},
	"BS5": {
		"ID": "BS5",
		"Name": "Basic Sword Skeleton",
		"Shorthand": "BSwS",
		"Path": "res://Entities/Units/Basic Skeletons/Basic_Sword_Skeleton.tscn",
		"Cost": ["Bones", 75]
	},
	"BS6": {
		"ID": "BS6",
		"Name": "Basic Halberd Skeleton",
		"Shorthand": "BHS",
		"Path": "res://Entities/Units/Basic Skeletons/Basic_Halberd_Skeleton.tscn",
		"Cost": ["Bones", 105]
	}
}
