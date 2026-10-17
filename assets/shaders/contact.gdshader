shader_type spatial;
render_mode unshaded, blend_mix, depth_draw_never, cull_disabled;
void fragment(){
 float d=length(UV-vec2(0.5))*2.0;
 ALBEDO=vec3(0.13,0.075,0.035);
 ALPHA=(1.0-smoothstep(0.15,1.0,d))*0.25;
}
