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

var swipe_start = null
var jump_budget = DEFAULT_JUMP_BUDGET
var jumping = false
var dash_available = true
var dash_budget = 0

@onready var game_scene: Game
@onready var main_scene: Main

func _ready() -> void:
	$Fire.visible = false
	$DashSprite.visible = false
	game_scene = get_parent()
	main_scene = get_parent().get_parent().get_parent()
	
func _process(delta):
	if game_scene.current_game_state == game_scene.GameState.Running:
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
			$Fire.visible = true
			$DashSprite.visible = true
			velocity.y = clamp(velocity.y, -INF, 0)
			velocity.x = DASH_FORCE
			dash_budget -= 1 * delta
			if dash_budget < 0:
				dash_budget = 0
		else:
			$Fire.visible = false
			$DashSprite.visible = false
			velocity.x = DEFAULT_MOVEMENT_SPEED
		
		move_and_slide()
		
		_handle_collisions()
	
func _handle_collisions():
	for index in get_slide_collision_count():
		var collision := get_slide_collision(index)
		var body := collision.get_collider()
		if body is People:
			print("Collided with People: ", body.name)
			game_scene.stop_game()
			main_scene.on_game_over()
			break
		elif body is Backpack:
			print("Collided with Backpack: ", body.name)
			body.queue_free()
			game_scene.points += 1
			break
		elif body is Suitcase:
			print("Collided with Suitcase: ", body.name)
			body.queue_free()
			game_scene.points += 1
			break
	
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
