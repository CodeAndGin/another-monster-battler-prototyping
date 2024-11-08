class_name EventQueue

var current: Move
var afters: Array

var tactics_to_check: Array

#{Move: tactics_line_index(int)}
var tracker: Dictionary

func _init(move: Move, arena: Arena) -> void:
	current = move
	collate_tactics(arena)
	add_to_tracker(current)

func add_to_tracker(move: Move) -> void:
	tracker[move] = 0

func collate_tactics(arena: Arena) -> void:
	var cro = arena.conflict_resolution_order.duplicate()
	for actor in cro:
		if actor is not Monster: continue
		var t = actor.tactics_sheet.setA if actor.active_tactics_set_is_A else actor.tactics_sheet.setB
		var keys = ["First reaction", "Second reaction", "Third reaction", "Fourth reaction", "Fifth reaction"] #TODO: CHANGE THIS
		for key in keys:
			if not t[key]: continue
			tactics_to_check.append(t[key])

func resolve_step() -> bool:
	if tracker[current] < len(tactics_to_check):
		#TODO: check the tactic
		tracker[current] += 1
		return false
	current.resolve()
	current = afters.pop_front() if len(afters) > 0 else null
	return false if current else true

func add_before(move: Move) -> void:
	afters.insert(0, current)
	current = move
	add_to_tracker(move)

func add_after(move: Move) -> void:
	afters.append(move)
	add_to_tracker(move)
# queue checks for "before" reactions to the next event to resolve (ie the front of the queue) #
# if a before reaction is found, it enters at the front of the queue, and reactions for it are then checked #
# The queue remembers where in the reactions it's checking it found a before, and once it's resolved, continues checking #
# Repeat as necessary. Resolve a Move when all possible Reactions are checked #
# When a move resolves, "After" reactions are checked for and added to the end of the queue #
# Repeat as necessary until the queue is empty #
