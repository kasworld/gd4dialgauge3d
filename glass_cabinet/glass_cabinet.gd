extends Node3D
class_name GlassCabinet

var cabinet_size :Vector3
func calc_pos_by_grid(x :int, y :int, x_grid:int, y_grid:int) -> Vector3:
	var xunit := cabinet_size.x/x_grid
	var yunit := cabinet_size.y/y_grid
	var posadj := Vector3(+xunit/2 - cabinet_size.x/2, +yunit/2-cabinet_size.y/2, 0)
	var pos := Vector3(xunit * x  , yunit * y , 0) + posadj
	return pos

func init(cabinet_size_a :Vector3) -> GlassCabinet:
	cabinet_size = cabinet_size_a
	$WallBox.mesh.size = cabinet_size
	$FixedCameraLight.set_center_pos_far(Vector3.ZERO, 	Vector3(0, 0, cabinet_size.z*2), cabinet_size.length()*2)
	$AxisArrow3D.set_size(cabinet_size.length()/10).set_colors()
	$Label3D.pixel_size = cabinet_size.y/200
	$Label3D.position = Vector3(0,-cabinet_size.y/2,cabinet_size.z/2)
	$WireBox.init_wire_box( cabinet_size, cabinet_size.length()/200, Color.WHITE)
	$Points.init_spheres_by_point_list(
		PlatonicSolids.MultiplyPointList(PlatonicSolids.CubePoints, cabinet_size/2),
		cabinet_size.length()/200, Color.WHITE,
	)
	return self

func show_axis_arrow(b :bool = true) -> GlassCabinet:
	$AxisArrow3D.visible = b
	return self

func show_wall_box(b :bool = true) -> GlassCabinet:
	$WallBox.visible = b
	return self
func set_wall_box_color(co :Color) -> GlassCabinet:
	$WallBox.mesh.material.albedo_color = co
	return self

func show_wire_box(b :bool = true) -> GlassCabinet:
	$WireBox.visible = b
	return self
func set_wire_box_color(co :Color) -> GlassCabinet:
	$WireBox.set_color_all(co)
	return self

func show_points(b :bool = true) -> GlassCabinet:
	$Points.visible = b
	return self
func set_points_color(co :Color) -> GlassCabinet:
	$Points.set_color_all(co)
	return self


func show_label(b :bool = true) -> GlassCabinet:
	$Label3D.visible = b
	return self
func set_label_text(t :String) -> GlassCabinet:
	$Label3D.text = t
	return self
func set_label_pixel_size(sz :float) -> GlassCabinet:
	$Label3D.pixel_size = sz
	return self

func get_camera_light() -> MovingCameraLight:
	return $FixedCameraLight

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed:
		if $FixedCameraLight.is_current_camera():
			var fi = FlyNode3D.Key2Info.get(event.keycode)
			if fi != null:
				FlyNode3D.fly_node3d($FixedCameraLight, fi)
