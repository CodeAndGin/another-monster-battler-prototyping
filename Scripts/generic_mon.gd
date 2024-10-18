extends Node3D
class_name Monster

@export var stat_sheet: MonsterStats
@export var tactics_sheet: TacticsSetTemplate
var active_tactics_set_is_A = true
@export var arena: Arena

@export var type = "monster"
var monster_name: String
@export var display_name = ""

var own_key = ""
var opponent_key:
	get:
		return "player2monster" if own_key == "player1monster" else "player1monster"

var av = 0 #private container, do not use
var action_value:
	get:
		if casting:
			return av + connected_move_container.get_children()[0].action_value
		return av
	set(value):
		var change = value-action_value
		if change > 0:
			av += change
		if change < 0:
			if casting:
				if connected_move_container.get_children()[0].action_value + change >= 0:
					connected_move_container.get_children()[0].action_value += change
					return
				else:
					change += connected_move_container.get_children()[0].action_value
					connected_move_container.get_children()[0].action_value = 0
					av += change
					return
			av += change

var reaction_value: float
var MAX_RV: float
var overcapping_rv: bool

var MAX_HP: float
@export var hp: float

var risk_and_guard: float

var connected_move_container: Node3D
var casting = false
#@onready var generic_move = preload("res://Gameplay Scenes/generic_basic_move.tscn")

var move_list: Array

func test_tactics_set():
	if not tactics_sheet: return
	if FuncUtils.evaluate(tactics_sheet.setA["First"][0], FuncUtils.get_condition_variable_names(), FuncUtils.get_condition_variable_values(self, arena)):
		tactics_sheet.setA["First"][1].bespoke_effect.bespoke_effect()
	else:
		print("condition not met")

func _ready() -> void:
	if stat_sheet:
		MAX_HP = stat_sheet.MAX_HP
		MAX_RV = stat_sheet.MAX_RV
		reaction_value = stat_sheet.STARTING_RV
		overcapping_rv = stat_sheet.overcapping_rv
		monster_name = stat_sheet.monster_name
		move_list = stat_sheet.move_list
	if tactics_sheet:
		active_tactics_set_is_A = tactics_sheet.default_set_is_A
	#for i in range(50): move_list_scenes.append(generic_move)
	#for move in move_list_scenes:
	#	move_list.append(move.instantiate())
	#for i in len(move_list): move_list[i].move_name = "Test %s" % (i+1)

func check_connected_move_container(container: Node3D):
	return container == connected_move_container

func take_physical_damage():
	pass
