extends Move
class_name Reaction

@export var reaction_timing_condition: ReactionTimingCondition

@export var before_or_after: GlobalUtils.ReactionTimings

@export var modifies_move: bool
var move_target: Move

func resolve():
	pass
