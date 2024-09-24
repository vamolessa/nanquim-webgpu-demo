struct type_ConstantBuffer_DrawUniforms {
  /* @offset(0) */
  view_proj : mat4x4f,
}

struct PsData {
  pos : vec4f,
  uv : vec2f,
  col : vec4f,
}

@group(0) @binding(0) var sampler_bilinear_repeat : sampler;

@group(0) @binding(4) var atlas_tex : texture_2d<f32>;

@group(0) @binding(20) var<uniform> draw_uniforms : type_ConstantBuffer_DrawUniforms;

var<private> x_2 : vec4f;

var<private> in_var_TEXCOORD : vec2f;

var<private> in_var_COLOR : vec4f;

var<private> out_var_SV_TARGET : vec4f;

fn src_ps(input : ptr<function, PsData>) -> vec4f {
  var col : vec4f;
  col = (*(input)).col;
  let x_52 = (*(input)).uv;
  let x_55 = textureSample(atlas_tex, sampler_bilinear_repeat, x_52);
  col = (col * x_55);
  col = vec4f(((col.xyz * col.w)).xyz, col.w);
  let x_67 = col;
  return x_67;
}

fn ps_1() {
  var param_var_input : PsData;
  param_var_input = PsData(x_2, in_var_TEXCOORD, in_var_COLOR);
  let x_39 = src_ps(&(param_var_input));
  out_var_SV_TARGET = x_39;
  return;
}

struct ps_out {
  @location(0)
  out_var_SV_TARGET_1 : vec4f,
}

@fragment
fn ps(@builtin(position) x_2_param : vec4f, @location(0) in_var_TEXCOORD_param : vec2f, @location(1) in_var_COLOR_param : vec4f) -> ps_out {
  x_2 = x_2_param;
  in_var_TEXCOORD = in_var_TEXCOORD_param;
  in_var_COLOR = in_var_COLOR_param;
  ps_1();
  return ps_out(out_var_SV_TARGET);
}
