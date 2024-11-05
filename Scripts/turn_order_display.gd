extends PanelContainer

#External Refs
@export var battle_controller: Arena

#Internal Refs
@onready var list = $MarginContainer/List

func populate_list(order):
	#clear list
	#get_refs()
	for child in list.get_children():
		child.queue_free()
	var labels: Array
	for entry in order:
		labels.append(Label.new())
	#var labels = [Label.new(), Label.new(), Label.new(), Label.new()]
	for i in range(len(labels)):
		labels[i].text = order[i].display_name + "; " + str(order[i].action_value)
	for label in labels:
		list.add_child(label)
