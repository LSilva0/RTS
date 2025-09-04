extends Sprite2D

@export var unit_scene_path = "res://unit.tscn"
var loaded_unit : PackedScene
var is_building = true
@onready var building_mode := $BuildingMode
func _ready():
	loaded_unit = load(unit_scene_path)
	building_mode.build_building.connect(_set_building_mode)

func _on_spawn_timer_timeout() -> void:
	if !is_building:
		var new_unit = loaded_unit.instantiate()
		get_tree().root.add_child(new_unit)
		new_unit.global_position = $SpawnPosition.global_position

func _set_building_mode():
	is_building = false
	$StaticBody2D/CollisionShape2D.disabled = false
