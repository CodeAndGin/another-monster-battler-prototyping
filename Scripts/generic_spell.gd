extends Node3D

@export var move_name: String
@export var av_cost: float
@export var rv_cost: float
@export var cast_time: float
@export var wound_amount: float
@export var damage_amount: float
@export var rally_amount: float
@export var heal_amount: float
@export var shield_amount: float
@export var target: String

@export var type = "cast"
@export var action_value: float #cast time left, name for compatibility
@export var display_name = ""

func cast_complete():
	queue_free()
