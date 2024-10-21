extends Actor
class_name Monster

@export var stat_sheet: MonsterStats
@export var tactics_sheet: TacticsSetTemplate
var active_tactics_set_is_A = true

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

func test_tactics_set():
	if not tactics_sheet: return
	if FuncUtils.evaluate(tactics_sheet.setA["First"][0], FuncUtils.get_condition_variable_names(), FuncUtils.get_condition_variable_values(self, arena)):
		tactics_sheet.setA["First"][1].bespoke_effect.bespoke_effect()
	else:
		print("condition not met")

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

func take_physical_damage(amount: int):
	if amount <= 0: return
	var to_take = amount
	if risk_and_guard > 0:
		while risk_and_guard > 0 or to_take > 0:
			to_take -= 1
			risk_and_guard -= 1
	elif risk_and_guard < 0:
		var to_boost = to_take
		while risk_and_guard < 0 or to_boost > 0:
			to_take += 2 if exposed else 1
			risk_and_guard += 1
			to_boost -= 1
	to_take = take_damage_to_shield(to_take)
	if to_take <= 0: return
	hp -= to_take

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
