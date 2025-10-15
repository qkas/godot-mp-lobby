extends Control

enum Menu { START, HOST, JOIN, LOADING, LOBBY }

@onready var menus: Dictionary = {
	Menu.START: $StartMenu,
	Menu.HOST: $HostMenu,
	Menu.JOIN: $JoinMenu,
	Menu.LOADING: $LoadingMenu,
	Menu.LOBBY: $LobbyMenu
}

var current_menu: Menu = Menu.START

func show_menu(target_menu: Menu):
	menus[current_menu].visible = false
	menus[target_menu].visible = true
	current_menu = target_menu

func _on_quit_button_pressed() -> void:
	get_tree().quit()

func _on_host_button_pressed() -> void:
	show_menu(Menu.HOST)

func _on_join_button_pressed() -> void:
	show_menu(Menu.JOIN)

func _on_start_loading_button_pressed() -> void:
	show_menu(Menu.LOADING)

func _on_back_button_pressed() -> void:
	show_menu(Menu.START)
