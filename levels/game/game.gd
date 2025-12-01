extends Node3D

@onready var players: Node3D = $Players
const PLAYER: PackedScene = preload("res://entities/player/player.tscn")

var players_loaded: int = 0

func _ready() -> void:
	MultiplayerManager.player_disconnected.connect(_on_player_disconnected)
	MultiplayerManager.server_disconnected.connect(_on_server_disconnected)
	
	# Server spawns all players
	if multiplayer.is_server():
		spawn_player(1)
		for peer in multiplayer.get_peers():
			spawn_player(peer)
	
	player_loaded.rpc_id(1) # Tell server that this peer has loaded

func spawn_player(peer_id: int) -> void:
	var player: CharacterBody3D = PLAYER.instantiate()
	player.name = str(peer_id)
	players.add_child(player)

@rpc("any_peer", "call_local", "reliable")
func player_loaded() -> void:
	if multiplayer.is_server():
		players_loaded += 1
		if players_loaded == MultiplayerManager.players.size():
			start_game()

func start_game() -> void:
	# All peers are connected and are ready to recieve RPCs
	update_game_status.rpc("Game started")
	assign_player_nametags.rpc()

@rpc("any_peer", "call_local", "reliable")
func update_game_status(message: String) -> void:
	$GameStatus.text = message

@rpc("any_peer", "call_local")
func assign_player_nametags() -> void:
	for player in players.get_children():
		var peer_id: int = int(player.name)
		var player_name: String = MultiplayerManager.players[peer_id].name
		player.get_node("Nametag").text = player_name

func _on_player_disconnected(peer_id) -> void:
	var player: CharacterBody3D = players.get_node_or_null(str(peer_id))
	if player: player.queue_free()

func _on_server_disconnected() -> void:
	MultiplayerManager.load_scene("res://levels/main_menu/main_menu.tscn")
