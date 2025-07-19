struct VertexOutput {
    @builtin(position) position: vec4<f32>,
    @location(0) uv: vec2<f32>,
    @location(1) color: vec4<f32>,
}

struct ResolutionUniform {
    width: f32,
    height: f32,
    time: f32,
}

@group(1) @binding(0)
var t: texture_2d<f32>;

@group(1) @binding(1)
var s: sampler;

@group(3) @binding(0)
var<uniform> resolution: ResolutionUniform;

@vertex
fn vs_main(@location(0) position: vec2<f32>) -> VertexOutput {
    var out: VertexOutput;
    out.position = vec4<f32>(position, 0.0, 1.0);
    out.uv = position * 0.5 + vec2<f32>(0.5, 0.5); // Remap NDC [-1,1] to [0,1], origin at bottom left
    out.color = vec4<f32>(1.0);
    return out;
}

// Simple hash function for randomness
fn hash(n: f32) -> f32 {
    return fract(sin(n) * 43758.5453);
}

fn grass_blade(uv: vec2<f32>, pos: vec2<f32>, height: f32, width: f32, sway: f32) -> f32 {
    let p = uv - pos;

    // Check if we're in the grass area (above the base position)
    if (p.y < 0.0 || p.y > height) {
        return 1.0;
    }

    // Normalize height position (0 at base, 1 at tip)
    let t = p.y / height;

    // Simple curved blade with sway
    let curve_x = sway * sin(t * 3.14159) * t;

    // Distance to blade center line
    let dist = abs(p.x - curve_x) - width * (1.0 - t * 0.5);

    return dist;
}

@fragment
fn fs_main(in: VertexOutput) -> @location(0) vec4<f32> {
    // Use UVs directly
    let uv = in.uv;

    // Ground color
    var color = vec3<f32>(0.2, 0.6, 0.3);

    // Grass parameters
    let blade_count = 10.0;
    let blade_spacing = 100.0 / blade_count;

    // Wind animation
    let wind = sin(resolution.time * 1.5) * 0.05;

    // Generate grass blades
    for (var i = 0.0; i < blade_count; i += 1.0) {
        let rand = hash(i);

        // Blade position - spread across full width, at bottom of screen
        let pos = vec2<f32>(
            (i / blade_count) + rand * 0.01,
            0.0
        );

        // Calculate blade SDF.
        let height = mix(0.2, 0.9, hash(i + 1.0));
        let width = mix(0.01, 0.03, hash(i + 2.0));
        let sway = mix(-0.05, 0.05, hash(i + 3.0)) + wind * hash(i + 7.0);
        let d = grass_blade(uv, pos, height, width, sway);

        // Apply a mask to blend the blade color.
        let blade_mask = 1.0 - smoothstep(0.0, 0.01, d);
        let blade_color = vec3<f32>(
            0.3 + hash(i + 4.0) * 0.2,
            0.7 + hash(i + 5.0) * 0.2,
            0.2 + hash(i + 6.0) * 0.15
        );

        color = mix(color, blade_color, blade_mask);
    }

    return vec4<f32>(color, 1.0);
}
