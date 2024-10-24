class_name EnumUtils

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

enum PlayerIdents \
{
	PLAYER,
	RIVAL_PLAYER
}

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
