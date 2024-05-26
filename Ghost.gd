extends Sprite2D

# Called when the node enters the scene tree for the first time.
func _ready():
	await get_tree().create_timer(0.15).timeout
	var tween = create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(self,"modulate:a",0,0.5)
	await  tween.finished
	queue_free()
	pass # Replace with function body.


