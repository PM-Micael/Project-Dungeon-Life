extends Node

var dungeon_data = {
	"enemy_formations": [
		{
			"formation_1": [
				{ "type": "Skeleton", "x": -150, "y": -250 },
				{ "type": "Skeleton", "x": -50,  "y": -250 },
				{ "type": "Skeleton", "x": 50,   "y": -250 },
				{ "type": "Skeleton", "x": 150,  "y": -250 }
			],
			"formation_2": [
				{ "type": "Skeleton", "x": -350, "y": -50 },
				{ "type": "Skeleton", "x": 150,  "y": -50 },
				{ "type": "Skeleton", "x":150,   "y": -50 },
				{ "type": "Skeleton", "x": 350,  "y": -50 }
			]
		}
	]
}

var enemy_formations = [
	{
		"formation_1" :[
			{ "type": "skeleton", "position": Vector2(-150, -250) },
			{ "type": "skeleton", "position": Vector2(-50, -250) },
			{ "type": "skeleton", "position": Vector2(50, -250) },
			{ "type": "skeleton", "position": Vector2(150, -250) },
		],
		"formation_2" :[
			{ "type": "skeleton", "position": Vector2(-350, -50) },
			{ "type": "skeleton", "position": Vector2(-150, -50) },
			{ "type": "skeleton", "position": Vector2(150, -50) },
			{ "type": "skeleton", "position": Vector2(350, -50) },
		]
	}
]
