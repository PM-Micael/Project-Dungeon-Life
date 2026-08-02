extends Node2D

var data_tables: Dictionary[String, Array] = {
	"player_units": [],
	"enemy_units": [],
	"weapons": [],
	"buffs": [],
	"debuffs": [],
	"combat_stats": []
}

var filters: Dictionary[String, bool] = {
	"player_units": true,
	"enemy_units": true,
	"weapons": true,
	"buffs": true,
	"debuffs": true,
	"combat_stats": true
	}

@onready var search_bar: LineEdit = $Search/SearchBar
@onready var search_button: Button = $Search/Button
@onready var browser_container: VBoxContainer = $WikiBrowser/ScrollContainer/VBoxContainer

@onready var toggle_player_units: Button = $Filters/TogglePlayerUnits
@onready var toggle_enemy_units: Button = $Filters/ToggleEnemyUnits
@onready var toggle_weapons: Button = $Filters/ToggleWeapons
@onready var toggle_buffs: Button = $Filters/ToggleBuffs
@onready var toggle_debuffs: Button = $Filters/ToggleDebuffs
@onready var toggle_combat_stats: Button = $Filters/ToggleCombatStats

func _ready() -> void:
	# Fetch everything
	for table_name in data_tables.keys():
		print("Fetching " + table_name + " table...")
		data_tables[table_name] = await Database.get_table(table_name)
	
	_display_filtered_tables()
	_connect_events()

func _connect_events():
	search_button.pressed.connect(_on_search_button_clicked)
	toggle_player_units.pressed.connect(_toggle_filters.bind(toggle_player_units, "player_units"))
	toggle_enemy_units.pressed.connect(_toggle_filters.bind(toggle_enemy_units, "enemy_units"))
	toggle_weapons.pressed.connect(_toggle_filters.bind(toggle_weapons, "weapons"))
	toggle_buffs.pressed.connect(_toggle_filters.bind(toggle_buffs, "buffs"))
	toggle_debuffs.pressed.connect(_toggle_filters.bind(toggle_debuffs, "debuffs"))
	toggle_combat_stats.pressed.connect(_toggle_filters.bind(toggle_combat_stats, "combat_stats"))
	
func _toggle_filters(button: Button, filter: String):
	filters[filter] = not filters[filter]
	if filters[filter]:
		button.modulate = Color.GREEN
	else:
		button.modulate = Color.RED
	_display_filtered_tables()

func _add_stat(control_node: Control, pos: Vector2, stat: String, value: String):
	var label = Label.new()
	label.text = stat+": "+value
	label.name = value
	label.position = pos
	
	control_node.add_child(label)

func prettify_name(text: String) -> String:
	var words = text.split("_")
	
	for i in range(words.size()):
		words[i] = words[i].capitalize()
	
	return " ".join(words)

func _display_filtered_tables() -> void:
	var nodes = browser_container.get_children()
	for node in nodes:
		node.queue_free()
	for table_name in filters:
		if filters[table_name]:
			var table_label = Label.new()
			table_label.text = prettify_name(table_name)
			table_label.name = table_name
			table_label.add_theme_font_size_override("font_size", 32)
			browser_container.add_child(table_label)
			
			var table = data_tables[table_name]
			for row in table:
				var control = Control.new()
				control.custom_minimum_size = Vector2(0, 350)
				control.name = row["display_name"] + "_control"
				browser_container.add_child(control)
				
				var display_name = Label.new()
				display_name.text = row["display_name"]
				display_name.name = "DisplayName"
				display_name.add_theme_font_size_override("font_size", 24)
				control.add_child(display_name)
				
				match table_name:
					"player_units":
						_add_stat(control, Vector2(0, 40), "Base Health", str(int(row["base_health"])))
						
						_add_stat(control, Vector2(0, 65), "Base Attack Damage", str(int(row["base_attack_damage"])))
						
						_add_stat(control, Vector2(0, 90), "Base Attack Range", str(int(row["base_attack_range"])))
						
						_add_stat(control, Vector2(0, 115), "Base Attack Speed", str(row["base_attack_speed"]))
						
						_add_stat(control, Vector2(0, 140), "Base Crit Chance", str(int(row["base_critical_percent_chance"]))+"%")
						
						_add_stat(control, Vector2(0, 165), "Base Crit Damage", str(int(row["base_critical_damage_multiplier"]))+"x")
						
						var sprite = Sprite2D.new()
						sprite.texture = load("res://Scenes/Units/PC/"+row["entry_id"]+"/"+row["entry_id"]+".png")
						sprite.position = Vector2(400, 100)
						sprite.scale = Vector2(3, 3)
						control.add_child(sprite)
						
						var weapon_label = Label.new()
						weapon_label.position = Vector2(0, 190)
						var weapon_table = data_tables["weapons"]
						for weapon in weapon_table:
							if weapon["id"] == row["signature_weapon_id"]:
								weapon_label.text = "Signature Weapon: "+weapon["display_name"]
						control.add_child(weapon_label)
						
						var passive_label = Label.new()
						passive_label.name = row["display_name"]
						passive_label.position = Vector2(0, 225)
						passive_label.size = Vector2(500, 0) # Maximum width
						passive_label.autowrap_mode = TextServer.AUTOWRAP_WORD
						passive_label.text = "Passive: " + row["passive_description"]
						control.add_child(passive_label)
					"weapons":
						_add_stat(control, Vector2(0, 40), "Added Attack", str(int(row["added_attack_damage"])))
						_add_stat(control, Vector2(0, 65), "Weapon Energy", str(int(row["max_weapon_energy"])))
						
						var weapon_skill = Label.new()
						weapon_skill.name = row["entry_id"]+"_sprite"
						weapon_skill.position = Vector2(0, 225)
						weapon_skill.size = Vector2(500, 0) # Maximum width
						weapon_skill.autowrap_mode = TextServer.AUTOWRAP_WORD
						weapon_skill.text = "Weapon Skill: " + row["weapon_skill"]
						control.add_child(weapon_skill)
						
						var sprite = Sprite2D.new()
						sprite.name = row["entry_id"]+"_sprite"
						sprite.texture = load("res://Scenes/Weapons/"+row["entry_id"]+"/"+row["entry_id"]+".png")
						sprite.position = Vector2(400, 100)
						sprite.scale = Vector2(2, 2)
						control.add_child(sprite)
					"buffs":
						var sprite = Sprite2D.new()
						sprite.name = row["entry_id"]+"_sprite"
						sprite.texture = load("res://Scripts/Effects/Buffs/"+row["entry_id"]+"/"+row["entry_id"]+".svg")
						sprite.position = Vector2(400, 100)
						sprite.scale = Vector2(2, 2)
						control.add_child(sprite)
					"debuffs":
						var sprite = Sprite2D.new()
						sprite.name = row["entry_id"]+"_sprite"
						sprite.texture = load("res://Scripts/Effects/Debuffs/"+row["entry_id"]+"/"+row["entry_id"]+".svg")
						sprite.position = Vector2(400, 100)
						sprite.scale = Vector2(2, 2)
						control.add_child(sprite)
					"combat_stats":
						var description = Label.new()
						description.name = "combad_stats_description"
						description.position = Vector2(0, 225)
						description.size = Vector2(500, 0)
						description.autowrap_mode = TextServer.AUTOWRAP_WORD
						description.text = "Description: " + row["description"]
						control.add_child(description)
						
				browser_container.add_child(_create_line_break())
		browser_container.add_child(_create_line_break())


func _create_line_break() -> Label:
	var label = Label.new()
	label.text = "____________________________________________________________________________"
	return label

func _on_search_button_clicked():
	return
