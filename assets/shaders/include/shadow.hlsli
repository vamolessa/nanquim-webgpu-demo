#define SHADOW

////////////////////////////////////////////////////////////////////////////////////////////////////
// CONFIG
////////////////////////////////////////////////////////////////////////////////////////////////////

#define SHADOWMAP_FILTER_SIZE 2
#define SHADOW_CASCADES_LEN 4
//#define SHADOWMAP_FILTER_CASCADES

static const float SHADOW_CASCADE_BLEND_THRESHOLD = 0.1;
static const float SHADOW_NORMAL_BIAS = 0.4;
static const float4 SHADOW_DEPTH_BIASES = float4(0.001, 0.001, 0.001, 0.01);

////////////////////////////////////////////////////////////////////////////////////////////////////
// TEXTURES
////////////////////////////////////////////////////////////////////////////////////////////////////

group0_texture3(shadowmap_tex, Texture2DArray<float>);

////////////////////////////////////////////////////////////////////////////////////////////////////
// API
////////////////////////////////////////////////////////////////////////////////////////////////////

float shadow_visibility(float3 world_pos, float3 normal, float clip_depth, float3 light_dir);
float4 shadow_debug_color(float clip_depth);

////////////////////////////////////////////////////////////////////////////////////////////////////
// IMPLEMENTATION
////////////////////////////////////////////////////////////////////////////////////////////////////

float3
biased_light_space_pos(int cascade_index, float3 world_pos, float3 N, float3 L) {
	float3 offset = N * (SHADOW_NORMAL_BIAS * saturate(1.0 - dot(N, L)));
	world_pos += offset;

	float4 result = mul(pass_uniforms.shadow_cascade_view_projs[cascade_index], float4(world_pos, 1.0));
	result.z += SHADOW_DEPTH_BIASES[cascade_index];

	return result.xyz;
}

float
sample_shadowmap(float2 base_uv, float u, float v, float cascade_index, float shadowmap_width_inv, float shadow_depth) {
	float2 uv = base_uv + float2(u, v) * shadowmap_width_inv;
	return shadowmap_tex.SampleCmpLevelZero(sampler_bilinear_clamp_cmp_greater, float3(uv, cascade_index), shadow_depth);
}

