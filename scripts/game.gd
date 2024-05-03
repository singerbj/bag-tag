extends Node2D

class_name Game

const GAME_OBJECT_SCENES = [
	preload("res://scenes/people/Bina.tscn"),
	preload("res://scenes/people/Ben.tscn"),
	preload("res://scenes/people/Dad.tscn"),
	preload("res://scenes/people/Gigi.tscn"),
	preload("res://scenes/people/MagJake.tscn"),
	preload("res://scenes/bags/Backpack.tscn"),
	preload("res://scenes/bags/Suitcase.tscn")
]

const MIN_GAME_OBJECT_SPAWN_DELAY = 2.5
const MIN_GAME_OBJECT_SPAWN_DISTANCE = 2500
const MIN_GAME_OBJECT_VARIATION_RANGE = 1000
const MAX_GAME_OBJECT_VARIATION_RANGE = 1000
const MIN_GAME_OBJECT_DELETE_DISTANCE = 2000
const RESET_POSITION_INTERVAL = 5
const POINT_DISTANCE_BUFFER = 500

var rng = RandomNumberGenerator.new()
var last_position_reset = 0
var last_game_object_spawn_time = 0
var last_game_objects = []
var last_pause = 0
var points = 0
var game_object_scenes = GAME_OBJECT_SCENES.duplicate()
var last_game_object : PackedScene

var game_objects = []

enum GameState {
	Running,
	Paused,
	Stopped
}
var current_game_state = GameState.Paused

@onready var camera = $Floor/Camera

func _ready() -> void:
	get_parent().get_node("CanvasLayer").hide()
	game_object_scenes.shuffle()
	last_game_object = game_object_scenes[game_object_scenes.size() - 1]

func _process(_delta: float) -> void:
	var current_time = Time.get_unix_time_from_system()
	if current_game_state == GameState.Paused:
		if last_pause == 0:
			last_pause = current_time
	elif current_game_state == GameState.Running:
		if last_pause != 0:
			var offset = current_time - last_pause
			last_position_reset += offset
			last_game_object_spawn_time += offset
			last_pause = 0
			
		$Floor.position.x = $Player.position.x
		
		if (current_time - last_game_object_spawn_time) > MIN_GAME_OBJECT_SPAWN_DELAY:
			last_game_object_spawn_time = current_time
			var new_last_game_object = 0
			if last_game_objects.size() == game_object_scenes.size():
				last_game_objects = []
				game_object_scenes = GAME_OBJECT_SCENES.duplicate()
				game_object_scenes.shuffle()
				while game_object_scenes[0] == last_game_object:
					game_object_scenes.shuffle()
				last_game_object = game_object_scenes[game_object_scenes.size() - 1]
				
			while last_game_objects.has(new_last_game_object):
				new_last_game_object += 1
			last_game_objects.append(new_last_game_object)
			
			var new_game_object: RigidBody2D = game_object_scenes[new_last_game_object].instantiate()
			new_game_object.position.x = $Player.position.x + MIN_GAME_OBJECT_SPAWN_DISTANCE + _get_game_object_variation_range()
			new_game_object.position.y = $Player.position.y
			game_objects.append(new_game_object)
			add_child(new_game_object)
			if _should_apply_random_rotation():
				new_game_object.inertia = 100
				new_game_object.apply_torque_impulse(_get_random_force())
				new_game_object.inertia = 0
				
	get_parent().get_node("CanvasLayer/ScoreLabel").text = " " + str(points)  + (" point" if points == 1 else " points")
		
func _physics_process(_delta: float) -> void:
	if current_game_state == GameState.Running && !$Player.hit_people:
		for i in range(game_objects.size()-1, -1, -1):
			if is_instance_valid(game_objects[i]): 
				var game_object: RigidBody2D = game_objects[i]
				if !(game_object is Backpack or game_object is Suitcase) && !game_object.point_counted && game_object.position.x < ($Player.position.x - POINT_DISTANCE_BUFFER):
					$DodgeAudioStreamPlayer.playing = true
					points += 1
					game_object.point_counted = true
				
				if ($Player.position.x - game_object.position.x) > MIN_GAME_OBJECT_DELETE_DISTANCE:
					game_object.queue_free()
					game_objects.remove_at(i)
			else:
				game_objects.remove_at(i)
		
func _get_random_number(min, max) -> float:
	rng.randomize()
	return rng.randi_range(min, max)

func _get_random_game_object_index():
	return _get_random_number(0, game_object_scenes.size() - 1)

func _get_game_object_variation_range():
	return _get_random_number(MIN_GAME_OBJECT_VARIATION_RANGE, MAX_GAME_OBJECT_VARIATION_RANGE)
	
func _should_apply_random_rotation():
	return _get_random_number(0, 100) > 95

func _get_random_force():
	return 200 if _get_random_number(0, 1) > 0 else -200
			
func start_game():
	if current_game_state == GameState.Paused:
		get_parent().get_node("CanvasLayer").show()
		if !$MusicAudioStreamPlayer.playing:
			$MusicAudioStreamPlayer.playing = true
		camera.enabled = true
		current_game_state = GameState.Running
	elif current_game_state == GameState.Stopped:
		print("Error: Cannot start a stopped game!")
	elif current_game_state == GameState.Stopped:
		print("Error: Cannot start an already started game!")
		
func pause_game():
	if current_game_state == GameState.Paused:
		print("Error: Cannot pause an already paused game!")
	elif current_game_state == GameState.Running:
		get_parent().get_node("CanvasLayer").hide()
		#$MusicAudioStreamPlayer.playing = false
		camera.enabled = false
		current_game_state = GameState.Paused
	elif current_game_state == GameState.Stopped:
		print("Error: Cannot pause an already stopped game!")
		
func stop_game():
	if current_game_state == GameState.Running || current_game_state == GameState.Paused:
		get_parent().get_node("CanvasLayer").hide()
		$MusicAudioStreamPlayer.playing = false
		camera.enabled = false
		current_game_state = GameState.Stopped
	elif current_game_state == GameState.Stopped:
		print("Error: Cannot stop an already stopped game!")
	
