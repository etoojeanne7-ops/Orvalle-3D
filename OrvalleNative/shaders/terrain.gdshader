shader_type spatial;
render_mode diffuse_burley, specular_schlick_ggx;

uniform sampler2D ground_albedo : source_color, repeat_enable;
uniform sampler2D ground_roughness : repeat_enable;
uniform float texture_world_scale : hint_range(0.25, 8.0) = 2.0;

varying vec3 terrain_local_position;

float hash21(vec2 p) {
	p = fract(p * vec2(123.34, 456.21));
	p += dot(p, p + 45.32);
	return fract(p.x * p.y);
}

float value_noise(vec2 p) {
	vec2 i = floor(p);
	vec2 f = fract(p);
	f = f * f * (3.0 - 2.0 * f);
	float a = hash21(i);
	float b = hash21(i + vec2(1.0, 0.0));
	float c = hash21(i + vec2(0.0, 1.0));
	float d = hash21(i + vec2(1.0, 1.0));
	return mix(mix(a, b, f.x), mix(c, d, f.x), f.y);
}

float fbm(vec2 p) {
	float result = 0.0;
	float amplitude = 0.5;
	for (int i = 0; i < 5; i++) {
		result += value_noise(p) * amplitude;
		p *= 2.03;
		amplitude *= 0.5;
	}
	return result;
}

void vertex() {
	terrain_local_position = VERTEX;
}

void fragment() {
	vec2 p = terrain_local_position.xz;
	vec2 uv = p / max(texture_world_scale, 0.25);
	float broad = fbm(p * 0.075);
	float fine = fbm(p * 1.7);
	float grain = value_noise(p * 8.0);
	float slope = 1.0 - clamp(dot(normalize(NORMAL), vec3(0.0, 1.0, 0.0)), 0.0, 1.0);

	vec3 grass_dark = vec3(0.075, 0.15, 0.065);
	vec3 grass_light = vec3(0.23, 0.31, 0.12);
	vec3 procedural_grass = mix(grass_dark, grass_light, clamp(broad * 0.9 + fine * 0.3, 0.0, 1.0));
	procedural_grass = mix(procedural_grass, vec3(0.24, 0.19, 0.11), smoothstep(0.60, 0.77, fine) * 0.55);
	procedural_grass *= mix(0.82, 1.13, grain);

	// Real CC0 Poly Haven albedo texture supplies leaf litter, twigs, moss and soil detail.
	vec3 scanned_ground = texture(ground_albedo, uv).rgb;
	scanned_ground *= mix(0.88, 1.12, broad);
	vec3 ground_color = mix(procedural_grass, scanned_ground, 0.82);
	vec3 stone = vec3(0.28, 0.29, 0.27);
	float rock_mask = smoothstep(0.24, 0.62, slope);
	rock_mask = max(rock_mask, smoothstep(2.0, 3.2, terrain_local_position.y) * 0.35);
	ALBEDO = mix(ground_color, stone * mix(0.82, 1.14, fine), clamp(rock_mask, 0.0, 0.92));
	ROUGHNESS = clamp(texture(ground_roughness, uv).r, 0.65, 1.0);
	METALLIC = 0.0;
}
