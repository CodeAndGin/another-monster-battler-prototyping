class_name GlobalUtils

enum ActionTypes \
{
	SKILL,
	SPELL,
	FIELD,
	TRAP,
	CHANNEL,
	COMBO,
	BUFF,
	DEBUFF
}

enum MoveEffectTypes \
{
	PHYS_DAMAGE,
	MAG_DAMAGE,
	STAT_DAMAGE,
	HEAL,
	RALLY,
	RISK,
	GUARD,
	SHIELD,
	POISON,
	BURN,
	BESPOKE
}

enum DamageTypes \
{
	MAGICAL,
	PHYSICAL,
	STATUS
}

enum Ranges \
{
	MELEE,
	RANGED
}

enum TargetTypes \
{
	SELF,
	RIVAL,
	ALLY
}

enum ReactionTimings \
{
	BEFORE,
	AFTER
}

enum PlayerIdents \
{
	PLAYER,
	RIVAL_PLAYER
}

#enum EventStates \
#{
	#
#}
#enum TargetTypesComp \
#{
	#SELF,
	#ALLY,
	#ALLY_AND_SELF
#}

enum ActorTypes \
{
	PLAYER,
	MONSTER
}


enum Comparisons \
{
	IS,
	IS_NOT,
	IS_EQUAL_TO,
	IS_NOT_EQUAL_TO,
	IS_LESS_THAN,
	IS_NOT_LESS_THAN,
	IS_LESS_THAN_OR_EQUAL_TO,
	IS_NOT_LESS_THAN_OR_EQUAL_TO,
	IS_GREATER_THAN,
	IS_NOT_GREATER_THAN,
	IS_GREATER_THAN_OR_EQUAL_TO,
	IS_NOT_GREATER_THAN_OR_EQUAL_TO
}

enum TargetPriorities \
{
	HIGHEST_HP, #TODO: Fill out
}

static func get_condition_variable_names() -> Array:
	return \
	[
		"HP",
		"eHP",
	]

static func get_condition_variable_values(user: Monster, arena: Arena) -> Array:
	return \
	[
		user.hp,
		arena.active_refs[user.opponent_key].hp
	]

#Modified version of evaluate from https://docs.godotengine.org/en/3.6/tutorials/scripting/evaluating_expressions.html
static func evaluate(command, variable_names = [], variable_values = []):
	var expression = Expression.new()
	var error = expression.parse(command, variable_names)
	if error != OK:
		push_error(expression.get_error_text())
		return

	var result = expression.execute(variable_values)

	if not expression.has_execute_failed():
		#print(str(result))
		return result

static func compare_actors_by_priority(curr: Actor, to_check: Actor, priority: TargetPriorities) -> Actor:
	match priority:
		_:
			printerr("That priority type has not been defined in the comparison function")
		TargetPriorities.HIGHEST_HP:
			return curr if curr.hp >= to_check.hp else to_check
	return curr


#
#enum Targets \
#{
	#SELF,
	#ACTIVE_ALLY,
	#BENCH_ALLY_1,
	#BENCH_ALLY_2,
	#ACTIVE_OPPONENT,
	#BENCH_OPPONENT_1,
	#BENCH_OPPONENT_2,
	#ANY
#}
#
#enum Values \
#{
	#AV,
	#RV,
	#CT,
	#HP,
	#MAX_HP,
	#RISK,
	#GUARD,
	#SHIELD,
	#DIRECT_ORDERED,
	#ANY
#}
