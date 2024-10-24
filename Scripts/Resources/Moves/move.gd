extends Resource
class_name Move

@export var move_name: String
@export var targets: TargetStructure

@export var bespoke_effect: BespokeEffectBase

##For checking costs other than RV
@export var bespoke_cost: BespokeCostBase
##For checking target conditions, such as in Half-Inch, for instance
@export var bespoke_target_check: BespokeTargetCheckBase
##For checking if buffs or fields are up, for instance
@export var bespoke_internal_condition: BespokeInternalConditionBase

var user: Actor
var target: Actor

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

func check_if_can_use_cost(_user: Actor) -> bool:
	var rv_check = _user.reaction_value + rv_cost >= 0
	var bcc = bespoke_cost.bespoke_cost_check(_user) if bespoke_cost else true
	var bic = bespoke_internal_condition.bespoke_internal_condition(_user) if bespoke_internal_condition else true
	return rv_check and bcc and bic

func check_if_can_use_on_target(_user: Actor, _target: Actor) -> bool:
	return bespoke_target_check.bespoke_target_check(_user, _target)
