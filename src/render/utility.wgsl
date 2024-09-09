
@group(0) @binding(0)
var<storage, read_write> export_buffer : array<u32>;

@group(0) @binding(1)
var<uniform> max_index : u32;

const WG_SIZE = 256u;

var<workgroup> sh: array<u32, WG_SIZE>;

@compute @workgroup_size(256)
fn main(@builtin(local_invocation_id) local_id: vec3<u32>) {
    var count = select(export_buffer[local_id.x], 0u, local_id.x >= max_index);
    sh[local_id.x] = count;
        for (var i = 0u; i < firstTrailingBit(WG_SIZE); i += 1u) {
        workgroupBarrier();
        if local_id.x >= 1u << i {
            let other = sh[local_id.x - (1u << i)];
            count = count + other;
        }
        workgroupBarrier();
        sh[local_id.x] = count;
    }
    workgroupBarrier();
    count = select(count, 0u, local_id.x >= max_index);
    export_buffer[local_id.x] = count;
}