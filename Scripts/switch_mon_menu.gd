extends PanelContainer

@onready var button1 = $MarginContainer/HBoxContainer/BenchMon1
@onready var button2 = $MarginContainer/HBoxContainer/BenchMon2
@export var icon_size: float

func _on_bench_mon_1_toggled(toggled_on: bool) -> void:
	button2.button_pressed = false if toggled_on else button2.button_pressed

func _on_bench_mon_2_toggled(toggled_on: bool) -> void:
	button1.button_pressed = false if toggled_on else button1.button_pressed

func populate_buttons(bench: Node3D):
	var bench_mons = bench.get_children()
	button1.text = bench_mons[0].display_name + " (AV: %s, RV: %s, DT: %s)" % [bench_mons[0].action_value, bench_mons[0].reaction_value, bench_mons[0].hp]
	button2.text = bench_mons[1].display_name + " (AV: %s, RV: %s, DT: %s)" % [bench_mons[1].action_value, bench_mons[1].reaction_value, bench_mons[1].hp]
