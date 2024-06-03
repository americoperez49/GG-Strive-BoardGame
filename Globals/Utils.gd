extends Node


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# utility function just so we can see who (server or clients) is printing the debug statements
func _who_created_this_message(peer):
	print ("Peer " + str(peer.get_unique_id()) + " created the following message:")

func clean_up_data_to_send_to_client(player_id,data):
	var new_data:Dictionary = {}
	#iterate through player data
		#if player_id does not match player_id in player data
			#if its public data
				#copy it
			#else create dummy entries in new_data for each piece of data that is not public
		#if player_id does match player_id in player data
			#if its hand data or public data
				#copy it
			#else create dummy entries in new_data for each piece of data that is not public
				
	return new_data
