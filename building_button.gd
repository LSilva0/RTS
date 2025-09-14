# BuildingButton.gd - Updated to handle both building selection and placement
extends Control

@export var building_id: String = "flier_base"
@export var building_name: String = "Flier Base"
@export var building_cost: int = 50
@export var building_sprite: Texture2D
@export var building_scene: PackedScene

@onready var sprite_button = $VBoxContainer/Button
@onready var name_label = $VBoxContainer/Label
@onready var cost_label = $VBoxContainer/CostLabel

signal building_selected(building_data)

var is_in_building_mode = false
var building_manager: Node

func _ready():
	add_to_group("building_buttons")
	Economy.money_changed.connect(_on_money_changed)
	
	# Find the building manager
	building_manager = get_tree().get_first_node_in_group("building_manager")
	
	setup_button()

func setup_button():
	if sprite_button and building_sprite:
		sprite_button.icon = building_sprite
	
	if name_label:
		name_label.text = building_name
	
	if cost_label:
		cost_label.text = str(building_cost) + " $"
	
	if sprite_button:
		sprite_button.pressed.connect(_on_button_pressed)
	
	update_button_state()

func _on_button_pressed():
	if not is_in_building_mode:
		# First click: Start building mode
		var building_data = {
			"id": building_id,
			"name": building_name,
			"cost": building_cost,
			"sprite": building_sprite,
			"scene": building_scene
		}
		building_selected.emit(building_data)
		is_in_building_mode = true
		cost_label.text = "Place Building"
	else:
		# Second click: Try to place the building
		print("Button pressed in building mode")
		if building_manager:
			print("Building manager found")
			if building_manager.current_building_instance:
				print("Current building instance exists")
				var building_mode = building_manager.current_building_instance.get_node("BuildingMode")
				if building_mode:
					print("BuildingMode node found, calling try_place_building")
					if building_mode.try_place_building():
						print("Building placed successfully")
						is_in_building_mode = false
						sprite_button.text = ""
					else:
						print("Building placement failed")
				else:
					print("BuildingMode node NOT found")
			else:
				print("No current building instance")
		else:
			print("Building manager not found")

func _on_money_changed(new_amount: int):
	update_button_state()

func update_button_state():
	var can_afford = Economy.can_afford(building_cost)
	
	if sprite_button:
		sprite_button.disabled = !can_afford
	
	if can_afford:
		modulate = Color.WHITE
	else:
		modulate = Color(0.5, 0.5, 0.5, 1.0)
	
	if cost_label:
		if can_afford:
			cost_label.modulate = Color.WHITE
		else:
			cost_label.modulate = Color.RED

# Reset button state when building is cancelled
func reset_building_mode():
	is_in_building_mode = false
	cost_label.text = ""
