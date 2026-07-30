extends Node

const SUPABASE_URL = "https://mbpsphlldyzzdtrhglbr.supabase.co"
const SUPABASE_KEY = "sb_publishable_dih5hMaz1q21iRcknN4DDQ_U3qHObWs"

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

	var response_code = response[1]
	var body = response[3]

	if response_code == 200:
		var data = JSON.parse_string(body.get_string_from_utf8())
		
		if data.size() > 0:
			var patch_note: Dictionary = data[0]

			print(data)
			print(patch_note["version"])

		http.queue_free()
		return data
	
	http.queue_free()
	return []
