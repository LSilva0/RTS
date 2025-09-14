extends Node2D
@export var building_area := Rect2(0, 0, 128, 128)
@export var parent_building : Node2D
var query_rect = RectangleShape2D.new()
var can_build = []
var has_built = false
var placed = false
signal build_building

# Remove this entire function:
func _input(event):
	if event.is_action_pressed("build") and can_build.size() == 0 and placed == false:
		build_building.emit()
		placed = true
		has_built = true
		queue_redraw()
		
		# Add this new public method instead:
func try_place_building() -> bool:
	if can_build.size() == 0 and placed == false:
		build_building.emit()
		placed = true
		has_built = true
		queue_redraw()
		return true
	return false

func _process(delta):
	if !has_built:
		# keep the building following the mouse
		parent_building.global_position = get_global_mouse_position()

		# center the local building_area around the parent
		building_area.position = -(building_area.size / 2)

		# prepare rectangle query according to the build node's scale
		var world_scale = Vector2.ONE
		if parent_building:
			world_scale = parent_building.global_scale

		# set the query_rect extents (RectangleShape2D uses extents)
		query_rect.extents = (building_area.size * world_scale) / 2.0

		var space = get_world_2d().direct_space_state
		var q = PhysicsShapeQueryParameters2D.new()
		q.shape = query_rect
		q.collision_mask = 3
		# position the query at the building's global position
		q.transform = Transform2D(0, parent_building.global_position)

		can_build = space.intersect_shape(q)
		queue_redraw()

func _draw():
	if can_build.size() == 0 and !has_built:
		draw_rect(building_area, Color(0,1,0,.5))
	elif !has_built:
		draw_rect(building_area, Color(1,0,0,.5))
	else:
		draw_rect(building_area, Color.TRANSPARENT)
