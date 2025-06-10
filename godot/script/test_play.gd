extends CharacterBody3D

@export var speed = 2 # 50 cm = 0.5
@export var rotation_speed = 2.0
@export var gravity = 9.8
@export var jump_force = 6.0
@export var jump_forward_force = 3.0

@onready var animation_player = $AnimationPlayer
@onready var camera:ClassicCameraCtrl = ClassicCameraCtrl.new($CameraPivot/Camera3D, $CameraPivot)

enum State { IDLE, WALK, RUN, TURNR, TURNL, UTURN, JUMP, FALL, ATTACK, AIR_ATTACK }
var current_state = State.IDLE
var direction: Vector3 = Vector3.ZERO

var is_jumping = false
var has_fallen = false
var is_uturning = false

func _ready():
	print("legoman ready")
	
func _physics_process(delta):
	camera.listener(delta)
	var input_dir := get_input_direction()
	handle_input(input_dir, delta)
	update_state(delta, input_dir)
	apply_gravity(delta)
	move_and_slide()

	if input_dir.length() > 0 and velocity.length() < 0.05:
		print("Stuck: velocity", velocity, " direction", input_dir)
		var nudge = input_dir.normalized() * 0.1
		#nudge.y = 0  # Don't nudge vertically
		velocity += nudge
		#velocity.x = input_dir.x * speed
		#velocity.z = input_dir.z * speed

func get_input_direction() -> Vector3:
	var dir = Vector3.ZERO
	if Input.is_action_pressed("ui_up"):
		dir -= transform.basis.z
		camera.reset_rot_y()
	elif Input.is_action_pressed("ui_down"):
		dir += transform.basis.z
		camera.reset_rot_y()
	#global_transform.origin.y=0.01
	return dir.normalized()

func handle_input(input_dir: Vector3, delta: float):
	# Turning
	if  Input.is_action_pressed("ui_left"):
		current_state = State.TURNL
	elif Input.is_action_pressed("ui_right"):
		current_state = State.TURNR
		
	if Input.is_action_just_pressed("ui_ctrl") and !is_uturning:
		current_state = State.UTURN
	if Input.is_action_just_pressed("ui_select") and is_on_floor() and !is_jumping:
		current_state = State.JUMP
	

func update_state(delta: float, input_dir: Vector3):
	match current_state:
		State.IDLE:
			if input_dir != Vector3.ZERO and is_on_floor():
				current_state = State.WALK
				do_animation("walk")
			elif is_jumping:
				current_state = State.JUMP
			elif is_uturning:
				pass
			else:
				do_animation("idle")

		State.WALK:
			if input_dir == Vector3.ZERO:
				current_state = State.IDLE
				do_animation("idle")
			elif is_jumping:
				current_state = State.JUMP
			else:
				do_animation("walk")

		State.TURNL:
			turn_l(delta)
			current_state=State.IDLE
		State.TURNR:
			turn_r(delta)
			current_state=State.IDLE
		State.UTURN:
			perform_uturn()
			current_state=State.IDLE
			
		State.JUMP:
			if not is_jumping:
				perform_jump(input_dir)
			elif is_on_floor():
				is_jumping=false
				has_fallen = true
				current_state=State.WALK
			elif !has_fallen and velocity.y < 0:
				print("fall",is_jumping," velo: ", velocity.y, ", sc:", State.keys()[current_state] )
				current_state = State.FALL
				#do_animation("jump_fall")

		State.FALL:
			if is_on_floor():
				print("doing fall")
				is_jumping = false
				do_animation("idle")
			else:
				has_fallen = true
				current_state=State.WALK

	# Movement application (only on ground)
	if is_on_floor() and not is_jumping and not is_uturning:
		velocity.x = input_dir.x * speed
		velocity.z = input_dir.z * speed
	elif is_jumping or current_state==State.FALL:
		velocity.x = input_dir.x * jump_forward_force
		velocity.z = input_dir.z * jump_forward_force
	elif is_jumping:
		# do not reset velocity.x/z
		pass
	else:
		velocity.x = 0
		velocity.z = 0

func apply_gravity(delta):
	if !is_on_floor():
		velocity.y -= gravity * delta
	else:
		if is_jumping and current_state != State.JUMP:
			is_jumping = false
		has_fallen = false

func turn_l(delta:float):
	do_animation("turn left")
	rotation.y += rotation_speed * delta
	
func turn_r(delta:float):
	do_animation("turn right")
	rotation.y -= rotation_speed * delta

func perform_uturn():
	is_uturning = true
	do_animation("uturn")
	var target_rotation = rotation.y + PI
	var tween = create_tween()
	tween.tween_property(self, "rotation:y", target_rotation, 0.6).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.connect("finished", Callable(self, "uturn_finished"))

func uturn_finished():
	is_uturning = false

func perform_jump(input_dir: Vector3):
	is_jumping = true
	has_fallen = false
	do_animation("jump")

	var move_direction := input_dir.normalized()
	if Input.is_action_pressed("ui_up"):
		move_direction = -transform.basis.z
	elif Input.is_action_pressed("ui_down"):
		move_direction = transform.basis.z

	move_direction = move_direction.normalized()
	velocity.y = jump_force
	#velocity.x = move_direction.x * jump_forward_force
	#velocity.z = move_direction.z * jump_forward_force

func do_animation(action: String):
	if animation_player.get_current_animation() != action:
		animation_player.play(action)
