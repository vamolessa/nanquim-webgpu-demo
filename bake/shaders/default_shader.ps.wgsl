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

struct PsData {
  pos : vec4f,
  world_pos : vec3f,
  normal : vec3f,
  uv : vec2f,
}

struct PBR {
  V : vec3f,
  N : vec3f,
  R : vec3f,
  albedo : vec3f,
  F0 : vec3f,
  kd : vec3f,
  dotNV : f32,
  roughness : f32,
}

@group(0) @binding(0) var sampler_bilinear_repeat : sampler;

@group(0) @binding(1) var sampler_trilinear_repeat : sampler;

@group(0) @binding(2) var sampler_bilinear_clamp : sampler;

@group(0) @binding(3) var sampler_bilinear_clamp_cmp_greater : sampler_comparison;

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

@group(0) @binding(7) var shadowmap_tex : texture_depth_2d_array;

var<private> x_3 : vec4f;

var<private> in_var_POSITION0 : vec3f;

var<private> in_var_NORMAL : vec3f;

var<private> in_var_TEXCOORD : vec2f;

var<private> out_var_SV_TARGET : vec4f;

const x_53 = vec3f(1.0f);

fn fresnel_schlick(F0_1 : ptr<function, vec3f>, cos_theta : ptr<function, f32>) -> vec3f {
  var f : f32;
  var f2 : f32;
  var f5 : f32;
  f = (1.0f - *(cos_theta));
  f2 = (f * f);
  f5 = ((f2 * f2) * f);
  let x_590 = *(F0_1);
  let x_591 = *(F0_1);
  let x_593 = f5;
  return (x_590 + ((x_53 - x_591) * x_593));
}

fn pbr_init(albedo_1 : ptr<function, vec3f>, metallic : ptr<function, f32>, roughness : ptr<function, f32>, V : ptr<function, vec3f>, N : ptr<function, vec3f>) -> PBR {
  var F0 : vec3f;
  var dotNV : f32;
  var R : vec3f;
  var F : vec3f;
  var param_var_F0 : vec3f;
  var param_var_cos_theta : f32;
  var kd : vec3f;
  var desc : PBR;
  F0 = mix(F_DIELECTRIC, *(albedo_1), vec3f(*(metallic)));
  dotNV = max(dot(*(N), *(V)), 0.0f);
  R = ((*(N) * (2.0f * dotNV)) - *(V));
  param_var_F0 = F0;
  param_var_cos_theta = dotNV;
  let x_316 = fresnel_schlick(&(param_var_F0), &(param_var_cos_theta));
  F = x_316;
  kd = ((x_53 - F) * (1.0f - *(metallic)));
  desc.V = *(V);
  desc.N = *(N);
  desc.R = R;
  desc.albedo = *(albedo_1);
  desc.F0 = F0;
  desc.kd = kd;
  desc.dotNV = clamp(dot(*(N), *(V)), 0.00100000004749745131f, 1.0f);
  desc.roughness = *(roughness);
  let x_342 = desc;
  return x_342;
}

fn ambient(pbr_1 : ptr<function, PBR>) -> vec3f {
  var irradiance : vec3f;
  var diffuse_ibl : vec3f;
  var envmap_radiance_width : f32;
  var envmap_radiance_height : f32;
  var envmap_radiance_mips_len : f32;
  var radiance_mip : f32;
  var radiance : vec3f;
  var specular_brdf : vec2f;
  var specular_ibl : vec3f;
  let x_358 = (*(pbr_1)).N;
  let x_360 = textureSample(env_irradiance_tex, sampler_bilinear_repeat, x_358);
  irradiance = x_360.xyz;
  diffuse_ibl = (((*(pbr_1)).kd * (*(pbr_1)).albedo) * irradiance);
  let x_371 = textureDimensions(env_radiance_tex, 0u).xy;
  envmap_radiance_width = f32(x_371.x);
  envmap_radiance_height = f32(x_371.y);
  envmap_radiance_mips_len = f32(textureNumLevels(env_radiance_tex));
  radiance_mip = ((*(pbr_1)).roughness * envmap_radiance_mips_len);
  radiance = textureSampleLevel(env_radiance_tex, sampler_trilinear_repeat, (*(pbr_1)).R, radiance_mip).xyz;
  let x_393 = (*(pbr_1)).dotNV;
  let x_395 = (*(pbr_1)).roughness;
  let x_398 = textureSample(env_brdf_lut_tex, sampler_bilinear_clamp, vec2f(x_393, x_395));
  specular_brdf = x_398.xy;
  specular_ibl = ((((*(pbr_1)).F0 * specular_brdf.x) + vec3f(specular_brdf.y)) * radiance);
  let x_411 = diffuse_ibl;
  let x_412 = specular_ibl;
  return (x_411 + x_412);
}

