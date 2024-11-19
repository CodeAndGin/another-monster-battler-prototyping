extends ReactionTimingCondition
class_name IncomingSkill

func check(own_user: Actor, triggering_move: Move, result: Dictionary) -> bool:
	#if triggering_move.target != own_user: return false
	#if triggering_move.move_type != GlobalUtils.ActionTypes.SKILL: return false
	#return true
	return triggering_move.target == own_user and triggering_move.move_type == GlobalUtils.ActionTypes.SKILL
