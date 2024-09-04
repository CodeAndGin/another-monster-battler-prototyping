extends Node3D

#Internal Refs
@onready var player_point_1 = $arena/PlayerPoint1
@onready var player_point_2 = $arena/PlayerPoint2
@onready var monster_point_1 = $arena/MonsterPoint1
@onready var monster_point_2 = $arena/MonsterPoint2
@onready var turn_order_display = $CanvasLayer/HUD/TurnOrderDisplay

@onready var av_input = $CanvasLayer/HUD/HBoxContainer/LineEdit
var test_button_ready = false
func _on_av_test_pressed() -> void:
	if test_button_ready:
		if av_input.text == "":
			print("please enter a number")
			return
		var going = active_refs[calculate_turn_order()[0]]
		going.action_value += av_input.text.to_int()
		regenerate_conflict_resolution(active_refs.find_key(going))
		test_button_ready = false
		if initial_order.size() > 0:
			initial_order.pop_front()
		turn_order_calculated.emit(calculate_turn_order())
		execute_turn()

func _on_button_random_pressed() -> void:
	if test_button_ready:
		var going = active_refs[calculate_turn_order()[0]]
		going.action_value += randi() % 7
		regenerate_conflict_resolution(active_refs.find_key(going))
		test_button_ready = false
		if initial_order.size() > 0:
			initial_order.pop_front()
		turn_order_calculated.emit(calculate_turn_order())
		execute_turn()

@onready var active_refs = \
	{
		"player1": null,
		"player2": null,
		"monster1": null,
		"monster2": null
	}:
		get:
			#regenerate active references in getter
			active_refs["player1"] = player_point_1.get_children()[0] if len(player_point_1.get_children()) > 0 else null
			active_refs["player2"] = player_point_2.get_children()[0] if len(player_point_2.get_children()) > 0 else null
			active_refs["monster1"] = monster_point_1.get_children()[0] if len(monster_point_1.get_children()) > 0 else null
			active_refs["monster2"] = monster_point_2.get_children()[0] if len(monster_point_2.get_children()) > 0 else null
			return active_refs
		set(value):
			pass

func _ready() -> void:
	turn_order_calculated.connect(turn_order_display.populate_list)
	generate_initial_order_random()
	turn_order_calculated.emit(calculate_turn_order())
	execute_turn()

func get_action_values() -> Dictionary:
	return {"player1": active_refs["player1"].action_value, \
			"player2": active_refs["player2"].action_value, \
			"monster1": active_refs["monster1"].action_value, \
			"monster2": active_refs["monster2"].action_value}

func execute_turn():
	var going = active_refs[calculate_turn_order()[0]]
	if going.action_value > 0:
		var av_to_reduce = going.action_value
		for actor in active_refs:
			active_refs[actor].action_value -= av_to_reduce
	test_button_ready = true

#region Turn Order Logic
var conflict_resolution_order = []
var initial_order = []

signal turn_order_calculated(order: Array)

func generate_initial_order_random():
	var actors = ["player1", "player2", "monster1", "monster2"]
	actors.shuffle()
	initial_order = actors.duplicate()

func regenerate_conflict_resolution(last_went):
	#Populates conflictResolutionOrder with the 4 keys in order of the least recent turn taker to the most
	if conflict_resolution_order.size() < 4:
		conflict_resolution_order.append(last_went)
		return
	conflict_resolution_order.erase(last_went)
	conflict_resolution_order.append(last_went)

func discover_av_conflicts(action_values):
	# returns an Array containing the keys ("player1", "player2", "monster1", "monster2")
	# of active actors that have the same action value. If there are 2 sets of action values that are equal
	# the Array contains both sets in indices 0,1 and 3,4, with the string "split" in index 2
	var conflicts = {}
	for act in action_values:
		for actor in action_values:
			if action_values[actor]==action_values[act] and act != actor and not conflicts.has(act):
				conflicts[act] = actor
	if conflicts.size()<=3:
		var newcon = []
		for key in conflicts:
			newcon.append(key)
		return newcon
	elif conflicts.size()==4:
		if action_values["player1"]==action_values["player2"] \
			and action_values["player2"]==action_values["monster1"] \
			and action_values["monster1"]==action_values["monster2"]:
				var newcon = []
				for key in conflicts:
					newcon.append(key)
				return newcon
		else:
			var newcon = ["", "", "split", "", ""]
			var i = 0
			for key in conflicts:
				if i == 2: i+=1
				if not newcon.has(key) and not newcon.has(conflicts[key]):
					newcon[i] = key
					i+=1
					newcon[i] = conflicts[key]
					i+=1
			return newcon

func calculate_turn_order() -> Array:
	var order = []
	var conflicts = discover_av_conflicts(get_action_values())
	#opening turn order
	if initial_order.size() == 4:
		order = initial_order.duplicate()
		#initial_order.pop_front()
		return order
	if initial_order.size() < 4 and initial_order.size() > 0:
		order = initial_order.duplicate()
		#initial_order.pop_front()
		order = turn_order_algorithm(order, conflicts, get_action_values())
		return order
	order = turn_order_algorithm(order, conflicts, get_action_values())
	turn_order_calculated.emit(order)
	return order

func turn_order_algorithm(order: Array, conflicts: Array, action_values: Dictionary) -> Array:
	while order.size() < 4:
		var lowest_av = INF
		var next = ""
		for key in action_values:
			var av = action_values[key]
			if order.has(key): continue
			if conflicts.size() == 4:
				av = conflict_resolution_order.find(key)
			elif conflicts.size() == 5:
				var a = conflicts.find(key)
				var b = 0
				if a == 0: b = 1
				elif a == 1: b = 0
				elif a == 3: b = 4
				elif a == 4: b = 3
				a = conflicts[a]
				b = conflicts[b]
				if conflict_resolution_order.find(a) > conflict_resolution_order.find(b):
					av+=0.01
			elif conflicts.has(key):
				var a = conflicts[0]
				var b = conflicts[1]
				var c = conflicts[2] if conflicts.size()==3 else null
				if c==null: #Hellish bit of math to order conflicts using the resolution array
					if conflict_resolution_order.find(a) > conflict_resolution_order.find(b):
						if key==a: av += 0.01
					else:
						if key==b: av += 0.01
				else: 
					if conflict_resolution_order.find(a)>conflict_resolution_order.find(b) \
					and conflict_resolution_order.find(a)>conflict_resolution_order.find(c):
						if conflict_resolution_order.find(b)>conflict_resolution_order.find(c): 
							if key==a: av += 0.02 
							elif key==b: av += 0.01
						else: 
							if key==a: av += 0.02 
							elif key==c: av += 0.01
					elif conflict_resolution_order.find(b)>conflict_resolution_order.find(a) \
					and conflict_resolution_order.find(b)>conflict_resolution_order.find(c):
						if conflict_resolution_order.find(a)>conflict_resolution_order.find(c): 
							if key==b: av += 0.02 
							elif key==a: av += 0.01
						else: 
							if key==b: av += 0.02 
							elif key==c: av += 0.01
					elif conflict_resolution_order.find(c)>conflict_resolution_order.find(a) \
					and conflict_resolution_order.find(c)>conflict_resolution_order.find(b):
						if conflict_resolution_order.find(a)>conflict_resolution_order.find(b): 
							if key==c: av += 0.02 
							elif key==a: av += 0.01
						else: 
							if key==c: av += 0.02 
							elif key==b: av += 0.01
					pass
			if av < lowest_av:
				lowest_av = av
				next = key
		order.append(next)
	return order

#endregion
