extends Control

enum Menu { START, HOST, JOIN, LOADING, ERROR, LOBBY }

@onready var menus: Dictionary = {
	Menu.START: $StartMenu,
	Menu.HOST: $HostMenu,
	Menu.JOIN: $JoinMenu,
	Menu.LOADING: $LoadingMenu,
	Menu.ERROR: $ErrorMenu,
	Menu.LOBBY: $LobbyMenu
}

var current_menu: Menu = Menu.START

func _ready() -> void:
	MultiplayerManager.connection_failed.connect(show_error)
	MultiplayerManager.player_connected.connect(_on_player_connected)
	MultiplayerManager.server_disconnected.connect(_on_server_disconnected)

func show_menu(target_menu: Menu) -> void:
	menus[current_menu].visible = false
	menus[target_menu].visible = true
	current_menu = target_menu

func show_loading(status: String) -> void:
	$LoadingMenu/LoadingStatus.text = status
	show_menu(Menu.LOADING)

func show_error(message: String) -> void:
	$ErrorMenu/ErrorMessage.text = message
	show_menu(Menu.ERROR)

func _on_quit_button_pressed() -> void:
	get_tree().quit()

func _on_host_button_pressed() -> void:
	show_menu(Menu.HOST)

func _on_join_button_pressed() -> void:
	show_menu(Menu.JOIN)

func _on_back_button_pressed() -> void:
	show_menu(Menu.START)

func _on_player_connected(peer_id: int, _player_info: Dictionary) -> void:
	if multiplayer.get_unique_id() == peer_id:
		show_menu(Menu.LOBBY)

func _on_server_disconnected() -> void:
	show_error("The host has disconnected.")