fn biased_light_space_pos(cascade_index_1 : ptr<function, i32>, world_pos_1 : ptr<function, vec3f>, N_1 : ptr<function, vec3f>, L_1 : ptr<function, vec3f>) -> vec3f {
  var offset_1 : vec3f;
  var result_1 : vec4f;
  offset_1 = (*(N_1) * (SHADOW_NORMAL_BIAS * clamp((1.0f - dot(*(N_1), *(L_1))), 0.0f, 1.0f)));
  *(world_pos_1) = (*(world_pos_1) + offset_1);
  let x_622 = *(world_pos_1);
  result_1 = (vec4f(x_622.x, x_622.y, x_622.z, 1.0f) * pass_uniforms.shadow_cascade_view_projs[*(cascade_index_1)]);
  result_1.z = (result_1.z + SHADOW_DEPTH_BIASES[bitcast<u32>(*(cascade_index_1))]);
  let x_635 = result_1;
  return x_635.xyz;
}

const x_68 = vec2f(0.5f);

fn shadow_cascade_visibility(light_pos : ptr<function, vec3f>, cascade_index_2 : ptr<function, i32>) -> f32 {
  var cascade_indexf : f32;
  var vis_1 : f32;
  var shadowmap_width : f32;
  var shadowmap_height : f32;
  var shadowmap_depth : f32;
  var uv : vec2f;
  var base_uv : vec2f;
  var shadowmap_width_inv : f32;
  var s : f32;
  var t : f32;
  cascade_indexf = f32(*(cascade_index_2));
  vis_1 = 0.0f;
  let x_655 = vec3u(textureDimensions(shadowmap_tex, 0i), textureNumLayers(shadowmap_tex));
  shadowmap_width = f32(x_655.x);
  shadowmap_height = f32(x_655.y);
  shadowmap_depth = f32(x_655.z);
  uv = ((*(light_pos)).xy * shadowmap_width);
  base_uv = floor((uv + x_68));
  shadowmap_width_inv = (1.0f / shadowmap_width);
  s = ((uv.x + 0.5f) - base_uv.x);
  t = ((uv.y + 0.5f) - base_uv.y);
  base_uv = (base_uv - x_68);
  base_uv = (base_uv * shadowmap_width_inv);
  let x_691 = (*(light_pos)).xy;
  vis_1 = textureSampleCompareLevel(shadowmap_tex, sampler_bilinear_clamp_cmp_greater, vec3f(x_691.x, x_691.y, cascade_indexf).xy, i32(round(vec3f(x_691.x, x_691.y, cascade_indexf).z)), (*(light_pos)).z);
  let x_701 = vis_1;
  return x_701;
}

fn shadow_visibility(world_pos : ptr<function, vec3f>, normal_1 : ptr<function, vec3f>, clip_depth : ptr<function, f32>, light_dir : ptr<function, vec3f>) -> f32 {
  var cascade_index : i32;
  var i : i32;
  var light_pos0 : vec3f;
  var param_var_cascade_index : i32;
  var param_var_world_pos_1 : vec3f;
  var param_var_N_1 : vec3f;
  var param_var_L_1 : vec3f;
  var vis : f32;
  var param_var_light_pos : vec3f;
  var param_var_cascade_index_1 : i32;
  cascade_index = 0i;
  i = 3i;
  loop {
    if ((i >= 0i)) {
    } else {
      break;
    }
    if ((*(clip_depth) <= pass_uniforms.shadow_cascade_splits[bitcast<u32>(i)])) {
      cascade_index = i;
    }

    continuing {
      i = (i - 1i);
    }
  }
  param_var_cascade_index = cascade_index;
  param_var_world_pos_1 = *(world_pos);
  param_var_N_1 = *(normal_1);
  param_var_L_1 = *(light_dir);
  let x_452 = biased_light_space_pos(&(param_var_cascade_index), &(param_var_world_pos_1), &(param_var_N_1), &(param_var_L_1));
  light_pos0 = x_452;
  param_var_light_pos = light_pos0;
  param_var_cascade_index_1 = cascade_index;
  let x_456 = shadow_cascade_visibility(&(param_var_light_pos), &(param_var_cascade_index_1));
  vis = x_456;
  let x_458 = vis;
  return x_458;
}

