class_name EventQueue

var current: Move
var afters: Array

var tactics_to_check: Array
var tactic_users: Dictionary

const BEFORE = GlobalUtils.ReactionTimings.BEFORE
const AFTER = GlobalUtils.ReactionTimings.AFTER

#{Move: tactics_line_index(int)}
var tracker: Dictionary

var arena: Arena

func _init(move: Move, _arena: Arena) -> void:
	current = move
	arena = _arena
	collate_reaction_tactics(_arena)
	add_to_tracker(current)

func add_to_tracker(move: Move) -> void:
	tracker[move] = 0

func collate_reaction_tactics(arena: Arena) -> void:
	tactics_to_check = []
	tactic_users = {}
	var cro = arena.conflict_resolution_order.duplicate()
	for actor in cro:
		if actor is not Monster: continue
		var t = actor.tactics_sheet.setA if actor.active_tactics_set_is_A else actor.tactics_sheet.setB
		var keys = ["First reaction", "Second reaction", "Third reaction", "Fourth reaction", "Fifth reaction"] #TODO: CHANGE THIS
		for key in keys:
			if not t[key]: continue
			var tac = t[key].duplicate()
			tactics_to_check.append(tac)
			tactic_users[tac] = actor

func resolve_step() -> bool:
	if tracker[current] < len(tactics_to_check):
		#TODO: check the tactic for befores
		var r = check_for_reaction_at_index(tracker[current], BEFORE, current, {})
		tracker[current] += 1
		if r: await add_before(r)
		return true
	var result = current.resolve() #TODO: Check the tactic for afters
	arena.display_event_description(current.user.display_name + " used " + current.move_name + (" (Instant)" if current.is_instant if current is Action else false else ""))
	for i in len(tactics_to_check):
		var r = check_for_reaction_at_index(i, AFTER, current, result)
		if r: await add_after(r)
	current = afters.pop_front() if len(afters) > 0 else null
	if current: await arena.get_tree().create_timer(arena.tick_time_length).timeout
	return true if current else false

func add_before(move: Move) -> void:
	afters.insert(0, current)
	current = move
	arena.display_event_description(current.user.display_name + " started to use " + current.move_name)
	add_to_tracker(move)
	await arena.get_tree().create_timer(arena.tick_time_length).timeout
	#await arena.get_tree().create_timer(arena.tick_time_length).timeout

func add_after(move: Move) -> void:
	afters.append(move)
	add_to_tracker(move)
	arena.display_event_description(move.user.display_name + " prepared to use " + move.move_name)
	await arena.get_tree().create_timer(arena.tick_time_length).timeout


func check_for_reaction_at_index(index: int, before_or_after: GlobalUtils.ReactionTimings, move_to_check_against: Move, result: Dictionary):
	var tactic: Tactic = tactics_to_check[index] if tactics_to_check[index] is Tactic else null
	if not tactic: return null
	var user: Monster = tactic_users[tactic] if tactic_users[tactic] is Actor else null
	if not user: return null
	var reaction = tactic.move if tactic.move is Reaction else null
	reaction = reaction as Reaction
	if not reaction: return null
	if reaction.before_or_after != before_or_after: return null
	if not reaction.reaction_timing_condition.check(user, move_to_check_against, result): return null
	
	var actor_targets = user.get_actor_targets(reaction.targets)
	var check = tactic.condition.check(arena, user, actor_targets, reaction, move_to_check_against)
	
	if check is Array and check == []: return null
	if not reaction.check_if_can_use_cost(user): return null
	#check should be Array[Actor] or Move at this point (i hope)
	var actor_target
	if check is Array:
		actor_target = user.choose_target_by_priority(check, tactic.priority)
		var r = reaction.duplicate()
		r.user = user
		r.target = actor_target
		r.calculate_amounts()
		return r
	var r = reaction.duplicate()
	r.user = user
	r.move_target = move_to_check_against
	r.calculate_amounts()
	return r



# queue checks for "before" reactions to the next event to resolve (ie the front of the queue) #
# if a before reaction is found, it enters at the front of the queue, and reactions for it are then checked #
# The queue remembers where in the reactions it's checking it found a before, and once it's resolved, continues checking #
# Repeat as necessary. Resolve a Move when all possible Reactions are checked #
# When a move resolves, "After" reactions are checked for and added to the end of the queue #
# Repeat as necessary until the queue is empty #
