shader_type canvas_item;

uniform vec4 color : source_color = vec4(1.0);
uniform sampler2D tex;

void vertex() {
}

void fragment() {
	vec2 uv = fract(UV * vec2(1.0, 0.01));
	vec4 c = texture(tex, uv.yx);
	COLOR = vec4(c.rgb, 1.0);
}