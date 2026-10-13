shader_type spatial;
render_mode diffuse_burley, specular_schlick_ggx;

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
	float broad = fbm(p * 0.075);
	float fine = fbm(p * 1.7);
	float grain = value_noise(p * 8.0);
	float slope = 1.0 - clamp(dot(normalize(NORMAL), vec3(0.0, 1.0, 0.0)), 0.0, 1.0);
	vec3 grass_dark = vec3(0.075, 0.15, 0.065);
	vec3 grass_light = vec3(0.23, 0.31, 0.12);
	vec3 soil = vec3(0.24, 0.19, 0.11);
	vec3 stone = vec3(0.28, 0.29, 0.27);
	vec3 grass = mix(grass_dark, grass_light, clamp(broad * 0.9 + fine * 0.3, 0.0, 1.0));
	grass = mix(grass, soil, smoothstep(0.60, 0.77, fine) * 0.55);
	grass *= mix(0.82, 1.13, grain);
	float rock_mask = smoothstep(0.24, 0.62, slope);
	rock_mask = max(rock_mask, smoothstep(2.0, 3.2, terrain_local_position.y) * 0.35);
	ALBEDO = mix(grass, stone * mix(0.82, 1.14, fine), clamp(rock_mask, 0.0, 0.92));
	ROUGHNESS = 0.94;
	METALLIC = 0.0;
}