float
shadow_cascade_visibility(float3 light_pos, int cascade_index) {
	// NOTE: sample shadowmap

	float cascade_indexf = (float)cascade_index;

    float vis = 0.0;
	{
		// NOTE: optimized pcf from the witness

		float shadowmap_width, shadowmap_height, shadowmap_depth;
		shadowmap_tex.GetDimensions(shadowmap_width, shadowmap_height, shadowmap_depth);

		float2 uv = light_pos.xy * shadowmap_width; // NOTE: 1 unit = 1 texel
		float2 base_uv = floor(uv + (0.5).xx);
		float shadowmap_width_inv = 1.0 / shadowmap_width;

		float s = uv.x + 0.5 - base_uv.x;
		float t = uv.y + 0.5 - base_uv.y;

		base_uv -= (0.5).xx;
		base_uv *= shadowmap_width_inv;

#if SHADOWMAP_FILTER_SIZE == 2

		vis = shadowmap_tex.SampleCmpLevelZero(
			sampler_bilinear_clamp_cmp_greater,
			float3(light_pos.xy, cascade_indexf),
			light_pos.z
		);

#elif SHADOWMAP_FILTER_SIZE == 3

		float uw0 = (3 - 2 * s);
		float uw1 = (1 + 2 * s);

		float u0 = (2 - s) / uw0 - 1;
		float u1 = s / uw1 + 1;

		float vw0 = (3 - 2 * t);
		float vw1 = (1 + 2 * t);

		float v0 = (2 - t) / vw0 - 1;
		float v1 = t / vw1 + 1;

		vis += uw0 * vw0 * sample_shadowmap(base_uv, u0, v0, cascade_indexf, shadowmap_width_inv, light_pos.z);
		vis += uw1 * vw0 * sample_shadowmap(base_uv, u1, v0, cascade_indexf, shadowmap_width_inv, light_pos.z);
		vis += uw0 * vw1 * sample_shadowmap(base_uv, u0, v1, cascade_indexf, shadowmap_width_inv, light_pos.z);
		vis += uw1 * vw1 * sample_shadowmap(base_uv, u1, v1, cascade_indexf, shadowmap_width_inv, light_pos.z);

		vis *= 1.0 / 16.0;

#elif SHADOWMAP_FILTER_SIZE == 5

		float uw0 = (4 - 3 * s);
		float uw1 = 7;
		float uw2 = (1 + 3 * s);

		float u0 = (3 - 2 * s) / uw0 - 2;
		float u1 = (3 + s) / uw1;
		float u2 = s / uw2 + 2;

		float vw0 = (4 - 3 * t);
		float vw1 = 7;
		float vw2 = (1 + 3 * t);

		float v0 = (3 - 2 * t) / vw0 - 2;
		float v1 = (3 + t) / vw1;
		float v2 = t / vw2 + 2;

		vis += uw0 * vw0 * sample_shadowmap(base_uv, u0, v0, cascade_indexf, shadowmap_width_inv, light_pos.z);
		vis += uw1 * vw0 * sample_shadowmap(base_uv, u1, v0, cascade_indexf, shadowmap_width_inv, light_pos.z);
		vis += uw2 * vw0 * sample_shadowmap(base_uv, u2, v0, cascade_indexf, shadowmap_width_inv, light_pos.z);

		vis += uw0 * vw1 * sample_shadowmap(base_uv, u0, v1, cascade_indexf, shadowmap_width_inv, light_pos.z);
		vis += uw1 * vw1 * sample_shadowmap(base_uv, u1, v1, cascade_indexf, shadowmap_width_inv, light_pos.z);
		vis += uw2 * vw1 * sample_shadowmap(base_uv, u2, v1, cascade_indexf, shadowmap_width_inv, light_pos.z);

		vis += uw0 * vw2 * sample_shadowmap(base_uv, u0, v2, cascade_indexf, shadowmap_width_inv, light_pos.z);
		vis += uw1 * vw2 * sample_shadowmap(base_uv, u1, v2, cascade_indexf, shadowmap_width_inv, light_pos.z);
		vis += uw2 * vw2 * sample_shadowmap(base_uv, u2, v2, cascade_indexf, shadowmap_width_inv, light_pos.z);

		vis *= 1.0 / 144.0;

#elif SHADOWMAP_FILTER_SIZE == 7

		float uw0 = (5 * s - 6);
		float uw1 = (11 * s - 28);
		float uw2 = -(11 * s + 17);
		float uw3 = -(5 * s + 1);

		float u0 = (4 * s - 5) / uw0 - 3;
		float u1 = (4 * s - 16) / uw1 - 1;
		float u2 = -(7 * s + 5) / uw2 + 1;
		float u3 = -s / uw3 + 3;

		float vw0 = (5 * t - 6);
		float vw1 = (11 * t - 28);
		float vw2 = -(11 * t + 17);
		float vw3 = -(5 * t + 1);

		float v0 = (4 * t - 5) / vw0 - 3;
		float v1 = (4 * t - 16) / vw1 - 1;
		float v2 = -(7 * t + 5) / vw2 + 1;
		float v3 = -t / vw3 + 3;

		vis += uw0 * vw0 * sample_shadowmap(base_uv, u0, v0, cascade_indexf, shadowmap_width_inv, light_pos.z);
		vis += uw1 * vw0 * sample_shadowmap(base_uv, u1, v0, cascade_indexf, shadowmap_width_inv, light_pos.z);
		vis += uw2 * vw0 * sample_shadowmap(base_uv, u2, v0, cascade_indexf, shadowmap_width_inv, light_pos.z);
		vis += uw3 * vw0 * sample_shadowmap(base_uv, u3, v0, cascade_indexf, shadowmap_width_inv, light_pos.z);

		vis += uw0 * vw1 * sample_shadowmap(base_uv, u0, v1, cascade_indexf, shadowmap_width_inv, light_pos.z);
		vis += uw1 * vw1 * sample_shadowmap(base_uv, u1, v1, cascade_indexf, shadowmap_width_inv, light_pos.z);
		vis += uw2 * vw1 * sample_shadowmap(base_uv, u2, v1, cascade_indexf, shadowmap_width_inv, light_pos.z);
		vis += uw3 * vw1 * sample_shadowmap(base_uv, u3, v1, cascade_indexf, shadowmap_width_inv, light_pos.z);

		vis += uw0 * vw2 * sample_shadowmap(base_uv, u0, v2, cascade_indexf, shadowmap_width_inv, light_pos.z);
		vis += uw1 * vw2 * sample_shadowmap(base_uv, u1, v2, cascade_indexf, shadowmap_width_inv, light_pos.z);
		vis += uw2 * vw2 * sample_shadowmap(base_uv, u2, v2, cascade_indexf, shadowmap_width_inv, light_pos.z);
		vis += uw3 * vw2 * sample_shadowmap(base_uv, u3, v2, cascade_indexf, shadowmap_width_inv, light_pos.z);

		vis += uw0 * vw3 * sample_shadowmap(base_uv, u0, v3, cascade_indexf, shadowmap_width_inv, light_pos.z);
		vis += uw1 * vw3 * sample_shadowmap(base_uv, u1, v3, cascade_indexf, shadowmap_width_inv, light_pos.z);
		vis += uw2 * vw3 * sample_shadowmap(base_uv, u2, v3, cascade_indexf, shadowmap_width_inv, light_pos.z);
		vis += uw3 * vw3 * sample_shadowmap(base_uv, u3, v3, cascade_indexf, shadowmap_width_inv, light_pos.z);

		vis *= 1.0 / 2704.0;

#else
# error invalid SHADOWMAP_FILTER_SIZE
#endif
	}

	return vis;
}

