extends Node

var peer = ENetMultiplayerPeer.new()
var PORT = 8000
var MAX_PLAYERS = 100
var players_ids = []
var initial_enemies_data = [
	{"position": Vector2(198, 272), "left_weapon_name": "bone_dagger", "sprite_frames_name": "regular_skeleton"},
	{"position": Vector2(85, 207), "left_weapon_name": "bone_dagger", "sprite_frames_name": "regular_skeleton"},
	{"position": Vector2(196, 142), "left_weapon_name": "bone_dagger", "sprite_frames_name": "regular_skeleton"},
	{"position": Vector2(1342, 1040), "direction": -1, "left_weapon_name": "bone_dagger", "right_weapon_name": "bone_round_shield", "sprite_frames_name": "regular_orc"},
	{"position": Vector2(1471, 981), "direction": -1, "left_weapon_name": "bone_heavy_shield", "right_weapon_name": "bone_club", "sprite_frames_name": "warrior_orc"},
	{"position": Vector2(1340, 910), "direction": -1, "left_weapon_name": "bone_dagger", "right_weapon_name": "bone_round_shield", "sprite_frames_name": "regular_orc"},
	{"position": Vector2(846, 1424), "left_weapon_name": "bone_heavy_shield", "right_weapon_name": "bone_club", "sprite_frames_name": "warrior_orc"},
	{"position": Vector2(675, 1425), "left_weapon_name": "bone_dagger", "right_weapon_name": "bone_round_shield", "sprite_frames_name": "regular_orc"},
	{"position": Vector2(768, 1296), "left_weapon_name": "bone_dagger", "right_weapon_name": "bone_round_shield", "sprite_frames_name": "regular_orc"},
	{"position": Vector2(948, 284), "left_weapon_name": "bone_dagger", "sprite_frames_name": "regular_skeleton"},
	{"position": Vector2(875, 175), "left_weapon_name": "bone_dagger", "sprite_frames_name": "regular_skeleton"},
	{"position": Vector2(1000, 178), "left_weapon_name": "bone_dagger", "sprite_frames_name": "regular_skeleton"},
	{"position": Vector2(448, 1079), "left_weapon_name": "bone_dagger", "right_weapon_name": "bone_round_shield", "sprite_frames_name": "regular_orc"},
	{"position": Vector2(312, 840), "left_weapon_name": "bone_dagger", "right_weapon_name": "bone_round_shield", "sprite_frames_name": "regular_orc"},
	{"position": Vector2(871, 964), "left_weapon_name": "bone_dagger", "right_weapon_name": "bone_round_shield", "sprite_frames_name": "regular_orc"},
	{"position": Vector2(876, 1107), "left_weapon_name": "bone_dagger", "right_weapon_name": "bone_round_shield", "sprite_frames_name": "regular_orc"},
	{"position": Vector2(1065, 743), "left_weapon_name": "bone_dagger", "right_weapon_name": "bone_round_shield", "sprite_frames_name": "regular_orc"},
	{"position": Vector2(530, 429), "left_weapon_name": "bone_club", "right_weapon_name": "bone_round_shield", "sprite_frames_name": "regular_skeleton"},
	{"position": Vector2(1383, 400), "left_weapon_name": "bone_club", "sprite_frames_name": "regular_skeleton"}
]
var enemies = []


func _ready():
	start_server()
	create_enemies()


func start_server():
	peer.create_server(PORT, MAX_PLAYERS)
	multiplayer.multiplayer_peer = peer
	peer.peer_connected.connect(_on_peer_connected)
	peer.peer_disconnected.connect(_on_peer_disconnected)
	
	
func create_enemies():
	var enemy_scene = load("res://scenes/characters/enemy.tscn")
	for ind in initial_enemies_data.size():
		var enemy_data = initial_enemies_data[ind]
		var enemy = enemy_scene.instantiate()
		enemy.name = "Enemy" + str(ind)
		enemy.enemy_id = ind
		enemy.position = enemy_data.get("position")
		enemy.direction = enemy_data.get("direction", 1)
		enemy.left_weapon_name = enemy_data.get("left_weapon_name", "")
		enemy.right_weapon_name = enemy_data.get("right_weapon_name", "")
		enemy.sprite_frames_name = enemy_data.get("sprite_frames_name", "")
		add_child(enemy, true)
		enemies.append(enemy)
		var synchronizer = MultiplayerSynchronizer.new()
		
		
func serialize_enemies():
	var enemies_data = []
	for enemy in enemies:
		enemies_data.append({
			"position": enemy.position,
			"direction": enemy.direction,
			"left_weapon_name": enemy.left_weapon_name,
			"right_weapon_name": enemy.right_weapon_name,
			"sprite_frames_name": enemy.sprite_frames_name
		})
	return enemies_data
	

func _on_peer_connected(player_id):
	print("Player id " + str(player_id) + " connected")
	players_ids.append(player_id)
	create_new_player.rpc(player_id)
	create_existing_players.rpc(player_id, players_ids)
	var enemies_data = serialize_enemies()
	replicate_enemies.rpc(enemies_data)
	
	
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


@rpc("authority", "call_remote", "reliable", 0)
func replicate_enemies(enemies_data):
	pass
	
	
@rpc("any_peer", "call_remote", "reliable", 0)
func replicate_enemy_following_player(enemies_data):
	pass
