extends MeshInstance3D

var camera: Camera3D
var effect_material: ShaderMaterial

var previous_camera_transform: Transform3D
var has_previous_frame: bool = false

func _ready() -> void:
	camera = get_parent() as Camera3D
	
	if camera == null:
		return
	
	var source_material := material_override as ShaderMaterial
	if source_material == null:
		return
	
	effect_material = source_material.duplicate() as ShaderMaterial
	material_override = effect_material
	
	_update_blur_settings()
	
	RenderingServer.frame_pre_draw.connect(_update_camera_history)
	
func _process(_delta: float) -> void:
	_update_blur_settings()
	
func _update_camera_history() -> void:
	
	var current_camera_transform := camera.get_camera_transform()
	var is_camera_moving := false
	
	if not has_previous_frame:
		previous_camera_transform = current_camera_transform
		has_previous_frame = true
	else: 
		is_camera_moving = not current_camera_transform.is_equal_approx(previous_camera_transform)
	
	effect_material.set_shader_parameter("is_camera_history_ready", true)
	effect_material.set_shader_parameter("previous_view", previous_camera_transform.affine_inverse())
	
	previous_camera_transform = current_camera_transform
	
func _update_blur_settings() -> void:
	if effect_material == null:
		return
	
	var strength_changed : bool = Config.value_changed("camera_motion_blur", "player.camera.motion_blur.strength")
	var sample_count_changed : bool = Config.value_changed("camera_motion_blur", "player.camera.motion_blur.sample_count")
	
	if strength_changed:
		effect_material.set_shader_parameter("blur_strength", float(Config.get_value("player.camera.motion_blur.strength")))
	if sample_count_changed:
		effect_material.set_shader_parameter("sample_count", int(Config.get_value("player.camera.motion_blur.sample_count")))
		
func _exit_tree() -> void:
	if RenderingServer.frame_pre_draw.is_connected(_update_camera_history): 
		RenderingServer.frame_pre_draw.disconnect(_update_camera_history)
		
		has_previous_frame = false
	
