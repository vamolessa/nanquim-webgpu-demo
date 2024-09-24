struct VertexSkin {
  /* @offset(0) */
  joints : u32,
  /* @offset(4) */
  weights : u32,
}

alias RTArr = array<VertexSkin>;

struct type_StructuredBuffer_VertexSkin {
  /* @offset(0) */
  field0 : RTArr,
}

struct PoseBone {
  /* @offset(0) */
  transform : mat3x4f,
}

alias RTArr_1 = array<PoseBone>;

struct type_StructuredBuffer_PoseBone {
  /* @offset(0) */
  field0 : RTArr_1,
}

alias Arr = array<mat4x4f, 4u>;

struct type_ConstantBuffer_PassColorUniforms {
  /* @offset(0) */
  view_proj : mat4x4f,
  /* @offset(64) */
  view_pos : vec4f,
  /* @offset(80) */
  light_dir : vec4f,
  /* @offset(96) */
  light_color : vec4f,
  /* @offset(112) */
  shadow_cascade_view_projs : Arr,
  /* @offset(368) */
  shadow_cascade_splits : vec4f,
}

struct type_ConstantBuffer_MaterialUniforms {
  /* @offset(0) */
  albedo_color : vec4f,
  /* @offset(16) */
  emissive_color : vec4f,
  /* @offset(32) */
  metallic_roughness : vec4f,
}

struct type_ConstantBuffer_DrawUniforms {
  /* @offset(0) */
  model : mat3x4f,
  /* @offset(48) */
  skin_offsets : vec4i,
}

struct VsData {
  pos : vec4f,
  tangent : vec4f,
  normal : vec3f,
  uv : vec2f,
}

struct PsData {
  pos : vec4f,
  world_pos : vec3f,
  normal : vec3f,
  uv : vec2f,
}

struct VertexSkin_1 {
  joints : u32,
  weights : u32,
}

@group(0) @binding(0) var sampler_bilinear_repeat : sampler;

@group(0) @binding(1) var sampler_trilinear_repeat : sampler;

@group(0) @binding(2) var sampler_bilinear_clamp : sampler;

@group(0) @binding(3) var sampler_bilinear_clamp_cmp_greater : sampler;

@group(0) @binding(12) var<storage, read> skins : type_StructuredBuffer_VertexSkin;

@group(0) @binding(13) var<storage, read> pose_bones : type_StructuredBuffer_PoseBone;

var<private> PI : f32;

var<private> TAU : f32;

var<private> EPSILON : f32;

var<private> F_DIELECTRIC : vec3f;

@group(0) @binding(4) var env_brdf_lut_tex : texture_2d<f32>;

@group(0) @binding(5) var env_radiance_tex : texture_cube<f32>;

@group(0) @binding(6) var env_irradiance_tex : texture_cube<f32>;

@group(0) @binding(20) var<uniform> pass_uniforms : type_ConstantBuffer_PassColorUniforms;

@group(1) @binding(20) var<uniform> material_uniforms : type_ConstantBuffer_MaterialUniforms;

@group(2) @binding(20) var<uniform> draw_uniforms : type_ConstantBuffer_DrawUniforms;

@group(1) @binding(4) var albedo_tex : texture_2d<f32>;

@group(1) @binding(5) var metallic_roughness_tex : texture_2d<f32>;

@group(1) @binding(6) var normal_tex : texture_2d<f32>;

@group(1) @binding(7) var emissive_tex : texture_2d<f32>;

var<private> SHADOW_CASCADE_BLEND_THRESHOLD : f32;

var<private> SHADOW_NORMAL_BIAS : f32;

var<private> SHADOW_DEPTH_BIASES : vec4f;

@group(0) @binding(7) var shadowmap_tex : texture_2d_array<f32>;

var<private> in_var_POSITION : vec4f;

var<private> in_var_TANGENT : vec4f;

var<private> in_var_NORMAL : vec3f;

var<private> in_var_TEXCOORD : vec2f;

var<private> x_7 : vec4f;

var<private> out_var_POSITION0 : vec3f;

var<private> out_var_NORMAL : vec3f;

