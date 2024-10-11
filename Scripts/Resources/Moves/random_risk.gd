#@tool #was trying to use to make the inspector clamp the min/max values but seems to be buggy
extends Resource
class_name RandomRisk

@export var move_type: EnumUtils.MoveTypes
@export var move_name: String
##The minimum value of the move. Only used for setting: Do not call this property, use amount instead. Setting this below 0 or above _max will produce unexpected results.
@export var _min: int
	#set(value):
		#_min = clamp(value, 0, _max)
##The maximum value of the move. Only used for setting: Do not call this property, use amount instead. Setting this below _min will produce unexpected results.
@export var _max: int
	#set(value):
		#_max = clamp(value, _min, INF)
var amount: int:
	get:
		return _min + randi() % (_max - _min + 1)

@export var av_cost: int ##Positive value indicates generation
@export var rv_cost: int ##Negative value indicates cost, positive value indicates generation
@export var ct_cost: int ##Positive value indicates generation
