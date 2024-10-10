extends Node3D

#Internal Refs
@onready var player_point_1 = $arena/PlayerPoint1
@onready var player_point_2 = $arena/PlayerPoint2
@onready var monster_point_1 = $arena/MonsterPoint1
@onready var monster_point_2 = $arena/MonsterPoint2
@onready var move_point_1 = $arena/MovePoint1
@onready var move_point_2 = $arena/MovePoint2
@onready var turn_order_display = $CanvasLayer/HUD/TurnOrderDisplay
@onready var hud = $CanvasLayer/HUD

@onready var player_1_bench = $arena/Bench1
@onready var player_2_bench = $arena/Bench2

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

@onready var move_container_refs = \
	{
		"player1spell": $arena/PlayerMovePoint1,
		"player2spell": $arena/PlayerMovePoint2,
		"monster1spell": $arena/MovePoint1,
		"monster2spell": $arena/MovePoint2
	}

@onready var bench_1_refs = \
	{
		"monster1": null, 
		"monster2": null
	}:
		get:
			bench_1_refs["monster1"] = player_1_bench.get_children()[0] if len(player_1_bench.get_children()) > 0 else null
			bench_1_refs["monster2"] = player_1_bench.get_children()[1] if len(player_1_bench.get_children()) > 1 else null
			return bench_1_refs
		set(value):
			pass

@onready var bench_2_refs = \
	{
		"monster1": null, 
		"monster2": null
	}:
		get:
			bench_2_refs["monster1"] = player_2_bench.get_children()[0] if len(player_2_bench.get_children()) > 0 else null
			bench_2_refs["monster2"] = player_2_bench.get_children()[1] if len(player_2_bench.get_children()) > 1 else null
			return bench_2_refs
		set(value):
			pass

#turn order testing
@onready var av_input = $CanvasLayer/HUD/HBoxContainer/LineEdit
@onready var cast_av_input = $CanvasLayer/HUD/CastSpellTester/CastAv
@onready var cast_ct_input = $CanvasLayer/HUD/CastSpellTester/CastCt

#event display and log
@onready var event_display = $CanvasLayer/HUD/EventDisplay
@onready var event_display_label = $CanvasLayer/HUD/EventDisplay/Label
@onready var event_display_timer = $CanvasLayer/HUD/EventDisplay/Timer
var display_event_queue: Array
var display_event_log: Array
@export var display_event_log_max_size = INF

#testing spell
@export var generic_spell: PackedScene

var round_in_progress = false

var game_time = 0
@export var tick_time_length = 0.25

var going_actor
var going_actor_key
var to_go: Array

var action_stack: Array
var after_action_stack: Array

signal turn_complete
signal to_go_complete

signal round_begin
signal round_end
signal round_time_tick


#region Test Buttons
var test_button_ready = false
func _on_av_test_pressed() -> void:
	if test_button_ready:
		if av_input.text == "" or av_input.text == "0":
			display_event_description(active_refs[going_actor_key].display_name + " used an instant move; they may go again.")
			#print("please enter a number")
			return
		regenerate_conflict_resolution(going_actor_key)
		going_actor.action_value += av_input.text.to_int()
		display_event_description(active_refs[going_actor_key].display_name + " used a " + av_input.text + " AV move.")
		test_button_ready = false
		going_actor = null
		going_actor_key = null
		calculate_turn_order()
		turn_complete.emit()
		#var going = active_refs[calculate_turn_order()[0]]
		#going.action_value += av_input.text.to_int()
		#regenerate_conflict_resolution(active_refs.find_key(going))
		#test_button_ready = false
		##if initial_order.size() > 0:
			##initial_order.pop_front()
		#turn_order_calculated.emit(calculate_turn_order())
		#execute_turn()

