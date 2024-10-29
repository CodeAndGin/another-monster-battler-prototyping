extends TacticsCondition
class_name userHPValueCompare

#IS,
#IS_NOT,
#IS_EQUAL_TO,
#IS_NOT_EQUAL_TO,
#IS_LESS_THAN,
#IS_NOT_LESS_THAN,
#IS_LESS_THAN_OR_EQUAL_TO,
#IS_NOT_LESS_THAN_OR_EQUAL_TO,
#IS_GREATER_THAN,
#IS_NOT_GREATER_THAN,
#IS_GREATER_THAN_OR_EQUAL_TO,
#IS_NOT_GREATER_THAN_OR_EQUAL_TO

@export var amount_to_compare_against: int
@export var comparison: GlobalUtils.Comparisons

func is_condition_met(user: Actor = null, target: Actor = null, move_target: Move = null) -> bool:
	if not user:
		printerr("This comparison type expects a user to be passed in")
		return false
	match comparison:
		GlobalUtils.Comparisons.IS:
			return user.hp == amount_to_compare_against
		GlobalUtils.Comparisons.IS_NOT:
			return user.hp != amount_to_compare_against
		GlobalUtils.Comparisons.IS_EQUAL_TO:
			return user.hp == amount_to_compare_against
		GlobalUtils.Comparisons.IS_NOT_EQUAL_TO:
			return user.hp != amount_to_compare_against
		GlobalUtils.Comparisons.IS_LESS_THAN:
			return user.hp < amount_to_compare_against
		GlobalUtils.Comparisons.IS_NOT_LESS_THAN:
			return not user.hp < amount_to_compare_against
		GlobalUtils.Comparisons.IS_LESS_THAN_OR_EQUAL_TO:
			return user.hp <= amount_to_compare_against
		GlobalUtils.Comparisons.IS_NOT_LESS_THAN_OR_EQUAL_TO:
			return not user.hp <= amount_to_compare_against
		GlobalUtils.Comparisons.IS_GREATER_THAN:
			return user.hp > amount_to_compare_against
		GlobalUtils.Comparisons.IS_NOT_GREATER_THAN:
			return not user.hp > amount_to_compare_against
		GlobalUtils.Comparisons.IS_GREATER_THAN_OR_EQUAL_TO:
			return user.hp >= amount_to_compare_against
		GlobalUtils.Comparisons.IS_NOT_GREATER_THAN_OR_EQUAL_TO:
			return not user.hp >= amount_to_compare_against
	return false

func check(user: Actor = null, potential_targets: Array[Actor] = [], move_target: Move = null):# -> Array[Actor]:
	if not user:
		printerr("This comparison type expects a user to be passed in")
		return []
	
	match comparison:
		GlobalUtils.Comparisons.IS:
			if user.hp == amount_to_compare_against: return potential_targets
		GlobalUtils.Comparisons.IS_NOT:
			if user.hp != amount_to_compare_against: return potential_targets
		GlobalUtils.Comparisons.IS_EQUAL_TO:
			if user.hp == amount_to_compare_against: return potential_targets
		GlobalUtils.Comparisons.IS_NOT_EQUAL_TO:
			if user.hp != amount_to_compare_against: return potential_targets
		GlobalUtils.Comparisons.IS_LESS_THAN:
			if user.hp < amount_to_compare_against: return potential_targets
		GlobalUtils.Comparisons.IS_NOT_LESS_THAN:
			if not user.hp < amount_to_compare_against: return potential_targets
		GlobalUtils.Comparisons.IS_LESS_THAN_OR_EQUAL_TO:
			if user.hp <= amount_to_compare_against: return potential_targets
		GlobalUtils.Comparisons.IS_NOT_LESS_THAN_OR_EQUAL_TO:
			if not user.hp <= amount_to_compare_against: return potential_targets
		GlobalUtils.Comparisons.IS_GREATER_THAN:
			if user.hp > amount_to_compare_against: return potential_targets
		GlobalUtils.Comparisons.IS_NOT_GREATER_THAN:
			if not user.hp > amount_to_compare_against: return potential_targets
		GlobalUtils.Comparisons.IS_GREATER_THAN_OR_EQUAL_TO:
			if user.hp >= amount_to_compare_against: return potential_targets
		GlobalUtils.Comparisons.IS_NOT_GREATER_THAN_OR_EQUAL_TO:
			if not user.hp >= amount_to_compare_against: return potential_targets
	return []
