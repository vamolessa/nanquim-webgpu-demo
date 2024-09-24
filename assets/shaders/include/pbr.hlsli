static const float PI = 3.141592;
static const float TAU = 2.0 * PI;
static const float EPSILON = 0.00001;

// constant normal incidence fresnel factor for all dielectrics
static const float3 F_DIELECTRIC = (0.04).rrr;

////////////////////////////////////////////////////////////////////////////////////////////////////

// ggx/towbridge-reitz normal distribution function.
// uses disney's reparametrization of alpha = roughness^2.
float
ndf_ggx(float cos_Lh, float roughness) {
	float alpha = roughness * roughness;
	float alpha2 = alpha * alpha;

	float denom = (cos_Lh * cos_Lh) * (alpha2 - 1.0) + 1.0;
	return alpha2 / (PI * denom * denom);
}

// single term for separable schlick-ggx
float ga_schlick_g1(float cos_theta, float k) { return cos_theta / (cos_theta * (1.0 - k) + k); }

float
ga_schlick_ggx(float dotNL, float dotNV, float roughness) {
	float r = roughness + 1.0;
	float k = (r * r) / 8.0; // epic suggests using this roughness remapping for analytic lights
	return ga_schlick_g1(dotNL, k) * ga_schlick_g1(dotNV, k);
}

// shlick's approximation of the fresnel factor
float3
fresnel_schlick(float3 F0, float cos_theta) {
	float f = 1.0 - cos_theta;
	float f2 = f * f;
	float f5 = f2 * f2 * f;
	return F0 + (1.0 - F0) * f5;
}

// importance sample ggx normal distribution function for a fixed roughness value.
// this returns normalized half-vector between li & lo.
// for derivation see: http://blog.tobias-franke.eu/2014/03/30/notes_on_importance_sampling.html
float3
sample_ggx(float u1, float u2, float roughness) {
	float alpha = roughness * roughness;

	float cos_theta = sqrt((1.0 - u2) / (1.0 + (alpha * alpha - 1.0) * u2));
	float sin_theta = sqrt(1.0 - cos_theta * cos_theta);
	float phi = TAU * u1;

	// convert to cartesian upon return
	return float3(sin_theta * cos(phi), sin_theta * sin(phi), cos_theta);
}

// schlick-ggx approximation of geometric attenuation function using smith's method (ibl version)
float
ga_schlick_ggx_ibl(float cos_Li, float cos_Lo, float roughness) {
	float r = roughness;
	float k = (r * r) / 2.0; // epic suggests using this roughness remapping for ibl lighting
	return ga_schlick_g1(cos_Li, k) * ga_schlick_g1(cos_Lo, k);
}

////////////////////////////////////////////////////////////////////////////////////////////////////

#if !defined(PBR_IBL_ONLY)

group0_texture0(env_brdf_lut_tex, Texture2D<float2>);
group0_texture1(env_radiance_tex, TextureCube<float4>);
group0_texture2(env_irradiance_tex, TextureCube<float4>);

struct PBR {
	float3 V;
	float3 N;
	float3 R;
	float3 albedo;
	float3 F0;
	float3 kd;
	float dotNV;
	float roughness;
};

PBR
pbr_init(float3 albedo, float metallic, float roughness, float3 V, float3 N) {
	float3 F0 = lerp(F_DIELECTRIC, albedo.rgb, metallic);
	float dotNV = max(dot(N, V), 0.0);
	float3 R = (2.0 * dotNV) * N - V;

	// calculate fresnel term for ambient lighting.
	// since we use pre-filtered cubemap(s) and irradiance is coming from many directions
	// use dotNV instead of angle with light's half-vector
	// https://seblagarde.wordpress.com/2011/08/17/hello-world/
	float3 F = fresnel_schlick(F0, dotNV);

	// diffuse scattering happens due to light being refracted multiple times by a dielectric medium.
	// metals on the other hand either reflect or absorb energy, so diffuse contribution is always zero.
	// to be energy conserving we must scale diffuse brdf contribution based on fresnel factor & metalness.
	float3 kd = ((1.0).rrr - F) * (1.0 - metallic);

	PBR desc;
	desc.V = V;
	desc.N = N;
	desc.R = R;
	desc.albedo = albedo;
	desc.F0 = F0;
	desc.kd = kd;
	desc.dotNV = clamp(dot(N, V), 0.001, 1.0);
	desc.roughness = roughness;
	return desc;
}

