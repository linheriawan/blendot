extends Node3D

@onready var options_page = $OptionsPage
@onready var char = $"Test-Play"
@onready var character = char.get_node("Character")
@onready var camera = char.get_node("CameraPivot/Camera3D")
#@onready var ray = camera.get_node("RayCast3D")

@onready var helper = preload("res://script/helper.gd").new()

func _ready():
	options_page.hide()

	var mesh = $post/postlamp.mesh
	var shape = ConcavePolygonShape3D.new()
	shape.data = mesh.get_faces()
	$post/postcol.shape = shape
	
	ConfigManager.value_changed.connect(_on_config_changed)
	var c_schema = ConfigManager.get_value("ctrl_schema", 0)
	$PlayDashboard/VBoxContainer/HBoxContainer/Label2.text= " Schema: "+helper.get_ctrlSchema( c_schema )
	var nodes :Array[MeshInstance3D]= [$"rooms/stair", $rooms/wall1, $rooms/wall2]
	
	
	helper.assign_script(nodes,"script/material.gd", {$rooms/UCX_Ramp:$"rooms/stair"})
	
	print(get_world_3d().direct_space_state)

func _process(delta: float) -> void:
	var chr=get_pos(char)
	var cam=get_pos($"Test-Play/CameraPivot/Camera3D")
	var vtext= "velocity: \n x:%.2f \n y:%.2f \n z:%.2f" % [char.velocity.x,char.velocity.y,char.velocity.z]
	var ltext= "\nlocation:\n x:%.2f \n y:%.2f \n z:%.2f" % [chr["pos"].x,chr["pos"].y,chr["pos"].z]
	var ftext= "facing:\n x:%.2f\t y:%.2f\t z:%.2f" % [chr["facing"].x,chr["facing"].y,chr["facing"].z]
	var rtext= "\nrotation:%.2f (%s)" % [chr["rotation"], cardinal_8dir(chr["rotation"])]
	$PlayDashboard/VBoxContainer/HBoxContainer/Label.text= ftext
	$PlayDashboard/VBoxContainer/HBoxContainer2/Label.text= vtext + ltext
	
	var cltext= "cam location:\n x:%.2f \n y:%.2f \n z:%.2f" % [cam["pos"].x,cam["pos"].y,cam["pos"].z]
	var cftext= "\ncam facing:\n x:%.2f\n y:%.2f\n z:%.2f" % [cam["facing"].x,cam["facing"].y,cam["facing"].z]
	
	$PlayDashboard/HBoxContainer/Label.text= "%s\tFPS: %s\tKPH: \n%s\t%s" % [rtext, Engine.get_frames_per_second(), cltext, cftext]
	#helper.raying(camera, character)	
	
	helper.seethru_effect(camera, character, get_world_3d().direct_space_state)

func get_pos(_char: Node3D):
	if _char:
		var yaw_deg = fmod(rad_to_deg(_char.rotation.y), 360.0)
		if yaw_deg < 0:
			yaw_deg += 360.0
		return {
			"pos": _char.global_transform.origin,
			"facing": -_char.global_transform.basis.z.normalized(),
			"rotation": 360.0 - yaw_deg
		}
	return {}

func cardinal_8dir(angle_deg: float) -> String:
	if angle_deg >= 337.5 or angle_deg < 22.5:
		return "N"
	elif angle_deg >= 22.5 and angle_deg < 67.5:
		return "NE"
	elif angle_deg >= 67.5 and angle_deg < 112.5:
		return "E"
	elif angle_deg >= 112.5 and angle_deg < 157.5:
		return "SE"
	elif angle_deg >= 157.5 and angle_deg < 202.5:
		return "S"
	elif angle_deg >= 202.5 and angle_deg < 247.5:
		return "SW"
	elif angle_deg >= 247.5 and angle_deg < 292.5:
		return "W"
	elif angle_deg >= 292.5 and angle_deg < 337.5:
		return "NW"
	return "?"
func _on_config_changed(key, value):
	if key == "ctrl_schema":
		$PlayDashboard/VBoxContainer/HBoxContainer/Label2.text = helper.get_ctrlSchema( value )
		
func _input(event):
	if event is InputEventKey:
		if event.pressed and event.keycode == KEY_ESCAPE:
			get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
		if event.pressed and event.keycode == KEY_BACKSPACE:
			options_page.show_options()
