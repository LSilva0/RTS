# BuildingButton.gd
extends Control

@export var building_name: String = "Flier Base"
@export var building_sprite: Texture2D
@export var building_scene: PackedScene  # The actual building to spawn

@onready var sprite_button = $VBoxContainer/Button
@onready var name_label = $VBoxContainer/Label

# Signal to communicate with the main game/building system
signal building_selected(building_data)

func _ready():
	setup_button()
	
func setup_button():
	# Set up the sprite button
	if building_sprite:
		sprite_button.icon = building_sprite
	
	# Set up the name label
	name_label.text = building_name
	
	# Connect the button signal
	sprite_button.pressed.connect(_on_button_pressed)

func _on_button_pressed():
	var building_data = {
		"name": building_name,
		"sprite": building_sprite,
		"scene": building_scene
	}
	
	# Emit signal to activate building mode
	building_selected.emit(building_data)
	
	# Optional: Visual feedback that this building is selected
	modulate = Color.YELLOW  # Highlight the selected button
