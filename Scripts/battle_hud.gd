extends Control

@onready var arena_root: Arena = $"../.."
@onready var switch_mon_menu = $"Switch Mon Menu"
@onready var switch_mon_button = $"Player Buttons/MarginContainer/HBoxContainer/VBoxContainer/HBoxContainer/Switch Monster Button"
@onready var direct_order_menu = $"Direct Order Menu"
@onready var direct_order_button = $"Player Buttons/MarginContainer/HBoxContainer/VBoxContainer/HBoxContainer/Direct Order Button"
@onready var healthbars = $Healthbars
var weird_scaling_fix_used = false

func _process(delta: float) -> void:
	update_healthbars()

func _ready() -> void:
	switch_mon_menu.populate_buttons($"../../arena/Bench1") #populate causes weird scaling on first use no idea why; this mitigates the issue
	#reset_all_buttons()

func _on_direct_order_button_toggled(toggled_on: bool) -> void:
	if toggled_on: detoggle("Direct Order Menu")
	#test version that does work, but need to register which player is pressing somehow; we'll get there
	if arena_root.monster_point_player_1: direct_order_menu.populate_buttons(arena_root.monster_point_player_1.get_children()[0].move_list)
	direct_order_menu.visible = toggled_on

func _on_switch_monster_button_toggled(toggled_on: bool) -> void:
	if arena_root.teams[0]["players"].has(arena_root.going_actor):#arena_root.going_actor_key == "player1":
		if toggled_on: detoggle("Switch Mon Menu")
		switch_mon_menu.populate_buttons(arena_root.player_1_bench)
		switch_mon_menu.visible = toggled_on
	elif arena_root.teams[1]["players"].has(arena_root.going_actor):
		if toggled_on: detoggle("Switch Mon Menu")
		switch_mon_menu.populate_buttons(arena_root.player_2_bench)
		switch_mon_menu.visible = toggled_on
	else:
		pass
		switch_mon_button.button_pressed = false
		switch_mon_menu.visible = false

func detoggle(active):
	if active == "Switch Mon Menu":
		direct_order_button.button_pressed = false
		direct_order_button.toggled.emit(false)
	elif active == "Direct Order Menu":
		switch_mon_button.button_pressed = false
		switch_mon_button.toggled.emit(false)

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
	direct_order_button.button_pressed = false
	direct_order_button.toggled.emit(false)
	switch_mon_button.button_pressed = false
	switch_mon_button.toggled.emit(false)
	switch_mon_menu.button2.button_pressed = false
	switch_mon_menu.button1.button_pressed = false

func _on_confirm_pressed() -> void:
	if switch_mon_menu.button1.button_pressed:
		arena_root.swap_monster(arena_root.teams[arena_root.going_actor.team]["benched"][0])
	if switch_mon_menu.button2.button_pressed:
		arena_root.swap_monster(arena_root.teams[arena_root.going_actor.team]["benched"][1])
	reset_all_buttons()


func _on_battle_arena_turn_begin(goer: Variant) -> void:
	$strikeTest.visible = false
	if goer is Monster:
		$strikeTest.visible = true

func update_healthbars():
	healthbars.get_node("P1/MonHealthBar1").draw_bar(
	arena_root.teams[0]["actives"][0].display_name, 
	arena_root.teams[0]["actives"][0].hp, 
	arena_root.teams[0]["actives"][0].MAX_HP)
	healthbars.get_node("P1/MonHealthBar2").draw_bar(
	arena_root.teams[0]["benched"][0].display_name, 
	arena_root.teams[0]["benched"][0].hp, 
	arena_root.teams[0]["benched"][0].MAX_HP)
	healthbars.get_node("P1/MonHealthBar3").draw_bar(
	arena_root.teams[0]["benched"][1].display_name, 
	arena_root.teams[0]["benched"][1].hp, 
	arena_root.teams[0]["benched"][1].MAX_HP)
	healthbars.get_node("P2/MonHealthBar1").draw_bar(
	arena_root.teams[1]["actives"][0].display_name, 
	arena_root.teams[1]["actives"][0].hp, 
	arena_root.teams[1]["actives"][0].MAX_HP)
	healthbars.get_node("P2/MonHealthBar2").draw_bar(
	arena_root.teams[1]["benched"][0].display_name, 
	arena_root.teams[1]["benched"][0].hp, 
	arena_root.teams[1]["benched"][0].MAX_HP)
	healthbars.get_node("P2/MonHealthBar3").draw_bar(
	arena_root.teams[1]["benched"][1].display_name, 
	arena_root.teams[1]["benched"][1].hp, 
	arena_root.teams[1]["benched"][1].MAX_HP)
