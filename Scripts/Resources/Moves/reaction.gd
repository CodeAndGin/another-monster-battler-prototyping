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
	for type in internal_order_of_effects:
		match type:
			GlobalUtils.MoveEffectTypes.PHYS_DAMAGE:
				target.take_physical_damage(calculated_phys_damage_amount)
			GlobalUtils.MoveEffectTypes.MAG_DAMAGE:
				target.take_magical_damage(calculated_mag_damage_amount)
			GlobalUtils.MoveEffectTypes.STAT_DAMAGE:
				target.take_status_damage(calculated_stat_damage_amount)
			GlobalUtils.MoveEffectTypes.HEAL:
				user.heal(calculated_heal_amount)
			GlobalUtils.MoveEffectTypes.RALLY:
				user.rally(calculated_rally_amount)
			GlobalUtils.MoveEffectTypes.RISK:
				target.take_risk(calculated_risk_amount)
			GlobalUtils.MoveEffectTypes.GUARD:
				user.gain_guard(calculated_guard_amount)
			GlobalUtils.MoveEffectTypes.SHIELD:
				user.gain_shield(calculated_shield_amount)
			GlobalUtils.MoveEffectTypes.POISON:
				target.take_poison(calculated_poison_amount)
			GlobalUtils.MoveEffectTypes.BURN:
				target.take_burn(calculated_burn_amount)
			GlobalUtils.MoveEffectTypes.BESPOKE:
				bespoke_effect.bespoke_effect(user, target, move_target)
			_:
				printerr("DEBUG: Chosen type " + GlobalUtils.MoveEffectTypes.keys()[type] + " is not recognised")

#Duplicates the Resource and sets targets for use in an EventQueue
#func copy(_user: Actor, _target: Monster) -> Reaction:
	#var copied = self.duplicate(true)
	#copied.user = _user
	#copied.target = _target
	#copied.move_target = move_target
	#copied.calculate_amounts()
	#return copied
