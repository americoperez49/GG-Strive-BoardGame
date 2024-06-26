extends Node

signal client_has_connected_to_server
signal all_players_have_connected_to_server
signal player_has_disconnected_from_server
signal player_ready_status_has_changed
signal all_players_have_loaded_character_select_screen
var peer:ENetMultiplayerPeer
var character_select_screen:PackedScene = preload("res://Scenes/CharacterSelect/character_select.tscn") as PackedScene
var board_game:PackedScene = preload("res://Scenes/Board/board.tscn") as PackedScene

# Called when the node enters the scene tree for the first time.
func _ready():
	multiplayer.connected_to_server.connect(_on_connected_to_server)
	multiplayer.connection_failed.connect(_on_connection_failed)
	pass # Replace with function body.

	
func connect_client():
		# we create a new peer object
	peer =ENetMultiplayerPeer.new()
	
	# we create a new client and connect to the server using its IP and PORT
	peer.create_client(Server.IP_ADDRESS,Server.PORT)
	multiplayer.multiplayer_peer=peer


func send_player_data_to_server(Name):
	Server.gather_player_data.rpc_id(1,multiplayer.get_unique_id(),Name)


func let_server_know_client_has_ready_uped():
	Server.client_has_ready_uped.rpc_id(1,multiplayer.get_unique_id())

func send_chosen_character_to_server(character_name):
	Server.client_has_chosen_character.rpc_id(1,multiplayer.get_unique_id(),character_name)

func tell_server_that_client_has_loaded_character_select_screen():
	print("Player " + str(multiplayer.get_unique_id()) + " is letting server know that they have loaded character select screen")
	Server.client_has_loaded_character_select_screen.rpc_id(1,multiplayer.get_unique_id())

@rpc("authority","call_local","reliable")
func all_clients_have_loaded_character_select_screen():
	all_players_have_loaded_character_select_screen.emit()

@rpc("authority","call_remote","reliable")
func ready_up_acknowledged(player_id):
	GameManager.Players[player_id].Ready = "Ready"
	player_ready_status_has_changed.emit(player_id)
	pass


@rpc("authority","call_remote","reliable")
func all_players_have_connected(players):
		GameManager.Players = players
		all_players_have_connected_to_server.emit()

@rpc("authority","call_remote","reliable")
func player_has_disconnected(player_id):
	GameManager.Players.erase(player_id)
	var myself = multiplayer.get_unique_id()
	GameManager.Players[myself].Ready="Not Ready"
	player_has_disconnected_from_server.emit()
	
	
#anyone (client or server) can call this function and it will run both locally for the peer who called it and remotely for all other peers
@rpc("authority","call_local","reliable")		
func start_character_selection():
	get_tree().change_scene_to_packed(character_select_screen)

@rpc("authority","call_local","reliable")
func start_game(players):
	GameManager.Players = players
	get_tree().change_scene_to_packed(board_game)
	
#only called on client when a peer has successfully established a connection to the server
func _on_connected_to_server():
	Utils._who_created_this_message(peer)
	print("conntected to server" + "\n")
	client_has_connected_to_server.emit()

#only called on client when a peer has unsuccessfully established a connection to the server
# we dont really need this function for this example.
# Just had it here for debug purposes
func _on_connection_failed():
	Utils._who_created_this_message(peer)
	print("connection failed" + "\n")

			

