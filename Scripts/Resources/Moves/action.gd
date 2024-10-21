#@tool #was trying to use to make the inspector clamp the min/max values but seems to be buggy
extends Move
class_name Action

@export var move_type: EnumUtils.ActionTypes

@export var is_melee: bool
@export var is_instant: bool
##Only to be used when copied for placing on the stack

func _init(_user: Actor = null, _target: Monster = null, to_copy: Action = null) -> void:
	if to_copy:
#region Variable copying
		move_type = to_copy.move_type
		move_name = to_copy.move_name
		
		bespoke_effect = to_copy.bespoke_effect
		bespoke_cost = to_copy.bespoke_cost
		
		is_melee = to_copy.is_melee
		is_instant = to_copy.is_instant
		
		internal_order_of_effects = to_copy.internal_order_of_effects
		
		_min_phys_damage = to_copy._min_phys_damage
		_max_phys_damage = to_copy._max_phys_damage
		
		_min_mag_damage = to_copy._min_mag_damage
		_max_mag_damage = to_copy._max_mag_damage
		
		_min_stat_damage = to_copy._min_stat_damage
		_max_stat_damage = to_copy._max_stat_damage
		
		_min_heal = to_copy._min_heal
		_max_heal = to_copy._max_heal
		
		_min_rally = to_copy._min_rally
		_max_rally = to_copy._max_rally
		
		_min_risk = to_copy._min_risk
		_max_risk = to_copy._max_risk
		
		_min_guard = to_copy._min_guard
		_max_guard = to_copy._max_guard
		
		_min_shield = to_copy._min_shield
		_max_shield = to_copy._max_shield
		
		_min_poison = to_copy._min_poison
		_max_poison = to_copy._max_poison
		
		_min_burn = to_copy._min_burn
		_max_burn = to_copy._max_burn
		
		av_cost = to_copy.av_cost
		rv_cost = to_copy.rv_cost
		ct_cost = to_copy.ct_cost
#endregion
		user = _user
		target = _target
		
		if user and target:
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

func copy(_user: Actor, _target: Monster) -> Action:
	return Action.new(_user, _target, self)

func check_if_can_use_on_target(_user: Actor, _target: Actor) -> bool:
	if _target is not Monster: return false
	return bespoke_target_check.bespoke_target_check(_user, _target)

func add_to_action_stack(arena: Arena, _user: Actor, _target: Monster):
	arena.action_stack.append(self.copy(_user, _target))

#func simulated_resolve():
	#if not user and target:
		#printerr("DEBUG: Something has gone horribly wrong. Do not call simulated_resolve() unless user and target are set, ideally only when the move has been copied and is stacked for use")
		#return
	#if len(internal_order_of_effects) < 1:
		#printerr("DEBUG: Please specify order of effects to resolve in the internal_order_of_effects array")
		#return
	#for type in internal_order_of_effects:
		#match type:
			#EnumUtils.MoveEffectTypes.PHYS_DAMAGE:
				#target.simulated_take_physical_damage(calculated_phys_damage_amount)
			#_:
				#printerr("DEBUG: Chosen type " + EnumUtils.MoveEffectTypes.keys()[type] + " is not recognised")

func resolve():
	if not user and target:
		printerr("DEBUG: Something has gone horribly wrong. Do not call resolve() unless user and target are set, ideally only when the move has been copied and is stacked for use")
		return
	if len(internal_order_of_effects) < 1:
		printerr("DEBUG: Please specify order of effects to resolve in the internal_order_of_effects array")
		return
	user.action_value += av_cost
	for type in internal_order_of_effects:
		match type:
			EnumUtils.MoveEffectTypes.PHYS_DAMAGE:
				target.take_physical_damage(calculated_phys_damage_amount)
			_:
				printerr("DEBUG: Chosen type " + EnumUtils.MoveEffectTypes.keys()[type] + " is not recognised")
	

func create_spell():
	pass

func create_channel():
	pass