func _on_button_random_pressed() -> void:
	if test_button_ready:
		var new_av = randi() % 7 + 1
		regenerate_conflict_resolution(going_actor_key)
		going_actor.action_value += new_av
		display_event_description(active_refs[going_actor_key].display_name + " used a " + str(new_av) + " AV move.")
		test_button_ready = false
		going_actor = null
		going_actor_key = null
		turn_order_calculated.emit(calculate_turn_order())
		turn_complete.emit()
		#var going = active_refs[calculate_turn_order()[0]]
		#going.action_value += randi() % 7
		#regenerate_conflict_resolution(active_refs.find_key(going))
		#test_button_ready = false
		##if initial_order.size() > 0:
			##initial_order.pop_front()
		#turn_order_calculated.emit(calculate_turn_order())
		#execute_turn()

func _on_cast_pressed() -> void:
	if test_button_ready:
		if cast_av_input.text == "" or cast_ct_input.text == "":
			display_event_description("please enter a number")
			print("please enter a number")
			return
		display_event_description(active_refs[going_actor_key].display_name + " began casting a " + cast_av_input.text + " AV and " + cast_ct_input.text + " CT spell.")
		regenerate_conflict_resolution(going_actor_key)
		
		going_actor.action_value += cast_av_input.text.to_int()
		var new_spell = generic_spell.instantiate()
		move_container_refs[going_actor_key+"spell"].add_child(new_spell)
		new_spell.action_value = cast_ct_input.text.to_int()
		new_spell.display_name = going_actor.display_name + "'s Spell"
		going_actor.casting = true
		spell_conflict_resolution_order.append(going_actor_key+"spell")
		test_button_ready = false
		going_actor = null
		going_actor_key = null
		turn_order_calculated.emit(calculate_turn_order())
		turn_complete.emit()
		#var going_key = calculate_turn_order()[0]
		#var going = active_refs[going_key]
		#going.action_value += cast_av_input.text.to_int()
		#
		#var new_spell = generic_spell.instantiate()
		#move_container_refs[going_key+"spell"].add_child(new_spell)
		##print(move_container_refs[going_key+"spell"].get_children())
		#new_spell.action_value = cast_ct_input.text.to_int()
		#new_spell.display_name = going.display_name + "'s Spell"
		#going.casting = true
		#spell_conflict_resolution_order.append(going_key+"spell")
		#regenerate_conflict_resolution(active_refs.find_key(going))
		#test_button_ready = false
		##if initial_order.size() > 0:
			##initial_order.pop_front()
		#turn_order_calculated.emit(calculate_turn_order())
		#execute_turn()
#endregion

func connect_move_containers():
	for key in active_refs:
		active_refs[key].connected_move_container = move_container_refs[key + "spell"]
		#print(active_refs[key].connected_move_container)

func get_active_spells():
	var active_spells: Dictionary
	for key in move_container_refs:
		if len(move_container_refs[key].get_children()) > 0:
			active_spells.get_or_add(key, move_container_refs[key].get_children()[0])
	return active_spells

func _ready() -> void:
	turn_order_calculated.connect(turn_order_display.populate_list)
	generate_initial_order_random()
	turn_order_calculated.emit(calculate_turn_order())
	#execute_turn()
	connect_move_containers()
	event_display_timer.wait_time = tick_time_length

func _process(delta: float) -> void:
	if not round_in_progress:
		round_in_progress = true
		execute_round()

func get_action_values() -> Dictionary:
	return {"player1": active_refs["player1"].action_value, \
			"player2": active_refs["player2"].action_value, \
			"monster1": active_refs["monster1"].action_value, \
			"monster2": active_refs["monster2"].action_value}

#func execute_turn():
	##print(calculate_turn_order()[0])
	#var going_key = calculate_turn_order()[0]
	#var going = null
	#if going_key.contains("spell"):
		#going = get_active_spells()[going_key]
	#else:
		#going = active_refs[going_key]
	#if going.action_value > 0:
		#var av_to_reduce = going.action_value
		#for actor in active_refs:
			#active_refs[actor].action_value -= av_to_reduce
	#if going_key.contains("spell"):
		#display_event_description(going.display_name + " has been cast")
		#print(going.display_name + " has been cast")
		#going.cast_complete()
		#spell_conflict_resolution_order.pop_front()
		#for n in move_container_refs[going_key].get_children(): move_container_refs[going_key].remove_child(n)
		#var caster = going_key.replace("spell", "")
		#active_refs[caster].casting = false
		#calculate_turn_order()
		##print(calculate_turn_order()[0])
		#execute_turn()
		#return
	#test_button_ready = true
	#display_event_description(active_refs[going_key].display_name + "'s turn")
	#print(active_refs[going_key].display_name + "'s turn")
	#calculate_turn_order()

