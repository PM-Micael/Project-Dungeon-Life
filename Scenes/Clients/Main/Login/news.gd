extends Node2D

@onready var v_box_container: VBoxContainer = $ScrollContainer/VBoxContainer

func _ready() -> void:
	var patch_notes_response: Array = await Database.get_table("patch_notes")
	var response_code = Database.get_code_from_response(patch_notes_response)
	
	if response_code == 500:
		print(Database.HTTP_STATUS_MESSAGES[response_code])
		return
	elif response_code >= 400 and response_code <= 499:
		print(Database.HTTP_STATUS_MESSAGES[response_code])
		return
	elif response_code >= 200 and response_code <= 299:
		var patch_notes = Database.get_body_from_response(patch_notes_response) 
		for patch_note in patch_notes:
			var title := Label.new()
			title.name = "title"
			title.text = "Patch: " + patch_note["version"] + " | " + patch_note["title"]
			title.add_theme_font_size_override("font_size", 24)
			title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			v_box_container.add_child(title)
			
			create_line_break(false, true, true)
			
			var description := Label.new()
			description.name = "description"
			description.text = patch_note["description"]
			description.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
			description.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			v_box_container.add_child(description)
			
			create_line_break(false, true, true)
			
			if patch_note["features"].size() > 0:
				var features_label = Label.new()
				features_label.name = "features"
				features_label.text = "Features"
				features_label.add_theme_font_size_override("font_size", 20)
				#features_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
				v_box_container.add_child(features_label)
			
				var feature_count: int = 1
				for feature in patch_note["features"]:
					var feature_label = Label.new()
					feature_label.name = "feature " + str(feature_count)
					feature_label.text = " - " + feature
					feature_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
					feature_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
					v_box_container.add_child(feature_label)
					
					create_line_break(false, false, true)
				
					feature_count += 1
			
			create_line_break(false, true, true)
			
			if patch_note["gameplay"].size() > 0:
				var gameplay_label = Label.new()
				gameplay_label.name = "gameplay"
				gameplay_label.text = "Gameplay updates"
				gameplay_label.add_theme_font_size_override("font_size", 20)
				#gameplay_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
				v_box_container.add_child(gameplay_label)
				
				var gameplay_count: int = 1
				for update in patch_note["gameplay"]:
					var update_label = Label.new()
					update_label.name = "update " + str(gameplay_count)
					update_label.text = " - " + update
					update_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
					update_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
					v_box_container.add_child(update_label)
					
					create_line_break(false, false, true)
				
					gameplay_count += 1
				
			
			if patch_note["bug_fixes"].size() > 0:
				var bugs_label = Label.new()
				bugs_label.name = "bugs"
				bugs_label.text = "Bug fixes"
				bugs_label.add_theme_font_size_override("font_size", 20)
				#bugs_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
				v_box_container.add_child(bugs_label)
				
				var bugs_count: int = 1
				for bug in patch_note["bug_fixes"]:
					var bug_label = Label.new()
					bug_label.name = "bug " + str(bugs_count)
					bug_label.text = " - " + bug
					bug_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
					bug_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
					v_box_container.add_child(bug_label)
					
					create_line_break(false, false, true)
				
					bugs_count += 1


func create_line_break(create_patch_line: bool, create_line: bool, create_space: bool):
	if create_line:
		var line_break = Label.new()
		line_break.name = "line_break"
		line_break.text = "_____________________________________________________________________________________________________________________________________________________"
		line_break.horizontal_alignment = 1
		v_box_container.add_child(line_break)

	if create_space:
		var space = Label.new()
		space.name = "space"
		v_box_container.add_child(space)
