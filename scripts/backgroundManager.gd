extends Node

const BKRD_SCALE = 1.25
const BKRD_WIDTH = 1080
const BKRD_HEIGHT = 1920
const BKRD_OFFSET = 285
const MIN_BKRDS = 10

var Blank = preload("res://assets/art/Blank.PNG")
var BlankDoor = preload("res://assets/art/BlankDoor.PNG")
var Shop = preload("res://assets/art/shop.PNG")
var WindowsWithPlane = preload("res://assets/art/WindowsWithPlane.PNG")
var WindowsWithStuff = preload("res://assets/art/WindowsWithStuff.PNG")
var Windows = preload("res://assets/art/Windows.PNG")

var backgroundTextures = [
	BlankDoor,
	Shop,
	WindowsWithPlane,
	WindowsWithStuff,
	WindowsWithPlane,
	WindowsWithStuff,
	Windows
]
var next_background_x = -BKRD_WIDTH * 5
var game_scene
var player_scene
var last_picked_bkrd = backgroundTextures[0]

func _ready() -> void:
	game_scene = get_parent()
	player_scene = game_scene.get_node("Player")
	
func _process(delta: float) -> void:
	for child in get_children():
		if (player_scene.position.x - child.position.x) > BKRD_WIDTH * BKRD_SCALE * 10:
			child.queue_free()
		else:
			child.position.x += delta * 100
		
	if get_child_count() < MIN_BKRDS:
		for i in (MIN_BKRDS - get_child_count()):
			_add_background()
			
	next_background_x += delta * 100
		
func _add_background() -> void:
	var new_sprite = Sprite2D.new()
	new_sprite.texture = backgroundTextures.pick_random()
	while(new_sprite.texture == last_picked_bkrd):
		new_sprite.texture = backgroundTextures.pick_random()
	last_picked_bkrd = new_sprite.texture
		
	add_child(new_sprite)
	new_sprite.scale = Vector2(BKRD_SCALE, BKRD_SCALE)
	new_sprite.position.x = next_background_x + (BKRD_WIDTH / 2)
	new_sprite.position.y = (BKRD_HEIGHT / 2) - BKRD_OFFSET
	next_background_x += (BKRD_WIDTH * BKRD_SCALE * 2) - 300
