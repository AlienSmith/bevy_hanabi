#import bevy_hanabi::vfx_common::{
    IndirectBuffer, ParticleGroup, RenderEffectMetadata, RenderGroupIndirect, SimParams, Spawner,
    seed, tau, pcg_hash, to_float01, frand, frand2, frand3, frand4,
    rand_uniform_f, rand_uniform_vec2, rand_uniform_vec3, rand_uniform_vec4, proj
}

//at most 256 particle groups are supported
const WG_SIZE = 256u;
const EXPORT_SIZE = 3u;

struct Particle {
{{ATTRIBUTES}}
}

struct ParticleBuffer {
    particles: array<Particle>,
}

{{PROPERTIES}}

@group(0) @binding(0) var<storage, read_write> export_buffer : array<f32>;
@group(0) @binding(1) var<uniform> particle_index : u32;
@group(1) @binding(0) var<storage, read_write> particle_buffer : ParticleBuffer;
@group(1) @binding(1) var<storage, read_write> indirect_buffer : IndirectBuffer;
@group(1) @binding(2) var<storage, read> particle_groups : array<ParticleGroup>;
{{PROPERTIES_BINDING}}
@group(2) @binding(0) var<storage, read_write> render_effect_indirect : RenderEffectMetadata;
@group(2) @binding(1) var<storage, read_write> render_group_indirect : array<RenderGroupIndirect>;


{{RENDER_EXTRA}}

@compute @workgroup_size(64)
fn main(@builtin(global_invocation_id) global_invocation_id: vec3<u32>) {
    let thread_index = global_invocation_id.x;
    let start = select( u32(export_buffer[particle_index - 1u]), 0u, particle_index == 0u);
    let thread_size = u32(export_buffer[particle_index]) - start;

    if thread_index >= thread_size {
        return;
    }

    // Always write into ping, read from pong
    let ping = render_effect_indirect.ping;

    let effect_particle_offset = particle_groups[{{GROUP_INDEX}}].effect_particle_offset;
    let base_index = effect_particle_offset + particle_groups[{{GROUP_INDEX}}].indirect_index;
    let particle_index = indirect_buffer.indices[3u * (base_index + thread_index) + ping];

    var particle: Particle = particle_buffer.particles[particle_index];

{{INPUTS}}

{{VERTEX_MODIFIERS}}

    var export_index = WG_SIZE + (start + thread_index) * EXPORT_SIZE;
    export_buffer[export_index] = f32(particle_index);
    export_buffer[export_index + 1u] = position.x;
    export_buffer[export_index + 2u] = position.y;
}
