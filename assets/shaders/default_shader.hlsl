#include <hlsl.hlsli>
#include <shader.hlsli>
#include <pbr.hlsli>

struct MaterialUniforms {
	float4 albedo_color;
	float4 emissive_color;
	float4 metallic_roughness;
};

// uniforms
group0_uniforms0(pass_uniforms, PassColorUniforms);
group1_uniforms0(material_uniforms, MaterialUniforms);
group2_uniforms0(draw_uniforms, DrawUniforms);

// material
group1_texture0(albedo_tex, Texture2D);
group1_texture1(metallic_roughness_tex, Texture2D);
group1_texture2(normal_tex, Texture2D);
group1_texture3(emissive_tex, Texture2D);

#include <shadow.hlsli>

PsData
vs(VsData input) {
	return default_vs(input, pass_uniforms.view_proj, draw_uniforms.model, draw_uniforms.skin_offsets);
}

float4
ps(PsData input) : SV_TARGET {
	float4 albedo = material_uniforms.albedo_color * albedo_tex.Sample(sampler_bilinear_repeat, input.uv);
	float4 emissive = material_uniforms.emissive_color * emissive_tex.Sample(sampler_bilinear_repeat, input.uv);
	float2 metallic_roughness = metallic_roughness_tex.Sample(sampler_bilinear_repeat, input.uv).bg;
	metallic_roughness *= material_uniforms.metallic_roughness.rg;

	float metal = metallic_roughness.r;
	float rough = metallic_roughness.g;

	float3 normal = normalize(input.normal);

	// TODO: use emissive.a as exponentiation
	float3 col = emissive.rgb;

	if (material_uniforms.metallic_roughness.r == -1.0) {
		// TODO: temp debug for env background
		col = env_irradiance_tex.SampleLevel(sampler_bilinear_repeat, normal, 0.0).rgb;
	} else {
		float3 view_dir = normalize(pass_uniforms.view_pos.xyz - input.world_pos.xyz);
		PBR pbr = pbr_init(albedo.rgb, metal, rough, view_dir, normal);

		float3 light_col = ambient(pbr);
		//light_col = (0.0).rrr;

		//return shadow_debug_color(input.pos.w);
		float shadow_vis = shadow_visibility(input.world_pos, normal, input.pos.w, pass_uniforms.light_dir.xyz);

		// NOTE: directional light
		light_col += brdf(pbr, pass_uniforms.light_dir.xyz) * pass_uniforms.light_color.rgb * shadow_vis;

		col += light_col;
	}

	col = tonemap(col, /* exposure */ 3.0);
	col = srgb_from_linear(float4(col, 0.0)).rgb;
	return float4(col, 1.0);
}
