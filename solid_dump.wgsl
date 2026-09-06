(def solid-sim-wgsl
  (String.append wgsl-tag-constants "

struct Uniforms {
    time: f32,
    width: f32,
    height: f32,
    brush_radius: f32,
    cam_pos: vec4<f32>,
    cam_dir: vec4<f32>,
    cam_right: vec4<f32>,
    cam_up: vec4<f32>,
    sun_dir: vec4<f32>,
    hit_pos: vec4<f32>,
    edit_params: vec4<f32>,
    solid_params: vec4<f32>,
}

@group(0) @binding(0) var<storage, read>       input_buffer: array<vec4<f32>>;
@group(0) @binding(1) var<storage, read_write> output_buffer: array<vec4<f32>>;
@group(0) @binding(2) var<uniform>             u: Uniforms;
@group(0) @binding(3) var<storage, read_write> solid_buffer: array<vec4<f32>>;
@group(0) @binding(4) var<storage, read>       registry_data: array<u32>;
@group(0) @binding(5) var solid_texture:       texture_3d<f32>;
@group(0) @binding(6) var liquid_texture:      texture_3d<f32>;
@group(0) @binding(7) var gas_texture:         texture_3d<f32>;

fn positive_mod(n: i32, m: i32) -> i32 {
    let r = n % m;
    if (r < 0) {
        return r + m;
    }
    return r;
}

fn get_world_pos(ip: vec3<i32>, cam_pos: vec3<f32>) -> vec3<f32> {
    let cx = i32(floor(cam_pos.x / 32.0));
    let cy = i32(floor(cam_pos.y / 32.0));
    let cz = i32(floor(cam_pos.z / 32.0));
    
    let offset_cx = cx - 2;
    let offset_cy = cy - 2;
    let offset_cz = cz - 2;
    
    let slot_x = ip.x / 32;
    let slot_y = ip.y / 32;
    let slot_z = ip.z / 32;
    
    let lx = ip.x % 32;
    let ly = ip.y % 32;
    let lz = ip.z % 32;
    
    let qx = offset_cx + positive_mod(slot_x - positive_mod(offset_cx, 5), 5);
    let qy = offset_cy + positive_mod(slot_y - positive_mod(offset_cy, 5), 5);
    let qz = offset_cz + positive_mod(slot_z - positive_mod(offset_cz, 5), 5);
    
    let gx = qx * 32 + lx;
    let gy = qy * 32 + ly;
    let gz = qz * 32 + lz;
    
    return vec3<f32>(f32(gx), f32(gy), f32(gz));
}

fn get_solid(p: vec3<i32>) -> vec4<f32> {
    let wrapped = (p + vec3<i32>(160)) % 160;
    let s_idx = u32(wrapped.x) + u32(wrapped.y) * 160u + u32(wrapped.z) * 25600u;
    return input_buffer[s_idx];
}

@compute @workgroup_size(64)
fn main(@builtin(global_invocation_id) global_id: vec3<u32>) {
    let idx = global_id.x;
    if (idx >= 4096000u) { return; }

    let x = idx % 160u;
    let y = (idx / 160u) % 160u;
    let z = idx / 25600u;
    let ip = vec3<i32>(i32(x), i32(y), i32(z));

    let self_sol = get_solid(ip);
    let self_vol = self_sol.y;
    var next_id = self_sol.x;
    var next_vol = self_vol;
    var next_age = self_sol.z;
    var next_sleep = self_sol.w;

    let dummy_val = u.time + solid_buffer[0].x + vec4<f32>(bitcast<f32>(registry_data[0])).x + textureLoad(solid_texture, vec3<i32>(0), 0).x + textureLoad(liquid_texture, vec3<i32>(0), 0).x + textureLoad(gas_texture, vec3<i32>(0), 0).x;
    if (dummy_val < -99999.0) { return; }

    if (next_sleep >= 10.0) {
        let n1 = get_solid(ip + vec3<i32>(-1,0,0)).w;
        let n2 = get_solid(ip + vec3<i32>(1,0,0)).w;
        let n3 = get_solid(ip + vec3<i32>(0,-1,0)).w;
        let n4 = get_solid(ip + vec3<i32>(0,1,0)).w;
        let n5 = get_solid(ip + vec3<i32>(0,0,-1)).w;
        let n6 = get_solid(ip + vec3<i32>(0,0,1)).w;
        // Wake up if the mouse is clicking (u.hit_pos.w == 1.0)
        if (n1 >= 10.0 && n2 >= 10.0 && n3 >= 10.0 && n4 >= 10.0 && n5 >= 10.0 && n6 >= 10.0 && u.hit_pos.w == 0.0) {
             output_buffer[idx] = self_sol;
             return;
        }
    }

    // --- Falling Sand Gravity Logic (SDF-Safe) ---
    let g_dir = vec3<i32>(0, -1, 0); 

    // 1. If we are EMPTY (positive SDF), check if sand wants to fall into us
    if (self_vol > 0.0) {
        let neighbor_ip = ip - g_dir;
        let neighbor_sol = get_solid(neighbor_ip);
        
        // If there is FALLING sand above us (negative SDF AND negative Material ID)
        if (neighbor_sol.y <= 0.0 && neighbor_sol.x < 0.0) {
            next_id = neighbor_sol.x;
            next_vol = neighbor_sol.y; // Become solid (negative)
            next_age = neighbor_sol.z;
            next_sleep = 0.0; // Wake up!
        }
    } 
    // 2. If we are FALLING SAND (negative SDF AND negative Material ID), check if we should fall
    else if (self_vol <= 0.0 && self_sol.x < 0.0) {
        let neighbor_ip = ip + g_dir;
        let neighbor_sol = get_solid(neighbor_ip);
        
        // If the space below us is empty (positive SDF)
        if (neighbor_sol.y > 0.0) {
            next_id = 0.0;
            next_vol = 0.5; // Become empty (positive)
            next_age = 0.0;
            next_sleep = 0.0; // Stay awake to process emptiness
        }
    }

    if (abs(next_vol - self_vol) < 0.001) {
        next_sleep = min(next_sleep + 1.0, 10.0);
    } else {
        next_sleep = 0.0;
    }
    
    if (next_vol <= 0.0 && next_id < 0.0 && next_sleep >= 10.0) {
        next_id = abs(next_id);
    }
    
    if (next_vol > 0.0) {
        next_age = next_age + 1.0;
    } else {
        next_age = 0.0;
    }

    // 3. Carve and Build natively on the GPU (Proper SDF Math)
    if (u.hit_pos.w > 0.5) {
        let world_pos = get_world_pos(ip, u.cam_pos.xyz);
        let dist = distance(world_pos, u.hit_pos.xyz);
        
        if (u.solid_params.x > 998.0) { // Carving (Intersection)
            if (dist <= u.brush_radius + 4.0) {
                let carve_val = u.brush_radius - dist;
                if (carve_val > next_vol) {
                    next_vol = carve_val;
                    if (next_vol > 0.0) {
                        next_id = 0.0;
                    }
                }
            }
        } else if (u.solid_params.x > 0.0) { // Spawning Rigid (Union)
            if (dist <= u.brush_radius + 4.0) {
                let build_val = dist - u.brush_radius;
                if (build_val < next_vol) {
                    next_vol = build_val;
                    if (next_vol <= 0.0) {
                        next_id = u.solid_params.x;
                    }
                }
            }
        } else if (u.solid_params.x < 0.0) { // Spawning CA (Discrete)
            if (dist <= u.brush_radius) {
                next_vol = -0.5;
                next_id = u.solid_params.x;
                next_sleep = 0.0;
            }
        }
    }

    output_buffer[idx] = vec4<f32>(next_id, next_vol, next_age, next_sleep);
}
"))