var<private> out_var_TEXCOORD : vec2f;

fn unpack_rgba8_uint(bits : ptr<function, u32>) -> vec4u {
  var result_2 : vec4u;
  result_2.x = ((*(bits) >> (0u & 31u)) & 255u);
  result_2.y = ((*(bits) >> (8u & 31u)) & 255u);
  result_2.z = ((*(bits) >> (16u & 31u)) & 255u);
  result_2.w = ((*(bits) >> (24u & 31u)) & 255u);
  let x_393 = result_2;
  return x_393;
}

fn unpack_rgba8_unorm(bits_1 : ptr<function, u32>) -> vec4f {
  var result_3 : vec4f;
  result_3.x = f32(((*(bits_1) >> (0u & 31u)) & 255u));
  result_3.y = f32(((*(bits_1) >> (8u & 31u)) & 255u));
  result_3.z = f32(((*(bits_1) >> (16u & 31u)) & 255u));
  result_3.w = f32(((*(bits_1) >> (24u & 31u)) & 255u));
  let x_422 = result_3;
  return (x_422 / vec4f(255.0f));
}

fn calc_model_matrix(pos_1 : ptr<function, vec4f>, model_matrix_1 : ptr<function, mat3x4f>, skin_offsets_1 : ptr<function, vec4i>) -> mat3x4f {
  var skins_offset : u32;
  var bones_offset : u32;
  var temp_var_logical : bool;
  var vertex_skin_index : u32;
  var skin_index : u32;
  var skin : VertexSkin_1;
  var joints : vec4u;
  var param_var_bits : u32;
  var weights : vec4f;
  var param_var_bits_1 : u32;
  var result : mat3x4f;
  skins_offset = bitcast<u32>((*(skin_offsets_1)).x);
  bones_offset = bitcast<u32>((*(skin_offsets_1)).y);
  let x_240 = skins_offset;
  temp_var_logical = false;
  if ((x_240 != 0u)) {
    temp_var_logical = (bones_offset != 0u);
  }
  if (temp_var_logical) {
    vertex_skin_index = u32((*(pos_1)).w);
    skin_index = (skins_offset + vertex_skin_index);
    let x_260 = skins.field0[skin_index];
    skin = VertexSkin_1(x_260.joints, x_260.weights);
    param_var_bits = skin.joints;
    let x_266 = unpack_rgba8_uint(&(param_var_bits));
    joints = x_266;
    param_var_bits_1 = skin.weights;
    let x_270 = unpack_rgba8_unorm(&(param_var_bits_1));
    weights = x_270;
    result = (pose_bones.field0[(bones_offset + joints.x)].transform * weights.x);
    let x_289 = (pose_bones.field0[(bones_offset + joints.y)].transform * weights.y);
    result = mat3x4f((result[0u] + x_289[0u]), (result[1u] + x_289[1u]), (result[2u] + x_289[2u]));
    let x_309 = (pose_bones.field0[(bones_offset + joints.z)].transform * weights.z);
    result = mat3x4f((result[0u] + x_309[0u]), (result[1u] + x_309[1u]), (result[2u] + x_309[2u]));
    let x_329 = (pose_bones.field0[(bones_offset + joints.w)].transform * weights.w);
    result = mat3x4f((result[0u] + x_329[0u]), (result[1u] + x_329[1u]), (result[2u] + x_329[2u]));
    let x_341 = result;
    return x_341;
  } else {
    let x_342 = *(model_matrix_1);
    return x_342;
  }
}

fn calc_normal_matrix(model_matrix_2 : ptr<function, mat3x4f>) -> mat3x3f {
  var result_1 : mat3x3f;
  let x_348 = *(model_matrix_2);
  result_1 = mat3x3f(x_348[0u].xyz, x_348[1u].xyz, x_348[2u].xyz);
  result_1[0u] = normalize(result_1[0u]);
  result_1[1u] = normalize(result_1[1u]);
  result_1[2u] = normalize(result_1[2u]);
  let x_368 = result_1;
  return x_368;
}

