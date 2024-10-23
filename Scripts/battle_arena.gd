extends Node3D
class_name Arena
##### Main Battle Logic #####

#### Variable and Signal Declarations ####

#region Static Node References
@onready var player_point_1 = $arena/PlayerPoint1
@onready var player_point_2 = $arena/PlayerPoint2
@onready var monster_point_player_1 = $arena/MonsterPoint1
@onready var monster_point_player_2 = $arena/MonsterPoint2
@onready var move_point_1 = $arena/MovePoint1
@onready var move_point_2 = $arena/MovePoint2
@onready var player_1_bench = $arena/Bench1
@onready var player_2_bench = $arena/Bench2
@onready var turn_order_display = $CanvasLayer/HUD/TurnOrderDisplay
@onready var hud = $CanvasLayer/HUD

#turn order testing
@onready var av_input = $CanvasLayer/HUD/HBoxContainer/LineEdit
@onready var cast_av_input = $CanvasLayer/HUD/CastSpellTester/CastAv
@onready var cast_ct_input = $CanvasLayer/HUD/CastSpellTester/CastCt

#event display and log
@onready var event_display = $CanvasLayer/HUD/EventDisplay
@onready var event_display_label = $CanvasLayer/HUD/EventDisplay/Label
@onready var event_display_timer = $CanvasLayer/HUD/EventDisplay/Timer
#endregion

#region Changeable Node Reference Dictionaries
@onready var active_refs = \
	{
		"player1": null,
		"player2": null,
		"player1monster": null,
		"player2monster": null
	}:
		get:
			#regenerate active references in getter
			active_refs["player1"] = player_point_1.get_children()[0] if len(player_point_1.get_children()) > 0 else null
			active_refs["player2"] = player_point_2.get_children()[0] if len(player_point_2.get_children()) > 0 else null
			active_refs["player1monster"] = monster_point_player_1.get_children()[0] if len(monster_point_player_1.get_children()) > 0 else null
			active_refs["player2monster"] = monster_point_player_2.get_children()[0] if len(monster_point_player_2.get_children()) > 0 else null
			return active_refs
		set(value):
			pass

@onready var move_container_refs = \
	{
		"player1spell": $arena/PlayerMovePoint1,
		"player2spell": $arena/PlayerMovePoint2,
		"player1monsterspell": $arena/MovePoint1,
		"player2monsterspell": $arena/MovePoint2
	}

@onready var bench_1_refs = \
	{
		"bmonster1": null, 
		"bmonster2": null
	}:
		get:
			bench_1_refs["bmonster1"] = player_1_bench.get_children()[0] if len(player_1_bench.get_children()) > 0 else null
			bench_1_refs["bmonster2"] = player_1_bench.get_children()[1] if len(player_1_bench.get_children()) > 1 else null
			return bench_1_refs
		set(value):
			pass

@onready var bench_2_refs = \
	{
		"bmonster1": null, 
		"bmonster2": null
	}:
		get:
			bench_2_refs["bmonster1"] = player_2_bench.get_children()[0] if len(player_2_bench.get_children()) > 0 else null
			bench_2_refs["bmonster2"] = player_2_bench.get_children()[1] if len(player_2_bench.get_children()) > 1 else null
			return bench_2_refs
		set(value):
			pass
#endregion

#region Signals
signal turn_begin(goer)
signal turn_complete
signal to_go_complete

signal round_begin
signal round_end
signal round_time_tick

signal turn_order_calculated(order: Array)
#endregion

#region Log storage
var display_event_queue: Array
var display_event_log: Array

##How many events to store in the event log. Unbounded if 0 or negative.
@export var display_event_log_max_size = INF:
	get:
		if display_event_log_max_size <= 0: return INF
		else: return  display_event_log_max_size
#endregion

#region Global variables used in round/turn resolution
var game_time = 0
@export var tick_time_length = 0.25 ##Amount of time the game waits between rounds, spells added to stack, etc.

var going_actor: Actor
var going_actor_key
var to_go: Array

var action_stack: Array
var after_action_stack: Array

var round_in_progress = false

var conflict_resolution_order = []
var spell_conflict_resolution_order = []
#endregion

##testing spell
@export var generic_spell: PackedScene
@export var test_move: Action

#### Functions ####

#region Ready and Process

func _ready() -> void:
	turn_order_calculated.connect(turn_order_display.populate_list)
	generate_initial_order_random()
	turn_order_calculated.emit(calculate_turn_order())
	#execute_turn()
	connect_move_containers()
	event_display_timer.wait_time = tick_time_length
	update_keys_on_monsters()

func test():
	print("tested")

func _process(_delta: float) -> void:
	#print(active_refs["player1monster"].sharpened if "sharpened" in active_refs["player1monster"] else null)#checks if the variable exists!!!
	if not round_in_progress:
		round_in_progress = true
		execute_round()
#endregion

#region Test Buttons Logic
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
		#var b = test_move.copy(active_refs["player1monster"], active_refs["player1monster"])
		#b.resolve()
		action_stack.pop_front()
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

func _on_strike_test_pressed() -> void:
	if test_button_ready:
		display_event_description(going_actor.display_name + " used " + going_actor.move_list[0].move_name)
		going_actor.move_list[0].add_to_action_stack(self, going_actor, active_refs[going_actor.opponent_key])
		resolve_action_stack()
		test_button_ready = false
		going_actor = null
		going_actor_key = null
		turn_order_calculated.emit(calculate_turn_order())
		turn_complete.emit()

#endregion

#region Utils
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

func get_action_values() -> Dictionary:
	return {"player1": active_refs["player1"].action_value, \
			"player2": active_refs["player2"].action_value, \
			"player1monster": active_refs["player1monster"].action_value, \
			"player2monster": active_refs["player2monster"].action_value}

func update_keys_on_monsters():
	for key in active_refs:
		if key.contains("monster"):
			active_refs[key].own_key = key
	for key in bench_1_refs:
		bench_1_refs[key].own_key = key
	for key in bench_2_refs:
		bench_2_refs[key].own_key = key

#endregion

#region Round and Turn Logic
func execute_round():
	#round start
	round_begin.emit()
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
	round_end.emit() #burn happens here
	#tick time
	round_time_tick.emit()
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
	turn_begin.emit(going_actor)
	test_button_ready = true
	display_event_description(going_actor.display_name + "'s turn")
	print(going_actor.display_name + "'s turn")

func add_move_to_stack(move: Move):
	action_stack.append(move)
	move.simulated_resolve()

func resolve_action_stack():
	#placeholder code for test spells
	while len(action_stack) > 0:
		var action = action_stack.pop_back()
		action.resolve()

func resolve_after_action_stack():
	pass
#endregion

#region Event Display and Logging
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
#endregion

#region Turn Order Computation
func generate_initial_order_random():
	var actors = ["player1", "player2", "player1monster", "player2monster"]
	actors.shuffle()
	conflict_resolution_order = actors.duplicate()

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

func calculate_turn_order() -> Array:
	var order = []
	order = better_turn_order_algorithm(order, conflict_resolution_order)
	turn_order_calculated.emit(order)
	return order

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
		active_refs_key = "player1monster"
		active_point = monster_point_player_1
		bench = player_1_bench
		bench_refs = bench_1_refs
	elif going_actor_key == "player2":
		active_refs_key = "player2monster"
		active_point = monster_point_player_2
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
	
	update_keys_on_monsters()
	
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
