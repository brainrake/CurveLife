shader_type canvas_item;

uniform vec4 color : source_color = vec4(1.0);
uniform float fade = 0.0;

void vertex() {
}

void fragment() {
	vec4 t = texture(TEXTURE, UV);
	vec2 p = (UV - 0.5) * 2.0;
	float c = length(p);

	COLOR = vec4(
    mix(mix(color.rgb, vec3(1.0), fade), vec3(1.0 - step(0.001, fade)), t.a), 
    // c * step(sin(TIME) * 0.25 + 0.25, c)
    // (1.0 - step(1.0, c))
    (1.0 - step(1.0, c))
  );
}