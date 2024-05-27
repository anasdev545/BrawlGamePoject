
extends CharacterBody2D


const SPEED = 300.0
const JUMP_VELOCITY = -450.0
const accelertion = 0.3
var current_combo = 0
var have_coyote = false
var dashed = false
var CanAttack=true
# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var x:int 
var y:int
@onready var animationNode = $AnimationTree.get("parameters/playback")
@export var attacking = false
@onready var buffer_timer = $timers/jumpBufferTimer
@onready var coyote_timer = $timers/CoyoteTimer
@onready var CoolDown_timer = $timers/AttackCoolDown
@onready var AttackDelay_timer = $timers/AttackDelayTimer
@onready var CoyoteAttack_timer = $timers/CoyoteAttack
@onready var Dash = $Dash
func _physics_process(delta):
	# Add the gravity.
	print(current_combo)
	if sign(velocity.x)!=0:
		$Sprite2D.scale.x = sign(velocity.x)
	move_and_slide()
	if Input.is_action_just_pressed("dodge") && !Dash.is_dashing() && Dash.can_dash && Vector2(x,y)!= Vector2.ZERO && dashed==false:
		await  get_tree().create_timer(0.1).timeout
		Dash.Start_dash(0.15)
		velocity = Vector2.ZERO
		dashed = true
	if is_on_floor():
		dashed = false
	if Dash.is_dashing():
		Dodge()
	# Handle jump.
	gravity_system(delta)
	if !attacking:
		move()
		animation_system()
	else:
		velocity.x = 0
	combo_system()
func move():
	if Dash.is_dashing()||attacking:
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
	if (Input.is_action_just_pressed("jump") or !buffer_timer.is_stopped() )and( is_on_floor() or !coyote_timer.is_stopped())&&!attacking:
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
	if !attacking:
		if is_on_floor():
			if sign(x) !=0:
				animationNode.travel("run")
			else: 
				animationNode.travel("idle")
		if !is_on_floor():
			if velocity.y >0:
				animationNode.travel("fall")
			elif velocity.y < 0:
				animationNode.travel("jump")
			else:
				animationNode.travel("MaxHeight")
func Dodge():
	var Dash_val = Vector2(x,y).normalized()*(Dash.Duration_timer.time_left * 1000) 
	velocity +=Dash_val
func combo_system():
	if Input.is_action_just_pressed("attack"):
		CoyoteAttack_timer.start()
	if (Input.is_action_just_pressed("attack")||!CoyoteAttack_timer.is_stopped()) && !attacking && CanAttack:
		CoyoteAttack_timer.stop()
		if current_combo<=1:
			print("attack",!CoyoteAttack_timer.is_stopped())
			animationNode.travel("attack1")
			AttackDelay_timer.start()
			current_combo+=1
		elif current_combo<=3:
			animationNode.travel("attack2")
			AttackDelay_timer.start()
			current_combo+=1
		elif current_combo==4:
			animationNode.travel("attack3 ")
			AttackDelay_timer.start()
			current_combo= 0
			CanAttack = false
			CoolDown_timer.start()
		await  get_tree().create_timer(0.2).timeout

func _on_attack_delay_timer_timeout():
	print("weee")
	current_combo= 0
	pass # Replace with function body.


func _on_attack_cool_down_timeout():
	print("weee2")
	CanAttack = true
	pass # Replace with function body.
