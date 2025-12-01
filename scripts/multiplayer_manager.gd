extends Node

signal upnp_completed(error: Error)
signal matchmaker_registered(code: String)

signal connection_failed(message: String)

signal player_connected(peer_id: int, player_info: Dictionary)
signal player_disconnected(peer_id: int)
signal server_disconnected

const PORT: int = 6000
const MATCHMAKING_SERVER_URL: String = "https://your-matchmaking-server.com"

const DEFAULT_SERVER_IP: String = "127.0.0.1"
const MAX_CONNECTIONS: int = 20

var upnp_thread: Thread = null

var players: Dictionary = {}
var player_info: Dictionary = { "name": "noname" }

func _ready() -> void:
	multiplayer.peer_connected.connect(_on_player_connected)
	multiplayer.peer_disconnected.connect(_on_player_disconnected)
	multiplayer.connected_to_server.connect(_on_connected_ok)
	multiplayer.connection_failed.connect(_on_connected_fail)
	multiplayer.server_disconnected.connect(_on_server_disconnected)

# Begins peer hosting; registers public IP if online
func create_game(player_name: String, is_online: bool) -> Error:
	if is_online:
		# Perform UPNP port forwarding on separate thread to avoid blocking
		if upnp_thread != null: upnp_thread.wait_to_finish()
		upnp_thread = Thread.new()
		upnp_thread.start(_upnp_setup.bind(PORT))
		
		var upnp_err: Error = await upnp_completed
		if (upnp_err != OK):
			return upnp_err
		
		var code = await register_code()
		if code == "":
			return ERR_CANT_CREATE
	
	var peer: ENetMultiplayerPeer = ENetMultiplayerPeer.new()
	var error: Error = peer.create_server(PORT, MAX_CONNECTIONS)
	if error != OK:
		return error
	
	multiplayer.multiplayer_peer = peer
	
	player_info.name = player_name
	players[1] = player_info
	player_connected.emit(1, player_info)
	
	return OK

# Send a POST request to register this host's IP with the matchmaking server
func register_code() -> String:
	var http_request: HTTPRequest = make_http_request(
		"%s/register" % MATCHMAKING_SERVER_URL,
		HTTPClient.METHOD_POST
	)
	
	var response: Array = await http_request.request_completed
	var response_code: int = response[1]
	var body: PackedByteArray = response[3]
	
	if response_code == 200:
		var code = JSON.parse_string(body.get_string_from_utf8())["code"]
		matchmaker_registered.emit(code)
		return code
	else:
		push_error(str(response_code))
		connection_failed.emit("Failed to register lobby code.")
		return ""

# Open specified port for external network connections
func _upnp_setup(server_port: int) -> void:
	var upnp: UPNP = UPNP.new()
	var err = upnp.discover()
	
	if err != OK:
		push_error(str(err))
		call_deferred("emit_signal", "upnp_completed", err)
		call_deferred("emit_signal", "connection_failed", "UPNP setup failed.")
		return
	if upnp.get_gateway() and upnp.get_gateway().is_valid_gateway():
		upnp.add_port_mapping(server_port, server_port, "godot mp example", "UDP")
		upnp.add_port_mapping(server_port, server_port, "godot mp example", "TCP")
		call_deferred("emit_signal", "upnp_completed", OK)

# Attempt connection to local or online session
func join_game(player_name: String, code: String = "") -> Error:
	var address: String = DEFAULT_SERVER_IP
	if code != "":
		address = await resolve_address(code)
		if address == "":
			return ERR_CANT_RESOLVE
	
	var peer: ENetMultiplayerPeer = ENetMultiplayerPeer.new()
	var error: Error = peer.create_client(address, PORT)
	if error != OK:
		return error
	
	multiplayer.multiplayer_peer = peer
	
	player_info.name = player_name
	
	return OK

# Send a GET request to resolve a join code to the host's IP address
func resolve_address(code: String) -> String:
	var http_request: HTTPRequest = make_http_request(
		"%s/resolve?code=%s" % [MATCHMAKING_SERVER_URL, code],
		HTTPClient.METHOD_GET
	)
	
	var response: Array = await http_request.request_completed
	var response_code: int = response[1]
	var body: PackedByteArray = response[3]
	
	if response_code == 200:
		var address = JSON.parse_string(body.get_string_from_utf8())["address"]
		return address
	else:
		push_error(str(response_code))
		connection_failed.emit("Failed to resolve lobby code.")
		return ""

func make_http_request(url: String, method: HTTPClient.Method, data := []) -> HTTPRequest:
	var http_request: HTTPRequest = HTTPRequest.new()
	http_request.use_threads = true
	get_tree().root.add_child(http_request)
	
	http_request.request(url, data, method)
	
	return http_request

@rpc("any_peer", "reliable")
func _register_player(new_player_info: Dictionary) -> void:
	var new_player_id: int = multiplayer.get_remote_sender_id()
	players[new_player_id] = new_player_info
	player_connected.emit(new_player_id, new_player_info)

func remove_multiplayer_peer() -> void:
	multiplayer.multiplayer_peer = OfflineMultiplayerPeer.new()
	players.clear()
	

@rpc("call_local", "reliable")
func load_scene(scene_path) -> void:
	get_tree().change_scene_to_file(scene_path)

func _on_player_connected(peer_id: int) -> void:
	_register_player.rpc_id(peer_id, player_info)

func _on_player_disconnected(peer_id: int) -> void:
	players.erase(peer_id)
	player_disconnected.emit(peer_id)

func _on_connected_ok() -> void:
	var peer_id: int = multiplayer.get_unique_id()
	players[peer_id] = player_info
	player_connected.emit(peer_id, player_info)

func _on_connected_fail() -> void:
	remove_multiplayer_peer()

func _on_server_disconnected() -> void:
	remove_multiplayer_peer()
	players.clear()
	server_disconnected.emit()
