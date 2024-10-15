class_name FuncUtils

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
