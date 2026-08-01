extends Node2D

var main_client_scene: PackedScene = load("res://Scenes/Clients/Main/main_client.tscn")

#Login Page
@onready var email_login_line_edit: LineEdit = $Login/Email/LineEdit
@onready var email_login_label: Label = $Login/Email/Label
@onready var password_login_line_edit: LineEdit = $Login/Password/LineEdit
@onready var password_login_label: Label = $Login/Password/Label
@onready var login_button: Button = $Login/LoginButton
@onready var register_page_button: Button = $Login/RegisterPageButton
@onready var recover_password_page_button: Button = $Login/RecoverPasswordPageButton
@onready var login_message_label: Label = $Login/ErrorLabel

#Register page
@onready var email_register_line_edit: LineEdit = $Register/Email/LineEdit
@onready var email_register_label: Label = $Register/Email/Label
@onready var password_register_line_edit: LineEdit = $Register/Password/LineEdit
@onready var password_register_label: Label = $Register/Password/Label
@onready var repeat_password_register_line_edit: LineEdit = $Register/RepeatPassword/LineEdit
@onready var repeat_password_register_label: Label = $Register/RepeatPassword/Label
@onready var register_button: Button = $Register/RegisterButton
@onready var login_page_button: Button = $Register/LoginPageButton
@onready var register_error_label: Label = $Register/ErrorLabel

#Recover Password Page
@onready var recover_password_email_line_edit: LineEdit = $PasswordRecover/Email/LineEdit
@onready var recover_password_email_label: Label = $PasswordRecover/Email/Label
@onready var send_recovery_email_button: Button = $PasswordRecover/SendRecoveryEmailButton
@onready var recover_password_message_label: Label = $PasswordRecover/MessageLabel
@onready var error_label: Label = $Register/ErrorLabel
@onready var recover_password_login_page_button: Button = $PasswordRecover/LoginPageButton


func _ready() -> void:
	Database.get_table("patch_notes")
	var settings = LocalData.load_settings()
	email_login_line_edit.text = settings["email_cockie"]
	login_button.pressed.connect(login_button_pressed)
	login_page_button.pressed.connect(change_window.bind("Login"))
	recover_password_login_page_button.pressed.connect(change_window.bind("Login"))
	register_button.pressed.connect(register_button_pressed)
	register_page_button.pressed.connect(change_window.bind("Register"))
	recover_password_page_button.pressed.connect(change_window.bind("PasswordRecover"))
	send_recovery_email_button.pressed.connect(recover_password_button_pressed)

func change_window(window_type: String):
	match window_type:
		"Login":
			get_node("Login").visible = true
			get_node("Register").visible = false
			get_node("PasswordRecover").visible = false
		"Register":
			get_node("Register").visible = true
			get_node("Login").visible = false
			get_node("PasswordRecover").visible = false
		"PasswordRecover":
			get_node("PasswordRecover").visible = true
			get_node("Register").visible = false
			get_node("Login").visible = false

func recover_password_button_pressed():
	var result = await Auth.send_password_reset(recover_password_email_line_edit.text)
	
	recover_password_message_label.text = "Recovery email has been sent."
	recover_password_message_label.visible = true

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
		LocalData.settings["email_cockie"] = email
		LocalData.save_settings()
		
		LocalData.apply_settings()
		
		var main_client: MainClient = main_client_scene.instantiate()
		await get_tree().create_timer(0.1).timeout
		get_tree().root.add_child(main_client)
		get_tree().current_scene.queue_free()
		get_tree().current_scene = main_client
		#print(result["response_text"])
	else:
		var response = JSON.parse_string(result["response_text"])
		var msg = response["msg"]
		#print(result["response_text"])
		login_message_label.text = msg
		login_message_label.visible = true
