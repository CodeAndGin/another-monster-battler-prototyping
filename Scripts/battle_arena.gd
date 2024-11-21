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
@onready var team_zero: Dictionary:
	get:
		return \
		{
			"players": player_point_1.get_children() if len(player_point_1.get_children()) > 0 else [],
			"actives": monster_point_player_1.get_children() if len(monster_point_player_1.get_children()) > 0 else [],
			"benched": player_1_bench.get_children() if len(player_1_bench.get_children()) > 0 else []
		}
@onready var team_one: Dictionary:
	get:
		return \
		{
			"players": player_point_2.get_children() if len(player_point_2.get_children()) > 0 else [],
			"actives": monster_point_player_2.get_children() if len(monster_point_player_2.get_children()) > 0 else [],
			"benched": player_2_bench.get_children() if len(player_2_bench.get_children()) > 0 else []
		}
@onready var teams: 
	get: return [team_zero, team_one]
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
#var going_actor_key
var to_go: Array

var action_stack: Array
var after_action_stack: Array

var queue: EventQueue

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
	#connect_move_containers()
	event_display_timer.wait_time = tick_time_length
	#update_keys_on_monsters() #Could be depricated?
	set_point_references_on_actors()
	connect_signals()

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
			display_event_description(going_actor.display_name + " used an instant move; they may go again.")
			#print("please enter a number")
			return
		regenerate_conflict_resolution(going_actor)
		going_actor.action_value += av_input.text.to_int()
		display_event_description(going_actor.display_name + " used a " + av_input.text + " AV move.")
		turn_cleanup()
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
		regenerate_conflict_resolution(going_actor)
		going_actor.action_value += new_av
		display_event_description(going_actor.display_name + " used a " + str(new_av) + " AV move.")
		get_tree().create_timer(tick_time_length).timeout
		turn_cleanup()
		#var going = active_refs[calculate_turn_order()[0]]
		#going.action_value += randi() % 7
		#regenerate_conflict_resolution(active_refs.find_key(going))
		#test_button_ready = false
		##if initial_order.size() > 0:
			##initial_order.pop_front()
		#turn_order_calculated.emit(calculate_turn_order())
		#execute_turn()

func _on_cast_pressed() -> void:
	pass
	#if test_button_ready:
		#if cast_av_input.text == "" or cast_ct_input.text == "":
			#display_event_description("please enter a number")
			#print("please enter a number")
			#return
		#display_event_description(active_refs[going_actor_key].display_name + " began casting a " + cast_av_input.text + " AV and " + cast_ct_input.text + " CT spell.")
		#regenerate_conflict_resolution(going_actor_key)
		#
		#going_actor.action_value += cast_av_input.text.to_int()
		#var new_spell = generic_spell.instantiate()
		#move_container_refs[going_actor_key+"spell"].add_child(new_spell)
		#new_spell.action_value = cast_ct_input.text.to_int()
		#new_spell.display_name = going_actor.display_name + "'s Spell"
		#going_actor.casting = true
		#spell_conflict_resolution_order.append(going_actor_key+"spell")
		#turn_cleanup()

func _on_strike_test_pressed() -> void:
	if test_button_ready:
		display_event_description(going_actor.display_name + " used " + going_actor.move_list[0].move_name)
		going_actor.move_list[0].add_to_action_stack(self, going_actor, teams[(going_actor.team-1)%1]["actives"][0])
		resolve_action_stack()
		turn_cleanup()

func on_player_direct_order(user: Monster, move: Move, target: Monster) -> void:
	display_event_description(going_actor.display_name + " ordered " + user.display_name + " to use " + move.move_name + " on " + target.display_name)
	going_actor.av += 3
	regenerate_conflict_resolution(going_actor)
	await get_tree().create_timer(tick_time_length).timeout
	turn_cleanup()
#endregion

#region Utils
#TODO: Rework with better, newer spell handler
#func get_active_spells():
	#var active_spells: Dictionary
	#for key in move_container_refs:
		#if len(move_container_refs[key].get_children()) > 0:
			#active_spells.get_or_add(key, move_container_refs[key].get_children()[0])
	#return active_spells

func connect_signals():
	for team in teams:
		for key in team:
			for actor in team[key]:
				if actor is Monster:
					turn_begin.connect(actor.test_tactics_set)
		#if key.contains("monster"):
			#turn_begin.connect(active_refs[key].test_tactics_set)
	#for key in bench_1_refs:
		#turn_begin.connect(bench_1_refs[key].test_tactics_set)
	#for key in bench_2_refs:
		#turn_begin.connect(bench_2_refs[key].test_tactics_set)

func set_point_references_on_actors():
	for key in team_zero:
		for actor in team_zero[key]:
			if actor is Actor:
				actor.team = 0
				actor.ally_point = monster_point_player_1
				actor.bench_point = player_1_bench
				actor.rival_point = monster_point_player_2
				actor.rival_bench_point = player_2_bench
				actor.own_player_point = player_point_1
				actor.rival_player_point = player_point_2
	for key in team_one:
		for actor in team_one[key]:
			if actor is Actor:
				actor.team = 1
				actor.ally_point = monster_point_player_2
				actor.bench_point = player_2_bench
				actor.rival_point = monster_point_player_1
				actor.rival_bench_point = player_1_bench
				actor.own_player_point = player_point_2
				actor.rival_player_point = player_point_1
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
	for team in teams:
		for key in team:
			if key == "benched": continue
			for actor in team[key]:
				actor.action_value -= 1
	calculate_turn_order()
	#TODO: Handle cast time stuff
	if len(action_stack) > 0:
		resolve_action_stack()
	#cleanup
	await get_tree().create_timer(tick_time_length).timeout
	round_in_progress = false