fn ndf_ggx(cos_Lh : ptr<function, f32>, roughness_1 : ptr<function, f32>) -> f32 {
  var alpha : f32;
  var alpha2 : f32;
  var denom : f32;
  alpha = (*(roughness_1) * *(roughness_1));
  alpha2 = (alpha * alpha);
  denom = (((*(cos_Lh) * *(cos_Lh)) * (alpha2 - 1.0f)) + 1.0f);
  let x_722 = alpha2;
  let x_723 = PI;
  let x_724 = denom;
  let x_726 = denom;
  return (x_722 / ((x_723 * x_724) * x_726));
}

fn ga_schlick_g1(cos_theta_1 : ptr<function, f32>, k_1 : ptr<function, f32>) -> f32 {
  let x_808 = *(cos_theta_1);
  let x_809 = *(cos_theta_1);
  let x_810 = *(k_1);
  let x_813 = *(k_1);
  return (x_808 / ((x_809 * (1.0f - x_810)) + x_813));
}

fn ga_schlick_ggx(dotNL_1 : ptr<function, f32>, dotNV_1 : ptr<function, f32>, roughness_2 : ptr<function, f32>) -> f32 {
  var r : f32;
  var k : f32;
  var param_var_cos_theta_2 : f32;
  var param_var_k : f32;
  var param_var_cos_theta_3 : f32;
  var param_var_k_1 : f32;
  r = (*(roughness_2) + 1.0f);
  k = ((r * r) / 8.0f);
  param_var_cos_theta_2 = *(dotNL_1);
  param_var_k = k;
  let x_748 = ga_schlick_g1(&(param_var_cos_theta_2), &(param_var_k));
  param_var_cos_theta_3 = *(dotNV_1);
  param_var_k_1 = k;
  let x_752 = ga_schlick_g1(&(param_var_cos_theta_3), &(param_var_k_1));
  return (x_748 * x_752);
}

fn brdf(pbr_2 : ptr<function, PBR>, L : ptr<function, vec3f>) -> vec3f {
  var result : vec3f;
  var dotNL : f32;
  var H : vec3f;
  var dotNH : f32;
  var dotVH : f32;
  var F_1 : vec3f;
  var param_var_F0_1 : vec3f;
  var param_var_cos_theta_1 : f32;
  var D : f32;
  var param_var_cos_Lh : f32;
  var param_var_roughness_1 : f32;
  var G : f32;
  var param_var_dotNL : f32;
  var param_var_dotNV : f32;
  var param_var_roughness_2 : f32;
  var diffuse_brdf : vec3f;
  var specular_brdf_1 : vec3f;
  result = vec3f();
  dotNL = dot((*(pbr_2)).N, *(L));
  if ((dotNL > 0.0f)) {
    H = normalize(((*(pbr_2)).V + *(L)));
    dotNH = max(dot((*(pbr_2)).N, H), 0.0f);
    dotVH = max(dot((*(pbr_2)).V, H), 0.0f);
    param_var_F0_1 = (*(pbr_2)).F0;
    param_var_cos_theta_1 = dotVH;
    let x_506 = fresnel_schlick(&(param_var_F0_1), &(param_var_cos_theta_1));
    F_1 = x_506;
    param_var_cos_Lh = dotNH;
    param_var_roughness_1 = (*(pbr_2)).roughness;
    let x_510 = ndf_ggx(&(param_var_cos_Lh), &(param_var_roughness_1));
    D = x_510;
    param_var_dotNL = dotNL;
    param_var_dotNV = (*(pbr_2)).dotNV;
    param_var_roughness_2 = (*(pbr_2)).roughness;
    let x_517 = ga_schlick_ggx(&(param_var_dotNL), &(param_var_dotNV), &(param_var_roughness_2));
    G = x_517;
    diffuse_brdf = ((*(pbr_2)).kd * (*(pbr_2)).albedo);
    specular_brdf_1 = (F_1 * ((D * G) / max(EPSILON, ((4.0f * dotNL) * (*(pbr_2)).dotNV))));
    result = ((diffuse_brdf + specular_brdf_1) * dotNL);
  }
  let x_542 = result;
  return x_542;
}

