struct type_ConstantBuffer_PassUniforms {
  /* @offset(0) */
  view_proj : mat4x4f,
}

struct PsData {
  pos : vec4f,
  col : vec4f,
}

@group(0) @binding(20) var<uniform> pass_color_uniforms : type_ConstantBuffer_PassUniforms;

var<private> x_2 : vec4f;

var<private> in_var_COLOR : vec4f;

var<private> out_var_SV_TARGET : vec4f;

fn src_ps(input : ptr<function, PsData>) -> vec4f {
  var col : vec4f;
  col = (*(input)).col;
  col = vec4f(((col.xyz * col.w)).xyz, col.w);
  let x_46 = col;
  return x_46;
}

fn ps_1() {
  var param_var_input : PsData;
  param_var_input = PsData(x_2, in_var_COLOR);
  let x_28 = src_ps(&(param_var_input));
  out_var_SV_TARGET = x_28;
  return;
}

struct ps_out {
  @location(0)
  out_var_SV_TARGET_1 : vec4f,
}

@fragment
fn ps(@builtin(position) x_2_param : vec4f, @location(0) in_var_COLOR_param : vec4f) -> ps_out {
  x_2 = x_2_param;
  in_var_COLOR = in_var_COLOR_param;
  ps_1();
  return ps_out(out_var_SV_TARGET);
}
