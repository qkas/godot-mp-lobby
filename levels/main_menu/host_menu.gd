extends VBoxContainer

var is_online: bool = false

@onready var main_menu: Control = $".."

@onready var name_input: LineEdit = $NameInput

func _on_connection_type_tab_changed(tab_index: int) -> void:
	is_online = bool(tab_index)

func _on_start_host_button_pressed() -> void:
	var player_name: String = name_input.text
	if player_name.is_empty():
		return
	
	player_name = player_name.replace(" ", "_")
	
	main_menu.show_loading("Creating game...")
	
	await MultiplayerManager.create_game(player_name, is_online)
