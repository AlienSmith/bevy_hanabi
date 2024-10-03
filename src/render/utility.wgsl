
@group(0) @binding(0)
var<storage, read_write> export_buffer : array<u32>;

@group(0) @binding(1)
var<uniform> max_index : u32;

const WG_SIZE = 256u;

var<workgroup> sh: array<u32, WG_SIZE>;

@compute @workgroup_size(256)
fn main(@builtin(local_invocation_id) local_id: vec3<u32>) {
    let value = export_buffer[local_id.x];
    var count = select(0u, 65536u - value, value != 0u);
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
    export_buffer[local_id.x] = count;
}