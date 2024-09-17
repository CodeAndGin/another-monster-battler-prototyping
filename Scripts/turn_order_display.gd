extends PanelContainer

#External Refs
@export var battle_controller: Node

#Internal Refs
@onready var list = $MarginContainer/List

#Empty dictionary for Active Player and Active Monster references
var active_refs = \
	{
		"player1": null,
		"player2": null,
		"monster1" : null,
		"monster2" : null,
		"player1spell": null,
		"player2spell": null,
		"monster1spell": null,
		"monster2spell": null,
	}

func get_refs():
	active_refs["player1"] = battle_controller.active_refs["player1"]
	active_refs["player2"] = battle_controller.active_refs["player2"]
	active_refs["monster1"] = battle_controller.active_refs["monster1"]
	active_refs["monster2"] = battle_controller.active_refs["monster2"]
	active_refs["player1spell"] = battle_controller.move_container_refs["player1spell"].get_children()[0] if len(battle_controller.move_container_refs["player1spell"].get_children()) > 0 else null
	active_refs["player2spell"] = battle_controller.move_container_refs["player2spell"].get_children()[0] if len(battle_controller.move_container_refs["player2spell"].get_children()) > 0 else null
	active_refs["monster1spell"] = battle_controller.move_container_refs["monster1spell"].get_children()[0] if len(battle_controller.move_container_refs["monster1spell"].get_children()) > 0 else null
	active_refs["monster2spell"] = battle_controller.move_container_refs["monster2spell"].get_children()[0] if len(battle_controller.move_container_refs["monster2spell"].get_children()) > 0 else null

func populate_list(order):
	#clear list
	get_refs()
	for child in list.get_children():
		child.queue_free()
	var labels: Array
	for key in active_refs:
		if active_refs[key] != null:
			labels.append(Label.new())
	#var labels = [Label.new(), Label.new(), Label.new(), Label.new()]
	var turn_order = order
	for i in range(len(labels)):
		labels[i].text = active_refs[turn_order[i]].display_name + "; " + str(active_refs[turn_order[i]].action_value)
	for label in labels:
		list.add_child(label)
