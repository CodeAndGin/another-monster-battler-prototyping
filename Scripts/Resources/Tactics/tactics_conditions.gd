extends Resource
class_name TacticsCondition

##Override in child classes
func is_condition_met(user: Actor = null, target: Actor = null, move_target: Move = null) -> bool:
	return false

func check(potential_targets: Array[Actor]) -> Array[Actor]:
	return potential_targets
