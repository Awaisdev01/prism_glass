// Copyright 2026 The Prism Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// Liquid Glass fallback material for platforms without Apple's
// UIGlassEffect (Android, web, desktop, iOS < 26).
//
// Renders a frosted, refractive glass surface with a specular highlight.
// Uniforms:
//   uResolution   - logical pixel size of the surface
//   uSigma        - blur strength proxy (drives frosting)
//   uTint         - premultiplied tint color (r,g,b,a)
//   uStyle        - 0 = regular, 1 = clear
//   uRadius       - corner radius in pixels (for rounded specular edges)

#include <flutter/runtime_effect.glsl>

uniform vec2 uResolution;
uniform float uSigma;
uniform vec4 uTint;
uniform float uStyle;
uniform float uRadius;
uniform float uTime;

out vec4 fragColor;

// Cheap value noise for the surface micro-refraction.
float hash(vec2 p) {
  return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453);
}

float noise(vec2 p) {
  vec2 i = floor(p);
  vec2 f = fract(p);
  vec2 u = f * f * (3.0 - 2.0 * f);
  return mix(
    mix(hash(i), hash(i + vec2(1, 0)), u.x),
    mix(hash(i + vec2(0, 1)), hash(i + vec2(1, 1)), u.x),
    u.y);
}

// Rounded-rectangle signed distance for edge highlights.
float roundedBox(vec2 p, vec2 halfSize, float r) {
  vec2 q = abs(p) - halfSize + r;
  return length(max(q, 0.0)) + min(max(q.x, q.y), 0.0) - r;
}

void main() {
  vec2 uv = FlutterFragCoord().xy / uResolution;
  vec2 p = FlutterFragCoord().xy;

  // Backdrop approximation: Flutter samples the widget tree behind this
  // widget via BackdropFilter; this shader only adds the glass *character*
  // on top of the blurred backdrop.
  float clear = clamp(uStyle, 0.0, 1.0);

  // Micro refraction shimmer.
  float shimmer = noise(p * 0.012 + uTime * 0.05) * 0.5
      + noise(p * 0.03 - uTime * 0.08) * 0.25;

  // Edge distortion: bend the sampling impression near the rim, the
  // signature refraction cue of Liquid Glass.
  float d = roundedBox(p - uResolution * 0.5, uResolution * 0.5, uRadius);
  float edge = smoothstep(uRadius + 24.0, 0.0, abs(d));

  // Specular rim light.
  float rim = smoothstep(2.0, 0.0, abs(d)) * 0.35;

  // Frosted body: clear style keeps backdrop mostly visible.
  float frost = mix(0.18, 0.06, clear);

  vec3 glass = vec3(frost)
      + shimmer * 0.06 * (1.0 - clear * 0.5)
      + rim * vec3(1.0)
      + edge * 0.05;

  float alpha = mix(0.55, 0.28, clear) + rim * 0.3;

  vec4 tinted = vec4(glass, alpha) * uTint;
  fragColor = vec4(tinted.rgb * tinted.a, tinted.a * 0.9);
}
