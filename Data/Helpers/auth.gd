extends Node

const SUPABASE_URL = "https://mbpsphlldyzzdtrhglbr.supabase.co"
const SUPABASE_KEY = "sb_publishable_dih5hMaz1q21iRcknN4DDQ_U3qHObWs"

const TEST_EMAIL = "fransisco7117@gmail.com"
const TEST_PASSWORD = "Micael123!"

var access_token: String = ""
var refresh_token: String = ""
var user_id: String = ""

func get_headers() -> PackedStringArray:
	return PackedStringArray([
		"apikey: " + SUPABASE_KEY,
		"Authorization: Bearer " + access_token,
		"Content-Type: application/json",
		"Prefer: resolution=merge-duplicates"
	])


func register_user(email: String, password: String) -> Dictionary:
	var url = SUPABASE_URL + "/auth/v1/signup"

	var headers = [
		"apikey: " + SUPABASE_KEY,
		"Content-Type: application/json"
	]

	var body = {
		"email": email,
		"password": password
	}

	var http := HTTPRequest.new()
	add_child(http)

	var err = http.request(
		url,
		headers,
		HTTPClient.METHOD_POST,
		JSON.stringify(body)
	)

	if err != OK:
		http.queue_free()
		return {
			"success": false,
			"error": "Failed to start HTTP request."
		}

	var response = await http.request_completed

	var code: int = response[1]
	var response_text = response[3].get_string_from_utf8()

	http.queue_free()

	print("Register status:", code)
	print(response_text)

	var json = JSON.parse_string(response_text)

	if code != 200:
		return {
			"success": false,
			"error": json
		}

	# Save the session
	access_token = json["access_token"]
	refresh_token = json["refresh_token"]
	user_id = json["user"]["id"]

	return {
		"success": true,
		"user": json["user"]
	}


func login_user(email: String, password: String) -> Dictionary:
	var url = SUPABASE_URL + "/auth/v1/token?grant_type=password"

	var headers = [
		"apikey: " + SUPABASE_KEY,
		"Content-Type: application/json"
	]

	var body = {
		"email": email,
		"password": password
	}

	var http := HTTPRequest.new()
	add_child(http)

	var err = http.request(
		url,
		headers,
		HTTPClient.METHOD_POST,
		JSON.stringify(body)
	)

	if err != OK:
		http.queue_free()
		return {
			"success": false,
			"error": "Failed to start HTTP request."
		}

	var response = await http.request_completed

	var code: int = response[1]
	var response_text = response[3].get_string_from_utf8()

	http.queue_free()

	print("Login status:", code)
	print(response_text)

	var json = JSON.parse_string(response_text)

	if code != 200:
		return {
			"success": false,
			"error": json
		}

	# Store the authenticated session
	access_token = json["access_token"]
	refresh_token = json["refresh_token"]
	user_id = json["user"]["id"]

	return {
		"success": true,
		"user": json["user"]
	}
