extends Node3D
const WorldSize := Vector3(160,90,80)

func on_viewport_size_changed() -> void:
	var vp_size := get_viewport().get_visible_rect().size
	var 짧은길이 :float = min(vp_size.x, vp_size.y)
	var panel_size := Vector2(vp_size.x/2 - 짧은길이/2, vp_size.y)
	$"왼쪽패널".size = panel_size
	$"왼쪽패널".custom_minimum_size = panel_size
	$오른쪽패널.size = panel_size
	$"오른쪽패널".custom_minimum_size = panel_size
	$오른쪽패널.position = Vector2(vp_size.x/2 + 짧은길이/2, 0)
	var msgrect := Rect2( vp_size.x * 0.1 ,vp_size.y * 0.4 , vp_size.x * 0.8 , vp_size.y * 0.25 )
	$TimedMessage.init(vp_size.y*0.05 , msgrect, "%s %s" % [
			ProjectSettings.get_setting("application/config/name"),
			ProjectSettings.get_setting("application/config/version") ] )
func timed_message_hidden(_s :String) -> void:
	pass

func label_demo() -> void:
	if $"오른쪽패널/LabelPerformance".visible:
		$"오른쪽패널/LabelPerformance".text = """%d FPS (%.2f mspf)
Currently rendering: occlusion culling:%s
%d objects
%dK primitive indices
%d draw calls""" % [
		Engine.get_frames_per_second(),1000.0 / Engine.get_frames_per_second(),
		get_tree().root.use_occlusion_culling,
		RenderingServer.get_rendering_info(RenderingServer.RENDERING_INFO_TOTAL_OBJECTS_IN_FRAME),
		RenderingServer.get_rendering_info(RenderingServer.RENDERING_INFO_TOTAL_PRIMITIVES_IN_FRAME) * 0.001,
		RenderingServer.get_rendering_info(RenderingServer.RENDERING_INFO_TOTAL_DRAW_CALLS_IN_FRAME),
		]
	if $"오른쪽패널/LabelInfo".visible:
		$"오른쪽패널/LabelInfo".text = "%s" % [ MovingCameraLight.GetCurrentCamera() ]

var name_to_camera := {}
func add_camera_dict(mcl :MovingCameraLight, text :String) -> void:
	mcl.set_info_text(text)
	name_to_camera[text] = mcl
	$"왼쪽패널/SelectCamera".add_item(text)
func _on_select_camera_item_selected(index: int) -> void:
	var text :String =  $"왼쪽패널/SelectCamera".get_item_text(index)
	var mcl :MovingCameraLight = name_to_camera.get(text)
	if mcl != null :
		mcl.make_current()
	$"왼쪽패널/SelectCamera".release_focus()

func _ready() -> void:
	on_viewport_size_changed()
	get_viewport().size_changed.connect(on_viewport_size_changed)
	$TimedMessage.panel_hidden.connect(timed_message_hidden)
	$TimedMessage.show_message("",0)
	$OmniLight3D.position = Vector3(0,0,WorldSize.length())
	$OmniLight3D.omni_range = WorldSize.length()*2
	$CenterCameraLight.set_center_pos_far( Vector3(0, 0, -WorldSize.z), Vector3.ZERO, WorldSize.length()*3)
	add_camera_dict($CenterCameraLight, "Center")
	$FixedCameraLight.set_center_pos_far(Vector3.ZERO, Vector3(0, 0, WorldSize.z),  WorldSize.length()*3)
	add_camera_dict($FixedCameraLight, "Fixed")
	$MovingCameraLightHober.set_center_pos_far(Vector3.ZERO, Vector3(0, 0, WorldSize.z),  WorldSize.length()*3)
	add_camera_dict($MovingCameraLightHober, "Hober")
	$MovingCameraLightAround.set_center_pos_far(Vector3.ZERO, Vector3(0, 0, WorldSize.z),  WorldSize.length()*3)
	add_camera_dict($MovingCameraLightAround, "Around")
	$AxisArrow3D.set_colors().set_size(WorldSize.length()/20)
	$FixedCameraLight.make_current()
	$GlassCabinet.init(WorldSize)
	dialgauge_demo($GlassCabinet)

var dialgauge_list :Array
func dialgauge_demo(gc :GlassCabinet) -> void:
	var dg = preload("res://dial_gauge/dial_gauge.tscn").instantiate(
		).init(gc.cabinet_size.y/2, gc.cabinet_size.z/20
		).init_range( [0,24], [PI*1.5,0]
		).add_dial_num(gc.cabinet_size.y/2*0.85, gc.cabinet_size.z/100, 2, 12, Color.BLUE,
		).add_dial_bar(gc.cabinet_size.y/2*0.99, Vector3(gc.cabinet_size.z/40, gc.cabinet_size.z/200, gc.cabinet_size.z/100),
			DialGauge.BarAlign.In, 120, Color.GREEN
		).add_dial_bar(gc.cabinet_size.y/2*0.99, Vector3(gc.cabinet_size.z/20, gc.cabinet_size.z/200, gc.cabinet_size.z/100),
			DialGauge.BarAlign.In, 12, Color.DARK_GREEN
		)
	gc.add_child(dg)
	dialgauge_list.append([dg, 0.0])
func dialgauge_animate() -> void:
	for dg in dialgauge_list:
		dg[1] += randfn(0,0.2)
		dg[1] = clampf(dg[1], 0,24)
		dg[0].set_needle_value(dg[1])

func _process(_delta: float) -> void:
	dialgauge_animate()

	var now := Time.get_unix_time_from_system()
	label_demo()
	if $MovingCameraLightHober.is_current_camera():
		$MovingCameraLightHober.move_hober_around_z(now/2.3, Vector3.ZERO, WorldSize.length()/2, WorldSize.length()/4 )
	elif $MovingCameraLightAround.is_current_camera():
		$MovingCameraLightAround.move_wave_around_y(now/2.3, Vector3.ZERO, WorldSize.length()/2, WorldSize.length()/4 )

func _on_카메라변경_pressed() -> void:
	MovingCameraLight.NextCamera()

func _on_button_fov_up_pressed() -> void:
	MovingCameraLight.GetCurrentCamera().camera_fov_inc()

func _on_button_fov_down_pressed() -> void:
	MovingCameraLight.GetCurrentCamera().camera_fov_dec()

var key2fn = {
	KEY_ESCAPE:_on_button_esc_pressed,
	KEY_ENTER:_on_카메라변경_pressed,
	KEY_PAGEUP:_on_button_fov_up_pressed,
	KEY_PAGEDOWN:_on_button_fov_down_pressed,
}
func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed:
		var fn = key2fn.get(event.keycode)
		if fn != null:
			fn.call()
		if $FixedCameraLight.is_current_camera():
			var fi = FlyNode3D.Key2Info.get(event.keycode)
			if fi != null:
				FlyNode3D.fly_node3d($FixedCameraLight, fi)
		elif $CenterCameraLight.is_current_camera():
			var fi = FlyNode3D.Key2Info.get(event.keycode)
			if fi != null:
				FlyNode3D.fly_node3d($CenterCameraLight, fi)
	elif event is InputEventMouseButton and event.is_pressed():
		pass

func _on_button_esc_pressed() -> void:
	get_tree().quit()
