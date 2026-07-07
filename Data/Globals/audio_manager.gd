extends Node

var master_volume: float:
	get:
		return LocalData.settings["audio"]["volume_master"]
var sfx_volume: float:
	get:
		return LocalData.settings["audio"]["volume_sfx"]

func play_sfx_once(parent_node: Node, audio_file: String):
	var player = AudioStreamPlayer.new()
	player.stream = load(audio_file)
	
	player.volume_db = get_gain(["volume_sfx"])
	
	parent_node.add_child(player)
	player.play()
	player.finished.connect(player.queue_free)

func get_gain(tags: Array) -> float:
	var gain: float = (1.0 * master_volume)
	
	for tag in tags:
		if LocalData.settings["audio"].has(tag):
			gain *= LocalData.settings["audio"][tag]
	
	gain -= 20
	if gain <= -30:
		gain = -80
	
	return gain
