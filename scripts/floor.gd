extends StaticBody2D

class Floor:
	func _init():
		pass

func _process(delta: float) -> void:
	self.position.y += 1 * delta
