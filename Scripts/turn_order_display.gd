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
		"monster2" : null
	}

func get_refs():
	active_refs = battle_controller.active_refs

func populate_list(order):
	#clear list
	for child in list.get_children():
		child.queue_free()
	var labels = [Label.new(), Label.new(), Label.new(), Label.new()]
	var turn_order = order
	get_refs()
	for i in range(4):
		labels[i].text = active_refs[turn_order[i]].display_name + "; " + str(active_refs[turn_order[i]].action_value)
	for label in labels:
		list.add_child(label)
