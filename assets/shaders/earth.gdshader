shader_type spatial;
render_mode cull_disabled, diffuse_burley;
uniform vec4 earth_dark:source_color=vec4(0.54,0.33,0.18,1.0);
uniform vec4 earth_light:source_color=vec4(0.76,0.53,0.31,1.0);
uniform sampler2D soil_tex:source_color,repeat_enable,filter_linear_mipmap_anisotropic;
varying vec3 world_pos;
float hash(vec2 p){return fract(sin(dot(p,vec2(127.1,311.7)))*43758.5453);}
float noise(vec2 p){
 vec2 i=floor(p),f=fract(p);f=f*f*(3.0-2.0*f);
 return mix(mix(hash(i),hash(i+vec2(1,0)),f.x),mix(hash(i+vec2(0,1)),hash(i+vec2(1,1)),f.x),f.y);
}
void vertex(){world_pos=(MODEL_MATRIX*vec4(VERTEX,1.0)).xyz;}
void fragment(){
 vec2 p=world_pos.xz;
 float broad=noise(p*3.1)*0.55+noise(p*11.0)*0.30+noise(p*41.0)*0.15;
 float grit=noise(p*135.0);
 float speck=(grit-0.5)*0.025;
 float soft_patch=exp(-dot(p-vec2(-0.55,0.10),p-vec2(-0.55,0.10))/0.065);
 ALBEDO=mix(earth_dark.rgb,earth_light.rgb,0.42+broad*0.48)+vec3(speck);
 vec3 detail=texture(soil_tex,p*2.0).rgb;
 ALBEDO=mix(ALBEDO,detail,0.80);
 ALBEDO*=1.0-soft_patch*0.035;
 ROUGHNESS=0.94;
 SPECULAR=0.12;
}
