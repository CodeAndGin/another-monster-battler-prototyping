extends Camera3D

@export var type = "player"

#Export vars
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

var connected_move_container: Node3D
var casting = false
@export var display_name = ""
