extends Node

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
	"Basic Skeleton": {
		"Shorthand": "BS",
		"Path": "res://Entities/Units/basic_unit_test.tscn",
		
	}
}
