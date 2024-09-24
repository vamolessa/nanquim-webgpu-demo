struct PsData {
  pos : vec4f,
  uv : vec2f,
}

@group(0) @binding(0) var sampler_bilinear_repeat : sampler;

@group(0) @binding(4) var src : texture_2d<f32>;

var<private> x_2 : vec4f;

var<private> in_var_TEXCOORD : vec2f;

var<private> out_var_SV_TARGET : vec4f;

fn src_ps(input : ptr<function, PsData>) -> vec4f {
  let x_40 = (*(input)).uv;
  let x_43 = textureSample(src, sampler_bilinear_repeat, x_40);
  return x_43;
}

fn ps_1() {
  var param_var_input : PsData;
  param_var_input = PsData(x_2, in_var_TEXCOORD);
  let x_31 = src_ps(&(param_var_input));
  out_var_SV_TARGET = x_31;
  return;
}

struct ps_out {
  @location(0)
  out_var_SV_TARGET_1 : vec4f,
}

@fragment
fn ps(@builtin(position) x_2_param : vec4f, @location(0) in_var_TEXCOORD_param : vec2f) -> ps_out {
  x_2 = x_2_param;
  in_var_TEXCOORD = in_var_TEXCOORD_param;
  ps_1();
  return ps_out(out_var_SV_TARGET);
}