func execute_round():
	#round start
	#do player/monster turns
	#starts calling for player/monster turns
	#Boolean to catch if no turns occuring, as the await hangs otherwise 
	#(unsure why, might be a timing thing)
	var need_to_wait = false
	generate_to_go()
	if len(to_go)>0: need_to_wait = true
	execute_to_go()
	if need_to_wait: await to_go_complete
	#round end
	#tick time
	game_time += 1 #currently unused but good to have
	for actor in active_refs:
		active_refs[actor].action_value -= 1
		#print(active_refs[actor].action_value)
	calculate_turn_order()
	#do spells and channels (channels todo)
	for i in len(spell_conflict_resolution_order):
		if len(spell_conflict_resolution_order) > 0:
			if get_active_spells()[spell_conflict_resolution_order[0]].action_value <= 0:
				action_stack.append(spell_conflict_resolution_order.pop_front())
				calculate_turn_order()
				await get_tree().create_timer(tick_time_length).timeout
			else: break
	if len(action_stack) > 0:
		resolve_action_stack()
	#cleanup
	await get_tree().create_timer(tick_time_length).timeout
	round_in_progress = false

func generate_to_go():
	#generates a queue of 0AV simultaneous turns
	var t_order: Array
	to_go = []
	for turn in calculate_turn_order(): #decouple spells from the order
		if not turn.contains("spell"):
			t_order.append(turn)
	for actor in t_order:
		if get_action_values()[actor] == 0:
			to_go.append(actor)

func execute_to_go():
	#Calls for turns in to_go queue order. *Should* be fine with to_go changing during its execution thanks to the while loop and await
	while len(to_go) > 0:
		execute_new_turn(to_go.pop_front())
		await turn_complete
	to_go_complete.emit()

func execute_new_turn(actor: String):
	going_actor_key = actor
	going_actor = active_refs[going_actor_key]
	test_button_ready = true
	display_event_description(going_actor.display_name + "'s turn")
	print(going_actor.display_name + "'s turn")

func resolve_action_stack():
	#placeholder code for test spells
	while len(action_stack) > 0:
		var action_key = action_stack.pop_back()
		if action_key.contains("spell"):
			var action = get_active_spells()[action_key]
			display_event_description(action.display_name + " has been cast")
			print(action.display_name + " has been cast")
			action.cast_complete()
			for n in move_container_refs[action_key].get_children(): move_container_refs[action_key].remove_child(n)
			var caster = action_key.replace("spell", "")
			active_refs[caster].casting = false

func resolve_after_action_stack():
	pass

func display_event_log_append_and_truncate(text: String):
	display_event_log.append(text)
	while len(display_event_log) > display_event_log_max_size:
		display_event_log.pop_front()

func display_event_description(text: String):
	display_event_queue.append(text)
	if event_display_timer.time_left > 0: return
	while len(display_event_queue) > 0:
		#if event_display_timer.time_left > 0: await event_display_timer.timeout
		var t = display_event_queue.pop_front()
		display_event_log_append_and_truncate(t)
		hud.regenerate_log()
		event_display_label.text = t
		event_display.show()
		event_display_timer.start()
		await event_display_timer.timeout
		event_display.hide()
		event_display_label.text = ""

#region Turn Order Logic
var conflict_resolution_order = []
#var initial_order = []
var spell_conflict_resolution_order = []

signal turn_order_calculated(order: Array)

func generate_initial_order_random():
	var actors = ["player1", "player2", "monster1", "monster2"]
	actors.shuffle()
	conflict_resolution_order = actors.duplicate()
	#initial_order = actors.duplicate()

