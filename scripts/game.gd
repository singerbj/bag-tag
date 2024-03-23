extends Node2D


const Player = preload("res://scripts/player.gd")
const game_object_scenes = [
	preload("res://scenes/people/Bina.tscn"),
	preload("res://scenes/people/Ben.tscn"),
	preload("res://scenes/people/Dad.tscn"),
	preload("res://scenes/people/Gigi.tscn"),
	preload("res://scenes/people/MagJake.tscn"),
	preload("res://scenes/bags/Backpack.tscn"),
	preload("res://scenes/bags/Suitcase.tscn")
]

const MIN_GAME_OBJECT_SPAWN_DELAY = 2.5
const MIN_GAME_OBJECT_SPAWN_DISTANCE = 3000
const GAME_OBJECT_VARIATION_RANGE = 1500
const MIN_GAME_OBJECT_DELETE_DISTANCE = 2000
const RESET_POSITION_INTERVAL = 5

var last_position_reset = 0
var last_game_object_spawn = 0

var game_objects = []

class Game:
	func _init():
		pass

func _ready() -> void:
	pass
	
func _process(_delta: float) -> void:
	var current_time = Time.get_unix_time_from_system()
	$Floor.position.x = $Player.position.x
	
	if (current_time - last_game_object_spawn) > MIN_GAME_OBJECT_SPAWN_DELAY:
		last_game_object_spawn = current_time
		var new_game_object = game_object_scenes.pick_random().instantiate()
		new_game_object.position.x = $Player.position.x + MIN_GAME_OBJECT_SPAWN_DISTANCE + get_game_object_variation_range()
		new_game_object.position.y = $Player.position.y
		game_objects.append(new_game_object)
		add_child(new_game_object)
	
	#if (current_time - last_position_reset) > RESET_POSITION_INTERVAL:
		#print("resetting position")
		#last_position_reset = current_time
		#for game_object in game_objects:
			#game_object.position.x - $Player.position.x
			#
		#$Player.position.x = 0
		
func _physics_process(_delta: float) -> void:
	for i in range(game_objects.size()-1, -1, -1):
		if is_instance_valid(game_objects[i]): 
			var game_object: RigidBody2D = game_objects[i]
			if ($Player.position.x - game_object.position.x) > MIN_GAME_OBJECT_DELETE_DISTANCE:
				game_object.queue_free()
				game_objects.remove_at(i)
		else:
			game_objects.remove_at(i)
		
func get_game_object_variation_range():
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	return rng.randi_range(0, GAME_OBJECT_VARIATION_RANGE)

func _input(event):
	if event is InputEventKey:
		if event.is_action_pressed("ui_cancel"):
			get_tree().quit()
		if event.is_action_pressed("reset_game"):
			$Player.position = Vector2(0, 0)
			
