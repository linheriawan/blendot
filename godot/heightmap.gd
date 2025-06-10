extends MeshInstance3D

@export var heightmap: Texture2D
@export var height_scale: float = 10.0

func _ready():
	if not heightmap:
		print("Error: Heightmap texture not assigned.")
		return

	call_deferred("process_mesh") # Delay mesh processing

func process_mesh():
	var mesh = self.mesh as ArrayMesh
	if not mesh:
		print("Error: Mesh is not an ArrayMesh. Could not convert mesh to ArrayMesh.")
		return

	var surface_arrays = mesh.get_surface_arrays(0)
	if surface_arrays.is_empty():
		print("Error: Mesh has no surface arrays.")
		return

	var vertices = surface_arrays[Mesh.ARRAY_VERTEX]
	if vertices.is_empty():
		print("Error: No vertices found in mesh surface.")
		return

	var width = heightmap.get_width()
	var height = heightmap.get_height()

	for i in range(vertices.size()):
		var x = i % width
		var z = i / width

		var color = heightmap.get_image().get_pixel(x, z)
		var height_value = color.r

		vertices[i].y = height_value * height_scale - height_scale / 2

	surface_arrays[Mesh.ARRAY_VERTEX] = vertices
	mesh.set_surface_arrays(0, surface_arrays)
	mesh.generate_normals() # Recalculate normals
