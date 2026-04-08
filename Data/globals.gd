extends Node

var owned_units: Array[PackedScene] = [
	preload("res://Scenes/Characters/goblin.tscn"),
	preload("res://Scenes/Characters/golem.tscn"),
	preload("res://Scenes/Characters/petamer.tscn"),
	preload("res://Scenes/Characters/soulbound.tscn"),
	preload("res://Scenes/Characters/orbath.tscn"),
]
var dungeon_team: Array[Entity]
