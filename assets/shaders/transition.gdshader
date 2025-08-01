shader_type canvas_item;

uniform float fill_amount = 0.5;
uniform vec2 size = vec2(1.0, 1.0);
uniform sampler2D trans_texture;
uniform bool is_tiling = false;
uniform bool invert = false;

void fragment() {
	vec2 uv = UV;
	if (is_tiling) {
    	 uv = (UV / TEXTURE_PIXEL_SIZE) / size;
	}
	float value = texture(trans_texture, uv).r;
	bool hide = (value > fill_amount && !invert) || (value < fill_amount && invert);
	if (hide) {
		COLOR = vec4(0.0);
	}
}