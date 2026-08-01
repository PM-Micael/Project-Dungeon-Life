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

func _ready() -> void:
	# Fetch everything
	for table_name in data_tables.keys():
		print("Fetching " + table_name + " table...")
		data_tables[table_name] = await Database.get_table(table_name)

	# Display only enabled filters
	display_filtered_tables()

func display_filtered_tables() -> void:
	for table_name in filters:
		if filters[table_name]:
			var table = data_tables[table_name]
			for row in table:
				var node = Node2D.new()
				var sprite = Sprite2D.new()
				
				var display_name = Label.new()
				display_name.text = row["display_name"]
				display_name.add_theme_font_size_override("font_size", 24)
				browser_container.add_child(display_name)
				
				match table_name:
					"player_units":
						var health = Label.new()
						health.text = "Base Health: "+str(int(row["base_health"]))
						browser_container.add_child(health)
						
						var attack = Label.new()
						attack.text = "Base Attack: "+str(int(row["base_attack_damage"]))
						browser_container.add_child(attack)
						
						var attack_range = Label.new()
						attack_range.text = "Base Attack Range: "+str(int(row["base_attack_range"]))
						browser_container.add_child(attack_range)
						
						var attack_speed = Label.new()
						attack_speed.text = "Base Attack Speed: "+str(row["base_attack_speed"])
						browser_container.add_child(attack_speed)
						
						var crit_chance = Label.new()
						crit_chance.text = "Critical Chance: "+str(int(row["base_critical_percent_chance"]))+"%"
						browser_container.add_child(crit_chance)
						
						var crit_damage = Label.new()
						crit_damage.text = "Critical Damage: "+str(row["base_critical_damage_multiplier"])+"x"
						browser_container.add_child(crit_damage)
						
						var weapon_label = Label.new()
						var weapon_table = data_tables["weapons"]
						for weapon in weapon_table:
							if weapon["id"] == row["signature_weapon_id"]:
								weapon_label.text = "Signature Weapon: "+weapon["display_name"]
						browser_container.add_child(weapon_label)
				
				browser_container.add_child(_create_line_break())
		browser_container.add_child(_create_line_break())

func _connect_events():
	search_button.pressed.connect(_on_search_button_clicked)

func _create_line_break() -> Label:
	var label = Label.new()
	label.text = "____________________________________________________________________________"
	return label

func _on_search_button_clicked():
	return