fn uncharted2_tonemap(col_3 : ptr<function, vec3f>) -> vec3f {
  var A : f32;
  var B : f32;
  var C : f32;
  var D_1 : f32;
  var E : f32;
  var F_2 : f32;
  A = 0.15000000596046447754f;
  B = 0.5f;
  C = 0.10000000149011611938f;
  D_1 = 0.20000000298023223877f;
  E = 0.01999999955296516418f;
  F_2 = 0.30000001192092895508f;
  let x_763 = *(col_3);
  let x_764 = *(col_3);
  let x_765 = A;
  let x_769 = (C * B);
  let x_775 = (D_1 * E);
  let x_778 = *(col_3);
  let x_779 = *(col_3);
  let x_780 = A;
  let x_782 = B;
  let x_788 = (D_1 * F_2);
  let x_794 = (E / F_2);
  return ((((x_763 * ((x_764 * x_765) + vec3f(x_769))) + vec3f(x_775)) / ((x_778 * ((x_779 * x_780) + vec3f(x_782))) + vec3f(x_788))) - vec3f(x_794));
}

fn tonemap(col_1 : ptr<function, vec3f>, exposure : ptr<function, f32>) -> vec3f {
  var param_var_col_2 : vec3f;
  var param_var_col_3 : vec3f;
  param_var_col_2 = (*(col_1) * *(exposure));
  let x_552 = uncharted2_tonemap(&(param_var_col_2));
  *(col_1) = x_552;
  let x_554 = *(col_1);
  param_var_col_3 = vec3f(11.19999980926513671875f);
  let x_555 = uncharted2_tonemap(&(param_var_col_3));
  *(col_1) = (x_554 * (x_53 / x_555));
  let x_558 = *(col_1);
  return x_558;
}

fn gamma_correct(col_4 : ptr<function, vec3f>, gamma : ptr<function, f32>) -> vec3f {
  let x_800 = *(col_4);
  let x_802 = *(gamma);
  return pow(abs(x_800), vec3f(x_802));
}

fn srgb_from_linear(col_2 : ptr<function, vec4f>) -> vec4f {
  var param_var_col_4 : vec3f;
  var param_var_gamma : f32;
  param_var_col_4 = (*(col_2)).xyz;
  param_var_gamma = 0.45454546809196472168f;
  let x_566 = gamma_correct(&(param_var_col_4), &(param_var_gamma));
  let x_569 = (*(col_2)).w;
  return vec4f(x_566.x, x_566.y, x_566.z, x_569);
}

