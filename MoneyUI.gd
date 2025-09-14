# Alternative: Simple money display script
extends Label

func _ready():
	Economy.money_changed.connect(_on_money_changed)
	text = "$" + str(Economy.get_money())

func _on_money_changed(new_amount: int):
	text = "$" + str(new_amount)
	
	# Simple scaling animation
	var tween = create_tween()
	tween.tween_property(self, "scale", Vector2(1.2, 1.2), 0.1)
	tween.tween_property(self, "scale", Vector2(1.0, 1.0), 0.1)
