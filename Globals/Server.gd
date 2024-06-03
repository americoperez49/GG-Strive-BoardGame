extends Node

var IP_ADDRESS = "localhost"
var PORT = 8910
const MAX_NUMBER_OF_PLAYERS = 2
var peer:ENetMultiplayerPeer
var number_of_players_that_have_connected_to_server:int = 0
var number_of_players_that_have_loaded_character_select_screen: int = 0
var number_of_players_that_have_selected_a_character: int = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	if OS.has_feature("dedicated_server"):
		multiplayer.peer_disconnected.connect(_on_peer_disconnected)
		_host_game()
		

#region Private Functions

func _host_game():
	# we create a new peer object
	peer = ENetMultiplayerPeer.new()
	
	# we create the server
	var error = peer.create_server(PORT,MAX_NUMBER_OF_PLAYERS)
	if error != OK:
		print("cannot host: " + error)
		return
	# If all went OK then we set the peer of our Godot instance to the peer that we just created
	multiplayer.multiplayer_peer=peer
	
	Utils._who_created_this_message(peer)
	print("waiting for other players" + "\n")

func _two_players_have_connected():
	return GameManager.Players.size() == 2
#endregion

@rpc("any_peer","reliable")
func gather_player_data(ID,Name):
	number_of_players_that_have_connected_to_server +=1
	print("Client: " + str(ID) + " has connected to server")
		#if the peer's list of players doesnt contain the player we just receieved data for, then add them to the list
	if !GameManager.Players.has(ID):
		GameManager.Players[ID]= {
			"ID":ID,
			"Name":Name,
			"Ready":"Not Ready",
			"Character":"",
			"Player_Number":number_of_players_that_have_connected_to_server
		}
		
	if _two_players_have_connected():
		print("Letting clients know that two players have connected and that they can show the ready list and enable the ready button")
		Client.all_players_have_connected.rpc(GameManager.Players)
	pass

@rpc("any_peer","call_remote","reliable")
func client_has_ready_uped(player_id):
	print("Sever has recieved ready up message from: " + str(player_id))
	GameManager.Players[player_id].Ready = "Ready"
	Client.ready_up_acknowledged.rpc(player_id)
	
	
	var all_players_are_ready = true
	for id in GameManager.Players:
		if GameManager.Players[id].Ready == "Not Ready":
			all_players_are_ready = false
	
	#start the game if all players are ready
	if all_players_are_ready:
		print("Server is starting the game")
		Client.start_character_selection.rpc()
	pass

@rpc("any_peer","call_remote","reliable")
func client_has_chosen_character(player_id,chosen_character_name):
	number_of_players_that_have_selected_a_character += 1
	print("Player: " + str(player_id) + " has chosen " + chosen_character_name)
	GameManager.Players[player_id].Character = chosen_character_name
	
	if number_of_players_that_have_selected_a_character == 2:
		GameManager.decide_who_goes_first()
		GameManager.setup_inital_hands()
		#send data to each player, making sure to only send
		Client.start_game.rpc(GameManager.Players)
	pass

@rpc("any_peer","call_remote","reliable")
func client_has_loaded_character_select_screen(player_id):
	print("server has received message from client, letting server know what client has loaded character selelect screen")
	number_of_players_that_have_loaded_character_select_screen +=1
	if number_of_players_that_have_loaded_character_select_screen == 2:
		Client.all_clients_have_loaded_character_select_screen.rpc()
	pass

func _on_peer_disconnected(player_id:int):
	GameManager.Players.erase(player_id)
	Client.player_has_disconnected.rpc(player_id)
	print("Player: " + str(player_id) + " has disconnected")
	pass
