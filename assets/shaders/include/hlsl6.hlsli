////////////////////////////////////////////////////////////////////////////////////////////////////
// SAMPLERS
////////////////////////////////////////////////////////////////////////////////////////////////////

#define group0_sampler0(NAME, TYPE) TYPE NAME : register(s0, space0)
#define group0_sampler1(NAME, TYPE) TYPE NAME : register(s1, space0)
#define group0_sampler2(NAME, TYPE) TYPE NAME : register(s2, space0)
#define group0_sampler3(NAME, TYPE) TYPE NAME : register(s3, space0)

#define group1_sampler0(NAME, TYPE) TYPE NAME : register(s0, space1)
#define group1_sampler1(NAME, TYPE) TYPE NAME : register(s1, space1)
#define group1_sampler2(NAME, TYPE) TYPE NAME : register(s2, space1)
#define group1_sampler3(NAME, TYPE) TYPE NAME : register(s3, space1)

#define group2_sampler0(NAME, TYPE) TYPE NAME : register(s0, space2)
#define group2_sampler1(NAME, TYPE) TYPE NAME : register(s1, space2)
#define group2_sampler2(NAME, TYPE) TYPE NAME : register(s2, space2)
#define group2_sampler3(NAME, TYPE) TYPE NAME : register(s3, space2)

#define group3_sampler0(NAME, TYPE) TYPE NAME : register(s0, space3)
#define group3_sampler1(NAME, TYPE) TYPE NAME : register(s1, space3)
#define group3_sampler2(NAME, TYPE) TYPE NAME : register(s2, space3)
#define group3_sampler3(NAME, TYPE) TYPE NAME : register(s3, space3)

////////////////////////////////////////////////////////////////////////////////////////////////////
// TEXTURES
////////////////////////////////////////////////////////////////////////////////////////////////////

#define group0_texture0(NAME, TYPE) TYPE NAME : register(t0, space0)
#define group0_texture1(NAME, TYPE) TYPE NAME : register(t1, space0)
#define group0_texture2(NAME, TYPE) TYPE NAME : register(t2, space0)
#define group0_texture3(NAME, TYPE) TYPE NAME : register(t3, space0)
#define group0_texture4(NAME, TYPE) TYPE NAME : register(t4, space0)
#define group0_texture5(NAME, TYPE) TYPE NAME : register(t5, space0)
#define group0_texture6(NAME, TYPE) TYPE NAME : register(t6, space0)
#define group0_texture7(NAME, TYPE) TYPE NAME : register(t7, space0)

#define group1_texture0(NAME, TYPE) TYPE NAME : register(t0, space1)
#define group1_texture1(NAME, TYPE) TYPE NAME : register(t1, space1)
#define group1_texture2(NAME, TYPE) TYPE NAME : register(t2, space1)
#define group1_texture3(NAME, TYPE) TYPE NAME : register(t3, space1)
#define group1_texture4(NAME, TYPE) TYPE NAME : register(t4, space1)
#define group1_texture5(NAME, TYPE) TYPE NAME : register(t5, space1)
#define group1_texture6(NAME, TYPE) TYPE NAME : register(t6, space1)
#define group1_texture7(NAME, TYPE) TYPE NAME : register(t7, space1)

#define group2_texture0(NAME, TYPE) TYPE NAME : register(t0, space2)
#define group2_texture1(NAME, TYPE) TYPE NAME : register(t1, space2)
#define group2_texture2(NAME, TYPE) TYPE NAME : register(t2, space2)
#define group2_texture3(NAME, TYPE) TYPE NAME : register(t3, space2)
#define group2_texture4(NAME, TYPE) TYPE NAME : register(t4, space2)
#define group2_texture5(NAME, TYPE) TYPE NAME : register(t5, space2)
#define group2_texture6(NAME, TYPE) TYPE NAME : register(t6, space2)
#define group2_texture7(NAME, TYPE) TYPE NAME : register(t7, space2)

