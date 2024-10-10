extends Node3D

#Export vars
@export var type = "monster"
@export var av = 0

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
