extends Sprite2D

@export var unit_scene_path = "res://unit.tscn"
var loaded_unit : PackedScene

func _ready():
	loaded_unit = load(unit_scene_path)

func _on_spawn_timer_timeout() -> void:
	var new_unit = loaded_unit.instantiate()
	get_tree().root.add_child(new_unit)
	new_unit.global_position = $SpawnPosition.global_position
