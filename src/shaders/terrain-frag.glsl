#version 300 es
precision highp float;

uniform vec2 u_PlanePos; // Our location in the virtual world displayed by the plane
uniform float u_TimeOfDay;

in vec3 fs_Pos;
in vec4 fs_Nor;
in vec4 fs_Col;

in float fs_Height;
in float fs_Moisture;
in vec4 fs_LightVec;

out vec4 out_Col; // This is the final output color that you will see on your
                  // screen for the pixel that is currently being processed.

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

vec3 color(float elevation, float moisture) {
    if (elevation <= 0.0) {
        if (u_TimeOfDay == 1.0) {
            return vec3(16.0, 26.0, 95.0) * fbm(pow(elevation, 2.0), moisture * 5.0)/ 90.0;
        } else {
            return vec3(66.0, 188.0, 244.0) * fbm(pow(elevation, 2.0), moisture)/ 60.0;
        }
    } else {
        return vec3(130.0, 221.0, 237.0) * fbm(elevation, moisture * 4.0)/ 100.0;
    }
}

void main()
{
    float t = clamp(smoothstep(30.0, 50.0, length(fs_Pos)), 0.0, 1.0); // Distance fog
    vec4 temp = vec4(color(fs_Height, fs_Moisture), 1.0);
    temp = vec4(mix(color(fs_Height, fs_Moisture), temp.xyz, t), 0.5);
    float diffuseTerm = dot(normalize(fs_Nor), normalize(fs_LightVec));
    float ambientTerm = 0.2;
    float lightIntensity = diffuseTerm + ambientTerm;
    lightIntensity /= 2.0;
    if (fs_Height <= 0.0) {
        lightIntensity /= 2.0;
    }
    out_Col = vec4(mix(vec3(temp.rgb * lightIntensity), vec3(0.5, 0.5, 0.5), t * 0.5), 1.2);
}
