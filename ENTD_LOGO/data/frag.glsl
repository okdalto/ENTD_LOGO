#ifdef GL_ES
precision mediump float;
precision mediump int;
#endif

uniform vec2 resolution;
uniform vec2 v[4];
uniform vec3 vertColor[4];
uniform float frameCount;
uniform vec2 translate;
uniform float size;
uniform float speed;

//	Simplex 3D Noise 
//	by Ian McEwan, Ashima Arts
//
vec4 permute(vec4 x){return mod(((x*34.0)+1.0)*x, 289.0);}
vec4 taylorInvSqrt(vec4 r){return 1.79284291400159 - 0.85373472095314 * r;}

float snoise(vec3 v){ 
  const vec2  C = vec2(1.0/6.0, 1.0/3.0) ;
  const vec4  D = vec4(0.0, 0.5, 1.0, 2.0);

// First corner
  vec3 i  = floor(v + dot(v, C.yyy) );
  vec3 x0 =   v - i + dot(i, C.xxx) ;

// Other corners
  vec3 g = step(x0.yzx, x0.xyz);
  vec3 l = 1.0 - g;
  vec3 i1 = min( g.xyz, l.zxy );
  vec3 i2 = max( g.xyz, l.zxy );

  //  x0 = x0 - 0. + 0.0 * C 
  vec3 x1 = x0 - i1 + 1.0 * C.xxx;
  vec3 x2 = x0 - i2 + 2.0 * C.xxx;
  vec3 x3 = x0 - 1. + 3.0 * C.xxx;

// Permutations
  i = mod(i, 289.0 ); 
  vec4 p = permute( permute( permute( 
             i.z + vec4(0.0, i1.z, i2.z, 1.0 ))
           + i.y + vec4(0.0, i1.y, i2.y, 1.0 )) 
           + i.x + vec4(0.0, i1.x, i2.x, 1.0 ));

// Gradients
// ( N*N points uniformly over a square, mapped onto an octahedron.)
  float n_ = 1.0/7.0; // N=7
  vec3  ns = n_ * D.wyz - D.xzx;

  vec4 j = p - 49.0 * floor(p * ns.z *ns.z);  //  mod(p,N*N)

  vec4 x_ = floor(j * ns.z);
  vec4 y_ = floor(j - 7.0 * x_ );    // mod(j,N)

  vec4 x = x_ *ns.x + ns.yyyy;
  vec4 y = y_ *ns.x + ns.yyyy;
  vec4 h = 1.0 - abs(x) - abs(y);

  vec4 b0 = vec4( x.xy, y.xy );
  vec4 b1 = vec4( x.zw, y.zw );

  vec4 s0 = floor(b0)*2.0 + 1.0;
  vec4 s1 = floor(b1)*2.0 + 1.0;
  vec4 sh = -step(h, vec4(0.0));

  vec4 a0 = b0.xzyw + s0.xzyw*sh.xxyy ;
  vec4 a1 = b1.xzyw + s1.xzyw*sh.zzww ;

  vec3 p0 = vec3(a0.xy,h.x);
  vec3 p1 = vec3(a0.zw,h.y);
  vec3 p2 = vec3(a1.xy,h.z);
  vec3 p3 = vec3(a1.zw,h.w);

//Normalise gradients
  vec4 norm = taylorInvSqrt(vec4(dot(p0,p0), dot(p1,p1), dot(p2, p2), dot(p3,p3)));
  p0 *= norm.x;
  p1 *= norm.y;
  p2 *= norm.z;
  p3 *= norm.w;

// Mix final noise value
  vec4 m = max(0.6 - vec4(dot(x0,x0), dot(x1,x1), dot(x2,x2), dot(x3,x3)), 0.0);
  m = m * m;
  return 42.0 * dot( m*m, vec4( dot(p0,x0), dot(p1,x1), 
                                dot(p2,x2), dot(p3,x3) ) );
}

float map(float value, float min1, float max1, float min2, float max2){
    float perc = (value - min1) / (max1 - min1);
    float result = perc * (max2 - min2) + min2;
	return result;
}

void main() {
	vec2 uv = gl_FragCoord.xy / resolution.xy;
	vec2 trans = translate.xy / resolution.xy;

	vec2 pos1 = v[0] / resolution.xy + trans;
	pos1.y = abs(pos1.y-1.0);
	vec2 pos2 = v[1] / resolution.xy + trans;
	pos2.y = abs(pos2.y-1.0);
	vec2 pos3 = v[2] / resolution.xy + trans;
	pos3.y = abs(pos3.y-1.0);
	vec2 pos4 = v[3] / resolution.xy + trans;
	pos4.y = abs(pos4.y-1.0);
	float leng = (size*1.0)/resolution.x;
	float noiseResolution = 1.4;
    float noiseAdd = 0.8;
	vec3 vertColor1 = vertColor[0];
	float dist1 = clamp(distance(pos1, uv),0.0,leng);
    dist1 = map(dist1,0,leng,1.0,0.0)*(snoise(vec3(uv*noiseResolution+pos1, frameCount*speed))*0.5+noiseAdd);
//    dist1 = min(map(dist1,0,leng,1.0,0.0),1.0);
	vertColor1 *= dist1;

	vec3 vertColor2 = vertColor[1];
	float dist2 = clamp(distance(pos2, uv),0.0,leng);
    dist2 = map(dist2,0,leng,1.0,0.0)*(snoise(vec3(uv*noiseResolution+pos2, frameCount*speed))*0.5+noiseAdd);
//    dist2 = min(map(dist2,0,leng,1.0,0.0),1.0);
	vertColor2 *= dist2;

	vec3 vertColor3 = vertColor[2];
	float dist3 = clamp(distance(pos3, uv),0.0,leng);
    dist3 = map(dist3,0,leng,1.0,0.0)*(snoise(vec3(uv*noiseResolution+pos3, frameCount*speed))*0.5+noiseAdd);
//    dist3 = min(map(dist3,0,leng,1.0,0.0),1.0);
	vertColor3 *= dist3;

	vec3 vertColor4 = vertColor[3];
	float dist4 = clamp(distance(pos4, uv),0.0,leng);
    dist4 = map(dist4,0,leng,1.0,0.0)*(snoise(vec3(uv*noiseResolution+pos4, frameCount*speed))*0.5+noiseAdd);
//    dist4 = min(map(dist4,0,leng,1.0,0.0),1.0);
	vertColor4 *= dist4;

	//* (noise(v[0]*0.01 + frameCount*0.02)*0.5+0.5)
	vec3 finalCol = vertColor1 + vertColor2 + vertColor3 + vertColor4;
	gl_FragColor = vec4(finalCol ,1.0);
}
