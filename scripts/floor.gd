extends StaticBody2D

func _process(delta: float) -> void:
	self.position.y += 1 * delta
	print(self.position.y)
