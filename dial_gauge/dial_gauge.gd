extends Node3D
class_name DialGauge

var font := preload("res://font/HakgyoansimBareondotumR.ttf")


var current_value :float
var value_range :Array # [min, max]
var rad_range :Array # [min, max]

func init_range(v :float, v_range :Array, r_range :Array ) -> DialGauge:
	current_value = v
	value_range = v_range
	rad_range = r_range
	return self

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

func init_dial_num(r :float, d:float, fsize :float, step_count :int, co :Color ) -> DialGauge:
	var mat := StandardMaterial3D.new()
	mat.albedo_color = co
	var rad_step :float = float(rad_range[1] - rad_range[0]) / step_count
	var value_step :float = (value_range[1] - value_range[0]) / step_count
	for i in step_count+1:
		var val :float = value_range[0] + value_step*i
		var rad :float = rad_range[0] + rad_step * i
		var t := new_text(fsize, d, mat, "%s" % [val])
		t.position = Vector3(cos(rad)*r, sin(rad)*r, 0)
		add_child(t)
	return self

enum BarAlign {None, In,Mid,Out}
func init_dial_bar(r :float, bar_size :Vector3, align :BarAlign, step_count :int, co :Color):
	# Set the transform of the instances.
	var bar_position := Vector3.ZERO
	var tf_list := []
	var rad_step :float = float(rad_range[1] - rad_range[0]) / step_count
	for i in step_count+1:
		var rad :float = rad_range[0] + rad_step * i
		var bar_center := Vector3(cos(rad)*r, sin(rad)*r,  0)
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
