extends Node2D

class_name Game

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

enum GameState {
	Running,
	Paused,
	Stopped
}
var current_game_state = GameState.Paused

@onready var camera = $Floor/Camera

func _ready() -> void:
	get_parent().get_node("CanvasLayer").hide()

func _process(_delta: float) -> void:
	if current_game_state == GameState.Running:
		var current_time = Time.get_unix_time_from_system()
		$Floor.position.x = $Player.position.x
		
		if (current_time - last_game_object_spawn) > MIN_GAME_OBJECT_SPAWN_DELAY:
			last_game_object_spawn = current_time
			var new_game_object = game_object_scenes.pick_random().instantiate()
			new_game_object.position.x = $Player.position.x + MIN_GAME_OBJECT_SPAWN_DISTANCE + _get_game_object_variation_range()
			new_game_object.position.y = $Player.position.y
			game_objects.append(new_game_object)
			add_child(new_game_object)
		
func _physics_process(_delta: float) -> void:
	if current_game_state == GameState.Running:
		for i in range(game_objects.size()-1, -1, -1):
			if is_instance_valid(game_objects[i]): 
				var game_object: RigidBody2D = game_objects[i]
				if ($Player.position.x - game_object.position.x) > MIN_GAME_OBJECT_DELETE_DISTANCE:
					game_object.queue_free()
					game_objects.remove_at(i)
			else:
				game_objects.remove_at(i)
		
func _get_game_object_variation_range():
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	return rng.randi_range(0, GAME_OBJECT_VARIATION_RANGE)

func _input(event):
	if current_game_state == GameState.Running:
		if event is InputEventKey:
			# TODO: Remove these later, probably
			if event.is_action_pressed("ui_cancel"):
				get_tree().quit()
			if event.is_action_pressed("reset_game"):
				$Player.position = Vector2(0, 0)
			
func start_game():
	if current_game_state == GameState.Paused:
		get_parent().get_node("CanvasLayer").show()
		$AudioStreamPlayer.playing = true
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
		$AudioStreamPlayer.playing = false
		camera.enabled = false
		current_game_state = GameState.Paused
	elif current_game_state == GameState.Stopped:
		print("Error: Cannot pause an already stopped game!")
		
func stop_game():
	if current_game_state == GameState.Running || current_game_state == GameState.Paused:
		$AudioStreamPlayer.playing = false
		current_game_state = GameState.Stopped
	elif current_game_state == GameState.Stopped:
		print("Error: Cannot stop an already stopped game!")
	
