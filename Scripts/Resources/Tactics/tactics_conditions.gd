extends Resource
class_name TacticsCondition

##Override in child classes
func is_condition_met(user: Monster) -> bool:
	return false
