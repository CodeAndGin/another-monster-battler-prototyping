extends Move
class_name Reaction

@export_group("Reaction Specific Variables")
@export var reaction_timing_condition: ReactionTimingCondition
@export var before_or_after: GlobalUtils.ReactionTimings
@export var modifies_move: bool
var move_target: Move


func resolve():
	if not user and target:
		printerr("DEBUG: Something has gone horribly wrong. Do not call resolve() unless user and target are set, ideally only when the move has been copied and is stacked for use")
		return
	if len(internal_order_of_effects) < 1:
		printerr("DEBUG: Please specify order of effects to resolve for " + move_name + " in the internal_order_of_effects array")
		return
	user.action_value += av_cost
	user.rv += rv_cost
	print(move_name)
	var results = {}
	for type in internal_order_of_effects:
		match type:
			GlobalUtils.MoveEffectTypes.PHYS_DAMAGE:
				var r = target.take_physical_damage(calculated_phys_damage_amount)
				convert_results_from_array_to_dict(r, results)
			GlobalUtils.MoveEffectTypes.MAG_DAMAGE:
				var r = target.take_magical_damage(calculated_mag_damage_amount)
				convert_results_from_array_to_dict(r, results)
			GlobalUtils.MoveEffectTypes.STAT_DAMAGE:
				var r = target.take_status_damage(calculated_stat_damage_amount)
				convert_results_from_array_to_dict(r, results)
			GlobalUtils.MoveEffectTypes.HEAL:
				var r = user.heal(calculated_heal_amount)
				convert_results_from_array_to_dict(r, results)
			GlobalUtils.MoveEffectTypes.RALLY:
				var r = user.rally(calculated_rally_amount)
				convert_results_from_array_to_dict(r, results)
			GlobalUtils.MoveEffectTypes.RISK:
				var r = target.take_risk(calculated_risk_amount)
				convert_results_from_array_to_dict(r, results)
			GlobalUtils.MoveEffectTypes.GUARD:
				var r = user.gain_guard(calculated_guard_amount)
				convert_results_from_array_to_dict(r, results)
			GlobalUtils.MoveEffectTypes.SHIELD:
				var r = user.gain_shield(calculated_shield_amount)
				convert_results_from_array_to_dict(r, results)
			GlobalUtils.MoveEffectTypes.POISON:
				var r = target.take_poison(calculated_poison_amount)
				convert_results_from_array_to_dict(r, results)
			GlobalUtils.MoveEffectTypes.BURN:
				var r = target.take_burn(calculated_burn_amount)
				convert_results_from_array_to_dict(r, results)
			GlobalUtils.MoveEffectTypes.BESPOKE:
				bespoke_effect.bespoke_effect(user, target, move_target)
			_:
				printerr("DEBUG: Chosen type " + GlobalUtils.MoveEffectTypes.keys()[type] + " is not recognised")
	return results

#Duplicates the Resource and sets targets for use in an EventQueue
#func copy(_user: Actor, _target: Monster) -> Reaction:
	#var copied = self.duplicate(true)
	#copied.user = _user
	#copied.target = _target
	#copied.move_target = move_target
	#copied.calculate_amounts()
	#return copied