#define group3_texture0(NAME, TYPE) TYPE NAME : register(t0, space3)
#define group3_texture1(NAME, TYPE) TYPE NAME : register(t1, space3)
#define group3_texture2(NAME, TYPE) TYPE NAME : register(t2, space3)
#define group3_texture3(NAME, TYPE) TYPE NAME : register(t3, space3)
#define group3_texture4(NAME, TYPE) TYPE NAME : register(t4, space3)
#define group3_texture5(NAME, TYPE) TYPE NAME : register(t5, space3)
#define group3_texture6(NAME, TYPE) TYPE NAME : register(t6, space3)
#define group3_texture7(NAME, TYPE) TYPE NAME : register(t7, space3)

////////////////////////////////////////////////////////////////////////////////////////////////////
// STORAGES
////////////////////////////////////////////////////////////////////////////////////////////////////

#define group0_storage0(NAME, TYPE) TYPE NAME : register(t8, space0)
#define group0_storage1(NAME, TYPE) TYPE NAME : register(t9, space0)
#define group0_storage2(NAME, TYPE) TYPE NAME : register(t10, space0)
#define group0_storage3(NAME, TYPE) TYPE NAME : register(t11, space0)
#define group0_storage4(NAME, TYPE) TYPE NAME : register(t12, space0)
#define group0_storage5(NAME, TYPE) TYPE NAME : register(t13, space0)
#define group0_storage6(NAME, TYPE) TYPE NAME : register(t14, space0)
#define group0_storage7(NAME, TYPE) TYPE NAME : register(t15, space0)

#define group1_storage0(NAME, TYPE) TYPE NAME : register(t8, space1)
#define group1_storage1(NAME, TYPE) TYPE NAME : register(t9, space1)
#define group1_storage2(NAME, TYPE) TYPE NAME : register(t10, space1)
#define group1_storage3(NAME, TYPE) TYPE NAME : register(t11, space1)
#define group1_storage4(NAME, TYPE) TYPE NAME : register(t12, space1)
#define group1_storage5(NAME, TYPE) TYPE NAME : register(t13, space1)
#define group1_storage6(NAME, TYPE) TYPE NAME : register(t14, space1)
#define group1_storage7(NAME, TYPE) TYPE NAME : register(t15, space1)

#define group2_storage0(NAME, TYPE) TYPE NAME : register(t8, space2)
#define group2_storage1(NAME, TYPE) TYPE NAME : register(t9, space2)
#define group2_storage2(NAME, TYPE) TYPE NAME : register(t10, space2)
#define group2_storage3(NAME, TYPE) TYPE NAME : register(t11, space2)
#define group2_storage4(NAME, TYPE) TYPE NAME : register(t12, space2)
#define group2_storage5(NAME, TYPE) TYPE NAME : register(t13, space2)
#define group2_storage6(NAME, TYPE) TYPE NAME : register(t14, space2)
#define group2_storage7(NAME, TYPE) TYPE NAME : register(t15, space2)

#define group3_storage0(NAME, TYPE) TYPE NAME : register(t8, space3)
#define group3_storage1(NAME, TYPE) TYPE NAME : register(t9, space3)
#define group3_storage2(NAME, TYPE) TYPE NAME : register(t10, space3)
#define group3_storage3(NAME, TYPE) TYPE NAME : register(t11, space3)
#define group3_storage4(NAME, TYPE) TYPE NAME : register(t12, space3)
#define group3_storage5(NAME, TYPE) TYPE NAME : register(t13, space3)
#define group3_storage6(NAME, TYPE) TYPE NAME : register(t14, space3)
#define group3_storage7(NAME, TYPE) TYPE NAME : register(t15, space3)

////////////////////////////////////////////////////////////////////////////////////////////////////
// UNIFORMS
////////////////////////////////////////////////////////////////////////////////////////////////////

#define group0_uniforms0(NAME, TYPE) ConstantBuffer<TYPE> NAME : register(b0, space0)
#define group0_uniforms1(NAME, TYPE) ConstantBuffer<TYPE> NAME : register(b1, space0)

