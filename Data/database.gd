extends Node

const SUPABASE_URL = "https://mbpsphlldyzzdtrhglbr.supabase.co"
const SUPABASE_KEY = "sb_publishable_dih5hMaz1q21iRcknN4DDQ_U3qHObWs"

const HTTP_STATUS_MESSAGES : Dictionary= {
	200: "OK",
	201: "Created",
	400: "Bad Request",
	401: "Unauthorized",
	403: "Forbidden",
	404: "Not Found",
	408: "Request Timeout",
	409: "Conflict",
	429: "Too Many Requests",
	500: "Internal Server Error",
	502: "Bad Gateway",
	503: "Service Unavailable",
	504: "Gateway Timeout"
}

func get_code_from_response(response) -> int:
	return response[1]

func get_body_from_response(response) -> Array:
	var body = response[3]
	var data = JSON.parse_string(body.get_string_from_utf8())
		
	if data.size() > 0:
		var patch_note: Dictionary = data[0]
		return data
	
	return []

func get_table(table: String) -> Array:
	var url = SUPABASE_URL + "/rest/v1/" + table + "?select=*"

	var http := HTTPRequest.new()
	add_child(http)

	var err = http.request(
		url,
		["apikey: " + Database.SUPABASE_KEY,],
		HTTPClient.METHOD_GET
	)

	if err != OK:
		http.queue_free()

	var response = await http.request_completed
	
	return response
	
	var response_code = response[1]
	var body = response[3]

	if response_code == 200:
		var data = JSON.parse_string(body.get_string_from_utf8())
		
		if data.size() > 0:
			var patch_note: Dictionary = data[0]

			#print(data)
			#print(patch_note["version"])

		http.queue_free()
		return data
	
	http.queue_free()
	return []
