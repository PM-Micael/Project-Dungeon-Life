extends Node2D

var main_client_scene: PackedScene = load("res://Scenes/Clients/Main/main_client.tscn")

@onready var email_login_line_edit: LineEdit = $Login/Email/LineEdit
@onready var email_login_label: Label = $Login/Email/Label

@onready var password_login_line_edit: LineEdit = $Login/Password/LineEdit
@onready var password_login_label: Label = $Login/Password/Label

@onready var login_button: Button = $Login/LoginButton

@onready var email_register_line_edit: LineEdit = $Register/Email/LineEdit
@onready var email_register_label: Label = $Register/Email/Label

@onready var password_register_line_edit: LineEdit = $Register/Password/LineEdit
@onready var password_register_label: Label = $Register/Password/Label

@onready var repeat_password_register_line_edit: LineEdit = $Register/RepeatPassword/LineEdit
@onready var repeat_password_register_label: Label = $Register/RepeatPassword/Label

@onready var register_button: Button = $Register/RegisterButton

@onready var register_page_button: Button = $Login/RegisterPageButton
@onready var login_page_button: Button = $Register/LoginPageButton

@onready var register_error_label: Label = $Register/ErrorLabel
@onready var login_error_label: Label = $Login/ErrorLabel

func _ready() -> void:
	login_button.pressed.connect(login_button_pressed)
	login_page_button.pressed.connect(change_window.bind("Login"))
	register_button.pressed.connect(register_button_pressed)
	register_page_button.pressed.connect(change_window.bind("Register"))

func change_window(window_type: String):
	match window_type:
		"Login":
			get_node("Login").visible = true
			get_node("Register").visible = false
		"Register":
			get_node("Register").visible = true
			get_node("Login").visible = false

func register_button_pressed():
	var email: String = email_register_line_edit.text
	var password: String = password_register_line_edit.text
	var repeat_password: String = repeat_password_register_line_edit.text
	if password == repeat_password:
		var result = await Auth.register_user(email, password)
		var code = result["code"]
		if code >= 200 and code <= 299:
			login(email, password)
			return
		
		var response = JSON.parse_string(result["response_text"])
		var msg = response["msg"]

		register_error_label.text = msg
		register_error_label.visible = true

	else:
		register_error_label.text = "Password must mach"
		register_error_label.visible = true

func login_button_pressed():
	var email: String = email_login_line_edit.text
	var password: String = password_login_line_edit.text
	
	login(email, password)

func login(email: String, password: String):
	var result = await Auth.login_user(email, password)
	
	var code = result["code"]
	if code >= 200 and code <= 299:
		PlayerData.player_id = result["user"]["id"]
		LocalData.settings["display"]["display_mode"] = LocalData.DISPLAY_MODE.BORDERLESS
		
		LocalData.apply_settings()
		
		var main_client: MainClient = main_client_scene.instantiate()
		await get_tree().create_timer(0.1).timeout
		get_tree().root.add_child(main_client)
		get_tree().current_scene.queue_free()
		get_tree().current_scene = main_client
		print(result["response_text"])
	else:
		print(result["response_text"])
		login_error_label.text = "Wrong email or password."
		login_error_label.visible = true
