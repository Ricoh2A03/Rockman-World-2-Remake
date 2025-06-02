shader_type canvas_item;

uniform bool active = false;

void fragment() {
	vec4 pixel_color = texture(TEXTURE, UV);
	if (pixel_color.a > 0.0 && active){
		COLOR = vec4(1, 1, 1, 1);
	}
}