func regenerate_conflict_resolution(last_went):
	#Populates conflictResolutionOrder with the 4 keys in order of the least recent turn taker to the most
	if conflict_resolution_order.size() < 4:
		conflict_resolution_order.append(last_went)
		return
	conflict_resolution_order.erase(last_went)
	conflict_resolution_order.append(last_went)

func better_turn_order_algorithm(order: Array, cro: Array):
	var avs = []
	
	var spells = spell_conflict_resolution_order.duplicate()
	if len(spells)>0:
		for key in spells:
			avs.append([key, get_active_spells()[key].action_value])
	
	for key in cro:
		avs.append([key, get_action_values()[key]])
	
	avs.sort_custom(\
	func(a, b):
		return a[1] < b[1]
	)
	
	for a in avs:
		if order.has(a[0]): continue
		order.append(a[0])
	return order

#func discover_av_conflicts(action_values):
	## returns an Array containing the keys ("player1", "player2", "monster1", "monster2")
	## of active actors that have the same action value. If there are 2 sets of action values that are equal
	## the Array contains both sets in indices 0,1 and 3,4, with the string "split" in index 2
	#var conflicts = {}
	#for act in action_values:
		#for actor in action_values:
			#if action_values[actor]==action_values[act] and act != actor and not conflicts.has(act):
				#conflicts[act] = actor
	#if conflicts.size()<=3:
		#var newcon = []
		#for key in conflicts:
			#newcon.append(key)
		#return newcon
	#elif conflicts.size()==4:
		#if action_values["player1"]==action_values["player2"] \
			#and action_values["player2"]==action_values["monster1"] \
			#and action_values["monster1"]==action_values["monster2"]:
				#var newcon = []
				#for key in conflicts:
					#newcon.append(key)
				#return newcon
		#else:
			#var newcon = ["", "", "split", "", ""]
			#var i = 0
			#for key in conflicts:
				#if i == 2: i+=1
				#if not newcon.has(key) and not newcon.has(conflicts[key]):
					#newcon[i] = key
					#i+=1
					#newcon[i] = conflicts[key]
					#i+=1
			#return newcon

func calculate_turn_order() -> Array:
	var order = []
	#if initial_order.size() == 4:
		#order = initial_order.duplicate()
		#return order
	#if initial_order.size() < 4 and initial_order.size() > 0:
		#order = initial_order.duplicate()
		##initial_order.pop_front()
		#order = better_turn_order_algorithm(order, conflict_resolution_order)
		#return order
	order = better_turn_order_algorithm(order, conflict_resolution_order)
	turn_order_calculated.emit(order)
	return order
	##############Old Version Below################
	#var conflicts = discover_av_conflicts(get_action_values())
	##opening turn order
	#if initial_order.size() == 4:
		#order = initial_order.duplicate()
		##initial_order.pop_front()
		#return order
	#if initial_order.size() < 4 and initial_order.size() > 0:
		#order = initial_order.duplicate()
		##initial_order.pop_front()
		#order = turn_order_algorithm(order, conflicts, get_action_values())
		#return order
	#order = turn_order_algorithm(order, conflicts, get_action_values())
	#turn_order_calculated.emit(order)
	#return order

