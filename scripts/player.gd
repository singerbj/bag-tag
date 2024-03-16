extends CharacterBody2D

const JUMP_FORCE := 1800 #-1500
const DASH_FORCE := 1300
const GRAVITY := 2700
const MINIMUM_SWIPE_DISTANCE := 100
const DEFAULT_JUMP_BUDGET := 0.1
const DEFAULT_DASH_BUDGET := 0.5
const DEFAULT_MOVEMENT_SPEED := 500

var swipe_start = null
var jump_budget = DEFAULT_JUMP_BUDGET
var jumping = false
var dash_budget = 0

func _ready() -> void:
	$Label2.visible = false

func _process(delta):
	velocity.y += GRAVITY * delta
		
	if dash_budget > 0:
		$Label2.visible = true
		velocity.x = DASH_FORCE
		dash_budget -= 1 * delta
		if dash_budget < 0:
			dash_budget = 0
	else:
		$Label2.visible = false
		velocity.x = DEFAULT_MOVEMENT_SPEED
		
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
  
	move_and_slide()
	
	$Label.text = str(self.position)
	
func _input(event):
	if event is InputEventKey:
		if event.is_action_pressed("ui_up"):
			if is_on_floor(): jumping = true
			if event is InputEventScreenTouch:
				swipe_start = event.get_position()
		if event.is_action_released("ui_up"):
			jumping = false
			if event is InputEventScreenTouch:
				_calculate_swipe(event.get_position())
		
		if event.is_action_pressed("ui_right"):
			dash_budget = DEFAULT_DASH_BUDGET
			
	if event is InputEventScreenTouch:
		if event.is_pressed():
			if is_on_floor(): jumping = true
			swipe_start = event.get_position()
		if event.is_released():	
			jumping = false
			_calculate_swipe(event.get_position())
		

func _calculate_swipe(swipe_end):
	if swipe_start != null: 
		var swipe = swipe_end - swipe_start
		if abs(swipe.x) > MINIMUM_SWIPE_DISTANCE:
			if swipe.x > 0:
				dash_budget = DEFAULT_DASH_BUDGET
			else:
				print("swipe left, doesn't do anything")
