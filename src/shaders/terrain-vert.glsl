#version 300 es

uniform mat4 u_Model;
uniform mat4 u_ModelInvTr;
uniform mat4 u_ViewProj;
uniform vec2 u_PlanePos; // Our location in the virtual world displayed by the plane

in vec4 vs_Pos;
in vec4 vs_Nor;
in vec4 vs_Col;

out vec3 fs_Pos;
out vec4 fs_Nor;
out vec4 fs_Col;

out float fs_Sine;
out float fs_Height;
out float fs_Moisture;
const vec4 lightPos = vec4(1.0, 2.0, 1.0, 1.0);
out vec4 fs_LightVec;


float random1( vec2 p , vec2 seed) {
  return fract(sin(dot(p + seed, vec2(127.1, 311.7))) * 43758.5453);
}

float random1( vec3 p , vec3 seed) {
  return fract(sin(dot(p + seed, vec3(987.654, 123.456, 531.975))) * 85734.3545);
}

vec2 random2( vec2 p , vec2 seed) {
  return fract(sin(vec2(dot(p + seed, vec2(311.7, 127.1)), dot(p + seed, vec2(269.5, 183.3)))) * 85734.3545);
}

float interpNoise2D(float x, float y) { //from slides
    float intX = floor(x);
    float fractX = fract(x);
    float intY = floor(y);
    float fractY = fract(y);

    float v1 = random1(vec2(intX, intY), vec2(1.f, 1.f));
    float v2 = random1(vec2(intX + 1.0f, intY), vec2(1.f, 1.f));
    float v3 = random1(vec2(intX, intY + 1.0f), vec2(1.f, 1.f));
    float v4 = random1(vec2(intX + 1.0, intY + 1.0), vec2(1.f, 1.f));

    float i1 = mix(v1, v2, fractX);
    float i2 = mix(v3, v4, fractX);

    return mix(i1, i2, fractY);
}

// Create a height field based on summed fractal noise
// Adjust distribution of noise values so they are biased to various height values, 
// or even radically remap height values entirely! 
float fbm(float x, float y) { //from slides
  float total = 0.0f;
  float persistence = 0.5f;
  float octaves = 10.0;

  for (float i = 0.0; i < octaves; i = i + 1.0) {
      float freq = pow(2.0f, i);
      float amp = pow(persistence, i);
      total += interpNoise2D(x * freq, y * freq) * amp;
  }
  return total;
}

void main()
{


  float elevation = fbm((vs_Pos.x + u_PlanePos.x) / 8.0, (vs_Pos.z + u_PlanePos.y) / 8.0);
  elevation = pow(elevation, 3.0) * floor(elevation); // or multiply
  // elevation = pow(elevation, 5.0) * floor(elevation) * random1(vec2(vs_Pos.z + u_PlanePos.y), vec2(100.f, 200.f)) * random1(vec2(vs_Pos.x + u_PlanePos.x), vec2(1.f, 1.f)); // melting ice caps
  fs_Height = elevation;
  fs_Pos = vec3(vs_Pos.x, elevation, vs_Pos.z);

  fs_Moisture = fbm((vs_Pos.x + u_PlanePos.x) / 10.0, (vs_Pos.z + u_PlanePos.y) / 10.0);
  
  vec4 modelposition = vec4(vs_Pos.x, elevation, vs_Pos.z, 1.0);
  modelposition = u_Model * modelposition;
  mat3 invTranspose = mat3(u_ModelInvTr);
  fs_Nor = vec4(invTranspose * vec3(vs_Nor), 0);
  fs_LightVec = lightPos - modelposition;
  gl_Position = u_ViewProj * modelposition;
}