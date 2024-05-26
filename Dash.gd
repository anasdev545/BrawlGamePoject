extends Node

@onready var Duration_timer=$DurationTimer
@onready var Ghost_timer=$instance_timer
var delay_duration = 0.5
var can_dash = true
var GhostScene = preload("res://players/ghost.tscn")
@export var Sprite:Sprite2D


func Start_dash(duration):
	Duration_timer.wait_time = duration
	Duration_timer.start()
	Ghost_timer.start()
	instance_ghosts()

func instance_ghosts():
	var ins = GhostScene.instantiate()
	$Ghosts.add_child(ins)
	ins.global_position = Sprite.global_position
	ins.hframes = Sprite.hframes
	ins.vframes = Sprite.vframes
	ins.frame = Sprite.frame
	ins.scale = Sprite.scale
	ins.texture = Sprite.texture
	pass


func is_dashing():
	return !Duration_timer.is_stopped()

func end_dash():
	Ghost_timer.stop()
	can_dash = false
	await get_tree().create_timer(delay_duration).timeout
	can_dash = true

func _on_duration_timer_timeout():
	end_dash()
	pass # Replace with function body.

func _on_instance_timer_timeout():
	instance_ghosts()
	pass # Replace with function body.


