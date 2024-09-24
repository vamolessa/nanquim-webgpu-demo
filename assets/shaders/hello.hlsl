#include <hlsl.hlsli>

struct DrawUniforms {
	float4x4 transform;
	float3x4 t;
	//float4 row0;
	//float4 row1;
	//float4 row2;
	uint4 pad;
	float4 color;
};

struct Uniforms {
	float4 color;
};

struct VertexSkin {
	uint joints; // uint8[4]
	uint weights; // unorm float[4]
};

group0_sampler0(sampler_bilinear_repeat, SamplerState);
group0_texture0(albedo, Texture2D<float4>);
group0_uniforms0(uniforms, DrawUniforms);
group0_storage0(skins, StructuredBuffer<VertexSkin>);

struct VsData {
	uint id : SV_VERTEXID;
	float2 pos : POSITION;
	float2 uv : TEXCOORD;
};

struct PsData {
	float4 pos : SV_POSITION;
	float2 uv : TEXCOORD;
};

float4x4
load_mat34(float4 row0, float4 row1, float4 row2) {
	row_major float4x4 result = { row0, row1, row2, float4(0.0, 0.0, 0.0, 1.0) };
	return result;
}

PsData
vs(VsData input) {
	VertexSkin skin = skins[input.id];

	float4 p = float4(input.pos, 0.0, 1.0);
	//float4 row0 = uniforms.row0;
	//row0.w -= skin.joints;
	//float4x4 transform = load_mat34(row0, uniforms.row1, uniforms.row2);
	//p = mul(transform, p);
	float4x4 transform = float4x4(uniforms.t, float4(0.0, 0.0, 0.0, 1.0));
	p = mul(transform, p);

	PsData output;
	output.pos = p;
	output.uv = input.uv;
	return output;
}

float3 gamma_correct(float3 col, float gamma) { return pow(abs(col), gamma); }
float4 srgb_from_linear(float4 col) { return float4(gamma_correct(col.rgb, 1.0 / 2.2), col.a); }

float4
ps(PsData input) : SV_TARGET {
	float4 tex_color = albedo.Sample(sampler_bilinear_repeat, input.uv);
	return srgb_from_linear(uniforms.color * tex_color);
}
