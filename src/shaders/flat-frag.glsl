#version 300 es
precision highp float;

// The fragment shader used to render the background of the scene
// Modify this to make your background more interesting

out vec4 out_Col;
uniform float u_TimeOfDay;

void main() {
  if (u_TimeOfDay == 1.0) {
    out_Col = vec4(5.0 / 255.0, 8.0 / 255.0, 40.0 / 255.0, 1.0);
  } else {
    out_Col = vec4(247.0 / 255.0, 233.0 / 255.0, 192.0 / 255.0, 1.0);
  }
}
