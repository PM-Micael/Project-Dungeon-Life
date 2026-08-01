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

func _add_stat(control_node: Control, pos: Vector2, stat: String, value: String):
	var label = Label.new()
	label.text = stat+": "+value
	label.position = pos
	
	control_node.add_child(label)

func prettify_name(text: String) -> String:
	var words = text.split("_")
	
	for i in range(words.size()):
		words[i] = words[i].capitalize()
	
	return " ".join(words)

func display_filtered_tables() -> void:
	for table_name in filters:
		if filters[table_name]:
			var table_label = Label.new()
			table_label.text = prettify_name(table_name)
			table_label.add_theme_font_size_override("font_size", 32)
			browser_container.add_child(table_label)
			
			var table = data_tables[table_name]
			for row in table:
				var control = Control.new()
				control.custom_minimum_size = Vector2(0, 350)
				browser_container.add_child(control)
				
				var display_name = Label.new()
				display_name.text = row["display_name"]
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
						passive_label.position = Vector2(0, 225)
						passive_label.size = Vector2(500, 0) # Maximum width
						passive_label.autowrap_mode = TextServer.AUTOWRAP_WORD
						passive_label.text = "Passive: " + row["passive_description"]
						control.add_child(passive_label)
					"weapons":
						_add_stat(control, Vector2(0, 40), "Added Attack", str(int(row["added_attack_damage"])))
					
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
