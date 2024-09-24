struct type_ConstantBuffer_DrawUniforms {
  /* @offset(0) */
  transform : mat4x4f,
  /* @offset(64) */
  t : mat3x4f,
  /* @offset(112) */
  pad : vec4u,
  /* @offset(128) */
  color : vec4f,
}

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

struct PsData {
  pos : vec4f,
  uv : vec2f,
}

@group(0) @binding(0) var sampler_bilinear_repeat : sampler;

@group(0) @binding(4) var albedo : texture_2d<f32>;

@group(0) @binding(20) var<uniform> uniforms : type_ConstantBuffer_DrawUniforms;

@group(0) @binding(12) var<storage, read> skins : type_StructuredBuffer_VertexSkin;

var<private> x_3 : vec4f;

var<private> in_var_TEXCOORD : vec2f;

var<private> out_var_SV_TARGET : vec4f;

fn gamma_correct(col_1 : ptr<function, vec3f>, gamma : ptr<function, f32>) -> vec3f {
  let x_91 = *(col_1);
  let x_93 = *(gamma);
  return pow(abs(x_91), vec3f(x_93));
}

fn srgb_from_linear(col : ptr<function, vec4f>) -> vec4f {
  var param_var_col_1 : vec3f;
  var param_var_gamma : f32;
  param_var_col_1 = (*(col)).xyz;
  param_var_gamma = 0.45454546809196472168f;
  let x_79 = gamma_correct(&(param_var_col_1), &(param_var_gamma));
  let x_82 = (*(col)).w;
  return vec4f(x_79.x, x_79.y, x_79.z, x_82);
}

fn src_ps(input : ptr<function, PsData>) -> vec4f {
  var tex_color : vec4f;
  var param_var_col : vec4f;
  let x_58 = (*(input)).uv;
  let x_61 = textureSample(albedo, sampler_bilinear_repeat, x_58);
  tex_color = x_61;
  param_var_col = (uniforms.color * tex_color);
  let x_67 = srgb_from_linear(&(param_var_col));
  return x_67;
}

fn ps_1() {
  var param_var_input : PsData;
  param_var_input = PsData(x_3, in_var_TEXCOORD);
  let x_46 = src_ps(&(param_var_input));
  out_var_SV_TARGET = x_46;
  return;
}

struct ps_out {
  @location(0)
  out_var_SV_TARGET_1 : vec4f,
}

@fragment
fn ps(@builtin(position) x_3_param : vec4f, @location(0) in_var_TEXCOORD_param : vec2f) -> ps_out {
  x_3 = x_3_param;
  in_var_TEXCOORD = in_var_TEXCOORD_param;
  ps_1();
  return ps_out(out_var_SV_TARGET);
}
