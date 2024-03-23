extends GameObject

class_name Backpack

func _ready() -> void:
	var backpackSprites = [
		$BackpackSprites/BackpackSprite0,
		$BackpackSprites/BackpackSprite1,
		$BackpackSprites/BackpackSprite2,
		$BackpackSprites/BackpackSprite3,
		$BackpackSprites/BackpackSprite4,
		$BackpackSprites/BackpackSprite5,
		$BackpackSprites/BackpackSprite6
	]

	for backpackSprite in backpackSprites:
		backpackSprite.hide()
		
	backpackSprites.pick_random().show()
