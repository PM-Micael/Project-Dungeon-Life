extends RefCounted

const KEY: Dictionary = {
	DISPLAY_NAME = "display_name",
	SIGNATURE_WEAPON = "signature_weapon"
}

const DUNGEON: Dictionary = {
	THE_DUNGEON = "The Dungeon"
}

const ZONE: Dictionary = {
	PUTRID_ZONE = "putrid_zone",
	SCORCHED_ZONE = "scorched_zone"
}

const UNIT: Dictionary = {
	PLAYER = {
		"paramander": {
			KEY.DISPLAY_NAME: "Paramander",
			KEY.SIGNATURE_WEAPON: "heat_seeker"
		},
		"scratch": {
			KEY.DISPLAY_NAME: "Scratch",
			KEY.SIGNATURE_WEAPON: "splinter"
		},
		"walking_hive": {
			KEY.DISPLAY_NAME: "Walking Hive",
			KEY.SIGNATURE_WEAPON: "cursed_lantern"
		},
		"devourer_of_ghouls": {
			KEY.DISPLAY_NAME: "Devourer Of Gouls",
			KEY.SIGNATURE_WEAPON: "rumble_gloves"
		},
		"magnus": {
			KEY.DISPLAY_NAME: "Magnus",
			KEY.SIGNATURE_WEAPON: "crag_chunk" 
		},
	},
}

const ITEM: Dictionary = {
	WEAPON = {
		"crag_chunk": {
			"scene": "res://Scenes/Weapons/crag_chunk/crag_chunk.tscn"
		},
		"rumble_gloves": {
			"scene": "res://Scenes/Weapons/rumble_gloves/rumble_gloves.tscn"
		},
		"splinter": {
			"scene": "res://Scenes/Weapons/splinter/splinter.tscn"
		},
		"cursed_lantern": {
			"scene": "res://Scenes/Weapons/cursed_lantern/cursed_lantern.tscn"
		},
		"heat_seeker": {
			"scene": "res://Scenes/Weapons/heat_seeker/heat_seeker.tscn"
		},
	},
}
