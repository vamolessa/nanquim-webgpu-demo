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

struct type_ConstantBuffer_PassShadowUniforms {
  /* @offset(0) */
  view_proj : mat4x4f,
}

struct type_ConstantBuffer_DrawUniforms {
  /* @offset(0) */
  model : mat3x4f,
  /* @offset(48) */
  skin_offsets : vec4i,
}

struct VsPosOnlyData {
  id : u32,
  pos : vec4f,
}

struct PsPosOnlyData {
  pos : vec4f,
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

@group(0) @binding(20) var<uniform> pass_uniforms : type_ConstantBuffer_PassShadowUniforms;

@group(2) @binding(20) var<uniform> draw_uniforms : type_ConstantBuffer_DrawUniforms;

var<private> x_2 : u32;

var<private> in_var_POSITION : vec4f;

var<private> x_4 : vec4f;

fn unpack_rgba8_uint(bits : ptr<function, u32>) -> vec4u {
  var result_1 : vec4u;
  result_1.x = ((*(bits) >> (0u & 31u)) & 255u);
  result_1.y = ((*(bits) >> (8u & 31u)) & 255u);
  result_1.z = ((*(bits) >> (16u & 31u)) & 255u);
  result_1.w = ((*(bits) >> (24u & 31u)) & 255u);
  let x_292 = result_1;
  return x_292;
}

fn unpack_rgba8_unorm(bits_1 : ptr<function, u32>) -> vec4f {
  var result_2 : vec4f;
  result_2.x = f32(((*(bits_1) >> (0u & 31u)) & 255u));
  result_2.y = f32(((*(bits_1) >> (8u & 31u)) & 255u));
  result_2.z = f32(((*(bits_1) >> (16u & 31u)) & 255u));
  result_2.w = f32(((*(bits_1) >> (24u & 31u)) & 255u));
  let x_321 = result_2;
  return (x_321 / vec4f(255.0f));
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
  let x_165 = skins_offset;
  temp_var_logical = false;
  if ((x_165 != 0u)) {
    temp_var_logical = (bones_offset != 0u);
  }
  if (temp_var_logical) {
    vertex_skin_index = u32((*(pos_1)).w);
    skin_index = (skins_offset + vertex_skin_index);
    let x_185 = skins.field0[skin_index];
    skin = VertexSkin_1(x_185.joints, x_185.weights);
    param_var_bits = skin.joints;
    let x_191 = unpack_rgba8_uint(&(param_var_bits));
    joints = x_191;
    param_var_bits_1 = skin.weights;
    let x_195 = unpack_rgba8_unorm(&(param_var_bits_1));
    weights = x_195;
    result = (pose_bones.field0[(bones_offset + joints.x)].transform * weights.x);
    let x_214 = (pose_bones.field0[(bones_offset + joints.y)].transform * weights.y);
    result = mat3x4f((result[0u] + x_214[0u]), (result[1u] + x_214[1u]), (result[2u] + x_214[2u]));
    let x_234 = (pose_bones.field0[(bones_offset + joints.z)].transform * weights.z);
    result = mat3x4f((result[0u] + x_234[0u]), (result[1u] + x_234[1u]), (result[2u] + x_234[2u]));
    let x_254 = (pose_bones.field0[(bones_offset + joints.w)].transform * weights.w);
    result = mat3x4f((result[0u] + x_254[0u]), (result[1u] + x_254[1u]), (result[2u] + x_254[2u]));
    let x_266 = result;
    return x_266;
  } else {
    let x_267 = *(model_matrix_1);
    return x_267;
  }
}

fn default_vs_pos_only(input_1 : ptr<function, VsPosOnlyData>, view_proj_matrix : ptr<function, mat4x4f>, model_matrix : ptr<function, mat3x4f>, skin_offsets : ptr<function, vec4i>) -> PsPosOnlyData {
  var param_var_pos : vec4f;
  var param_var_model_matrix_1 : mat3x4f;
  var param_var_skin_offsets_1 : vec4i;
  var pos : vec3f;
  var clip_pos : vec4f;
  var output : PsPosOnlyData;
  param_var_pos = (*(input_1)).pos;
  param_var_model_matrix_1 = *(model_matrix);
  param_var_skin_offsets_1 = *(skin_offsets);
  let x_115 = calc_model_matrix(&(param_var_pos), &(param_var_model_matrix_1), &(param_var_skin_offsets_1));
  *(model_matrix) = x_115;
  let x_120 = (*(input_1)).pos.xyz;
  pos = (vec4f(x_120.x, x_120.y, x_120.z, 1.0f) * *(model_matrix));
  clip_pos = (vec4f(pos.x, pos.y, pos.z, 1.0f) * *(view_proj_matrix));
  output.pos = clip_pos;
  let x_135 = output;
  return x_135;
}

fn src_vs(input : ptr<function, VsPosOnlyData>) -> PsPosOnlyData {
  var param_var_input_1 : VsPosOnlyData;
  var param_var_view_proj_matrix : mat4x4f;
  var param_var_model_matrix : mat3x4f;
  var param_var_skin_offsets : vec4i;
  param_var_input_1 = *(input);
  param_var_view_proj_matrix = pass_uniforms.view_proj;
  param_var_model_matrix = draw_uniforms.model;
  param_var_skin_offsets = draw_uniforms.skin_offsets;
  let x_93 = default_vs_pos_only(&(param_var_input_1), &(param_var_view_proj_matrix), &(param_var_model_matrix), &(param_var_skin_offsets));
  return x_93;
}

fn vs_1() {
  var param_var_input : VsPosOnlyData;
  param_var_input = VsPosOnlyData(x_2, in_var_POSITION);
  let x_70 = src_vs(&(param_var_input));
  x_4 = x_70.pos;
  return;
}

struct vs_out {
  @builtin(position)
  x_4_1 : vec4f,
}

@vertex
fn vs(@builtin(vertex_index) x_2_param : u32, @location(0) in_var_POSITION_param : vec4f) -> vs_out {
  x_2 = x_2_param;
  in_var_POSITION = in_var_POSITION_param;
  vs_1();
  return vs_out(x_4);
}