float3
ambient(PBR pbr) {
	// sample diffuse irradiance at normal direction
	float3 irradiance = env_irradiance_tex.Sample(sampler_bilinear_repeat, pbr.N).rgb;

	// irradiance map contains exitant radiance assuming lambertian brdf, no need to scale by 1/pi here either
	float3 diffuse_ibl = pbr.kd * pbr.albedo * irradiance;

	// sample pre-filtered specular reflection environment at correct mipmap level
	float envmap_radiance_width, envmap_radiance_height, envmap_radiance_mips_len;
	env_radiance_tex.GetDimensions(
		/* MipLevel */ 0,
		envmap_radiance_width,
		envmap_radiance_height,
		envmap_radiance_mips_len
	);
	float radiance_mip = pbr.roughness * envmap_radiance_mips_len;
	float3 radiance = env_radiance_tex.SampleLevel(sampler_trilinear_repeat, pbr.R, radiance_mip).rgb;

	// split-sum approximation factors for cook-torrance specular brdf
	float2 specular_brdf = env_brdf_lut_tex.Sample(sampler_bilinear_clamp, float2(pbr.dotNV, pbr.roughness)).rg;

	// total specular ibl contribution
	float3 specular_ibl = (pbr.F0 * specular_brdf.x + specular_brdf.y) * radiance;

	// total ambient lighting contribution
	return diffuse_ibl + specular_ibl;
}

float3
brdf(PBR pbr, float3 L) {
	// NOTE: specular brdf composition
	// NOTE: L points *towards* light

	float3 result = (0.0).rrr;
	float dotNL = dot(pbr.N, L);
	if (dotNL > 0.0) {
		float3 H = normalize(pbr.V + L);
		float dotNH = max(dot(pbr.N, H), 0.0);
		float dotVH = max(dot(pbr.V, H), 0.0);

		// calculate fresnel term for direct lighting
		float3 F = fresnel_schlick(pbr.F0, dotVH);
		// calculate normal distribution for specular brdf
		float D = ndf_ggx(dotNH, pbr.roughness);
		// calculate geometric attenuation for specular brdf
		float G = ga_schlick_ggx(dotNL, pbr.dotNV, pbr.roughness);

		// lambert diffuse brdf.
		// we don't scale by 1/pi for lighting & material units to be more convenient
		// https://seblagarde.wordpress.com/2012/01/08/pi-or-not-to-pi-in-game-lighting-equation/
		float3 diffuse_brdf = pbr.kd * pbr.albedo;

		// cook-torrance specular microfacet brdf
		float3 specular_brdf = F * (D * G / max(EPSILON, 4.0 * dotNL * pbr.dotNV));

		result = (diffuse_brdf + specular_brdf) * dotNL;
	}
	return result;
}

#endif

////////////////////////////////////////////////////////////////////////////////////////////////////

float3
uncharted2_tonemap(float3 col) {
	float A = 0.15;
	float B = 0.50;
	float C = 0.10;
	float D = 0.20;
	float E = 0.02;
	float F = 0.30;
	return ((col * (A * col + C * B) + D * E) / (col * (A * col + B) + D * F)) - E / F;
}

float3
tonemap(float3 col, float exposure) {
	col = uncharted2_tonemap(col * exposure);
	col = col * (1.0 / uncharted2_tonemap((11.2).rrr));
	return col;
}

float3 gamma_correct(float3 col, float gamma) { return pow(abs(col), gamma.xxx); }
float4 linear_from_srgb(float4 col) { return float4(gamma_correct(col.rgb, 2.2), col.a); }
float4 srgb_from_linear(float4 col) { return float4(gamma_correct(col.rgb, 1.0 / 2.2), col.a); }
