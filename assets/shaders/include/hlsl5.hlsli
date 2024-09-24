////////////////////////////////////////////////////////////////////////////////////////////////////
// SAMPLERS
////////////////////////////////////////////////////////////////////////////////////////////////////

#define group0_sampler0(NAME, TYPE) TYPE NAME : register(s0)
#define group0_sampler1(NAME, TYPE) TYPE NAME : register(s1)
#define group0_sampler2(NAME, TYPE) TYPE NAME : register(s2)
#define group0_sampler3(NAME, TYPE) TYPE NAME : register(s3)

#define group1_sampler0(NAME, TYPE) TYPE NAME : register(s4)
#define group1_sampler1(NAME, TYPE) TYPE NAME : register(s5)
#define group1_sampler2(NAME, TYPE) TYPE NAME : register(s6)
#define group1_sampler3(NAME, TYPE) TYPE NAME : register(s7)

#define group2_sampler0(NAME, TYPE) TYPE NAME : register(s8)
#define group2_sampler1(NAME, TYPE) TYPE NAME : register(s9)
#define group2_sampler2(NAME, TYPE) TYPE NAME : register(s10)
#define group2_sampler3(NAME, TYPE) TYPE NAME : register(s11)

#define group3_sampler0(NAME, TYPE) TYPE NAME : register(s12)
#define group3_sampler1(NAME, TYPE) TYPE NAME : register(s13)
#define group3_sampler2(NAME, TYPE) TYPE NAME : register(s14)
#define group3_sampler3(NAME, TYPE) TYPE NAME : register(s15)

////////////////////////////////////////////////////////////////////////////////////////////////////
// TEXTURES
////////////////////////////////////////////////////////////////////////////////////////////////////

#define group0_texture0(NAME, TYPE) TYPE NAME : register(t0)
#define group0_texture1(NAME, TYPE) TYPE NAME : register(t1)
#define group0_texture2(NAME, TYPE) TYPE NAME : register(t2)
#define group0_texture3(NAME, TYPE) TYPE NAME : register(t3)
#define group0_texture4(NAME, TYPE) TYPE NAME : register(t4)
#define group0_texture5(NAME, TYPE) TYPE NAME : register(t5)
#define group0_texture6(NAME, TYPE) TYPE NAME : register(t6)
#define group0_texture7(NAME, TYPE) TYPE NAME : register(t7)

#define group1_texture0(NAME, TYPE) TYPE NAME : register(t16)
#define group1_texture1(NAME, TYPE) TYPE NAME : register(t17)
#define group1_texture2(NAME, TYPE) TYPE NAME : register(t18)
#define group1_texture3(NAME, TYPE) TYPE NAME : register(t19)
#define group1_texture4(NAME, TYPE) TYPE NAME : register(t20)
#define group1_texture5(NAME, TYPE) TYPE NAME : register(t21)
#define group1_texture6(NAME, TYPE) TYPE NAME : register(t22)
#define group1_texture7(NAME, TYPE) TYPE NAME : register(t23)

#define group2_texture0(NAME, TYPE) TYPE NAME : register(t32)
#define group2_texture1(NAME, TYPE) TYPE NAME : register(t33)
#define group2_texture2(NAME, TYPE) TYPE NAME : register(t34)
#define group2_texture3(NAME, TYPE) TYPE NAME : register(t35)
#define group2_texture4(NAME, TYPE) TYPE NAME : register(t36)
#define group2_texture5(NAME, TYPE) TYPE NAME : register(t37)
#define group2_texture6(NAME, TYPE) TYPE NAME : register(t38)
#define group2_texture7(NAME, TYPE) TYPE NAME : register(t39)

#define group3_texture0(NAME, TYPE) TYPE NAME : register(t48)
#define group3_texture1(NAME, TYPE) TYPE NAME : register(t49)
#define group3_texture2(NAME, TYPE) TYPE NAME : register(t50)
#define group3_texture3(NAME, TYPE) TYPE NAME : register(t51)
#define group3_texture4(NAME, TYPE) TYPE NAME : register(t52)
#define group3_texture5(NAME, TYPE) TYPE NAME : register(t53)
#define group3_texture6(NAME, TYPE) TYPE NAME : register(t54)
#define group3_texture7(NAME, TYPE) TYPE NAME : register(t55)

////////////////////////////////////////////////////////////////////////////////////////////////////
// STORAGES
////////////////////////////////////////////////////////////////////////////////////////////////////

#define group0_storage0(NAME, TYPE) TYPE NAME : register(t8)
#define group0_storage1(NAME, TYPE) TYPE NAME : register(t9)
#define group0_storage2(NAME, TYPE) TYPE NAME : register(t10)
#define group0_storage3(NAME, TYPE) TYPE NAME : register(t11)
#define group0_storage4(NAME, TYPE) TYPE NAME : register(t12)
#define group0_storage5(NAME, TYPE) TYPE NAME : register(t13)
#define group0_storage6(NAME, TYPE) TYPE NAME : register(t14)
#define group0_storage7(NAME, TYPE) TYPE NAME : register(t15)

#define group1_storage0(NAME, TYPE) TYPE NAME : register(t24)
#define group1_storage1(NAME, TYPE) TYPE NAME : register(t25)
#define group1_storage2(NAME, TYPE) TYPE NAME : register(t26)
#define group1_storage3(NAME, TYPE) TYPE NAME : register(t27)
#define group1_storage4(NAME, TYPE) TYPE NAME : register(t28)
#define group1_storage5(NAME, TYPE) TYPE NAME : register(t29)
#define group1_storage6(NAME, TYPE) TYPE NAME : register(t30)
#define group1_storage7(NAME, TYPE) TYPE NAME : register(t31)

