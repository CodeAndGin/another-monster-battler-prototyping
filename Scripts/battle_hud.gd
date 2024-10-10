extends Control

@onready var arena_root = $"../.."

var weird_scaling_fix_used = false

func _ready() -> void:
	$"Switch Mon Menu".populate_buttons($"../../arena/Bench1") #populate causes weird scaling on first use no idea why; this mitigates the issue
	reset_all_buttons()

func _on_direct_order_button_toggled(toggled_on: bool) -> void:
	if toggled_on: detoggle("Direct Order Menu")
	#test version that does work, but need to register which player is pressing somehow; we'll get there
	if arena_root.monster_point_1: $"Direct Order Menu".populate_buttons(arena_root.monster_point_1.get_children()[0].move_list)
	$"Direct Order Menu".visible = toggled_on

func _on_switch_monster_button_toggled(toggled_on: bool) -> void:
	if arena_root.going_actor_key == "player1":
		if toggled_on: detoggle("Switch Mon Menu")
		$"Switch Mon Menu".populate_buttons($"../../arena/Bench1")
		$"Switch Mon Menu".visible = toggled_on
	elif arena_root.going_actor_key == "player2":
		if toggled_on: detoggle("Switch Mon Menu")
		$"Switch Mon Menu".populate_buttons($"../../arena/Bench2")
		$"Switch Mon Menu".visible = toggled_on
	else:
		pass
		$"Player Buttons/MarginContainer/HBoxContainer/VBoxContainer/HBoxContainer/Switch Monster Button".button_pressed = false
		$"Switch Mon Menu".visible = false

func detoggle(active):
	if active == "Switch Mon Menu":
		$"Player Buttons/MarginContainer/HBoxContainer/VBoxContainer/HBoxContainer/Direct Order Button".button_pressed = false
		$"Player Buttons/MarginContainer/HBoxContainer/VBoxContainer/HBoxContainer/Direct Order Button".toggled.emit(false)
	elif active == "Direct Order Menu":
		$"Player Buttons/MarginContainer/HBoxContainer/VBoxContainer/HBoxContainer/Switch Monster Button".button_pressed = false
		$"Player Buttons/MarginContainer/HBoxContainer/VBoxContainer/HBoxContainer/Switch Monster Button".toggled.emit(false)

func _on_log_toggle_toggled(toggled_on: bool) -> void:
	#var labels = $EventDisplayLog/PanelContainer/MarginContainer/ScrollContainer/EventDisplayLogLabels
	if toggled_on:
		regenerate_log()
	$EventDisplayLog/PanelContainer.visible = toggled_on

func regenerate_log():
	var labels = $EventDisplayLog/PanelContainer/MarginContainer/ScrollContainer/EventDisplayLogLabels
	for label in labels.get_children():
		label.queue_free()
	var elog = arena_root.display_event_log.duplicate()
	elog.reverse()
	for entry in elog:
		var label = Label.new()
		label.text = entry
		label.horizontal_alignment=1
		labels.add_child(label)

func reset_all_buttons():
	$"Player Buttons/MarginContainer/HBoxContainer/VBoxContainer/HBoxContainer/Direct Order Button".button_pressed = false
	$"Player Buttons/MarginContainer/HBoxContainer/VBoxContainer/HBoxContainer/Direct Order Button".toggled.emit(false)
	$"Player Buttons/MarginContainer/HBoxContainer/VBoxContainer/HBoxContainer/Switch Monster Button".button_pressed = false
	$"Player Buttons/MarginContainer/HBoxContainer/VBoxContainer/HBoxContainer/Switch Monster Button".toggled.emit(false)
	$"Switch Mon Menu".button2.button_pressed = false
	$"Switch Mon Menu".button1.button_pressed = false

func _on_confirm_pressed() -> void:
	if $"Switch Mon Menu".button1.button_pressed:
		arena_root.swap_monster("monster1")
	if $"Switch Mon Menu".button2.button_pressed:
		arena_root.swap_monster("monster2")
	reset_all_buttons()
