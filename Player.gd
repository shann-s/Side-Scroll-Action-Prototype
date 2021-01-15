extends KinematicBody2D

#TODO: Hitbox/Hurtbox for enemy and player.

enum {
	MOVE,
	ATTACK,
	ROLL
}

var state = MOVE

var velocity = Vector2.ZERO
var input_vector = Vector2.ZERO
var direction = Vector2.RIGHT
export var SPEED = 50
var jump_speed = -100
var jump_boost = -50
var double_jump = false
var jumping = false
var air_attack = false

const GRAVITY = 200.0

onready var animationPlayer = $AnimationPlayer
onready var animationTree = $AnimationTree
onready var animationState = animationTree.get("parameters/playback")
onready var sprite = $Sprite



func _process(delta):
	match state:
		MOVE:
			move(delta)
		ROLL:
			pass
		ATTACK:
			attack(delta)
	#check if on floor to regen air attacks

#move func
func move(delta):
	#apply fall gravity
	velocity.y += delta * GRAVITY
	getinput(delta)
	#Input cases
	velocity = move_and_slide(velocity, Vector2.UP)
	velocity.x = 0
	if is_on_floor():
		air_attack = false
	
	if Input.is_action_just_pressed("Attack"):
		state = ATTACK

#roll func

#attack func
func attack(delta):
	#get direction and play attack
	
	#floor attack
	if air_attack:
		state = MOVE
	if is_on_floor():
		#commit attacks if it is on floor 
		if direction == Vector2.LEFT:
			animationPlayer.play("Attack Left")
			velocity = Vector2.ZERO
		if direction == Vector2.RIGHT:
			animationPlayer.play("Attack Right")
			velocity = Vector2.ZERO
		velocity = move_and_slide(velocity, Vector2.UP)
	#not on  floor, apply gravity
	if !is_on_floor() and !air_attack:
		if direction == Vector2.LEFT: 
			animationPlayer.play("Attack Left")
		if direction == Vector2.RIGHT:
			animationPlayer.play("Attack Right")
		#apply gravity when attacking in air
		velocity.y += delta * GRAVITY
		velocity = move_and_slide(velocity, Vector2.UP)
		double_jump = false
		air_attack = true
	#not on floor but continue fall after air attack
	#ignore attack button press?

func getinput(delta):
	input_vector.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	input_vector = input_vector.normalized()
	#input directions
	if input_vector != Vector2.ZERO:
		#from input vector get move direction/speed
		if input_vector.x == 1:
			velocity.x += SPEED
			#if it's on the floor then play walk animation
			if is_on_floor():
				animationPlayer.play("Walk Right")
			#getting direction to face
			direction = Vector2.RIGHT
		elif input_vector.x == -1:
			if is_on_floor():
				animationPlayer.play("Walk Left")
			velocity.x -= SPEED
			direction = Vector2.LEFT
	else:
		if is_on_floor():
			if direction == Vector2.LEFT:
				animationPlayer.play("Idle Left")
			if direction == Vector2.RIGHT:
				animationPlayer.play("Idle Right")
			#reset air attack here
			air_attack = false
	
	#double jump func
	doublejump()

func doublejump():
	var jump = Input.is_action_just_pressed("jump")
	if is_on_floor():
		double_jump = false
	if jump:
		#first jump
		if is_on_floor():
			velocity.y = jump_speed
			#getting directions
			if direction == Vector2.LEFT:
				animationPlayer.play("Jump Left")
			elif direction == Vector2.RIGHT:
				animationPlayer.play("Jump Right")
			jumping = true
			print("jump animation")
		#2nd jump
		elif !double_jump:
			if direction == Vector2.LEFT:
				animationPlayer.play("Hi Jump Left")
			elif direction == Vector2.RIGHT:
				animationPlayer.play("Hi Jump Right")
			velocity.y = jump_speed * 1.5
			double_jump = true
			jumping = true

func attack_animation_finished():
	state = MOVE
