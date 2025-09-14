# BuildingManager.gd - Updated for multiple buildings
extends Control

var current_building_instance: Node2D = null
var current_building_data: Dictionary = {}

# Building definitions with costs
var building_types = {
	"flier_base": {
		"name": "Flier Base",
		"cost": 100,
		"scene": preload("res://basic_building.tscn")
	},
	"heavy_base": {
		"name": "Heavy Base",
		"cost": 200,
		"scene": preload("res://basic_building.tscn")  # You can use different scenes
	}
}

func _ready():
	# Add to group so buttons can find this manager
	add_to_group("building_manager")
	
	# Connect to all building buttons
	connect_building_buttons()
	
	# Connect to economy signals
	Economy.insufficient_funds.connect(_on_insufficient_funds)

func connect_building_buttons():
	# Find all building buttons and connect them
	var buttons = get_tree().get_nodes_in_group("building_buttons")
	for button in buttons:
		if button.has_signal("building_selected"):
			button.building_selected.connect(start_building_mode)

func start_building_mode(building_data: Dictionary):
	# Check if we can afford this building
	var cost = building_data.get("cost", 0)
	if not Economy.can_afford(cost):
		_on_insufficient_funds(cost, Economy.get_money())
		return
	
	# Cancel existing building
	if current_building_instance:
		current_building_instance.queue_free()
	
	# Store building data for when we place it
	current_building_data = building_data
	
	# Instantiate the building
	current_building_instance = building_data.scene.instantiate()
	add_child(current_building_instance)
	
	# Set up building mode - Connect to BuildingMode's build_building signal
	var building_mode = current_building_instance.get_node("BuildingMode")
	if building_mode:
		building_mode.parent_building = current_building_instance
		# This is the key fix - connect to the manager's placement handler
		building_mode.build_building.connect(_on_building_placed)
		building_mode.has_built = false
		building_mode.placed = false
	
	# Also ensure the basic_building gets the signal for its own logic
	var basic_building = current_building_instance
	if basic_building and basic_building.has_method("_set_building_mode"):
		# Connect the building mode signal to the building's own handler too
		if building_mode:
			# Only connect if not already connected
			if not building_mode.build_building.is_connected(basic_building._set_building_mode):
				building_mode.build_building.connect(basic_building._set_building_mode)
	
	print("Started building mode for: ", building_data.name, " (Cost: ", cost, ")")

func _on_building_placed():
	# Deduct money when building is successfully placed
	var cost = current_building_data.get("cost", 0)
	if Economy.spend_money(cost):
		print("Building placed! Spent ", cost, " money.")
	
	# Reset all building buttons
	reset_all_building_buttons()
	
	# Building is now permanent
	current_building_instance = null
	current_building_data = {}

func _on_insufficient_funds(cost: int, current_money: int):
	print("Cannot afford building! Cost: ", cost, ", Money: ", current_money)
	cancel_building()

func cancel_building():
	if current_building_instance:
		current_building_instance.queue_free()
		current_building_instance = null
		current_building_data = {}
	
	# Reset all building buttons
	reset_all_building_buttons()

func reset_all_building_buttons():
	var buttons = get_tree().get_nodes_in_group("building_buttons")
	for button in buttons:
		if button.has_method("reset_building_mode"):
			button.reset_building_mode()

func _input(event):
	# Right-click to cancel
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_RIGHT:
		if current_building_instance:
			cancel_building()

# Helper function to get building info
func get_building_info(building_id: String) -> Dictionary:
	return building_types.get(building_id, {})
