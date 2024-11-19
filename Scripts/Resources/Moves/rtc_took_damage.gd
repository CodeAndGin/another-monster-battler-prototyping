extends ReactionTimingCondition
class_name Took_Damage

func check(own_user: Actor, triggering_move: Move, result: Dictionary) -> bool:
	if triggering_move.target != own_user: return false
	
	if result == {}: return false
	
	if not own_user in result: return false
	
	var effects = result[own_user]
	#[[effects],[values]]
	if not (GlobalUtils.AfterEffectTriggers.PHYS_DAMAGE in effects[0] or \
		GlobalUtils.AfterEffectTriggers.MAG_DAMAGE in effects[0] or \
		GlobalUtils.AfterEffectTriggers.STAT_DAMAGE in effects[0]): return false
	return true