fn default_vs(input_1 : ptr<function, VsData>, view_proj_matrix : ptr<function, mat4x4f>, model_matrix : ptr<function, mat3x4f>, skin_offsets : ptr<function, vec4i>) -> PsData {
  var param_var_pos : vec4f;
  var param_var_model_matrix_1 : mat3x4f;
  var param_var_skin_offsets_1 : vec4i;
  var pos : vec3f;
  var clip_pos : vec4f;
  var output : PsData;
  var normal : vec3f;
  var param_var_model_matrix_2 : mat3x4f;
  param_var_pos = (*(input_1)).pos;
  param_var_model_matrix_1 = *(model_matrix);
  param_var_skin_offsets_1 = *(skin_offsets);
  let x_175 = calc_model_matrix(&(param_var_pos), &(param_var_model_matrix_1), &(param_var_skin_offsets_1));
  *(model_matrix) = x_175;
  let x_180 = (*(input_1)).pos.xyz;
  pos = (vec4f(x_180.x, x_180.y, x_180.z, 1.0f) * *(model_matrix));
  clip_pos = (vec4f(pos.x, pos.y, pos.z, 1.0f) * *(view_proj_matrix));
  output.pos = clip_pos;
  param_var_model_matrix_2 = *(model_matrix);
  let x_197 = calc_normal_matrix(&(param_var_model_matrix_2));
  normal = ((*(input_1)).normal * x_197);
  output.world_pos = pos;
  output.normal = normal;
  output.uv = (*(input_1)).uv;
  let x_210 = output;
  return x_210;
}

fn src_vs(input : ptr<function, VsData>) -> PsData {
  var param_var_input_1 : VsData;
  var param_var_view_proj_matrix : mat4x4f;
  var param_var_model_matrix : mat3x4f;
  var param_var_skin_offsets : vec4i;
  param_var_input_1 = *(input);
  param_var_view_proj_matrix = pass_uniforms.view_proj;
  param_var_model_matrix = draw_uniforms.model;
  param_var_skin_offsets = draw_uniforms.skin_offsets;
  let x_152 = default_vs(&(param_var_input_1), &(param_var_view_proj_matrix), &(param_var_model_matrix), &(param_var_skin_offsets));
  return x_152;
}

fn vs_1() {
  var param_var_input : VsData;
  PI = 3.1415920257568359375f;
  TAU = (2.0f * PI);
  EPSILON = 0.00000999999974737875f;
  F_DIELECTRIC = vec3f(0.03999999910593032837f);
  SHADOW_CASCADE_BLEND_THRESHOLD = 0.10000000149011611938f;
  SHADOW_NORMAL_BIAS = 0.40000000596046447754f;
  SHADOW_DEPTH_BIASES = vec4f(0.00100000004749745131f, 0.00100000004749745131f, 0.00100000004749745131f, 0.00999999977648258209f);
  param_var_input = VsData(in_var_POSITION, in_var_TANGENT, in_var_NORMAL, in_var_TEXCOORD);
  let x_126 = src_vs(&(param_var_input));
  x_7 = x_126.pos;
  out_var_POSITION0 = x_126.world_pos;
  out_var_NORMAL = x_126.normal;
  out_var_TEXCOORD = x_126.uv;
  return;
}

struct vs_out {
  @builtin(position)
  x_7_1 : vec4f,
  @location(0)
  out_var_POSITION0_1 : vec3f,
  @location(1)
  out_var_NORMAL_1 : vec3f,
  @location(2)
  out_var_TEXCOORD_1 : vec2f,
}

@vertex
fn vs(@location(0) in_var_POSITION_param : vec4f, @location(1) in_var_TANGENT_param : vec4f, @location(2) in_var_NORMAL_param : vec3f, @location(3) in_var_TEXCOORD_param : vec2f) -> vs_out {
  in_var_POSITION = in_var_POSITION_param;
  in_var_TANGENT = in_var_TANGENT_param;
  in_var_NORMAL = in_var_NORMAL_param;
  in_var_TEXCOORD = in_var_TEXCOORD_param;
  vs_1();
  return vs_out(x_7, out_var_POSITION0, out_var_NORMAL, out_var_TEXCOORD);
}
