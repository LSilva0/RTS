extends CharacterBody2D

@export var speed = 500
@export var stop_distance = 10
var target = null
var stopped = true;
var idle_tween = Tween;
func _ready():
	start_idle_animation()
	
func _input(event):
	if event.is_action_pressed("set_target"):
		target = get_global_mouse_position()
		print('Input');

func _physics_process(delta):
	if target != null:
		
		var distance_to_target = position.distance_to(target)
		
		velocity = position.direction_to(target)
		velocity = velocity.normalized() * speed
		move_and_collide(velocity * delta)
		if distance_to_target <= stop_distance:
				target = null
				velocity = Vector2.ZERO
		else:
			# Move towards target
			var direction = position.direction_to(target)
			velocity = direction * speed
	if velocity != Vector2.ZERO:
		stopped = false
		stop_idle_animation()
	elif velocity == Vector2.ZERO and stopped == false:
		
		stopped = true
		start_idle_animation()
		

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
