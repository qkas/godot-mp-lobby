extends VBoxContainer

func _ready() -> void:
	MultiplayerManager.matchmaker_registered.connect(_on_matchmaker_registered)
	MultiplayerManager.player_connected.connect(_on_player_connected)
	MultiplayerManager.player_disconnected.connect(_on_player_disconnected)

func update_player_list() -> void:
	var player_names_arr: Array[String] = []
	for player_info in MultiplayerManager.players.values():
		player_names_arr.append(player_info.name)
	var player_names_str: String = " ".join(player_names_arr)
	update_players_label.rpc(player_names_str)

@rpc("any_peer", "call_local", "reliable")
func update_players_label(names_str: String) -> void:
	$MarginContainer/PlayerList.text = names_str

func _on_quit_lobby_button_pressed() -> void:
	MultiplayerManager.remove_multiplayer_peer()

func _on_matchmaker_registered(code: String) -> void:
	$LobbyCode.text = code
	DisplayServer.clipboard_set(code) # Copy code to clipboard

func _on_player_connected(_peer_id: int, _player_info: Dictionary) -> void:
	if multiplayer.is_server():
		update_player_list()

func _on_player_disconnected(_peer_id: int) -> void:
	if multiplayer.is_server():
		update_player_list()

func _on_start_game_button_pressed() -> void:
	MultiplayerManager.load_scene.rpc("res://levels/game/game.tscn")
