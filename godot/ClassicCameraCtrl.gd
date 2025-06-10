class_name ClassicCameraCtrl

extends RefCounted

var camera_pivot: Node3D
var camera: Camera3D

@export var rotation_speed = 50.0
@export var horizontal_rotation_speed = 100.0
@export var y_min = 0.2 # altitude 
@export var y_max = 2.6
@export var x_rot_min = deg_to_rad(-40.0) # horizontal orbit 
@export var x_rot_max = deg_to_rad(120.0)
var initial_position = Vector3.ZERO
var initial_rotation = Vector3.ZERO
var phy_delta

func _init(cam: Camera3D, pivot: Node3D):
	camera_pivot = pivot
	camera = cam
	initial_position = camera.position
	initial_rotation = camera.rotation
	#cam_reset()

func listener(delta: float):
	phy_delta=delta
	# Zoom
	if Input.is_action_pressed("camera_up") and Input.is_key_pressed(KEY_SHIFT):
		camera.position.z-= 0.1
		camera.position.z = clamp(camera.position.z, 1, 3)
		
	elif Input.is_action_pressed("camera_down") and Input.is_key_pressed(KEY_SHIFT):
		camera.position.z+= 0.1
		camera.position.z = clamp(camera.position.z, 1, 3)

	# altitude
	elif Input.is_action_pressed("camera_up") and Input.is_key_pressed(KEY_ALT):	
		camera.position.y+= 0.1
		camera.position.y = clamp(camera.position.y, y_min, y_max)
		camera.rotate_x(0)
		
	elif Input.is_action_pressed("camera_down") and Input.is_key_pressed(KEY_ALT):
		camera.position.y-= 0.1
		camera.position.y = clamp(camera.position.y, y_min, y_max)
		camera.rotate_x(0)

	# Camera orbit
	elif Input.is_action_pressed("camera_left"):
		camera_pivot.rotate_y(deg_to_rad(horizontal_rotation_speed * phy_delta))
	elif Input.is_action_pressed("camera_right"):
		camera_pivot.rotate_y(deg_to_rad(-horizontal_rotation_speed * phy_delta))
	elif Input.is_action_pressed("camera_up"):
		camera.rotate_x(deg_to_rad(rotation_speed * phy_delta))
		camera.rotation.x = clamp(camera.rotation.x, x_rot_min, x_rot_max)
	elif Input.is_action_pressed("camera_down"):
		camera.rotate_x(deg_to_rad(-rotation_speed * phy_delta))
		camera.rotation.x = clamp(camera.rotation.x, x_rot_min, x_rot_max)
	
	if Input.is_action_just_pressed("camera_reset"):
		reset_rot_y()
		cam_reset()

func cam_reset():
	camera.position = initial_position
	camera.rotation = initial_rotation
	#print("loc:%s,rot:%s"%[camera.position,camera.rotation])
	camera.position.y-= 1
	camera_pivot.rotation.y=0
	
func reset_rot_y():
	var current_y = camera_pivot.rotation.y
	var target_y = 0.0
	var speed = 5.0  # adjust for smoothness
	camera_pivot.rotation.y = lerp_angle(current_y, target_y, phy_delta * speed)
