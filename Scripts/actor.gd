extends Node3D
class_name Actor

@export var arena: Arena
@export var type: EnumUtils.ActorTypes
@export var default_name: String
@export var display_name: String

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

var rv: int
var MAX_RV: int
var overcapping_rv: bool

var connected_move_container: Node3D
var casting = false
#@onready var generic_move = preload("res://Gameplay Scenes/generic_basic_move.tscn")

func check_connected_move_container(container: Node3D) -> bool:
	return container == connected_move_container

func find_arena():
	arena = get_tree().root.get_node("BattleArena")

func _ready() -> void:
	if arena:
		if arena.name != "BattleArena":
			find_arena()
	if not arena: find_arena()

func gain_shield(amount: int): #TODO: implement shield
	pass
