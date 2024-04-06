extends GameObject

class_name Suitcase

func _process(delta: float) -> void:
	if impulse_applied:
		$CollisionPolygon2D.disabled = true
		$Sprite2D.modulate.a -= (1 * delta)
