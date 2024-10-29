extends Node3D
class_name Actor

@export var arena: Arena
@export var type: GlobalUtils.ActorTypes
@export var default_name: String
@export var display_name: String

var team: int
var ally_point: Node3D
var bench_point: Node3D
var rival_point: Node3D
var rival_bench_point: Node3D
var own_player_point: Node3D
var rival_player_point: Node3D

var av = 0 #private container, do not use
var action_value:
	get:
		if casting:
			return av + connected_move_container.get_children()[0].action_value
		return av
	set(value):
		var change = value-action_value
		if change > 0:
			av += change
		if change < 0:
			if casting:
				if connected_move_container.get_children()[0].action_value + change >= 0:
					connected_move_container.get_children()[0].action_value += change
					return
				else:
					change += connected_move_container.get_children()[0].action_value
					connected_move_container.get_children()[0].action_value = 0
					av += change
					return
			av += change

var rv: int
var MAX_RV: int
var overcapping_rv: bool

var connected_move_container: Node3D
var casting = false
#@onready var generic_move = preload("res://Gameplay Scenes/generic_basic_move.tscn")

func check_connected_move_container(container: Node3D) -> bool:
	return container == connected_move_container

func find_arena():
	arena = get_tree().root.get_node("BattleArena")

func _ready() -> void:
	if arena:
		if arena.name != "BattleArena":
			find_arena()
	if not arena: find_arena()

func gain_shield(amount: int): #TODO: implement shield
	pass

func get_actor_targets(target_types: TargetStructure) -> Array[Actor]:
	if not team or not ally_point or not bench_point \
	or not rival_point or not rival_bench_point \
	or not own_player_point or not rival_player_point:
		printerr("DEBUG: At least 1 reference for targeting has not been set. Returning empty target list")
		return []
	
	var potential_targets: Array[Actor]
	
	for type in target_types.active:
		match type:
			GlobalUtils.TargetTypes.SELF:
				var allies = ally_point.get_children()
				if allies.has(self):
					potential_targets.append(self)
			GlobalUtils.TargetTypes.ALLY:
				var allies = ally_point.get_children()
				if allies.has(self):
					allies.erase(self)
				for ally in allies:
					potential_targets.append(ally)
			GlobalUtils.TargetTypes.RIVAL:
				for rival in rival_point.get_children():
					potential_targets.append(rival)
			_:
				printerr("DEBUG: Something went wrong in the actives target list. Ensure all relevent target types are monitored")
	
	for type in target_types.benched:
		match type:
			GlobalUtils.TargetTypes.SELF:
				var allies = bench_point.get_children()
				if allies.has(self):
					potential_targets.append(self)
			GlobalUtils.TargetTypes.ALLY:
				var allies = bench_point.get_children()
				if allies.has(self):
					allies.erase(self)
				for ally in allies:
					potential_targets.append(ally)
			GlobalUtils.TargetTypes.RIVAL:
				for rival in rival_bench_point.get_children():
					potential_targets.append(rival)
			_:
				printerr("DEBUG: Something went wrong in the benched target list. Ensure all relevent target types are monitored")
	
	#### This one feels dubious ####
	for type in target_types.players:
		match type:
			GlobalUtils.PlayerIdents.PLAYER:
				var friendly_players = own_player_point.get_children()
				for player in friendly_players:
					potential_targets.append(player)
			GlobalUtils.PlayerIdents.RIVAL_PLAYER:
				var rival_players = rival_player_point.get_children()
				for player in rival_players:
					potential_targets.append(player)
			_:
				printerr("DEBUG: Something went wrong in the player target list. Ensure all relevent target types are monitored")
	
	return potential_targets
