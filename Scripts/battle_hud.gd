extends Control

@onready var arena_root = $"../.."

func _on_direct_order_button_toggled(toggled_on: bool) -> void:
	if toggled_on: detoggle("Direct Order Menu")
		#test version that does work, but need to register which player is pressing somehow; we'll get there
		#$"Direct Order Menu".populate_buttons(arena_root.monster_point_1.get_children()[0].move_list)
	$"Direct Order Menu".visible = toggled_on

func _on_switch_monster_button_toggled(toggled_on: bool) -> void:
	if toggled_on: detoggle("Switch Mon Menu")
	$"Switch Mon Menu".visible = toggled_on

func detoggle(active):
	if active == "Switch Mon Menu":
		$"Player Buttons/MarginContainer/VBoxContainer/HBoxContainer/Direct Order Button".button_pressed = false
		$"Player Buttons/MarginContainer/VBoxContainer/HBoxContainer/Direct Order Button".toggled.emit(false)
	else:
		$"Player Buttons/MarginContainer/VBoxContainer/HBoxContainer/Switch Monster Button".button_pressed = false
		$"Player Buttons/MarginContainer/VBoxContainer/HBoxContainer/Switch Monster Button".toggled.emit(false)
