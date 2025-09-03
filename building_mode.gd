extends Node2D

@export var building_area := Rect2(0, 0, 64, 64)
var query_rect = RectangleShape2D.new()
var can_build = []

func _process(delta):
	building_area.position = get_global_mouse_position() - building_area.size/2
	var space = get_world_2d().direct_space_state
	query_rect.size = abs(building_area.size)
	var q = PhysicsShapeQueryParameters2D.new()
	q.shape = query_rect
	q.collision_mask = 2
	q.transform = Transform2D(0, get_global_mouse_position())
	can_build = space.intersect_shape(q)
	queue_redraw()
	
func _draw():
	if can_build.size() == 0:
		draw_rect(building_area, Color.GREEN)
	else:
		draw_rect(building_area, Color.RED)
