extends Node3D

var move_resource: Action

var damage
var heal
var risk
var guard
var shield
var poison
var burn

var av
var rv
var ct

#region Ready and Process
func _ready() -> void:
	damage = move_resource.damage_amount
	heal = move_resource.heal_amount
	risk = move_resource.risk_amount
	guard = move_resource.guard_amount
	shield = move_resource.shield_amount
	poison = move_resource.poison_amount
	burn = move_resource.burn_amount
	
	av = move_resource.av_cost
	rv = move_resource.rv_cost
	ct = move_resource.ct_cost

func _process(_delta: float) -> void:
	pass
#endregion
