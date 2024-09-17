extends Node3D

#Export vars
@export var type = "monster"
@export var action_value = 0:
	get:
		if casting:
			return action_value + connected_move_container.get_children()[0].action_value
		return action_value
	set(value):
		if value < action_value and casting:
			connected_move_container.get_children()[0].action_value = connected_move_container.get_children()[0].action_value - (action_value - value)
			return
		action_value = value
@export var reaction_value: float
@export var display_name = ""
@export var max_health: float
@export var damage_taken: float
@export var vuln: float

#@onready var generic_move = preload("res://Gameplay Scenes/generic_basic_move.tscn")

@export var move_list_scenes: Array

var connected_move_container: Node3D
var casting = false
var move_list: Array

func _ready() -> void:
	#for i in range(50): move_list_scenes.append(generic_move)
	for move in move_list_scenes:
		move_list.append(move.instantiate())
	#for i in len(move_list): move_list[i].move_name = "Test %s" % (i+1)

func check_connected_move_container(container: Node3D):
	return container == connected_move_container
