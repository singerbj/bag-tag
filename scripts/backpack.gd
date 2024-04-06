extends GameObject

class_name Backpack

var backpackSprites

func _ready() -> void:
	backpackSprites = [
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
	
func _process(delta: float) -> void:
	if impulse_applied:
		$CollisionPolygon2D.disabled = true
		for backpackSprite in backpackSprites:
			backpackSprite.modulate.a -= (1 * delta)
