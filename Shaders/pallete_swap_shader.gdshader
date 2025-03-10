shader_type canvas_item;

uniform sampler2D palette: filter_nearest, repeat_disable;
uniform int color_count = 0;
uniform int palette_row = 0;

#define APPROX_EQUAL(A,B) dot(A - B, A - B) < 0.01

void fragment() {
	for (int i = 0; i < color_count; i++){
		
	}
}