float
shadow_visibility(float3 world_pos, float3 normal, float clip_depth, float3 light_dir) {
	int cascade_index = 0;
	[unroll]
	for (int i = SHADOW_CASCADES_LEN - 1; i >= 0; i--) {
		if (clip_depth <= pass_uniforms.shadow_cascade_splits[i]) {
			cascade_index = i;
		}
	}

	float3 light_pos0 = biased_light_space_pos(cascade_index, world_pos, normal, light_dir);
	float vis = shadow_cascade_visibility(light_pos0, cascade_index);

#if defined(SHADOWMAP_FILTER_CASCADES)
	float next_split = pass_uniforms.shadow_cascade_splits[cascade_index];
	float split_size = next_split;
	if (cascade_index > 0) {
		split_size -= pass_uniforms.shadow_cascade_splits[cascade_index - 1];
	}
	float fade_factor = (next_split - clip_depth) / split_size;

	[branch]
	if (fade_factor <= SHADOW_CASCADE_BLEND_THRESHOLD && cascade_index != SHADOW_CASCADES_LEN - 1) {
		float3 light_pos1 = biased_light_space_pos(cascade_index + 1, world_pos, normal, light_dir);
		float cascade_blend = 1.0 - smoothstep(0.0, SHADOW_CASCADE_BLEND_THRESHOLD, fade_factor);

		float next_vis = shadow_cascade_visibility(light_pos1.xyz, cascade_index + 1);
		vis = lerp(vis, next_vis, cascade_blend);
	}
#endif

	return vis;
}

float4
shadow_debug_color(float clip_depth) {
	int cascade_index = 0;
	[unroll]
	for (int i = SHADOW_CASCADES_LEN - 1; i >= 0; i--) {
		if (clip_depth <= pass_uniforms.shadow_cascade_splits[i]) {
			cascade_index = i;
		}
	}

	const float3 cascade_colors[SHADOW_CASCADES_LEN] = {
		float3(1.0, 0.0, 0.0),
		float3(0.0, 1.0, 0.0),
		float3(0.0, 0.0, 1.0),
		float3(1.0, 1.0, 0.0),
	};

	float3 c = cascade_colors[cascade_index];

#if defined(SHADOWMAP_FILTER_CASCADES)
	float next_split = pass_uniforms.shadow_cascade_splits[cascade_index];
	float split_size = next_split;
	if (cascade_index > 0) {
		split_size -= pass_uniforms.shadow_cascade_splits[cascade_index - 1];
	}
	float fade_factor = (next_split - clip_depth) / split_size;

	if (fade_factor <= SHADOW_CASCADE_BLEND_THRESHOLD && cascade_index != SHADOW_CASCADES_LEN - 1) {
		float cascade_blend = 1.0 - smoothstep(0.0, SHADOW_CASCADE_BLEND_THRESHOLD, fade_factor);
		c = lerp(c, cascade_colors[cascade_index + 1], cascade_blend);
	}
#endif

	return float4(c, 1.0);
}
