extends Resource
class_name TacticsCondition

##Override in child classes
func is_condition_met(user: Actor = null, target: Actor = null, move_target: Move = null) -> bool:
	return false

func check(arena: Arena = null, user: Actor = null, potential_targets: Array[Actor] = [], move_to_use: Move = null, move_target: Move = null):
	return potential_targets
