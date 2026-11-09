shader_type spatial;
render_mode unshaded, fog_disabled, depth_test_disabled, depth_draw_never, cull_disabled;

uniform sampler2D scene_texture : hint_screen_texture, repeat_disable, filter_linear;
uniform sampler2D depth_texture : hint_depth_texture, repeat_disable, filter_nearest;

uniform float blur_strength : hint_range(0.0, 64) = 25.0;
uniform int sample_count : hint_range(2, 30) = 15;

uniform bool is_camera_history_ready = false;

uniform mat4 previous_view;

void vertex() {
	POSITION = vec4(VERTEX.xy, 1.0, 1.0);
}

void fragment() {
	vec2 movement_uv = vec2(0.0);
	
	// Read depth of the surface at this pixel
	float depth = texture(depth_texture, SCREEN_UV).x;
	
	if (is_camera_history_ready && depth > 0.0) {
		// Transform screen coordinates into normalized device coordinates
		vec3 ndc_position = vec3(SCREEN_UV * 2.0 - 1.0, depth);
		
		// Construct world position from ndc
		vec4 world_position = INV_VIEW_MATRIX * INV_PROJECTION_MATRIX * vec4(ndc_position, 1.0);
		world_position /= world_position.w;
		
		// Compute this same point's position relative to previous camera
		vec4 previous_position = PROJECTION_MATRIX * previous_view * world_position;
		
		// Reconstruct uv coordinates relative to previous camera and compute the difference vector 
		if (previous_position.w > 0.0001) {
    		vec2 previous_ndc = previous_position.xy / previous_position.w;
    		vec2 previous_uv = previous_ndc * 0.5 + 0.5;

    		movement_uv = SCREEN_UV - previous_uv;
		}
	}
	
	vec2 blur_uv = movement_uv * blur_strength;
	vec3 color_sum = vec3(0.0);
	int count = max(sample_count, 2);
	
	for (int i = 0; i < count; i++) {
		float position_along_blur = float(i) / float(count - 1) - 0.5;
		vec2 offset = blur_uv * position_along_blur;
		
		vec3 sample_color = texture(scene_texture, SCREEN_UV + offset).rgb;
		color_sum += sample_color;
	}
	
	ALBEDO = color_sum / float(count);
}