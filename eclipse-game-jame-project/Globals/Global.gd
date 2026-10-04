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
		"Name": "Basic Unarmed Skeleton",
		"Shorthand": "BS",
		"Path": "res://Entities/Units/basic_unit_test.tscn",
		"Cost": ["Bones", 1]
	}
}