#define group2_storage0(NAME, TYPE) TYPE NAME : register(t40)
#define group2_storage1(NAME, TYPE) TYPE NAME : register(t41)
#define group2_storage2(NAME, TYPE) TYPE NAME : register(t42)
#define group2_storage3(NAME, TYPE) TYPE NAME : register(t43)
#define group2_storage4(NAME, TYPE) TYPE NAME : register(t44)
#define group2_storage5(NAME, TYPE) TYPE NAME : register(t45)
#define group2_storage6(NAME, TYPE) TYPE NAME : register(t46)
#define group2_storage7(NAME, TYPE) TYPE NAME : register(t47)

#define group3_storage0(NAME, TYPE) TYPE NAME : register(t56)
#define group3_storage1(NAME, TYPE) TYPE NAME : register(t57)
#define group3_storage2(NAME, TYPE) TYPE NAME : register(t58)
#define group3_storage3(NAME, TYPE) TYPE NAME : register(t59)
#define group3_storage4(NAME, TYPE) TYPE NAME : register(t60)
#define group3_storage5(NAME, TYPE) TYPE NAME : register(t61)
#define group3_storage6(NAME, TYPE) TYPE NAME : register(t62)
#define group3_storage7(NAME, TYPE) TYPE NAME : register(t63)

////////////////////////////////////////////////////////////////////////////////////////////////////
// UNIFORMS
////////////////////////////////////////////////////////////////////////////////////////////////////

#define group0_uniforms0(NAME, TYPE) cbuffer NAME : register(b0) { TYPE NAME; }
#define group0_uniforms1(NAME, TYPE) cbuffer NAME : register(b1) { TYPE NAME; }

#define group1_uniforms0(NAME, TYPE) cbuffer NAME : register(b2) { TYPE NAME; }
#define group1_uniforms1(NAME, TYPE) cbuffer NAME : register(b3) { TYPE NAME; }

#define group2_uniforms0(NAME, TYPE) cbuffer NAME : register(b4) { TYPE NAME; }
#define group2_uniforms1(NAME, TYPE) cbuffer NAME : register(b5) { TYPE NAME; }

#define group3_uniforms0(NAME, TYPE) cbuffer NAME : register(b6) { TYPE NAME; }
#define group3_uniforms1(NAME, TYPE) cbuffer NAME : register(b7) { TYPE NAME; }

////////////////////////////////////////////////////////////////////////////////////////////////////
// WRITE TEXTURES
////////////////////////////////////////////////////////////////////////////////////////////////////

#define group0_write_texture0(NAME, TYPE) TYPE NAME : register(u0)
#define group0_write_texture1(NAME, TYPE) TYPE NAME : register(u1)
#define group0_write_texture2(NAME, TYPE) TYPE NAME : register(u2)
#define group0_write_texture3(NAME, TYPE) TYPE NAME : register(u3)

#define group1_write_texture0(NAME, TYPE) TYPE NAME : register(u8)
#define group1_write_texture1(NAME, TYPE) TYPE NAME : register(u9)
#define group1_write_texture2(NAME, TYPE) TYPE NAME : register(u10)
#define group1_write_texture3(NAME, TYPE) TYPE NAME : register(u11)

#define group2_write_texture0(NAME, TYPE) TYPE NAME : register(u16)
#define group2_write_texture1(NAME, TYPE) TYPE NAME : register(u17)
#define group2_write_texture2(NAME, TYPE) TYPE NAME : register(u18)
#define group2_write_texture3(NAME, TYPE) TYPE NAME : register(u19)

#define group3_write_texture0(NAME, TYPE) TYPE NAME : register(u24)
#define group3_write_texture1(NAME, TYPE) TYPE NAME : register(u25)
#define group3_write_texture2(NAME, TYPE) TYPE NAME : register(u26)
#define group3_write_texture3(NAME, TYPE) TYPE NAME : register(u27)

////////////////////////////////////////////////////////////////////////////////////////////////////
// WRITE BUFFERS
////////////////////////////////////////////////////////////////////////////////////////////////////

#define group0_write_buffer0(NAME, TYPE) TYPE NAME : register(u4)
#define group0_write_buffer1(NAME, TYPE) TYPE NAME : register(u5)
#define group0_write_buffer2(NAME, TYPE) TYPE NAME : register(u6)
#define group0_write_buffer3(NAME, TYPE) TYPE NAME : register(u7)

#define group1_write_buffer0(NAME, TYPE) TYPE NAME : register(u12)
#define group1_write_buffer1(NAME, TYPE) TYPE NAME : register(u13)
#define group1_write_buffer2(NAME, TYPE) TYPE NAME : register(u14)
#define group1_write_buffer3(NAME, TYPE) TYPE NAME : register(u15)

#define group2_write_buffer0(NAME, TYPE) TYPE NAME : register(u20)
#define group2_write_buffer1(NAME, TYPE) TYPE NAME : register(u21)
#define group2_write_buffer2(NAME, TYPE) TYPE NAME : register(u22)
#define group2_write_buffer3(NAME, TYPE) TYPE NAME : register(u23)

#define group3_write_buffer0(NAME, TYPE) TYPE NAME : register(u28)
#define group3_write_buffer1(NAME, TYPE) TYPE NAME : register(u29)
#define group3_write_buffer2(NAME, TYPE) TYPE NAME : register(u30)
#define group3_write_buffer3(NAME, TYPE) TYPE NAME : register(u31)
