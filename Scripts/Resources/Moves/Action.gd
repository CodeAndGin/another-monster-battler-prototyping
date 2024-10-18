#@tool #was trying to use to make the inspector clamp the min/max values but seems to be buggy
extends Resource
class_name Action

@export var move_type: EnumUtils.ActionTypes
@export var move_name: String

@export var bespoke_effect: BespokeEffectBase

##For checking costs other than RV
@export var bespoke_cost_check: BespokeCostCheckBase
##For checking target conditions, such as in Half-Inch, for instance
@export var bespoke_target_check: BespokeTargetCheckBase
##For checking if buffs or fields are up, for instance
@export var bespoke_internal_condition: BespokeInternalConditionBase

@export var is_melee: bool
@export var is_instant: bool
##Only to be used when copied for placing on the stack
var user: Monster
var target: Monster

#@export var path_to_scene: String

@export var internal_order_of_effects: Array[EnumUtils.MoveEffectTypes]

#region Damage
@export_group("Damage")
@export_subgroup("Physical")
##The minimum physical damage value of the move. Only used for setting: Do not call this property, use amount instead. Setting this below 0 or above _max will produce unexpected results. 
##Set min and max to the same value for a static amount
@export var _min_phys_damage: int
##The maximum physical damage value of the move. Only used for setting: Do not call this property, use amount instead. Setting this below _min will produce unexpected results.
##Set min and max to the same value for a static amount
@export var _max_phys_damage: int
var phys_damage_amount: int:
	get:
		return _min_phys_damage + randi() % (_max_phys_damage - _min_phys_damage + 1)
var calculated_phys_damage_amount: int
@export_subgroup("Magical")
##The minimum magical damage value of the move. Only used for setting: Do not call this property, use amount instead. Setting this below 0 or above _max will produce unexpected results. 
##Set min and max to the same value for a static amount
@export var _min_mag_damage: int
##The maximum magical damage value of the move. Only used for setting: Do not call this property, use amount instead. Setting this below _min will produce unexpected results.
##Set min and max to the same value for a static amount
@export var _max_mag_damage: int
var mag_damage_amount: int:
	get:
		return _min_mag_damage + randi() % (_max_mag_damage - _min_mag_damage + 1)
var calculated_mag_damage_amount: int
@export_subgroup("Status")
##The minimum status damage value of the move. Only used for setting: Do not call this property, use amount instead. Setting this below 0 or above _max will produce unexpected results. 
##Set min and max to the same value for a static amount
@export var _min_stat_damage: int
##The maximum status damage value of the move. Only used for setting: Do not call this property, use amount instead. Setting this below _min will produce unexpected results.
##Set min and max to the same value for a static amount
@export var _max_stat_damage: int
var stat_damage_amount: int:
	get:
		return _min_stat_damage + randi() % (_max_stat_damage - _min_stat_damage + 1)
var calculated_stat_damage_amount: int
#endregion

#region Heal
@export_group("Heal")
##The minimum heal value of the move. Only used for setting: Do not call this property, use amount instead. Setting this below 0 or above _max will produce unexpected results.
##Set min and max to the same value for a static amount
@export var _min_heal: int
##The maximum heal value of the move. Only used for setting: Do not call this property, use amount instead. Setting this below _min will produce unexpected results.
##Set min and max to the same value for a static amount
@export var _max_heal: int
var heal_amount: int:
	get:
		return _min_heal + randi() % (_max_heal - _min_heal + 1)
var calculated_heal_amount: int
#endregion

#region Rally
@export_group("Rally")
##The minimum rally value of the move. Only used for setting: Do not call this property, use amount instead. Setting this below 0 or above _max will produce unexpected results.
##Set min and max to the same value for a static amount
@export var _min_rally: int
##The maximum rally value of the move. Only used for setting: Do not call this property, use amount instead. Setting this below _min will produce unexpected results.
##Set min and max to the same value for a static amount
@export var _max_rally: int
var rally_amount: int:
	get:
		return _min_rally + randi() % (_max_rally - _min_rally + 1)
var calculated_rally_amount: int
#endregion

#region Risk
@export_group("Risk")
##The minimum risk value of the move. Only used for setting: Do not call this property, use amount instead. Setting this below 0 or above _max will produce unexpected results.
##Set min and max to the same value for a static amount
@export var _min_risk: int
##The maximum risk value of the move. Only used for setting: Do not call this property, use amount instead. Setting this below _min will produce unexpected results.
##Set min and max to the same value for a static amount
@export var _max_risk: int
var risk_amount: int:
	get:
		return _min_risk + randi() % (_max_risk - _min_risk + 1)
