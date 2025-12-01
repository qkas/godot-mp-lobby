extends VBoxContainer

@onready var main_menu: Control = $".."

@onready var name_input: LineEdit = $NameInput
@onready var code_input: LineEdit = $CodeInput

func _on_connection_type_tab_changed(tab_index: int) -> void:
	code_input.editable = bool(tab_index)
	code_input.text = ""

func _on_start_join_button_pressed() -> void:
	var player_name: String = name_input.text
	if player_name.is_empty():
		return
	
	player_name = player_name.replace(" ", "_")
	
	main_menu.show_loading("Joining game...")
	
	var code: String = code_input.text
	await MultiplayerManager.join_game(player_name, code)
