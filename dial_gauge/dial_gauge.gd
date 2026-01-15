extends Node3D
class_name DialGauge

var font := preload("res://font/HakgyoansimBareondotumR.ttf")

func init(radius :float, depth :float) -> DialGauge:
	init_case(radius, depth, Color(1,1,1,0.5) )
	init_center(radius/10, depth/2, Color(0.5,0.5,0.5))
	init_needle(radius*0.9, depth*0.3, Color.RED)
	return self

func init_case(radius :float, depth :float, co :Color) -> DialGauge:
	$Case.mesh.top_radius = radius
	$Case.mesh.bottom_radius = radius
	$Case.mesh.height = depth
	$Case.mesh.material.albedo_color = co
	return self

func init_center(radius :float, depth :float, co :Color) -> DialGauge:
	$Center.mesh.top_radius = radius
	$Center.mesh.bottom_radius = radius
	$Center.mesh.height = depth
	$Center.mesh.material.albedo_color = co
	return self

func init_needle(radius :float, depth :float, co :Color) -> DialGauge:
	$NeedleBase/Needle.mesh.size = Vector3(radius, depth, depth)
	$NeedleBase/Needle.position = Vector3(radius/2,0,0)
	$NeedleBase/Needle.mesh.material.albedo_color = co
	return self

func init_dial_num(r :float, d:float, fsize :float, num_range :Array, rad_range :Array, co :Color ) -> DialGauge:
	var mat := StandardMaterial3D.new()
	mat.albedo_color = co
	if num_range.size() == 2:
		num_range.append(1)
	var rad_step :float = float(rad_range[1] - rad_range[0]) / float(num_range[1] - num_range[0] ) * num_range[2]
	var rad_cursor :float = rad_range[0]
	num_range[1] += 1
	for num in range.callv(num_range):
		var t := new_text(fsize, d, mat, "%d" % [num])
		t.position = Vector3(cos(rad_cursor)*r, sin(rad_cursor)*r, 0)
		add_child(t)
		rad_cursor += rad_step
	return self

enum BarAlign {None, In,Mid,Out}
func init_dial_bar(r :float, bar_size :Vector3, align :BarAlign, rad_range :Array,   co :Color):
	# Set the transform of the instances.
	var bar_position := Vector3.ZERO
	var tf_list := []
	if rad_range[0] > rad_range[1]:
		rad_range = [rad_range[1], rad_range[0], -rad_range[2]]
	var rad :float = rad_range[0]
	while rad < rad_range[1]+ rad_range[2]:
		var bar_center := Vector3(cos(rad)*r, sin(rad)*r,  0)
		#var	bar_size := Vector3(bar_len, bar_width, bar_depth)
		match align:
			BarAlign.In :
				bar_position = bar_center*(1 - bar_size.x/r/2)
			BarAlign.Mid :
				bar_position = bar_center
			BarAlign.Out :
				bar_position = bar_center*(1 + bar_size.x/r/2)
		# make transform from bar_rotation, bar_position, bar_size
		var t := Transform3D(Basis(), bar_position)
		t = t.rotated_local(Vector3.BACK, rad)
		t = t.scaled_local( bar_size )
		tf_list.append(t)
		rad += rad_range[2]

	var mesh := BoxMesh.new()
	mesh.material = MultiMeshShape.make_color_material()
	$ScaleMarks.init_with_color_mesh(mesh, tf_list.size(), 1.0)
	for i in tf_list.size():
		$ScaleMarks.multimesh.set_instance_transform(i,tf_list[i])
	$ScaleMarks.set_color_all(co)

func new_text(fsize :float, fdepth :float, mat :Material, text :String) -> MeshInstance3D:
	var mesh := TextMesh.new()
	mesh.font = font
	mesh.depth = fdepth
	mesh.pixel_size = fsize / 16
	mesh.text = text
	mesh.material = mat
	var sp := MeshInstance3D.new()
	sp.mesh = mesh
	return sp

func set_needle_angle(rad :float) -> void:
	$NeedleBase.rotation.z = rad
