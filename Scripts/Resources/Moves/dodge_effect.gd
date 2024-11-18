extends BespokeEffect
class_name DodgeReactionEffect

func bespoke_effect(user: Actor, target: Actor = null, move_target: Move = null):
	move_target.calculated_phys_damage_amount = 0
	move_target.calculated_burn_amount = 0
	move_target.calculated_risk_amount = 0
	move_target.calculated_mag_damage_amount = 0
	move_target.calculated_poison_amount = 0
	move_target.calculated_stat_damage_amount = 0
