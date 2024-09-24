struct type_ConstantBuffer_PassUniforms {
  /* @offset(0) */
  view_proj : mat4x4f,
}

struct VsData {
  pos : vec3f,
  col : vec4f,
}

struct PsData {
  pos : vec4f,
  col : vec4f,
}

@group(0) @binding(20) var<uniform> pass_color_uniforms : type_ConstantBuffer_PassUniforms;

var<private> in_var_POSITION : vec3f;

var<private> in_var_COLOR : vec4f;

var<private> x_4 : vec4f;

var<private> out_var_COLOR : vec4f;

fn src_vs(input : ptr<function, VsData>) -> PsData {
  var output : PsData;
  let x_47 = (*(input)).pos;
  output.pos = (vec4f(x_47.x, x_47.y, x_47.z, 1.0f) * pass_color_uniforms.view_proj);
  output.col = (*(input)).col;
  let x_58 = output;
  return x_58;
}

fn vs_1() {
  var param_var_input : VsData;
  param_var_input = VsData(in_var_POSITION, in_var_COLOR);
  let x_33 = src_vs(&(param_var_input));
  x_4 = x_33.pos;
  out_var_COLOR = x_33.col;
  return;
}

struct vs_out {
  @builtin(position)
  x_4_1 : vec4f,
  @location(0)
  out_var_COLOR_1 : vec4f,
}

@vertex
fn vs(@location(0) in_var_POSITION_param : vec3f, @location(1) in_var_COLOR_param : vec4f) -> vs_out {
  in_var_POSITION = in_var_POSITION_param;
  in_var_COLOR = in_var_COLOR_param;
  vs_1();
  return vs_out(x_4, out_var_COLOR);
}
