extends Node2D
@export var player_1_sprite:Sprite2D
@export var player_2_sprite:Sprite2D
@export var characters:Node2D
# Called when the node enters the scene tree for the first time.
func _ready():
	for player_id in GameManager.Players:
		var character_name = GameManager.Players[player_id].Character
		var player_number = GameManager.Players[player_id].Player_Number
		if player_number == 1:
			player_1_sprite.texture = load("res://Textures/"+character_name +"/"+ character_name +".png")
		else:
			player_2_sprite.texture = load("res://Textures/"+character_name +"/"+ character_name +".png")
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
