extends Node2D

var obstacle_scene = preload("res://scenes/Obstacle.tscn")

const MIN_OBSTACLE_SPAWN_DELAY = 2.5
const MIN_OBSTACLE_SPAWN_DISTANCE = 3000
const OBSTACLE_VARIATION_RANGE = 1500
const MIN_OBSTACLE_DELETE_DISTANCE = 2000
const RESET_POSITION_INTERVAL = 5

var last_position_reset = 0
var last_obstacle_spawn = 0

var obstacles = []

func _process(_delta: float) -> void:
	var current_time = Time.get_unix_time_from_system()
	$Floor.position.x = $Player.position.x
	
	if (current_time - last_obstacle_spawn) > MIN_OBSTACLE_SPAWN_DELAY:
		last_obstacle_spawn = current_time
		var new_obstacle = obstacle_scene.instantiate()
		new_obstacle.position.x = $Player.position.x + MIN_OBSTACLE_SPAWN_DISTANCE + get_obstacle_variation_range()
		new_obstacle.position.y = $Player.position.y
		obstacles.append(new_obstacle)
		add_child(new_obstacle)
	
	#if (current_time - last_position_reset) > RESET_POSITION_INTERVAL:
		#print("resetting position")
		#last_position_reset = current_time
		#for obstacle in obstacles:
			#obstacle.position.x - $Player.position.x
			#
		#$Player.position.x = 0
		
func _physics_process(delta: float) -> void:
	for i in range(obstacles.size()-1, -1, -1):
		var obstacle = obstacles[i]
		if ($Player.position.x - obstacle.position.x) > MIN_OBSTACLE_DELETE_DISTANCE:
			obstacle.queue_free()
			obstacles.remove_at(i)
		
func get_obstacle_variation_range():
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	return rng.randi_range(0, OBSTACLE_VARIATION_RANGE)

func _input(event):
	if event is InputEventKey:
		if event.is_action_pressed("ui_cancel"):
			get_tree().quit()
		if event.is_action_pressed("reset_game"):
			$Player.position = Vector2(0, 0)
			
