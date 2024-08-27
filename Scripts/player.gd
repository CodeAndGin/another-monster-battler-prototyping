extends Camera3D

#Export vars
@export var action_value = 0:
	get:
		return action_value
	set(value):
		action_value = value

@export var display_name = ""
