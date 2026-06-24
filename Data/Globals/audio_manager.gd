extends Node

func play_sfx_once(parent_node: Node, audio_file: String):
	var player = AudioStreamPlayer.new()
	player.stream = load(audio_file)
	player.volume_db = -16
	parent_node.add_child(player)
	player.play()
	player.finished.connect(player.queue_free)
