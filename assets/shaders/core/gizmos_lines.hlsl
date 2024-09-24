#include <hlsl.hlsli>

struct VsData {
	float3 pos : POSITION;
	float4 col : COLOR;
};

struct PsData {
	float4 pos : SV_POSITION;
	float4 col : COLOR;
};

struct PassUniforms {
	float4x4 view_proj;
};

group0_uniforms0(pass_color_uniforms, PassUniforms);

PsData
vs(VsData input) {
	PsData output;
	output.pos = mul(pass_color_uniforms.view_proj, float4(input.pos, 1.0));
	output.col = input.col;
	return output;
}

float4
ps(PsData input) : SV_TARGET {
	float4 col = input.col;
	col.rgb *= col.a;
	return col;
}
