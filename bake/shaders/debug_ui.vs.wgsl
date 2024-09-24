struct type_ConstantBuffer_DrawUniforms {
  /* @offset(0) */
  view_proj : mat4x4f,
}

struct VsData {
  pos : vec2f,
  uv : vec2f,
  col : vec4f,
}

struct PsData {
  pos : vec4f,
  uv : vec2f,
  col : vec4f,
}

@group(0) @binding(0) var sampler_bilinear_repeat : sampler;

@group(0) @binding(4) var atlas_tex : texture_2d<f32>;

@group(0) @binding(20) var<uniform> draw_uniforms : type_ConstantBuffer_DrawUniforms;

var<private> in_var_POSITION : vec2f;

var<private> in_var_TEXCOORD : vec2f;

var<private> in_var_COLOR : vec4f;

var<private> x_5 : vec4f;

var<private> out_var_TEXCOORD : vec2f;

var<private> out_var_COLOR : vec4f;

fn src_vs(input : ptr<function, VsData>) -> PsData {
  var output : PsData;
  let x_60 = (*(input)).pos;
  output.pos = (vec4f(x_60.x, x_60.y, 0.0f, 1.0f) * draw_uniforms.view_proj);
  output.col = (*(input)).col;
  output.uv = (*(input)).uv;
  let x_73 = output;
  return x_73;
}

fn vs_1() {
  var param_var_input : VsData;
  param_var_input = VsData(in_var_POSITION, in_var_TEXCOORD, in_var_COLOR);
  let x_45 = src_vs(&(param_var_input));
  x_5 = x_45.pos;
  out_var_TEXCOORD = x_45.uv;
  out_var_COLOR = x_45.col;
  return;
}

struct vs_out {
  @builtin(position)
  x_5_1 : vec4f,
  @location(0)
  out_var_TEXCOORD_1 : vec2f,
  @location(1)
  out_var_COLOR_1 : vec4f,
}

@vertex
fn vs(@location(0) in_var_POSITION_param : vec2f, @location(1) in_var_TEXCOORD_param : vec2f, @location(2) in_var_COLOR_param : vec4f) -> vs_out {
  in_var_POSITION = in_var_POSITION_param;
  in_var_TEXCOORD = in_var_TEXCOORD_param;
  in_var_COLOR = in_var_COLOR_param;
  vs_1();
  return vs_out(x_5, out_var_TEXCOORD, out_var_COLOR);
}
