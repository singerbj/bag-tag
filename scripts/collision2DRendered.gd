extends Node2D

@export var color: Color = Color.WHITE

func _draw():
	if get_parent() is CollisionShape2D:
		get_parent().shape.draw(get_canvas_item(), color)
	elif get_parent() is CollisionPolygon2D:
		draw_polygon(get_parent().polygon, [ color ])
	else:
		assert(false, "ERROR: You must use the Collision2DRendered as a child of a CollisionShape2D or CollisionPolygon2D.");
	
