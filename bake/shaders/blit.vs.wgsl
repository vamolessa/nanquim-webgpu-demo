struct PsData {
  pos : vec4f,
  uv : vec2f,
}

@group(0) @binding(0) var sampler_bilinear_repeat : sampler;

@group(0) @binding(4) var src : texture_2d<f32>;

var<private> x_2 : u32;

var<private> x_3 : vec4f;

var<private> out_var_TEXCOORD : vec2f;

fn src_vs(id : ptr<function, u32>) -> PsData {
  var uv : vec2f;
  var pos : vec4f;
  var output : PsData;
  uv = vec2f(f32((*(id) & 1u)), f32((*(id) >> (1u & 31u))));
  pos = vec4f(0.0f, 0.0f, 0.0f, 1.0f);
  pos = vec4f((((uv * 2.0f) - vec2f(1.0f))).xy, pos.zw);
  uv.y = (1.0f - uv.y);
  output.pos = pos;
  output.uv = uv;
  let x_73 = output;
  return x_73;
}

fn vs_1() {
  var param_var_id : u32;
  param_var_id = x_2;
  let x_38 = src_vs(&(param_var_id));
  x_3 = x_38.pos;
  out_var_TEXCOORD = x_38.uv;
  return;
}

struct vs_out {
  @builtin(position)
  x_3_1 : vec4f,
  @location(0)
  out_var_TEXCOORD_1 : vec2f,
}

@vertex
fn vs(@builtin(vertex_index) x_2_param : u32) -> vs_out {
  x_2 = x_2_param;
  vs_1();
  return vs_out(x_3, out_var_TEXCOORD);
}
