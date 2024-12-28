#version 330

in vec2 fragTexCoord;
in vec4 fragColor;

out vec4 finalColor;

const float curvature = 10.0;
const float vignette_width = 30.0;

const vec2 size = vec2(1344, 864);  // render size
const float samples = 10.0;         // pixels per axis; higher = bigger glow, worse performance
const float quality = 2.0;          // lower = smaller glow, better quality

uniform sampler2D texture0;
uniform vec4 colDiffuse;

float offsets[3] = float[](0.0, 1.3846153846, 3.2307692308);
float weight[3] = float[](0.2270270270, 0.3162162162, 0.0702702703);

void main() {
    // curvature
    vec2 uv = fragTexCoord * 2.0 - 1.0;
    vec2 offset = uv.yx / curvature;
    uv = uv + uv * offset * offset;
    uv = uv * 0.5 + 0.5;

    // blur !
    vec3 texelColor = texture(texture0, uv).rgb*weight[0];
    for (int i = 1; i < 3; i++) {
        texelColor += texture(texture0, uv + vec2(offsets[i]) / size.x, 0.0).rgb * weight[i];
        texelColor += texture(texture0, uv - vec2(offsets[i]) / size.x, 0.0).rgb * weight[i];
    }
    finalColor = vec4(texelColor, 1.0);

    // bloom !
//   vec4 sum = vec4(0);
//   vec2 sizeFactor = vec2(1) / size * quality;
//   const int range = 2; //(samples - 1)/2;
//   for (int x = -range; x <= range; x++) {
//       for (int y = -range; y <= range; y++) {
//           sum += texture(texture0, uv + vec2(x, y) * sizeFactor);
//       }
//   }
//   finalColor = ((sum/(samples*samples)) + finalColor)*colDiffuse;

    // make out of bounds pixels black
    if (uv.x <= 0.0 || 1.0 <= uv.x || uv.y <= 0.0 || 1.0 <= uv.y) {
        finalColor = vec4(0.0);
    }

    // vignette
    uv = uv * 2.0 - 1.0;
    vec2 vignette = vignette_width / size.xy;
    vignette = smoothstep(vec2(0.0), vignette, 1.0 - abs(uv));
    vignette = clamp(vignette, 0.0, 1.0);

    // scanlines
    finalColor.g *= (sin(fragTexCoord.y * size.y * 1.0) + 1.0) * 0.15 + 1.0;
    finalColor.rb *= (cos(fragTexCoord.y * size.y * 1.0) + 1.0) * 0.135 + 1.0;

    finalColor = clamp(finalColor, 0.0, 1.0) * vignette.x * vignette.y;
}
