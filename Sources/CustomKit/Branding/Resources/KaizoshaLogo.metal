#include <metal_stdlib>
#include <SwiftUI/SwiftUI_Metal.h>

using namespace metal;

/// Adds restrained chromatic refraction and a specular line positioned by the
/// supplied light direction while preserving the semantic source color.
[[ stitchable ]] half4 kaizoshaGlassRefraction(
    float2 position,
    SwiftUI::Layer layer,
    float2 size,
    float2 lightDirection,
    float progress,
    float velocity
) {
    float2 safeSize = max(size, float2(1.0));
    float2 uv = saturate(position / safeSize);
    float pull = smoothstep(0.0, 1.0, progress);
    float2 light = clamp(lightDirection, float2(-1.0), float2(1.0));

    float2 refraction = float2(
        sin(uv.y * 18.0 + light.y * 4.8),
        cos(uv.x * 15.0 - light.x * 4.2)
    );
    refraction *= 0.75 + pull * 1.7;
    refraction += light * (1.1 + pull * 0.75);
    refraction.x += velocity * 2.2 * sin(uv.y * M_PI_F);

    half4 center = layer.sample(position + refraction * 0.42);
    half alpha = center.a;
    if (alpha <= 0.001h) {
        return center;
    }

    float chromaDistance = 0.9 + pull * 0.45;
    float2 dispersionAxis = normalize(
        float2(0.94, 0.18) + light * 0.16
    );
    half4 redSample = layer.sample(
        position + refraction + dispersionAxis * chromaDistance
    );
    half4 greenSample = layer.sample(position + refraction * 0.65);
    half4 blueSample = layer.sample(
        position + refraction - dispersionAxis * chromaDistance
    );

    half3 base = center.rgb / max(alpha, 0.001h);
    half3 refracted = half3(
        redSample.r / max(redSample.a, 0.001h),
        greenSample.g / max(greenSample.a, 0.001h),
        blueSample.b / max(blueSample.a, 0.001h)
    );

    float2 highlightCenter = saturate(
        float2(0.5) + light * float2(0.42, 0.38)
    );
    float2 highlightNormal = normalize(
        float2(0.92, 0.46) + float2(light.y, -light.x) * 0.24
    );
    float diagonal = dot(uv, highlightNormal);
    float specularPosition = dot(highlightCenter, highlightNormal);
    float specular = exp(
        -pow(diagonal - specularPosition, 2.0) * 125.0
    );
    float lightPhase = light.x * 6.2 - light.y * 4.8;
    float caustic = 0.5 + 0.5 * sin(
        uv.x * 21.0 - uv.y * 14.0 + lightPhase
    );
    caustic *= 0.5 + 0.5 * sin(
        uv.y * 27.0 + uv.x * 9.0 - lightPhase * 0.73
    );

    half3 glassColor = mix(base, refracted, 0.11h);
    glassColor += half3(0.34h, 0.39h, 0.46h) * half(specular);
    glassColor += half3(0.025h, 0.042h, 0.055h) * half(caustic);

    return half4(glassColor * alpha, alpha);
}

/// Pulls the complete mark through a tapered, velocity-sensitive singularity.
/// The same progress field reverses continuously as the native sheet returns.
[[ stitchable ]] float2 kaizoshaSingularityWarp(
    float2 position,
    float2 size,
    float progress,
    float velocity
) {
    float2 safeSize = max(size, float2(1.0));
    float2 uv = saturate(position / safeSize);
    float pull = smoothstep(0.0, 1.0, progress);
    float speed = saturate(abs(velocity));
    float centerX = safeSize.x * 0.5;
    float halfWidth = safeSize.x * 0.5;
    float verticalEnvelope = sin(uv.y * M_PI_F);

    // Material nearest the sensor narrows first while the lower edge trails.
    // Inverse sampling turns this aperture into a continuous funnel instead of
    // clipping the artwork behind a shrinking rectangle.
    float gravity = pow(saturate(1.0 - uv.y), 0.72);
    float funnel = pull * (0.10 + gravity * 0.82);
    float aperture = max(
        1.0 - funnel * (0.82 + speed * 0.06),
        0.14
    );
    float2 source = position;
    source.x = centerX + (position.x - centerX) / aperture;

    // The center stream reaches the pull point first. Outer material lags by a
    // few pixels, creating the stretched neck associated with strong suction.
    float sampledX = (source.x - centerX) / max(halfWidth, 1.0);
    float coreStream = exp(-sampledX * sampledX * 4.2);
    float differentialPull = mix(-5.0, 18.0, coreStream);
    source.y += differentialPull
        * pull
        * verticalEnvelope
        * (1.0 + speed * 0.35);

    // A restrained curl keeps the funnel fluid. Signed velocity bends the
    // stream in the release direction and naturally unwinds on sheet return.
    float curl = sin(uv.y * 11.0 + pull * 4.6);
    source.x += curl
        * pull
        * gravity
        * verticalEnvelope
        * (4.0 + speed * 3.0);
    source.x += velocity
        * verticalEnvelope
        * (uv.y - 0.32)
        * 8.0;

    return source;
}

/// Gives the Controls mark a bounded gel-like stretch along the active drag.
/// The mark remains in layout; this shader only bends its rendered material.
[[ stitchable ]] float2 kaizoshaElasticWarp(
    float2 position,
    float2 size,
    float2 dragDirection,
    float stretch,
    float speed
) {
    float2 safeSize = max(size, float2(1.0));
    float2 uv = saturate(position / safeSize);
    float2 centered = uv - float2(0.5);
    float directionLength = length(dragDirection);
    float2 direction = directionLength > 0.001
        ? dragDirection / directionLength
        : float2(0.0, 1.0);
    float2 tangent = float2(-direction.y, direction.x);
    float boundedStretch = saturate(stretch);
    float boundedSpeed = saturate(speed);
    float along = dot(centered, direction);
    float across = dot(centered, tangent);
    float edgeEnvelope =
        sin(uv.x * M_PI_F) * sin(uv.y * M_PI_F);

    float2 source = position;
    source -= direction
        * along
        * boundedStretch
        * (18.0 + boundedSpeed * 8.0);
    source += tangent
        * sin(along * M_PI_F * 2.0)
        * edgeEnvelope
        * boundedStretch
        * (4.0 + boundedSpeed * 7.0);
    source += direction
        * across
        * across
        * boundedStretch
        * boundedSpeed
        * 8.0;

    return source;
}