var calculated_risk_amount: int
#endregion

#region Guard
@export_group("Guard")
##The minimum guard value of the move. Only used for setting: Do not call this property, use amount instead. Setting this below 0 or above _max will produce unexpected results.
##Set min and max to the same value for a static amount
@export var _min_guard: int
##The maximum guard value of the move. Only used for setting: Do not call this property, use amount instead. Setting this below _min will produce unexpected results.
##Set min and max to the same value for a static amount
@export var _max_guard: int
var guard_amount: int:
	get:
		return _min_guard + randi() % (_max_guard - _min_guard + 1)
var calculated_guard_amount: int
#endregion

#region Shield
@export_group("Shield")
##The minimum shield value of the move. Only used for setting: Do not call this property, use amount instead. Setting this below 0 or above _max will produce unexpected results.
##Set min and max to the same value for a static amount
@export var _min_shield: int
##The maximum shield value of the move. Only used for setting: Do not call this property, use amount instead. Setting this below _min will produce unexpected results.
##Set min and max to the same value for a static amount
@export var _max_shield: int
var shield_amount: int:
	get:
		return _min_shield + randi() % (_max_shield - _min_shield + 1)
var calculated_shield_amount: int
#endregion

#region Poison
@export_group("Poison")
##The minimum poison value of the move. Only used for setting: Do not call this property, use amount instead. Setting this below 0 or above _max will produce unexpected results.
##Set min and max to the same value for a static amount
@export var _min_poison: int
##The maximum poison value of the move. Only used for setting: Do not call this property, use amount instead. Setting this below _min will produce unexpected results.
##Set min and max to the same value for a static amount
@export var _max_poison: int
var poison_amount: int:
	get:
		return _min_poison + randi() % (_max_poison - _min_poison + 1)
var calculated_poison_amount: int
#endregion

#region Burn
@export_group("Burn")
##The minimum burn value of the move. Only used for setting: Do not call this property, use amount instead. Setting this below 0 or above _max will produce unexpected results.
##Set min and max to the same value for a static amount
@export var _min_burn: int
##The maximum burn value of the move. Only used for setting: Do not call this property, use amount instead. Setting this below _min will produce unexpected results.
##Set min and max to the same value for a static amount
@export var _max_burn: int
var burn_amount: int:
	get:
		return _min_burn + randi() % (_max_burn - _min_burn + 1)
var calculated_burn_amount: int
#endregion

#region Cost
@export_group("Cost")
@export var av_cost: int ##Positive value indicates generation
@export var rv_cost: int ##Negative value indicates cost, positive value indicates generation
@export var ct_cost: int ##Positive value indicates generation
#endregion

func _init(_user: Monster = null, _target: Monster = null, to_copy: Action = null) -> void:
	if to_copy:
#region Variable copying
		move_type = to_copy.move_type
		move_name = to_copy.move_name
		
		bespoke_effect = to_copy.bespoke_effect
		bespoke_cost_check = to_copy.bespoke_cost_check
		
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

func copy(_user: Monster, _target: Monster) -> Action:
	return Action.new(_user, _target, self)

func check_if_can_use_cost(_user: Monster) -> bool:
	var rv_check = _user.reaction_value + rv_cost >= 0
	var bcc = bespoke_cost_check.bespoke_cost_check(_user) if bespoke_cost_check else true
	var bic = bespoke_internal_condition.bespoke_internal_condition(_user) if bespoke_internal_condition else true
	return rv_check and bcc and bic

func check_if_can_use_on_target(_user: Monster, _target: Monster) -> bool:
	return bespoke_target_check.bespoke_target_check(_user, _target)

func add_to_action_stack(arena: Arena, _user: Monster, _target: Monster):
	arena.action_stack.append(self.copy(_user, _target))

func resolve():
	if not user and target:
		printerr("DEBUG: Something has gone horribly wrong. Do not call resolve() unless user and target are set, ideally only when the move has been copied and is stacked for use")
		return
	if len(internal_order_of_effects) < 1:
		printerr("DEBUG: Please specify order of effects to resolve in the internal_order_of_effects array")
		return
	for type in internal_order_of_effects:
		match type:
			EnumUtils.MoveEffectTypes.PHYS_DAMAGE:
				#target.take_physical_damage()
				print("test")
			_:
				printerr("DEBUG: Chosen type " + EnumUtils.MoveEffectTypes.keys()[type] + " is not recognised")

func create_spell():
	pass

func create_channel():
	pass
