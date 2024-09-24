#include <hlsl.hlsli>
#include <shader.hlsli>

group0_uniforms0(pass_uniforms, PassShadowUniforms);
group2_uniforms0(draw_uniforms, DrawUniforms);

PsPosOnlyData
vs(VsPosOnlyData input) {
	return default_vs_pos_only(input, pass_uniforms.view_proj, draw_uniforms.model, draw_uniforms.skin_offsets);
}