func generate_to_go():
	#generates a queue of 0AV simultaneous turns
	var t_order = calculate_turn_order()
	to_go = []
	for actor in t_order:
		if actor.action_value == 0:
			to_go.append(actor)

func execute_to_go():
	#Calls for turns in to_go queue order. *Should* be fine with to_go changing during its execution thanks to the while loop and await
	while len(to_go) > 0:
		execute_new_turn(to_go.pop_front())
		await turn_complete
	to_go_complete.emit()

func execute_new_turn(actor: Actor):
	going_actor = actor
	if going_actor is Player: test_button_ready = true
	display_event_description(going_actor.display_name + "'s turn")
	await get_tree().create_timer(tick_time_length).timeout
	turn_begin.emit(going_actor)
	if going_actor is Monster:
		var was_instant = await going_actor.tactic_excecuted
		await get_tree().create_timer(tick_time_length).timeout
		if queue: await resolve_action_stack()
		if not was_instant: regenerate_conflict_resolution(going_actor)
		else: to_go.insert(0, going_actor)
		turn_cleanup()

#TODO: Completely redo the stack into nu-Queue
func add_move_to_stack(move: Move):
	#action_stack.append(move)
	queue = EventQueue.new(move, self)
	#await get_tree().create_timer(tick_time_length).timeout

func resolve_action_stack():
	#placeholder code for test spells
	var go = true
	while go:
		go = await queue.resolve_step()
	queue = null
	return
	#while len(action_stack) > 0:
		#var action = action_stack.pop_back()
		#action.resolve()

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
	var actors = []
	for team in teams:
		for key in team:
			for actor in team[key]:
				actors.append(actor)
	actors.shuffle()
	conflict_resolution_order = actors.duplicate()

#TODO: Make doubly sure this is ok
func regenerate_conflict_resolution(last_went):
	#trafficlight thingy
	#if conflict_resolution_order.size() < 4:
		#conflict_resolution_order.append(last_went)
		#return
	if conflict_resolution_order.has(last_went):
		conflict_resolution_order.erase(last_went)
	conflict_resolution_order.append(last_went)

#TODO: Make sure it takes spells and channels into account
func better_turn_order_algorithm(order: Array, cro: Array):
	var avs = []
	
	for actor in cro:
		if teams[0]["benched"].has(actor) or teams[1]["benched"].has(actor): continue #Skip the benches
		avs.append([actor, actor.action_value])
	
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

func turn_cleanup():
	test_button_ready = false
	going_actor = null
	calculate_turn_order()
	turn_complete.emit()
#endregion

#region Switching Monsters Logic
#TODO: extend for more than one active monster
func swap_monster(monster_to_swap_in: Actor): #for player swapping; either a refactor or seperate function necessary for Tornado
	#declarations
	var team_no
	var bench
	var active_point
	
	if teams[0]["players"].has(going_actor):
		team_no = 0
		active_point = monster_point_player_1
		bench = player_1_bench
	elif teams[1]["players"].has(going_actor):
		team_no = 1
		active_point = monster_point_player_2
		bench = player_2_bench
	
	#check who's going and assign variables accordingly
	#if going_actor_key == "player1":
		#active_refs_key = "player1monster"
		#active_point = monster_point_player_1
		#bench = player_1_bench
		#bench_refs = bench_1_refs
	#elif going_actor_key == "player2":
		#active_refs_key = "player2monster"
		#active_point = monster_point_player_2
		#bench = player_2_bench
		#bench_refs = bench_2_refs
	if bench == null: return #just return if the variable assignments go funny; todo better error management
	
	#announce action
	display_event_description(going_actor.display_name + " switches out " + teams[team_no]["actives"][0].display_name + " for " + monster_to_swap_in.display_name + ".")
	
	#declare and assign what's being moved
	var out_mon = teams[team_no]["actives"][0]
	var in_mon = monster_to_swap_in
	var out_pos = out_mon.position
	var in_pos = in_mon.position
	
	#TODO: interrupt spells
	#if out_mon.casting:
		#display_event_description(out_mon.display_name + "'s spell was interrupted")
		#out_mon.casting = false
		#spell_conflict_resolution_order.erase(active_refs_key+"spell")
		#out_mon.connected_move_container.get_children()[0].queue_free()
	
	#swap parents and positions
	active_point.remove_child(out_mon)
	bench.remove_child(in_mon)
	active_point.add_child(in_mon)
	bench.add_child(out_mon)
	out_mon.position = in_pos
	in_mon.position = out_pos
	
	#update AVs and turn order neccesary stuff
	going_actor.action_value += 3
	regenerate_conflict_resolution(going_actor)
	regenerate_conflict_resolution(in_mon)
	
	#regenerate to_go in case of a 0AV swap
	#TODO: ensure this does not screw with instants
	generate_to_go()
	await get_tree().create_timer(tick_time_length).timeout
	#end of turn cleanup
	turn_cleanup()

#endregion
