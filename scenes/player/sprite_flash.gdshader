shader_type canvas_item;
uniform float intensity = 0.0;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	vec4 default_color = texture(TEXTURE, UV);
	vec4 white_color = vec4(1.0, 1.0, 1.0, default_color.a);
	vec4 set_color = default_color;
	set_color += vec4(1,1,1,0)*intensity;
	COLOR = set_color;
	// Called for every pixel the material is visible on.
}

//void light() {
	// Called for every pixel for every light affecting the CanvasItem.
	// Uncomment to replace the default light processing function with this one.
//}
