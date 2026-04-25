extends Node

var owned_units: Array[PackedScene] = [
	preload("res://Scenes/Units/goblin.tscn"),
	preload("res://Scenes/Units/golem.tscn"),
	preload("res://Scenes/Units/petamer.tscn"),
	preload("res://Scenes/Units/soulbound.tscn"),
	preload("res://Scenes/Units/orbath.tscn"),
]
var dungeon_team: Array[Entity]
var dungeon_loot: Array[Entity]
var backpack_contents: Array[PackedScene] = [
	preload("res://Scenes/Weapons/burst_staff.tscn"),
	preload("res://Scenes/Weapons/clobber_club.tscn"),
]
