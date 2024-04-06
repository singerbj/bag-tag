extends CharacterBody2D

class_name Player

const People = preload("res://scripts/people.gd")
const Suitcase = preload("res://scripts/suitcase.gd")
const Backpack = preload("res://scripts/backpack.gd")

const JUMP_FORCE := 1800
const DASH_FORCE := 1300
const GRAVITY := 2700
const MINIMUM_SWIPE_DISTANCE := 100
const DEFAULT_JUMP_BUDGET := 0.1
const DEFAULT_DASH_BUDGET := 0.5
const DEFAULT_MOVEMENT_SPEED := 500
const SPEED_MULTIPLIER_INCREMENT = 0.00001

var swipe_start = null
var jump_budget = DEFAULT_JUMP_BUDGET
var jumping = false
var dash_available = true
var dash_budget = 0
var speed_multiplier = 1.0
var hit_people = false

@onready var game_scene: Game
@onready var main_scene: Main

func _ready() -> void:
	_hide_flames()
	$DashSprite.visible = false
	$TagSprite.visible = false
	game_scene = get_parent()
	main_scene = get_parent().get_parent().get_parent()
	
func _process(delta):
	if game_scene.current_game_state == game_scene.GameState.Running:
		speed_multiplier += SPEED_MULTIPLIER_INCREMENT
		
		velocity.y += GRAVITY * delta
			
		if jumping:
			if is_on_floor() && jump_budget == DEFAULT_JUMP_BUDGET:
				velocity.y = -JUMP_FORCE
			elif !is_on_floor() && jump_budget > 0 && jump_budget < DEFAULT_JUMP_BUDGET:
				velocity.y = -JUMP_FORCE
				
			jump_budget -= 1 * delta
			if jump_budget < 0:
				jump_budget = 0
		else:
			if is_on_floor() && jump_budget < DEFAULT_JUMP_BUDGET:
				jump_budget = DEFAULT_JUMP_BUDGET
				dash_available = true
		
		if dash_budget > 0:
			_show_flames()
			$DashSprite.visible = true
			velocity.y = clamp(velocity.y, -INF, 0)
			velocity.x = DASH_FORCE * speed_multiplier
			dash_budget -= 1 * delta
			if dash_budget < 0:
				dash_budget = 0
		else:
			_hide_flames()
			$DashSprite.visible = false
			velocity.x = DEFAULT_MOVEMENT_SPEED * speed_multiplier
		
		if !hit_people:
			move_and_slide()
		
		_handle_collisions()
	
func _handle_collisions():
	for index in get_slide_collision_count():
		var collision := get_slide_collision(index)
		var game_object := collision.get_collider()
		if game_object is People:
			print("Collided with People: ", game_object.name)
			if !hit_people && !$GaspAudioStreamPlayer.playing:
				$GaspAudioStreamPlayer.playing = true
			hit_people = true
			$DashSprite.visible = true
			game_scene.get_node("MusicAudioStreamPlayer").playing = false
			_smack_game_object(game_object, 3, func():
				$GameOverAudioStreamPlayer.playing = true
				game_scene.stop_game()
				main_scene.on_game_over(get_parent().points)
			)
			break
		elif game_object is Backpack || game_object is Suitcase:
			print("Collided with Backpack/Suitcase: ", game_object.name)
			$TagSprite.visible = true
			if(!game_object.impulse_applied):
				$TagAudioStreamPlayer.playing = true
			if(!game_object.point_counted):
				game_scene.points += 1
			_smack_game_object(game_object, 1.5, func(): $TagSprite.visible = false)
			break

func _get_random_force(min: int, max: int):
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	return rng.randi_range(min, max)

func _smack_game_object(game_object: GameObject, wait_time: int, callback: Callable = func():):
	if(!game_object.impulse_applied):
		game_object.impulse_applied = true
		game_object.apply_impulse(Vector2(_get_random_force(1000, 1100), _get_random_force(-1100, -1000)), Vector2(-100, 100))
	
	var timer := Timer.new()
	game_object.add_child(timer)
	timer.wait_time = wait_time
	timer.one_shot = true
	timer.connect("timeout", func(): 
		timer.get_parent().queue_free()
		callback.call()
	)
	timer.start()
	
func _unhandled_input(event):
	if game_scene.current_game_state == game_scene.GameState.Running:
		if event is InputEventKey:
			if event.is_action_pressed("ui_up"):
				if is_on_floor():
					jumping = true
					$JumpAudioStreamPlayer.playing = true
				if event is InputEventScreenTouch:
					swipe_start = event.get_position()
			if event.is_action_released("ui_up"):
				jumping = false
				if event is InputEventScreenTouch:
					_calculate_swipe(event.get_position())
			
			if event.is_action_pressed("ui_right") && dash_available && !is_on_floor():
				dash_budget = DEFAULT_DASH_BUDGET
				$DashAudioStreamPlayer.playing = true
				dash_available = false
			
	if event is InputEventScreenTouch:
		if event.is_pressed():
			if is_on_floor(): 
				jumping = true
				$JumpAudioStreamPlayer.playing = true
			swipe_start = event.get_position()
		if event.is_released():	
			jumping = false
			_calculate_swipe(event.get_position())

func _calculate_swipe(swipe_end):
	if swipe_start != null: 
		var swipe = swipe_end - swipe_start
		if abs(swipe.x) > MINIMUM_SWIPE_DISTANCE:
			if swipe.x > 0:
				if dash_available && !is_on_floor():
					dash_budget = DEFAULT_DASH_BUDGET
					$DashAudioStreamPlayer.playing = true
					dash_available = false
			else:
				print("swipe left, doesn't do anything")
				
func _hide_flames():
	$Fire.visible = false
	$Fire/Flames1.visible = false
	$Fire/Flames2.visible = false
				
func _show_flames():
	$Fire.visible = true
	$Fire/Flames1.visible = true
	var timer := Timer.new()
	add_child(timer)
	timer.wait_time = 0.15
	timer.one_shot = true
	timer.connect("timeout", func(): $Fire/Flames2.visible = true)
	timer.start()
