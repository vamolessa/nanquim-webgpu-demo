#include <hlsl.hlsli>

struct VsData {
	float2 pos : POSITION;
	float2 uv : TEXCOORD;
	float4 col : COLOR;
};

struct PsData {
	float4 pos : SV_POSITION;
	float2 uv : TEXCOORD;
	float4 col : COLOR;
};

struct DrawUniforms {
	float4x4 view_proj;
};

group0_sampler0(sampler_bilinear_repeat, SamplerState);
group0_texture0(atlas_tex, Texture2D);
group0_uniforms0(draw_uniforms, DrawUniforms);

PsData
vs(VsData input) {
	PsData output;
	output.pos = mul(draw_uniforms.view_proj, float4(input.pos, 0.0, 1.0));
	output.col = input.col;
	output.uv = input.uv;
	return output;
}

float4
ps(PsData input) : SV_TARGET {
	float4 col = input.col;
	col *= atlas_tex.Sample(sampler_bilinear_repeat, input.uv);
	col.rgb *= col.a;
	return col;
}