#func turn_order_algorithm(order: Array, conflicts: Array, action_values: Dictionary) -> Array:
	#while order.size() < 4:
		#var lowest_av = INF
		#var next = ""
		#for key in action_values:
			#var av = action_values[key]
			#if order.has(key): continue
			#if conflicts.size() == 4:
				#av = conflict_resolution_order.find(key)
			#elif conflicts.size() == 5:
				#var a = conflicts.find(key)
				#var b = 0
				#if a == 0: b = 1
				#elif a == 1: b = 0
				#elif a == 3: b = 4
				#elif a == 4: b = 3
				#a = conflicts[a]
				#b = conflicts[b]
				#if conflict_resolution_order.find(a) > conflict_resolution_order.find(b):
					#av+=0.01
			#elif conflicts.has(key):
				#var a = conflicts[0]
				#var b = conflicts[1]
				#var c = conflicts[2] if conflicts.size()==3 else null
				#if c==null: #Hellish bit of math to order conflicts using the resolution array
					#if conflict_resolution_order.find(a) > conflict_resolution_order.find(b):
						#if key==a: av += 0.01
					#else:
						#if key==b: av += 0.01
				#else: 
					#if conflict_resolution_order.find(a)>conflict_resolution_order.find(b) \
					#and conflict_resolution_order.find(a)>conflict_resolution_order.find(c):
						#if conflict_resolution_order.find(b)>conflict_resolution_order.find(c): 
							#if key==a: av += 0.02 
							#elif key==b: av += 0.01
						#else: 
							#if key==a: av += 0.02 
							#elif key==c: av += 0.01
					#elif conflict_resolution_order.find(b)>conflict_resolution_order.find(a) \
					#and conflict_resolution_order.find(b)>conflict_resolution_order.find(c):
						#if conflict_resolution_order.find(a)>conflict_resolution_order.find(c): 
							#if key==b: av += 0.02 
							#elif key==a: av += 0.01
						#else: 
							#if key==b: av += 0.02 
							#elif key==c: av += 0.01
					#elif conflict_resolution_order.find(c)>conflict_resolution_order.find(a) \
					#and conflict_resolution_order.find(c)>conflict_resolution_order.find(b):
						#if conflict_resolution_order.find(a)>conflict_resolution_order.find(b): 
							#if key==c: av += 0.02 
							#elif key==a: av += 0.01
						#else: 
							#if key==c: av += 0.02 
							#elif key==b: av += 0.01
					#pass
			#if av < lowest_av:
				#lowest_av = av
				#next = key
		#order.append(next)
	#return order

#endregion

#region Switching Monsters Logic

func swap_monster(monster_to_swap: String): #for player swapping; either a refactor or seperate function necessary for Tornado
	#declarations
	var bench
	var bench_refs
	var active_point
	var active_refs_key
	
	#check who's going and assign variables accordingly
	if going_actor_key == "player1":
		active_refs_key = "monster1"
		active_point = monster_point_1
		bench = player_1_bench
		bench_refs = bench_1_refs
	elif going_actor_key == "player2":
		active_refs_key = "monster2"
		active_point = monster_point_2
		bench = player_2_bench
		bench_refs = bench_2_refs
	if bench == null or bench_refs == null: return #just return if the variable assignments go funny; todo better error management
	
	#announce action
	display_event_description(active_refs[going_actor_key].display_name + " switches out " + active_refs[active_refs_key].display_name + " for " + bench_refs[monster_to_swap].display_name + ".")
	
	#declare and assign what's being moved
	var out_mon = active_refs[active_refs_key]
	var in_mon = bench_refs[monster_to_swap]
	var out_pos = out_mon.position
	var in_pos = in_mon.position
	
	#interrupt spells
	if out_mon.casting:
		display_event_description(out_mon.display_name + "'s spell was interrupted")
		out_mon.casting = false
		spell_conflict_resolution_order.erase(active_refs_key+"spell")
		out_mon.connected_move_container.get_children()[0].queue_free()
	
	#swap parents and positions
	active_point.remove_child(out_mon)
	bench.remove_child(in_mon)
	active_point.add_child(in_mon)
	bench.add_child(out_mon)
	out_mon.position = in_pos
	in_mon.position = out_pos
	
	#cleanup move containers
	out_mon.connected_move_container = null
	connect_move_containers()
	
	#update AVs and turn order neccesary stuff
	going_actor.action_value += 3
	regenerate_conflict_resolution(going_actor_key)
	regenerate_conflict_resolution(active_refs_key)
	
	#regenerate to_go in case of a 0AV swap
	generate_to_go()
	
	#end of turn cleanup
	test_button_ready = false
	going_actor = null
	going_actor_key = null
	calculate_turn_order()
	turn_complete.emit()

#endregion