#define group1_uniforms0(NAME, TYPE) ConstantBuffer<TYPE> NAME : register(b0, space1)
#define group1_uniforms1(NAME, TYPE) ConstantBuffer<TYPE> NAME : register(b1, space1)

#define group2_uniforms0(NAME, TYPE) ConstantBuffer<TYPE> NAME : register(b0, space2)
#define group2_uniforms1(NAME, TYPE) ConstantBuffer<TYPE> NAME : register(b1, space2)

#define group3_uniforms0(NAME, TYPE) ConstantBuffer<TYPE> NAME : register(b0, space3)
#define group3_uniforms1(NAME, TYPE) ConstantBuffer<TYPE> NAME : register(b1, space3)

////////////////////////////////////////////////////////////////////////////////////////////////////
// WRITE TEXTURES
////////////////////////////////////////////////////////////////////////////////////////////////////

#define group0_write_texture0(NAME, TYPE) TYPE NAME : register(u0, space0)
#define group0_write_texture1(NAME, TYPE) TYPE NAME : register(u1, space0)
#define group0_write_texture2(NAME, TYPE) TYPE NAME : register(u2, space0)
#define group0_write_texture3(NAME, TYPE) TYPE NAME : register(u3, space0)

#define group1_write_texture0(NAME, TYPE) TYPE NAME : register(u0, space1)
#define group1_write_texture1(NAME, TYPE) TYPE NAME : register(u1, space1)
#define group1_write_texture2(NAME, TYPE) TYPE NAME : register(u2, space1)
#define group1_write_texture3(NAME, TYPE) TYPE NAME : register(u3, space1)

#define group2_write_texture0(NAME, TYPE) TYPE NAME : register(u0, space2)
#define group2_write_texture1(NAME, TYPE) TYPE NAME : register(u1, space2)
#define group2_write_texture2(NAME, TYPE) TYPE NAME : register(u2, space2)
#define group2_write_texture3(NAME, TYPE) TYPE NAME : register(u3, space2)

#define group3_write_texture0(NAME, TYPE) TYPE NAME : register(u0, space3)
#define group3_write_texture1(NAME, TYPE) TYPE NAME : register(u1, space3)
#define group3_write_texture2(NAME, TYPE) TYPE NAME : register(u2, space3)
#define group3_write_texture3(NAME, TYPE) TYPE NAME : register(u3, space3)

////////////////////////////////////////////////////////////////////////////////////////////////////
// WRITE BUFFERS
////////////////////////////////////////////////////////////////////////////////////////////////////

#define group0_write_buffer0(NAME, TYPE) TYPE NAME : register(u4, space0)
#define group0_write_buffer1(NAME, TYPE) TYPE NAME : register(u5, space0)
#define group0_write_buffer2(NAME, TYPE) TYPE NAME : register(u6, space0)
#define group0_write_buffer3(NAME, TYPE) TYPE NAME : register(u7, space0)

#define group1_write_buffer0(NAME, TYPE) TYPE NAME : register(u4, space1)
#define group1_write_buffer1(NAME, TYPE) TYPE NAME : register(u5, space1)
#define group1_write_buffer2(NAME, TYPE) TYPE NAME : register(u6, space1)
#define group1_write_buffer3(NAME, TYPE) TYPE NAME : register(u7, space1)

#define group2_write_buffer0(NAME, TYPE) TYPE NAME : register(u4, space2)
#define group2_write_buffer1(NAME, TYPE) TYPE NAME : register(u5, space2)
#define group2_write_buffer2(NAME, TYPE) TYPE NAME : register(u6, space2)
#define group2_write_buffer3(NAME, TYPE) TYPE NAME : register(u7, space2)

#define group3_write_buffer0(NAME, TYPE) TYPE NAME : register(u4, space3)
#define group3_write_buffer1(NAME, TYPE) TYPE NAME : register(u5, space3)
#define group3_write_buffer2(NAME, TYPE) TYPE NAME : register(u6, space3)
#define group3_write_buffer3(NAME, TYPE) TYPE NAME : register(u7, space3)
