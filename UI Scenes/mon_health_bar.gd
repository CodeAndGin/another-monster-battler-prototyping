extends PanelContainer
@export var name_box: Label
@export var health_bar: ProgressBar
@export var amount: Label

func draw_bar(_name: String, curr: int, max: int):
	name_box.text = _name
	health_bar.value = curr
	health_bar.min_value = 0
	health_bar.max_value = max
	amount.text = str(curr) + "/" + str(max)
