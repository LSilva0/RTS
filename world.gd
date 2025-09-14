extends Node2D

var dragging = false
var drag_start = Vector2.ZERO
var select_rect = RectangleShape2D.new()
var selected = []
var has_building = false
var build_mode_on = false
var current_building = null

@onready var building_scene = preload("res://basic_building.tscn")
@export var color_rect = ColorRect
func _ready():
	color_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	
func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			if selected.size() == 0: #Checks if there are units selected
				dragging = true
				drag_start = event.position
			else:
				for item in selected:
					item.collider.target = event.position
					item.collider.selected = false
				selected = [] #Process every item, point them towards the event - mouse click - then unselect them
		elif dragging:
			dragging = false
			queue_redraw()
			var drag_end = event.position
			select_rect.size = abs(drag_end - drag_start)
			var space = get_world_2d().direct_space_state
			var q = PhysicsShapeQueryParameters2D.new()
			q.shape = select_rect
			q.collision_mask = 2
			q.transform = Transform2D(0, (drag_end + drag_start) / 2)
			selected = space.intersect_shape(q) #Actual selection inside the rect area
			for item in selected:
				item.collider.selected = true
	if event is InputEventMouseMotion and dragging:
		queue_redraw()


func _on_building_placed():
	build_mode_on = false

func _draw():
	if dragging:
		draw_rect(Rect2(drag_start, get_global_mouse_position() - drag_start), Color.AQUA, false, 2)
