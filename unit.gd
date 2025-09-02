extends CharacterBody2D

@export var speed = 500
@export var target_radius = 10

var stopped = true;
var idle_tween = Tween;
var av = Vector2.ZERO
var avoid_weight = 0.2

var selected = false:
	set = set_selected
	
var target = null:
	set = set_target
	
func _ready():
	start_idle_animation()
	

#func _input(event):
#	if event.is_action_pressed("set_target"):
#		target = get_global_mouse_position()
#		print('Input');

func _physics_process(delta):
	velocity = Vector2.ZERO
	if target != null:
		velocity = position.direction_to(target)
		rotation = lerp_angle(rotation,velocity.angle(), 0.5)
		
		if position.distance_to(target) <= target_radius:
				target = null
				velocity = Vector2.ZERO
	
		# Move towards target
	av = avoid()
	velocity = (velocity + av * avoid_weight).normalized() * speed
	move_and_collide(velocity * delta)
	print(velocity)
	if velocity != Vector2.ZERO and stopped == true:
		stopped = false
		stop_idle_animation()
	elif velocity == Vector2.ZERO and stopped == false:
		
		stopped = true
		start_idle_animation()
		
func set_selected(value):
	selected = value
	if selected:
		$Sprite2D.self_modulate = Color.AQUA
	else:
		$Sprite2D.self_modulate = Color.WHITE;

func set_target(value):
	target = value

func avoid():
	var result = Vector2.ZERO
	var neighbors = $Detect.get_overlapping_bodies()
	if neighbors:
		for n in neighbors:
			result += n.position.direction_to(position) #Averaging direction of neighbors to self - avoid vector
		result /= neighbors.size() #average
	return result.normalized();
	
func start_idle_animation():
	
	idle_tween = create_tween()
	idle_tween.set_loops()
	#var original_pos = position;
	var original_scale = scale;
	idle_tween.tween_property(self, "scale", original_scale*1.03, 1.0)
	idle_tween.tween_property(self, "scale", original_scale*0.97, 1.0)

func stop_idle_animation():
	if idle_tween:
		idle_tween.kill()
		idle_tween = null
