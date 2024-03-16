extends Node2D


@export var color: Color = Color.WHITE

func _draw():
	get_parent().shape.draw(get_canvas_item(), color)
