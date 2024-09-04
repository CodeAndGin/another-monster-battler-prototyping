extends PanelContainer

@onready var buttons_container = $MarginContainer/ScrollContainer/VBoxContainer

func populate_buttons(move_list: Array):
	for button in buttons_container.get_children(): button.queue_free()
	for move in move_list:
		var button = Button.new()
		var av = " (AV: %s)" % move.av_cost if move.av_cost > 0 else ""
		var rv = " (RV: %s)" % move.rv_cost if move.rv_cost > 0 else ""
		var ct = " (CT: %s)" % move.cast_time if move.cast_time > 0 else ""
		button.text = move.move_name+av+rv+ct
		buttons_container.add_child(button)
	pass
