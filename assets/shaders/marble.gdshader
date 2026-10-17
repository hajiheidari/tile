shader_type spatial;
render_mode unshaded, depth_draw_always;
uniform sampler2D scene_color:hint_screen_texture, repeat_disable, filter_linear_mipmap;
uniform vec4 tint:source_color=vec4(0.025,0.4,0.8,1.0);
uniform float radius=0.025;
varying vec3 surface_point;
varying vec3 eye_object;
void vertex(){
 surface_point=VERTEX/radius;
 eye_object=(inverse(MODELVIEW_MATRIX)*vec4(0.0,0.0,0.0,1.0)).xyz/radius;
}
void fragment(){
 vec3 p=normalize(surface_point);
 vec3 object_view=normalize(eye_object-surface_point);
 vec3 ray=refract(-object_view,p,1.0/1.52);
 float chord=max(-2.0*dot(p,ray),0.0);
 vec3 pigment=vec3(0.0);
 float opacity=0.0;
 // Sample the colored twist inside the glass, rather than painting surface stripes.
 for(int i=0;i<14;i++){
  vec3 q=p+ray*chord*(float(i)+0.5)/14.0;
  float a=q.y*5.6;
  float twist=abs(q.x*cos(a)+q.z*sin(a));
  float inside=1.0-smoothstep(0.74,0.94,length(q));
  float ribbon=(1.0-smoothstep(0.065,0.14,twist))*inside;
  float cream=(1.0-smoothstep(0.025,0.065,abs(q.x*cos(a+0.55)+q.z*sin(a+0.55))))*inside;
  vec3 color=mix(tint.rgb*0.72+vec3(0.025),vec3(0.95,0.86,0.64),cream*0.85);
  float alpha=ribbon*0.42;
  pigment+=color*alpha*(1.0-opacity);
  opacity+=alpha*(1.0-opacity);
 }
 vec3 n=normalize(NORMAL);
 vec3 v=normalize(VIEW);
 float facing=max(dot(n,v),0.0);
 float fresnel=0.04+0.96*pow(1.0-facing,4.0);
 vec3 background=textureLod(scene_color,SCREEN_UV+n.xy*0.006,0.0).rgb;
 vec3 glass=background*vec3(0.86,0.95,1.0);
 glass=glass*(1.0-opacity)+pigment;
 vec3 reflection=mix(vec3(0.13,0.22,0.25),vec3(0.54,0.78,0.87),smoothstep(-0.2,0.8,n.y));
 glass=mix(glass,reflection,fresnel*0.72);
 float highlight=pow(max(dot(n,normalize(vec3(-0.36,0.52,0.78))),0.0),56.0);
 float glint=pow(max(dot(n,normalize(vec3(0.48,-0.28,0.82))),0.0),100.0);
 ALBEDO=glass+vec3(1.0,0.98,0.90)*highlight*0.95+vec3(0.66,0.85,0.95)*glint*0.45;
 ALPHA=1.0;
}
