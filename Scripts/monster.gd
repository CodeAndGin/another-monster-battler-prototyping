extends Actor
class_name Monster

@export var stat_sheet: MonsterStats
@export var tactics_sheet: TacticsSet
var active_tactics_set_is_A = true

var direct_order: Action
var direct_order_target: Monster

var own_key = ""
var opponent_key:
	get:
		if own_key.contains("monster"):
			return "player2monster" if own_key == "player1monster" else "player1monster"
		return ""

var MAX_HP: int
var STARTING_HP: int
@export var hp: int:
	get:
		return hp
	set(value):
		var v = value
		if v < 0: v = 0
		hp = v
		if hp <= 0: pass #KO check here?

var risk_and_guard: int

var move_list: Array

var exposed: bool = false

var poison: int
var burn: int


signal tactic_excecuted(was_instant: bool)


func test_tactics_set(user):
	if not user == self: return
	if not tactics_sheet: return
	
	var was_instant = false
	await get_tree().create_timer(arena.tick_time_length).timeout
	if direct_order:
		print(display_name + " direct order")
		var target_team = arena.team_zero if direct_order_target.team == 0 else arena.team_one
		if not direct_order_target in target_team["actives"]:
			
			#Get new active target if available (random for now)
			var potential_targets = get_actor_targets(direct_order.targets)
			var target = potential_targets.pick_random() if potential_targets != [] else null
			direct_order_target = target
		if direct_order_target and direct_order.check_if_can_use_cost(self) and direct_order.check_if_can_use_on_target(self, direct_order_target):
			
			direct_order.add_to_action_stack(arena, self, direct_order_target)
			arena.display_event_description(display_name + " started to use " + direct_order.move_name + (" (Instant)" if direct_order.is_instant else ""))
			was_instant = direct_order.is_instant
			tactic_excecuted.emit(was_instant)
			direct_order = null
			return
		print("Direct order failed, defaulting to tactics")
	
	
	var keys = ["First", "Second", "Third", "Fourth", "Fifth"]
	var active_set = tactics_sheet.setA if active_tactics_set_is_A else tactics_sheet.setB
	
	var went = false
	for key in keys:
		if not active_set[key]: continue
		var tactic: Tactic = active_set[key]
		var potential_targets = get_actor_targets(tactic.move.targets)
		var condition: TacticsCondition = tactic.condition
		potential_targets = condition.check(arena, self, potential_targets)
		if potential_targets == []: continue
		var target = choose_target_by_priority(potential_targets, tactic.priority)
		var checks = tactic.move.check_if_can_use_cost(self) and tactic.move.check_if_can_use_on_target(self, target)
		var move: Action = tactic.move if tactic.move is Action else null
		if not move:
			printerr("Move was not an Action, this section of the tactics only expects actions")
			continue
		if not checks: continue
		move.add_to_action_stack(arena, self, target)
		arena.display_event_description(display_name + " started to use " + move.move_name + (" (Instant)" if move.is_instant else ""))
		was_instant = move.is_instant
		went = true
		break
	if not went: av += 2 #for now
	tactic_excecuted.emit(was_instant)

func choose_target_by_priority(potential_targets: Array[Actor], priority: GlobalUtils.TargetPriorities) -> Actor:
	if len(potential_targets) == 1: return potential_targets.pop_front()
	var target = potential_targets[0]
	for actor in potential_targets:
		if target == actor: continue
		target = GlobalUtils.compare_actors_by_priority(target, actor, priority)
	return target

func _ready() -> void:
	super() #calls parent class' _ready()
	if stat_sheet:
		MAX_HP = stat_sheet.MAX_HP
		STARTING_HP = stat_sheet.STARTING_HP
		MAX_RV = stat_sheet.MAX_RV
		rv = stat_sheet.STARTING_RV
		overcapping_rv = stat_sheet.overcapping_rv
		default_name = stat_sheet.monster_name
		move_list = stat_sheet.move_list
	if tactics_sheet:
		active_tactics_set_is_A = tactics_sheet.default_set_is_A
	#for i in range(50): move_list_scenes.append(generic_move)
	#for move in move_list_scenes:
	#	move_list.append(move.instantiate())
	#for i in len(move_list): move_list[i].move_name = "Test %s" % (i+1)
	hp = STARTING_HP


func take_damage_to_shield(amount: int) -> int:
	return amount

#func simulated_take_damage_to_shield(amount: int) -> int:
	#return amount

#region functions to add Damage, risk, poison, etc.
func take_physical_damage(amount: int):
	if amount <= 0: return []
	var to_take = amount
	if risk_and_guard > 0: #guard
		while risk_and_guard > 0 or to_take > 0:
			to_take -= 1
			risk_and_guard -= 1
	elif risk_and_guard < 0: #risk
		var to_boost = to_take
		while risk_and_guard < 0 or to_boost > 0:
			to_take += 2 if exposed else 1
			risk_and_guard += 1
			to_boost -= 1
	to_take = take_damage_to_shield(to_take)
	if to_take <= 0: return []
	hp -= to_take
	return [self, GlobalUtils.AfterEffectTriggers.PHYS_DAMAGE, to_take]

