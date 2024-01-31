extends Node

var peer = ENetMultiplayerPeer.new()
var PORT = 8000
var MAX_PLAYERS = 100
var players_ids = []


func _ready():
	StartServer()


func StartServer():
	peer.create_server(PORT, MAX_PLAYERS)
	multiplayer.multiplayer_peer = peer
	peer.peer_connected.connect(_on_peer_connected)
	peer.peer_disconnected.connect(_on_peer_disconnected)
	

func _on_peer_connected(player_id):
	print("Player id " + str(player_id) + " connected")
	players_ids.append(player_id)
	create_new_player.rpc(player_id)
	create_existing_players.rpc(player_id, players_ids)
	
	
func _on_peer_disconnected(player_id):
	print("Player id " + str(player_id) + " disconnected")
	players_ids.erase(player_id)
	remove_player.rpc(player_id)
	

@rpc("authority", "call_remote", "reliable", 0)
func create_new_player(_player_id):
	pass
	
	
@rpc("authority", "call_remote", "reliable", 0)
func create_existing_players(_incoming_player_id, _players_ids):
	pass
	

@rpc("authority", "call_remote", "reliable", 0)
func remove_player(_player_id):
	pass
	
	
@rpc("any_peer", "call_remote", "unreliable", 0)
func update_player_movement(_player_id, _velocity_vector, _previous_x, _previous_y):
	pass
	
	
@rpc("any_peer", "call_remote", "unreliable", 0)
func make_player_attack(_player_id):
	pass
