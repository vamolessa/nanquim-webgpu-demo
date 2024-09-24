#pragma pack_matrix(row_major)

#if !defined(__SHADER_TARGET_MAJOR)
# define __SHADER_TARGET_MAJOR 5
#endif

#if !defined(__SHADER_TARGET_MINOR)
# define __SHADER_TARGET_MINOR 0
#endif

#if __SHADER_TARGET_MAJOR == 5
# include "hlsl5.hlsli"
#elif __SHADER_TARGET_MAJOR == 6
# include "hlsl6.hlsli"
#else
# error unsuported shader target version __SHADER_TARGET_MAJOR __SHADER_TARGET_MINOR
#endif
