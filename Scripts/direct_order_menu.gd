extends PanelContainer

#@onready var buttons_container = $MarginContainer/ScrollContainer/VBoxContainer

@export var arena: Arena

@export var back_button: Button
@export var instructional_title: Label
@export var list: VBoxContainer

var player: Player
var monster_to_order: Monster
var move_to_order: Move
var target_for_move: Monster

var state: States

signal direct_order_complete(user: Monster, move: Move, target: Monster)

enum States \
{
	INACTIVE,
	CHOOSE_MONSTER_TO_ORDER,
	CHOOSE_MOVE_TO_ORDER,
	CHOOSE_TARGET_FOR_MOVE
}

class MonsterSelectButton extends Button:
	var monster: Monster
	signal pressed_pass(button: Button)
	
	func _init(_mon: Monster) -> void:
		monster = _mon
		text = monster.display_name
		pressed.connect(on_pressed)
	
	func on_pressed() -> void:
		pressed_pass.emit(self)

class MoveToOrderButton extends Button:
	var move: Move
	signal pressed_pass(button: Button)
	
	func _init(_move: Move) -> void:
		move = _move
		var av = " (AV: %s)" % move.av_cost if move.av_cost > 0 else ""
		var rv = " (RV: %s)" % move.rv_cost if move.rv_cost != 0 else ""
		var ct = " (CT: %s)" % move.ct_cost if move.ct_cost > 0 else ""
		text = move.move_name+av+rv+ct
		pressed.connect(on_pressed)
	
	func on_pressed() -> void:
		pressed_pass.emit(self)


func populate_buttons():
	for button in list.get_children(): button.queue_free()
	if state == States.CHOOSE_MONSTER_TO_ORDER:
		var team = arena.team_zero if player.team == 0 else arena.team_one
		for monster in team["actives"]:
			var button = MonsterSelectButton.new(monster)
			button.pressed_pass.connect(on_monster_select_button_pressed)
			list.add_child(button)
	elif state == States.CHOOSE_MOVE_TO_ORDER:
		for move in monster_to_order.stat_sheet.move_list:
			if not move is Action: continue
			var button = MoveToOrderButton.new(move)
			button.pressed_pass.connect(on_move_select_button_pressed)
			list.add_child(button)
	elif state == States.CHOOSE_TARGET_FOR_MOVE:
		var rival_team = arena.team_zero if player.team == 1 else arena.team_one
		for monster in rival_team["actives"]:
			var button = MonsterSelectButton.new(monster)
			button.pressed_pass.connect(on_monster_select_button_pressed)
			list.add_child(button)

func on_back_pressed() -> void:
	if state == States.CHOOSE_TARGET_FOR_MOVE:
		state = States.CHOOSE_MOVE_TO_ORDER
		move_to_order = null
		populate_buttons()
		return
	if state == States.CHOOSE_MOVE_TO_ORDER:
		state = States.CHOOSE_MONSTER_TO_ORDER
		monster_to_order = null
		populate_buttons()
		return
	if state == States.CHOOSE_MONSTER_TO_ORDER:
		state = States.INACTIVE
		visible = false
		populate_buttons()
		return

func on_monster_select_button_pressed(button: MonsterSelectButton) -> void:
	if state == States.CHOOSE_MONSTER_TO_ORDER:
		monster_to_order = button.monster
		state = States.CHOOSE_MOVE_TO_ORDER
		populate_buttons()
		return
	if state == States.CHOOSE_TARGET_FOR_MOVE:
		target_for_move = button.monster
		state = States.INACTIVE
		visible = false
		populate_buttons()
		monster_to_order.direct_order = move_to_order
		monster_to_order.direct_order_target = target_for_move
		direct_order_complete.emit(monster_to_order, move_to_order, target_for_move)
		return

func on_move_select_button_pressed(button: MoveToOrderButton) -> void:
	move_to_order = button.move
	state = States.CHOOSE_TARGET_FOR_MOVE
	populate_buttons()
