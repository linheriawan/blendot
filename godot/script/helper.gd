extends Node

var ctrlSchema := ["Tank", "Modern"]
var transparent_nodes := []
var nodes:Array[MeshInstance3D]=[]
var mesh_map: Dictionary

func get_ctrlSchema(index: int) -> String:
	if index >= 0 and index < ctrlSchema.size():
		return ctrlSchema[index]
	return "INVALID_INDEX"

func get_ctrlSchemaId(value: String) -> int:
	return ctrlSchema.find(value)

func assign_script(_nodes:Array[MeshInstance3D], path:String, _mesh_map: Dictionary) -> void:
	nodes=_nodes
	mesh_map=_mesh_map
	var script := load("res://"+path) as GDScript
	for mesh in nodes:
		mesh.set_script(script)

func clear_seethru():
	for obj in transparent_nodes:
		if obj and obj.has_method("reset_transparency"):
			obj.reset_transparency()
	transparent_nodes.clear()
	
func seethru_effect(camera: Camera3D, character: Node3D, space_state:PhysicsDirectSpaceState3D) -> void:
	var ray_params = PhysicsRayQueryParameters3D.new()
	ray_params.from = camera.global_transform.origin
	ray_params.to = character.global_transform.origin
	ray_params.exclude = [$"Test-Play", $land]
	ray_params.collision_mask = 1  # optional, use your desired mask
	
	# Reset previously made-transparent objects
	clear_seethru()
	#raying(camera, character)
	var result = space_state.intersect_ray(ray_params)
	
	if result and result.has("collider"):
		var node = result["collider"]
		while node and not (node is MeshInstance3D):
			node = node.get_parent()
		node=mesh_map.get(node,node)
		if node and node.has_method("make_transparent"):
			node.make_transparent()
			transparent_nodes.append(node)		
		#elif node != null:
			#print("no func",node)

func raying(camera: Camera3D, character: Node3D)->void:
	var ray_origin = camera.global_transform.origin
	var ray_target = character.global_transform.origin

	for mesh in nodes:
		var aabb = transform_aabb(mesh.get_aabb(), mesh.global_transform)
		var char_dist = ray_origin.distance_to(ray_target)
		var mesh_dist = ray_origin.distance_to(mesh.global_transform.origin)
		if aabb.intersects_segment(ray_origin, ray_target) and char_dist>mesh_dist:
			if mesh and mesh.has_method("make_transparent"):
				mesh.make_transparent()
				transparent_nodes.append(mesh)

func transform_aabb(aabb: AABB, transform: Transform3D) -> AABB:
	var corners = []
	var origin = aabb.position
	var size = aabb.size
	# Create all 8 corners of the AABB
	for x in [0, 1]:
		for y in [0, 1]:
			for z in [0, 1]:
				var corner = origin + Vector3(x * size.x, y * size.y, z * size.z)
				corners.append(transform * corner)

	# Create a new AABB that encloses all transformed corners
	var new_aabb = AABB(corners[0], Vector3.ZERO)
	for i in range(1, corners.size()):
		new_aabb = new_aabb.merge(AABB(corners[i], Vector3.ZERO))
	return new_aabb
