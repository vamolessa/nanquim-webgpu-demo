#include <hlsl.hlsli>

struct PsData {
	float4 pos : SV_POSITION;
	float2 uv : TEXCOORD;
};

group0_sampler0(sampler_bilinear_repeat, SamplerState);
group0_texture0(src, Texture2D);

PsData
vs(uint id : SV_VERTEXID) {
	float2 uv = float2(id & 1, id >> 1);
	float4 pos = float4(0.0, 0.0, 0.0, 1.0);
	pos.xy = (uv * 2.0) - float2(1.0, 1.0);
	uv.y = 1.0 - uv.y;
	PsData output;
	output.pos = pos;
	output.uv = uv;
	return output;
}

float4
ps(PsData input) : SV_TARGET {
	return src.Sample(sampler_bilinear_repeat, input.uv);
}
