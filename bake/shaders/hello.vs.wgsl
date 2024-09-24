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

struct VsData {
  id : u32,
  pos : vec2f,
  uv : vec2f,
}

struct PsData {
  pos : vec4f,
  uv : vec2f,
}

struct VertexSkin_1 {
  joints : u32,
  weights : u32,
}

@group(0) @binding(0) var sampler_bilinear_repeat : sampler;

@group(0) @binding(4) var albedo : texture_2d<f32>;

@group(0) @binding(20) var<uniform> uniforms : type_ConstantBuffer_DrawUniforms;

@group(0) @binding(12) var<storage, read> skins : type_StructuredBuffer_VertexSkin;

var<private> x_2 : u32;

var<private> in_var_POSITION : vec2f;

var<private> in_var_TEXCOORD : vec2f;

var<private> x_5 : vec4f;

var<private> out_var_TEXCOORD : vec2f;

fn src_vs(input : ptr<function, VsData>) -> PsData {
  var skin : VertexSkin_1;
  var p : vec4f;
  var transform : mat4x4f;
  var output : PsData;
  let x_73 = skins.field0[(*(input)).id];
  skin = VertexSkin_1(x_73.joints, x_73.weights);
  let x_79 = (*(input)).pos;
  p = vec4f(x_79.x, x_79.y, 0.0f, 1.0f);
  let x_85 = uniforms.t;
  transform = mat4x4f(vec4f(x_85[0u].x, x_85[0u].y, x_85[0u].z, x_85[0u].w), vec4f(x_85[1u].x, x_85[1u].y, x_85[1u].z, x_85[1u].w), vec4f(x_85[2u].x, x_85[2u].y, x_85[2u].z, x_85[2u].w), vec4f(0.0f, 0.0f, 0.0f, 1.0f));
  p = (p * transform);
  output.pos = p;
  output.uv = (*(input)).uv;
  let x_111 = output;
  return x_111;
}

fn vs_1() {
  var param_var_input : VsData;
  param_var_input = VsData(x_2, in_var_POSITION, in_var_TEXCOORD);
  let x_52 = src_vs(&(param_var_input));
  x_5 = x_52.pos;
  out_var_TEXCOORD = x_52.uv;
  return;
}

struct vs_out {
  @builtin(position)
  x_5_1 : vec4f,
  @location(0)
  out_var_TEXCOORD_1 : vec2f,
}

@vertex
fn vs(@builtin(vertex_index) x_2_param : u32, @location(0) in_var_POSITION_param : vec2f, @location(1) in_var_TEXCOORD_param : vec2f) -> vs_out {
  x_2 = x_2_param;
  in_var_POSITION = in_var_POSITION_param;
  in_var_TEXCOORD = in_var_TEXCOORD_param;
  vs_1();
  return vs_out(x_5, out_var_TEXCOORD);
}
