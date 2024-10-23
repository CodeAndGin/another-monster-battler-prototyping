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
@export var comparison: EnumUtils.Comparisons

func is_condition_met(user: Actor = null, target: Actor = null, move_target: Move = null) -> bool:
	if not user:
		printerr("This comparison type expects a user to be passed in")
		return false
	match comparison:
		EnumUtils.Comparisons.IS:
			return user.hp == amount_to_compare_against
		EnumUtils.Comparisons.IS_NOT:
			return user.hp != amount_to_compare_against
		EnumUtils.Comparisons.IS_EQUAL_TO:
			return user.hp == amount_to_compare_against
		EnumUtils.Comparisons.IS_NOT_EQUAL_TO:
			return user.hp != amount_to_compare_against
		EnumUtils.Comparisons.IS_LESS_THAN:
			return user.hp < amount_to_compare_against
		EnumUtils.Comparisons.IS_NOT_LESS_THAN:
			return not user.hp < amount_to_compare_against
		EnumUtils.Comparisons.IS_LESS_THAN_OR_EQUAL_TO:
			return user.hp <= amount_to_compare_against
		EnumUtils.Comparisons.IS_NOT_LESS_THAN_OR_EQUAL_TO:
			return not user.hp <= amount_to_compare_against
		EnumUtils.Comparisons.IS_GREATER_THAN:
			return user.hp > amount_to_compare_against
		EnumUtils.Comparisons.IS_NOT_GREATER_THAN:
			return not user.hp > amount_to_compare_against
		EnumUtils.Comparisons.IS_GREATER_THAN_OR_EQUAL_TO:
			return user.hp >= amount_to_compare_against
		EnumUtils.Comparisons.IS_NOT_GREATER_THAN_OR_EQUAL_TO:
			return not user.hp >= amount_to_compare_against
	return false
