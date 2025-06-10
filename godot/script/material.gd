extends MeshInstance3D

var original_material : Material = null

func make_transparent():
	var mat : Material = null

	if material_override:
		mat = material_override
	elif mesh and mesh.get_surface_count() > 0:
		mat = mesh.surface_get_material(0)

	if mat == null:
		return  # No material to work with, so skip

	if original_material == null:
		original_material = mat.duplicate()

	var transparent_mat = original_material.duplicate()
	transparent_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	transparent_mat.albedo_color.a = 0.4
	transparent_mat.flags_transparent = true

	material_override = transparent_mat

func reset_transparency():
	if original_material:
		material_override = original_material
