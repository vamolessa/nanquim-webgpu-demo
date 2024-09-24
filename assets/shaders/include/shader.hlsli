////////////////////////////////////////////////////////////////////////////////////////////////////
// IO
////////////////////////////////////////////////////////////////////////////////////////////////////

struct VsData {
	float4 pos : POSITION;
	float4 tangent : TANGENT;
	float3 normal : NORMAL;
	float2 uv : TEXCOORD;
};

struct VsPosOnlyData {
	uint id : SV_VERTEXID;
	float4 pos : POSITION;
};

struct PsData {
	float4 pos : SV_POSITION;
	float3 world_pos : POSITION0;
	float3 normal : NORMAL;
	float2 uv : TEXCOORD;
};

struct PsPosOnlyData {
	float4 pos : SV_POSITION;
};

////////////////////////////////////////////////////////////////////////////////////////////////////
// DEFAULT SAMPLERS
////////////////////////////////////////////////////////////////////////////////////////////////////

group0_sampler0(sampler_bilinear_repeat, SamplerState);
group0_sampler1(sampler_trilinear_repeat, SamplerState);
group0_sampler2(sampler_bilinear_clamp, SamplerState);
group0_sampler3(sampler_bilinear_clamp_cmp_greater, SamplerComparisonState);

////////////////////////////////////////////////////////////////////////////////////////////////////
// DEFAULT UNIFORMS
////////////////////////////////////////////////////////////////////////////////////////////////////

struct PassColorUniforms {
	float4x4 view_proj;
	float4 view_pos;

	float4 light_dir;
	float4 light_color;

	float4x4 shadow_cascade_view_projs[4];
	float4 shadow_cascade_splits;
};

struct PassShadowUniforms {
	float4x4 view_proj;
};

struct DrawUniforms {
	float3x4 model;
	int4 skin_offsets; // {skins_offset, bones_offset, 0, 0}
};

////////////////////////////////////////////////////////////////////////////////////////////////////
// STORAGE BUFFERS
////////////////////////////////////////////////////////////////////////////////////////////////////

struct VertexSkin {
	uint joints; // uint8[4]
	uint weights; // unorm float[4]
};

struct PoseBone {
	float3x4 transform;
};

group0_storage0(skins, StructuredBuffer<VertexSkin>);
group0_storage1(pose_bones, StructuredBuffer<PoseBone>);

uint4
unpack_rgba8_uint(uint bits) {
	uint4 result;
	result.x = (bits >> 0) & 0xff;
	result.y = (bits >> 8) & 0xff;
	result.z = (bits >> 16) & 0xff;
	result.w = (bits >> 24) & 0xff;
	return result;
}

float4
unpack_rgba8_unorm(uint bits) {
	precise float4 result;
	result.x = (float)((bits >> 0) & 0xff);
	result.y = (float)((bits >> 8) & 0xff);
	result.z = (float)((bits >> 16) & 0xff);
	result.w = (float)((bits >> 24) & 0xff);
	return result / (float)0xff;
}

////////////////////////////////////////////////////////////////////////////////////////////////////
// VERTEX
////////////////////////////////////////////////////////////////////////////////////////////////////

float3x4
calc_model_matrix(float4 pos, float3x4 model_matrix, int4 skin_offsets) {
	uint skins_offset = (uint)skin_offsets.x;
	uint bones_offset = (uint)skin_offsets.y;

	[branch]
	if (skins_offset && bones_offset) {
		uint vertex_skin_index = (uint)pos.w;
		uint skin_index = skins_offset + vertex_skin_index;
		VertexSkin skin = skins[skin_index];
		uint4 joints = unpack_rgba8_uint(skin.joints);
		float4 weights = unpack_rgba8_unorm(skin.weights);

		float3x4 result = weights[0] * pose_bones[bones_offset + joints[0]].transform;
		result += weights[1] * pose_bones[bones_offset + joints[1]].transform;
		result += weights[2] * pose_bones[bones_offset + joints[2]].transform;
		result += weights[3] * pose_bones[bones_offset + joints[3]].transform;

		return result;
	} else {
		return model_matrix;
	}
}

float3x3
calc_normal_matrix(float3x4 model_matrix) {
	float3x3 result = (float3x3)model_matrix;
	result[0] = normalize(result[0]);
	result[1] = normalize(result[1]);
	result[2] = normalize(result[2]);
	return result;
}

PsData
default_vs(VsData input, float4x4 view_proj_matrix, float3x4 model_matrix, int4 skin_offsets) {
	model_matrix = calc_model_matrix(input.pos, model_matrix, skin_offsets);
	float3 pos = mul(model_matrix, float4(input.pos.xyz, 1.0)).xyz;
	float4 clip_pos = mul(view_proj_matrix, float4(pos, 1.0));

	PsData output;
	output.pos = clip_pos;

	float3 normal = mul(calc_normal_matrix(model_matrix), input.normal);

	output.world_pos = pos;
	output.normal = normal;
	output.uv = input.uv;

	return output;
}

PsPosOnlyData
default_vs_pos_only(VsPosOnlyData input, float4x4 view_proj_matrix, float3x4 model_matrix, int4 skin_offsets) {
	model_matrix = calc_model_matrix(input.pos, model_matrix, skin_offsets);
	float3 pos = mul(model_matrix, float4(input.pos.xyz, 1.0)).xyz;
	float4 clip_pos = mul(view_proj_matrix, float4(pos, 1.0));

	PsPosOnlyData output;
	output.pos = clip_pos;
	return output;
}
