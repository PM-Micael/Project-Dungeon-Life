extends PanelContainer

@onready var content = $MarginContainer/VBoxContainer


func add_title(text:String):

	var label = Label.new()
	label.text = text
	label.add_theme_font_size_override("font_size", 24)

	content.add_child(label)


func add_property(name:String, value:String):

	var row = HBoxContainer.new()

	var name_label = Label.new()
	name_label.text = name + ":"

	var value_label = Label.new()
	value_label.text = value

	row.add_child(name_label)
	row.add_child(value_label)

	content.add_child(row)
