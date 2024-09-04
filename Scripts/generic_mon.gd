extends Node3D

#Export vars
@export var action_value = 0:
	get:
		return action_value
	set(value):
		action_value = value
@export var display_name = ""
@export var max_health = 20
@export var move_list_scenes: Array

var move_list: Array

func _ready() -> void:
	for move in move_list_scenes:
		move_list.append(move.instantiate())
