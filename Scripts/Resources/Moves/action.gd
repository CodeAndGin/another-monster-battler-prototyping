#@tool #was trying to use to make the inspector clamp the min/max values but seems to be buggy
extends Move
class_name Action


@export var is_melee: bool
@export var is_instant: bool

func calculate_amounts():
	calculated_phys_damage_amount = phys_damage_amount
	calculated_mag_damage_amount = mag_damage_amount
	calculated_stat_damage_amount = stat_damage_amount
	calculated_heal_amount = heal_amount
	calculated_rally_amount = rally_amount
	calculated_risk_amount = risk_amount
	calculated_guard_amount = guard_amount
	calculated_shield_amount = shield_amount
	calculated_poison_amount = poison_amount
	calculated_burn_amount = burn_amount

#Duplicates the Resource and sets targets for use in an EventQueue
func copy(_user: Actor, _target: Monster) -> Action:
	var copied = self.duplicate(true)
	copied.user = _user
	copied.target = _target
	copied.calculate_amounts()
	return copied

func check_if_can_use_on_target(_user: Actor, _target: Actor) -> bool:
	if _target is not Monster: return false
	return bespoke_target_check.bespoke_target_check(_user, _target) if bespoke_target_check else true

func add_to_action_stack(arena: Arena, _user: Actor, _target: Monster):
	arena.add_move_to_stack(self.copy(_user, _target))

#func simulated_resolve():
	#if not user and target:
		#printerr("DEBUG: Something has gone horribly wrong. Do not call resolve() unless user and target are set, ideally only when the move has been copied and is stacked for use")
		#return
	#if len(internal_order_of_effects) < 1:
		#printerr("DEBUG: Please specify order of effects to resolve in the internal_order_of_effects array")
		#return
	#if target is not Monster:
		#printerr("DEBUG: Actions should only target monsters. Current target: " + target.display_name)
		#return
	#var result: SimulationResult
	#for type in internal_order_of_effects:
		#match type:
			#GlobalUtils.MoveEffectTypes.PHYS_DAMAGE:
				#pass
				##target.simulated_take_physical_damage(calculated_phys_damage_amount)
			#GlobalUtils.MoveEffectTypes.MAG_DAMAGE:
				#result = target.simulated_take_magical_damage(calculated_mag_damage_amount)
			#GlobalUtils.MoveEffectTypes.STAT_DAMAGE:
				#pass
				##target.simulated_take_status_damage(calculated_stat_damage_amount)
			#GlobalUtils.MoveEffectTypes.HEAL:
				#pass
				##user.simulated_heal(calculated_heal_amount)
			#GlobalUtils.MoveEffectTypes.RALLY:
				#pass
				##user.simulated_rally(calculated_rally_amount)
			#GlobalUtils.MoveEffectTypes.RISK:
				#pass
				##target.simulated_take_risk(calculated_risk_amount)
			#GlobalUtils.MoveEffectTypes.GUARD:
				#pass
				##user.simulated_gain_guard(calculated_guard_amount)
			#GlobalUtils.MoveEffectTypes.SHIELD:
				#pass
				##user.simulated_gain_shield(calculated_shield_amount)
			#GlobalUtils.MoveEffectTypes.POISON:
				#pass
				##target.simulated_take_poison(calculated_poison_amount)
			#GlobalUtils.MoveEffectTypes.BURN:
				#pass
				##target.simulated_take_burn(calculated_burn_amount)
			#GlobalUtils.MoveEffectTypes.BESPOKE:
				#pass
				##bespoke_effect.bespoke_effect(user, target)
			#_:
				#printerr("DEBUG: Chosen type " + GlobalUtils.MoveEffectTypes.keys()[type] + " is not recognised")
	#if result:
		#result.user = user
		#result.target = target
		#result.move = self
		#user.before_reaction_call(result)
		#target.before_reaction_call(result)

func resolve():
	if not user and target:
		printerr("DEBUG: Something has gone horribly wrong. Do not call resolve() unless user and target are set, ideally only when the move has been copied and is stacked for use")
		return
	if len(internal_order_of_effects) < 1:
		printerr("DEBUG: Please specify order of effects to resolve in the internal_order_of_effects array")
		return
	if target is not Monster:
		printerr("DEBUG: Actions should only target monsters. Current target: " + target.display_name)
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
				bespoke_effect.bespoke_effect(user, target)
			_:
				printerr("DEBUG: Chosen type " + GlobalUtils.MoveEffectTypes.keys()[type] + " is not recognised")

func create_spell():
	pass

func create_channel():
	pass
