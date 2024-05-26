
extends CharacterBody2D


const SPEED = 300.0
const JUMP_VELOCITY = -450.0
const accelertion = 0.3
var have_coyote = false
@onready var buffer_timer = $timers/jumpBufferTimer
@onready var coyote_timer = $timers/CoyoteTimer
@onready var Dash = $Dash
# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var x 
var y
@onready var animationNode = $AnimationTree.get("parameters/playback")
func _physics_process(delta):
	# Add the gravity.
		
	if sign(velocity.x)!=0:
		$Sprite2D.scale.x = sign(velocity.x)
	move_and_slide()
	if Input.is_action_just_pressed("dodge") && !Dash.is_dashing() && Dash.can_dash && Vector2(x,y)!= Vector2.ZERO:
		Dash.Start_dash(0.1)
		velocity = Vector2.ZERO
	if Dash.is_dashing():
		Dodge()
	# Handle jump.
	gravity_system(delta)
	move()
	animation_system()
func move():
	if Dash.is_dashing():
		return
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	
	x = Input.get_axis("left", "right")
	y = Input.get_axis("up", "down")
	if x:
		velocity.x = lerpf(velocity.x,x * SPEED,accelertion)
	else:
		velocity.x = lerpf(velocity.x,0,0.2)

func gravity_system(delta):
	if Dash.is_dashing(): return
	if Input.is_action_just_pressed("jump"):
		buffer_timer.start()
		pass
	if (Input.is_action_just_pressed("jump") or !buffer_timer.is_stopped() )and( is_on_floor() or !coyote_timer.is_stopped()):
		velocity.y = JUMP_VELOCITY
		coyote_timer.stop()
		buffer_timer.stop()
	if !Input.is_action_pressed("jump") && velocity.y<-225:
		velocity.y = lerpf(velocity.y,0,0.1)
	if  !is_on_floor():
		if have_coyote:
			have_coyote = false
			coyote_timer.start()
		velocity.y += gravity * delta
	if is_on_floor():
		have_coyote = true
	if is_on_ceiling():
		velocity.y=gravity

func animation_system():
	if is_on_floor():
		if sign(x) !=0:
			animationNode.travel("run")
		else: 
			animationNode.travel("idle")
	if !is_on_floor():
		if velocity.y >0:
			animationNode.travel("fall")
		if velocity.y < 0:
			animationNode.travel("jump")
func Dodge():

	var Dash_val = Vector2(x,y)*(Dash.Duration_timer.time_left * 3000) 
	velocity +=Dash_val
