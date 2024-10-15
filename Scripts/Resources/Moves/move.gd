#@tool #was trying to use to make the inspector clamp the min/max values but seems to be buggy
extends Resource
class_name Move

@export var move_type: EnumUtils.MoveTypes
@export var move_contact_type: EnumUtils.DamageContactTypes
@export var move_name: String
@export var bespoke_effect: BespokeEffectBase

#region Damage
@export_group("Damage")
##The minimum damage value of the move. Only used for setting: Do not call this property, use amount instead. Setting this below 0 or above _max will produce unexpected results. 
##Set min and max to the same value for a static amount
@export var _min_damage: int
##The maximum damage value of the move. Only used for setting: Do not call this property, use amount instead. Setting this below _min will produce unexpected results.
##Set min and max to the same value for a static amount
@export var _max_damage: int
var damage_amount: int:
	get:
		return _min_damage + randi() % (_max_damage - _min_damage + 1)
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
#endregion

@export var av_cost: int ##Positive value indicates generation
@export var rv_cost: int ##Negative value indicates cost, positive value indicates generation
@export var ct_cost: int ##Positive value indicates generation
