extends Node

var Players:Dictionary = {}
var whos_turn_it_is
var turn_queue:Array = []

func decide_who_goes_first():
	whos_turn_it_is = randi_range(1,2)
	turn_queue.push_front(whos_turn_it_is)

func setup_inital_hands():
	for player_id in Players:
		if Players[player_id].Player_Number == 1:
			#Gather character specific deck
			#Shuffle deck
			#Pick 5 or 6 cards, depending on who is going first
			#set this information back in the player data
			pass
		else:
			pass
	