func take_magical_damage(amount: int):
	if amount <= 0: return []
	var to_take = amount
	to_take = take_damage_to_shield(to_take)
	if to_take <= 0: return []
	hp -= to_take
	return [self, GlobalUtils.AfterEffectTriggers.MAG_DAMAGE, to_take]

#func simulated_take_magical_damage(amount: int):
	#if amount <= 0: return
	#var to_take = amount
	#to_take = take_damage_to_shield(to_take)
	#if to_take <= 0: return
	#var result = SimulationResult.new()
	#result.mag_damage_taken = to_take
	#result.resulting_hp = hp - to_take
	#return result

func take_status_damage(amount: int):
	if amount <= 0: return []
	var to_take = amount #redundant for now
	if to_take <= 0: return [] #redundant for now
	hp -= to_take
	return [self, GlobalUtils.AfterEffectTriggers.STAT_DAMAGE, to_take]

func heal(amount: int): #need to do KO checking
	if amount <= 0: return []
	var to_take = amount
	if to_take <= 0: return []
	hp += to_take
	return [self, GlobalUtils.AfterEffectTriggers.HEAL, to_take]

func rally(amount: int):
	if amount <= 0: return []
	var to_take = amount
	if risk_and_guard > 0: #guard
		var to_boost = to_take
		while risk_and_guard > 0 or to_boost > 0:
			to_take += 1
			risk_and_guard -= 1
			to_boost -= 1
	elif risk_and_guard < 0: #risk
		while risk_and_guard < 0 or to_take > 0:
			to_take -= 1
			risk_and_guard += 1
	if to_take <= 0: return []
	hp += to_take
	return [self, GlobalUtils.AfterEffectTriggers.RALLY, to_take]

func take_risk(amount: int):
	if amount <= 0: return []
	var to_take = amount
	if to_take <= 0: return []
	risk_and_guard -= to_take
	return [self, GlobalUtils.AfterEffectTriggers.RISK, to_take]

func gain_guard(amount: int):
	if amount <= 0: return []
	var to_take = amount
	if to_take <= 0: return []
	risk_and_guard += to_take
	return [self, GlobalUtils.AfterEffectTriggers.GUARD, to_take]

func take_poison(amount: int):
	if amount <= 0: return []
	var to_take = amount
	if to_take <= 0: return []
	poison += to_take
	return [self, GlobalUtils.AfterEffectTriggers.POISON, to_take]

func take_burn(amount: int):
	if amount <= 0: return []
	var to_take = amount
	if to_take <= 0: return []
	burn += to_take
	return [self, GlobalUtils.AfterEffectTriggers.BURN, to_take]
#endregion

#region functions to proc statuses like poison
func burn_proc(): #call at round end
	if burn < 0:
		printerr("DEBUG: Burn on " + display_name + " has gone below zero to: " + str(burn) + ". Correcting.")
		burn = 0
		return
	if burn == 0: return
	take_status_damage(burn)
	burn -= 1

func poison_proc(av: int, ct: int): #call at any av/ct gain - ct may be an issue here unsure
	if poison < 0:
		printerr("DEBUG: Poison on " + display_name + " has gone below zero to: " + str(burn) + ". Correcting.")
		poison = 0
		return
	if poison == 0: return
	take_status_damage(av+ct)
	poison -= 1
#endregion

func before_reaction_call(result: SimulationResult):
	var keys = ["First reaction", "Second reaction", "Third reaction", "Fourth reaction", "Fifth reaction"]
	if tactics_sheet:
		var t_set = tactics_sheet.setA if active_tactics_set_is_A else tactics_sheet.setB
		for key in keys:
			pass

#func simulated_take_physical_damage(amount: int, results: SimulationResult):
	#if amount <= 0:
		#return results
	#var to_take = amount
	#var simulated_risk_and_guard = risk_and_guard
	#if simulated_risk_and_guard > 0:
		#while simulated_risk_and_guard > 0 or to_take > 0:
			#to_take -= 1
			#simulated_risk_and_guard -= 1
			#results.guard_used += 1
	#elif simulated_risk_and_guard < 0:
		#var to_boost = to_take
		#while simulated_risk_and_guard < 0 or to_boost > 0:
			#to_take += 2 if exposed else 1
			#simulated_risk_and_guard += 1
			#to_boost -= 1
			#results.risk_used += 1
	#to_take = simulated_take_damage_to_shield(to_take)
	#results.resulting_risk_and_guard += simulated_risk_and_guard - risk_and_guard
	#results.phys_damage_taken = to_take
	#results.resulting_hp -= to_take
	#return to_take
