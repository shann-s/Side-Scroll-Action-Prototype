extends KinematicBody2D

enum {
	ATTACK,
	CHASE,
	DEAD,
	STOP
}

export var chaseSpeed = 80

var state = CHASE
var velocity = Vector2.ZERO
var knockback = Vector2.ZERO
var temp = Vector2.ZERO
const GRAVITY = 200.0

onready var stats = $Stats
onready var hurtbox = $Hurtbox
onready var sprite = $AnimatedSprite
onready var target = get_node("../Player")
onready var Detect = $"Attack Detection"
onready var timer = $Timer
onready var collision = $CollisionShape2D
onready var animation = $AnimationPlayer
#disable only when NOT attacking
onready var sprite2 = $Sprite
#var to discern between self and outside
onready var hitbox = $"Hitbox Pivot"

#bool if player left range
var anim_finish = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	match state:
		ATTACK:
			attackPlayer()
			sprite2.visible = true
		CHASE:
			chasePlayer()
			#chase player using detection range or just give player coords
			#apply physics
			velocity.y += delta * GRAVITY
			velocity = move_and_slide(velocity, Vector2.UP)
			sprite2.visible = false
			anim_finish = false
		DEAD:
			dead()
			sprite2.visible = false
		STOP:
			pass

func attackPlayer():
	sprite.play("Attack")
	attackDirection()

func playerInRange():
	if anim_finish == true:
		state = CHASE

func attackDirection():
	if velocity.x < 0:
		animation.play("Attack Left")
	if velocity.x > 0:
		animation.play("Attack Right")

func chasePlayer():
		#var dist = position.distance_to(target.position)
		temp = (target.position - position).normalized()
		velocity.x = temp.x * chaseSpeed
		direction(temp)
		sprite.play("Walk")
		#can chase player in x position

#direction function
func direction(dir):
	#left
	if dir.x < 0:
		sprite.flip_h = true
	#right
	elif dir.x > 0:
		sprite.flip_h = false

#die state
func dead():
	print("died")
	timer.start(10)
	direction(velocity)
	sprite.play("Die")
	state = STOP
	#After it dies enable player through collision
	#temp fix but very buggy
	collision.one_way_collision = true
	

func _on_Hurtbox_area_entered(area):
	#Range area overlap // Can use groups instead of this fix.
	if area.name == "Range":
		pass
	if area.name == "EnemyHitbox":
		pass
	if area.name == "Hitbox" && state != STOP:
		#skeleton gets hit
		stats.health -= area.damage
		#Does nothing yet. Find how to add knockback
		knockback = area.knockback_vector * 120
		print("hit!")


func _on_Stats_no_health():
	#Skeleton dies
	#queue_free()
	#print("dead")
	#Start timer and play animation
	if stats.health < 0:
		state = DEAD
 
func _on_Timer_timeout():
	queue_free()

func _on_Range_body_entered(body):
	print("body entered: " + str(body.name))
	#make sure it's player
	if state == DEAD || state == STOP:
		pass
	elif body.name == "Player":
		state = ATTACK


func _on_Range_body_exited(body):
	#player left range
	anim_finish = true