fn src_ps(input : ptr<function, PsData>) -> vec4f {
  var albedo : vec4f;
  var emissive : vec4f;
  var metallic_roughness : vec2f;
  var metal : f32;
  var rough : f32;
  var normal : vec3f;
  var col : vec3f;
  var view_dir : vec3f;
  var pbr : PBR;
  var param_var_albedo : vec3f;
  var param_var_metallic : f32;
  var param_var_roughness : f32;
  var param_var_V : vec3f;
  var param_var_N : vec3f;
  var light_col : vec3f;
  var param_var_pbr : PBR;
  var shadow_vis : f32;
  var param_var_world_pos : vec3f;
  var param_var_normal : vec3f;
  var param_var_clip_depth : f32;
  var param_var_light_dir : vec3f;
  var param_var_pbr_1 : PBR;
  var param_var_L : vec3f;
  var param_var_col : vec3f;
  var param_var_exposure : f32;
  var param_var_col_1 : vec4f;
  let x_167 = material_uniforms.albedo_color;
  let x_171 = (*(input)).uv;
  let x_174 = textureSample(albedo_tex, sampler_bilinear_repeat, x_171);
  albedo = (x_167 * x_174);
  let x_177 = material_uniforms.emissive_color;
  let x_181 = (*(input)).uv;
  let x_183 = textureSample(emissive_tex, sampler_bilinear_repeat, x_181);
  emissive = (x_177 * x_183);
  let x_188 = (*(input)).uv;
  let x_190 = textureSample(metallic_roughness_tex, sampler_bilinear_repeat, x_188);
  metallic_roughness = x_190.zy;
  metallic_roughness = (metallic_roughness * material_uniforms.metallic_roughness.xy);
  metal = metallic_roughness.x;
  rough = metallic_roughness.y;
  normal = normalize((*(input)).normal);
  col = emissive.xyz;
  if ((material_uniforms.metallic_roughness.x == -1.0f)) {
    col = textureSampleLevel(env_irradiance_tex, sampler_bilinear_repeat, normal, 0.0f).xyz;
  } else {
    view_dir = normalize((pass_uniforms.view_pos.xyz - (*(input)).world_pos));
    param_var_albedo = albedo.xyz;
    param_var_metallic = metal;
    param_var_roughness = rough;
    param_var_V = view_dir;
    param_var_N = normal;
    let x_235 = pbr_init(&(param_var_albedo), &(param_var_metallic), &(param_var_roughness), &(param_var_V), &(param_var_N));
    pbr = x_235;
    param_var_pbr = pbr;
    let x_238 = ambient(&(param_var_pbr));
    light_col = x_238;
    param_var_world_pos = (*(input)).world_pos;
    param_var_normal = normal;
    param_var_clip_depth = (*(input)).pos.w;
    param_var_light_dir = pass_uniforms.light_dir.xyz;
    let x_249 = shadow_visibility(&(param_var_world_pos), &(param_var_normal), &(param_var_clip_depth), &(param_var_light_dir));
    shadow_vis = x_249;
    param_var_pbr_1 = pbr;
    param_var_L = pass_uniforms.light_dir.xyz;
    let x_255 = brdf(&(param_var_pbr_1), &(param_var_L));
    light_col = (light_col + ((x_255 * pass_uniforms.light_color.xyz) * shadow_vis));
    col = (col + light_col);
  }
  param_var_col = col;
  param_var_exposure = 3.0f;
  let x_269 = tonemap(&(param_var_col), &(param_var_exposure));
  col = x_269;
  param_var_col_1 = vec4f(col.x, col.y, col.z, 0.0f);
  let x_276 = srgb_from_linear(&(param_var_col_1));
  col = x_276.xyz;
  let x_279 = col;
  return vec4f(x_279.x, x_279.y, x_279.z, 1.0f);
}

fn ps_1() {
  var param_var_input : PsData;
  PI = 3.1415920257568359375f;
  TAU = (2.0f * PI);
  EPSILON = 0.00000999999974737875f;
  F_DIELECTRIC = vec3f(0.03999999910593032837f);
  SHADOW_CASCADE_BLEND_THRESHOLD = 0.10000000149011611938f;
  SHADOW_NORMAL_BIAS = 0.40000000596046447754f;
  SHADOW_DEPTH_BIASES = vec4f(0.00100000004749745131f, 0.00100000004749745131f, 0.00100000004749745131f, 0.00999999977648258209f);
  param_var_input = PsData(x_3, in_var_POSITION0, in_var_NORMAL, in_var_TEXCOORD);
  let x_128 = src_ps(&(param_var_input));
  out_var_SV_TARGET = x_128;
  return;
}

struct ps_out {
  @location(0)
  out_var_SV_TARGET_1 : vec4f,
}

@fragment
fn ps(@builtin(position) x_3_param : vec4f, @location(0) in_var_POSITION0_param : vec3f, @location(1) in_var_NORMAL_param : vec3f, @location(2) in_var_TEXCOORD_param : vec2f) -> ps_out {
  x_3 = x_3_param;
  in_var_POSITION0 = in_var_POSITION0_param;
  in_var_NORMAL = in_var_NORMAL_param;
  in_var_TEXCOORD = in_var_TEXCOORD_param;
  ps_1();
  return ps_out(out_var_SV_TARGET);
}
