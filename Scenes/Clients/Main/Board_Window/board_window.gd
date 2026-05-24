extends Window

func _ready() -> void:
	title = "Window Manager"
	size = Vector2i(800, 800)
	position = Vector2i(800, 800)
	unresizable = true
	#borderless = true
	always_on_top = true
	transparent_bg = true
	transparent = true
	
	#var board = GameBoard.new()
	#add_child(board)
