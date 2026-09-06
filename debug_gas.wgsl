
const TAG_FLAMMABLE: u32 = 1u;
const TAG_IGNITER: u32 = 2u;
const TAG_EXPLOSIVE: u32 = 4u;
const TAG_MELTABLE: u32 = 8u;
const TAG_FREEZABLE: u32 = 16u;
const TAG_EVAPORABLE: u32 = 32u;
const TAG_CORRODIBLE: u32 = 64u;
const TAG_ACIDIC: u32 = 128u;
const TAG_SOLUBLE: u32 = 256u;
const TAG_CONDUCTIVE: u32 = 512u;
const TAG_SHOCKING: u32 = 1024u;
const TAG_GRANULAR: u32 = 2048u;
const TAG_LIGHT_FLUID: u32 = 4096u;
const TAG_HEAVY_GAS: u32 = 8192u;
const TAG_BRITTLE: u32 = 16384u;
const TAG_TOXIC: u32 = 32768u;
const TAG_HEALING: u32 = 65536u;
const TAG_RADIOACTIVE: u32 = 131072u;
const TAG_SLIPPERY: u32 = 262144u;
const TAG_STICKY: u32 = 524288u;
const TAG_BREATHABLE: u32 = 1048576u;
const TAG_LUMINESCENT: u32 = 2097152u;
const TAG_TRANSPARENT: u32 = 4194304u;
const TAG_EXTINGUISHER: u32 = 8388608u;
const TAG_INDESTRUCTIBLE: u32 = 16777216u;
const TAG_ANTI_GRAVITY: u32 = 33554432u;
const TAG_BOUNCY: u32 = 67108864u;
const TAG_ABSORBENT: u32 = 134217728u;
const TAG_DISSIPATES: u32 = 268435456u;
const TAG_ORGANIC: u32 = 536870912u;
const TAG_MAGNETIC: u32 = 1073741824u;
const TAG_STAINABLE: u32 = 2147483648u;

fn get_mat_tags(id: f32, cat: u32) -> u32 {
    if (id < 0.5) { return 0u; }
    let mat_id = clamp(u32(round(id)), 0u, 255u);
    return bitcast<u32>(materials[cat + mat_id].tags);
}
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


struct Material {
    id: f32,
    r: f32,
    g: f32,
    b: f32,
    a: f32,
    density: f32,
    toughness: f32,
    tags: u32,
}

const TAG_FLAMMABLE: u32 = 1u;
const TAG_IGNITER: u32 = 2u;
const TAG_EXPLOSIVE: u32 = 4u;
const TAG_MELTABLE: u32 = 8u;
const TAG_FREEZABLE: u32 = 16u;
const TAG_EVAPORABLE: u32 = 32u;
const TAG_CORRODIBLE: u32 = 64u;
const TAG_ACIDIC: u32 = 128u;
const TAG_SOLUBLE: u32 = 256u;
const TAG_CONDUCTIVE: u32 = 512u;
const TAG_SHOCKING: u32 = 1024u;
const TAG_GRANULAR: u32 = 2048u;
const TAG_LIGHT_FLUID: u32 = 4096u;
const TAG_HEAVY_GAS: u32 = 8192u;
const TAG_BRITTLE: u32 = 16384u;
const TAG_TOXIC: u32 = 32768u;
const TAG_HEALING: u32 = 65536u;
const TAG_RADIOACTIVE: u32 = 131072u;
const TAG_SLIPPERY: u32 = 262144u;
const TAG_STICKY: u32 = 524288u;
const TAG_BREATHABLE: u32 = 1048576u;
const TAG_LUMINESCENT: u32 = 2097152u;
const TAG_TRANSPARENT: u32 = 4194304u;
const TAG_EXTINGUISHER: u32 = 8388608u;
const TAG_INDESTRUCTIBLE: u32 = 16777216u;
const TAG_ANTI_GRAVITY: u32 = 33554432u;
const TAG_BOUNCY: u32 = 67108864u;
const TAG_ABSORBENT: u32 = 134217728u;
const TAG_DISSIPATES: u32 = 268435456u;
const TAG_ORGANIC: u32 = 536870912u;
const TAG_MAGNETIC: u32 = 1073741824u;
const TAG_STAINABLE: u32 = 2147483648u;

struct GasProps {
    g_rate: f32,
    l_rate: f32,
    decay: f32,
}

fn get_gas_props(id: f32) -> GasProps {
    if (id < 0.5) { return GasProps(0.0, 0.0, 0.0); }
    let mat_id = clamp(u32(round(id)), 0u, 255u);
    let mat = materials[512u + mat_id];
    let tags = bitcast<u32>(mat.tags);
    
    var g = min(1.0, 0.3 / max(mat.density, 0.1));
    var l = min(1.0, 0.15 / max(mat.density, 0.1));
    var dec = 0.0;
    if ((tags & TAG_DISSIPATES) != 0u) {
        dec = 0.015;
    }
    if ((tags & TAG_HEAVY_GAS) != 0u) {
        g = -g; // Sinks instead of rises
    }
    return GasProps(g, l, dec);
}

@group(0) @binding(0) var<storage, read>       input_buffer: array<vec4<f32>>;
@group(0) @binding(1) var<storage, read_write> output_buffer: array<vec4<f32>>;
@group(0) @binding(2) var<uniform>             u: Uniforms;
@group(0) @binding(3) var<storage, read>       chunk_info: array<vec4<f32>>;
@group(0) @binding(4) var<storage, read>       materials: array<Material>;
@group(0) @binding(5) var solid_texture:       texture_3d<f32>;
@group(0) @binding(6) var liquid_texture:      texture_3d<f32>;
@group(0) @binding(7) var gas_texture:         texture_3d<f32>;

fn get_solid(p: vec3<i32>) -> vec4<f32> {
    let wrapped = (p + vec3<i32>(160)) % 160;
    let val = textureLoad(solid_texture, wrapped, 0);
    return val;
}

fn is_solid(p: vec3<i32>) -> bool {
    let sol = get_solid(p);
    return sol.y * 0.5 < 0.008;
}

fn get_gas(p: vec3<i32>) -> vec4<f32> {
    let wrapped = (p + vec3<i32>(160)) % 160;
    let val = textureLoad(gas_texture, wrapped, 0);
    return val;
}

fn get_liquid(p: vec3<i32>) -> vec4<f32> {
    let wrapped = (p + vec3<i32>(160)) % 160;
    let val = textureLoad(liquid_texture, wrapped, 0);
    return val;
}

fn is_explosion_center(p: vec3<i32>) -> bool {
    let g = get_gas(p);
    if (g.x == 2.0 && g.y > 0.1) {
        let dirs = array<vec3<i32>, 6>(
            vec3<i32>(-1, 0, 0), vec3<i32>(1, 0, 0),
            vec3<i32>(0, -1, 0), vec3<i32>(0, 1, 0),
            vec3<i32>(0, 0, -1), vec3<i32>(0, 0, 1)
        );
        for (var i = 0; i < 6; i = i + 1) {
            let np = p + dirs[i];
            let n_gas = get_gas(np);
            if (n_gas.x == 3.0 && n_gas.y > 0.1) {
                return true;
            }
            let n_liq = get_liquid(np);
            if (n_liq.x == 2.0 && n_liq.y > 0.1) {
                return true;
            }
        }
    }
    return false;
}

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

@compute @workgroup_size(64)
fn main(@builtin(global_invocation_id) global_id: vec3<u32>) {
    let idx = global_id.x;
    if (idx >= 4096000u) { return; }

    // Dummy reads to prevent compiler from optimizing out unused bindings
    let dummy_val = input_buffer[0] + chunk_info[0] + vec4<f32>(materials[0].id);
    if (dummy_val.x > 999999.0) {
        output_buffer[idx] = textureLoad(liquid_texture, vec3<i32>(0), 0);
    }

    let x = idx % 160u;
    let y = (idx / 160u) % 160u;
    let z = idx / 25600u;
    let ip = vec3<i32>(i32(x), i32(y), i32(z));

    if (is_solid(ip)) {
        output_buffer[idx] = vec4<f32>(0.0, 0.0, 0.0, 10.0);
        return;
    }

    let self_gas = get_gas(ip);
    let self_vol = self_gas.y;
    var next_id = self_gas.x;
    var next_vol = self_vol;
    var next_age = self_gas.z;
    var next_sleep = self_gas.w;
    
    if (next_sleep >= 10.0) {
        let n1 = get_gas(ip + vec3<i32>(-1,0,0)).w;
        let n2 = get_gas(ip + vec3<i32>(1,0,0)).w;
        let n3 = get_gas(ip + vec3<i32>(0,-1,0)).w;
        let n4 = get_gas(ip + vec3<i32>(0,1,0)).w;
        let n5 = get_gas(ip + vec3<i32>(0,0,-1)).w;
        let n6 = get_gas(ip + vec3<i32>(0,0,1)).w;
        let my_liq = get_liquid(ip).w;
        if (n1 >= 10.0 && n2 >= 10.0 && n3 >= 10.0 && n4 >= 10.0 && n5 >= 10.0 && n6 >= 10.0 && my_liq >= 10.0 && u.edit_params.w == 0.0) {
             output_buffer[idx] = self_gas;
             return;
        }
    }

    let below_p = ip + vec3<i32>(0, -1, 0);
    let above_p = ip + vec3<i32>(0, 1, 0);

    let neighbors = array<vec3<i32>, 4>(
        vec3<i32>(-1, 0, 0),
        vec3<i32>(1, 0, 0),
        vec3<i32>(0, 0, -1),
        vec3<i32>(0, 0, 1)
    );

    let self_props = get_gas_props(self_gas.x);
    let g_rate = self_props.g_rate;
    let l_rate = self_props.l_rate;

    var net_flow = 0.0;
    var max_inflow = 0.0;

    // --- 1. Upward rising flow ---
    // Flow out to above
    if (!is_solid(above_p)) {
        let above = get_gas(above_p);
        let flow_out = min(self_vol, max(0.0, 1.0 - above.y)) * g_rate;
        net_flow -= flow_out;
    }
    // Flow in from below
    if (!is_solid(below_p)) {
        let below = get_gas(below_p);
        let below_props = get_gas_props(below.x);
        let flow_in = min(below.y, max(0.0, 1.0 - self_vol)) * below_props.g_rate;
        net_flow += flow_in;
        if (flow_in > max_inflow) {
            max_inflow = flow_in;
            next_id = below.x;
        }
    }

    // --- 2. Lateral flow ---
    for (var i = 0; i < 4; i = i + 1) {
        let np = ip + neighbors[i];
        if (!is_solid(np)) {
            let n_gas = get_gas(np);
            let n_props = get_gas_props(n_gas.x);
            // Flow out to neighbor if we have more
            if (self_vol > n_gas.y) {
                let flow_out = (self_vol - n_gas.y) * l_rate;
                net_flow -= flow_out;
            }
            // Flow in from neighbor if it has more
            if (n_gas.y > self_vol) {
                let flow_in = (n_gas.y - self_vol) * n_props.l_rate;
                net_flow += flow_in;
                if (flow_in > max_inflow) {
                    max_inflow = flow_in;
                    next_id = n_gas.x;
                }
            }
        }
    }

    next_vol = next_vol + net_flow;

    // --- 3. Spawn gas if click is active ---
    if (u.hit_pos.w > 0.5) {
        let world_pos = get_world_pos(ip, u.cam_pos.xyz);
        let dist = distance(world_pos, u.hit_pos.xyz);
        if (dist <= u.brush_radius && u.edit_params.z > 0.5) {
            next_id = u.edit_params.z;
            next_vol = min(1.0, next_vol + u.edit_params.w);
        }
    }

    // --- 4. Multi-Phase Gas Reactions ---
    var spawn_gas_id = 0.0;
    var spawn_gas_vol = 0.0;

    let my_liq = get_liquid(ip);
    let below_liq = get_liquid(below_p);
    let above_liq = get_liquid(above_p);
    if (my_liq.y > 0.05) {
        if (my_liq.x == 1.0) { // Water
            for (var i = 0; i < 4; i = i + 1) {
                let n_liq = get_liquid(ip + neighbors[i]);
                if (n_liq.y > 0.05 && n_liq.x == 2.0) { spawn_gas_id = 1.0; spawn_gas_vol = 1.0; break; }
            }
            if (below_liq.y > 0.05 && below_liq.x == 2.0) { spawn_gas_id = 1.0; spawn_gas_vol = 1.0; }
            if (above_liq.y > 0.05 && above_liq.x == 2.0) { spawn_gas_id = 1.0; spawn_gas_vol = 1.0; }
        } else if (my_liq.x == 2.0) { // Lava
            // Steam
            for (var i = 0; i < 4; i = i + 1) {
                let n_liq = get_liquid(ip + neighbors[i]);
                if (n_liq.y > 0.05 && n_liq.x == 1.0) { spawn_gas_id = 1.0; spawn_gas_vol = 1.0; break; }
            }
            if (below_liq.y > 0.05 && below_liq.x == 1.0) { spawn_gas_id = 1.0; spawn_gas_vol = 1.0; }
            if (above_liq.y > 0.05 && above_liq.x == 1.0) { spawn_gas_id = 1.0; spawn_gas_vol = 1.0; }
            
            // Fire/Smoke from Lava + Oil
            for (var i = 0; i < 4; i = i + 1) {
                let n_liq = get_liquid(ip + neighbors[i]);
                if (n_liq.y > 0.05 && n_liq.x == 4.0) { spawn_gas_id = 3.0; spawn_gas_vol = 1.0; break; }
            }
            if (below_liq.y > 0.05 && below_liq.x == 4.0) { spawn_gas_id = 3.0; spawn_gas_vol = 1.0; }
            if (above_liq.y > 0.05 && above_liq.x == 4.0) { spawn_gas_id = 3.0; spawn_gas_vol = 1.0; }
            
            // Fire/Smoke from Lava + Wood (Solid 3)
            for (var i = 0; i < 4; i = i + 1) {
                let sol = get_solid(ip + neighbors[i]);
                let is_sol_block = sol.y * 0.5 < 0.008;
                if (is_sol_block && sol.x == 3.0) { spawn_gas_id = 3.0; spawn_gas_vol = 1.0; break; }
            }
            let below_sol = get_solid(below_p);
            if (below_sol.y * 0.5 < 0.008 && below_sol.x == 3.0) { spawn_gas_id = 3.0; spawn_gas_vol = 1.0; }
            let above_sol = get_solid(above_p);
            if (above_sol.y * 0.5 < 0.008 && above_sol.x == 3.0) { spawn_gas_id = 3.0; spawn_gas_vol = 1.0; }
        } else if (my_liq.x == 3.0) { // Acid
            // Toxic Gas from Acid + Grass/Wood/Stone
            var acid_react = false;
            for (var i = 0; i < 4; i = i + 1) {
                let sol = get_solid(ip + neighbors[i]);
                if (sol.y * 0.5 < 0.008 && (sol.x == 1.0 || sol.x == 2.0 || sol.x == 3.0)) { acid_react = true; break; }
            }
            let below_sol = get_solid(below_p);
            if (below_sol.y * 0.5 < 0.008 && (below_sol.x == 1.0 || below_sol.x == 2.0 || below_sol.x == 3.0)) { acid_react = true; }
            let above_sol = get_solid(above_p);
            if (above_sol.y * 0.5 < 0.008 && (above_sol.x == 1.0 || above_sol.x == 2.0 || above_sol.x == 3.0)) { acid_react = true; }
            
            if (acid_react) {
                spawn_gas_id = 2.0; // Toxic Gas
                spawn_gas_vol = 1.0;
            }
        }
    }

    // Fire + Water ➔ Steam
    if (next_id == 3.0 && next_vol > 0.05) {
        var touches_water = false;
        if (my_liq.y > 0.05 && my_liq.x == 1.0) { touches_water = true; }
        for (var i = 0; i < 4; i = i + 1) {
            let n_liq = get_liquid(ip + neighbors[i]);
            if (n_liq.y > 0.05 && n_liq.x == 1.0) { touches_water = true; break; }
        }
        let below_liq = get_liquid(below_p);
        if (below_liq.y > 0.05 && below_liq.x == 1.0) { touches_water = true; }
        let above_liq = get_liquid(above_p);
        if (above_liq.y > 0.05 && above_liq.x == 1.0) { touches_water = true; }
        
        if (touches_water) {
            next_id = 1.0; // Steam
            next_vol = 0.5;
        }
    }

    // --- 4d. Spawn Steam/Smoke in Air adjacent to reactions ---
    var reaction_spawn_id = 0.0;
    var reaction_spawn_vol = 0.0;
    
    let dirs6 = array<vec3<i32>, 6>(
        vec3<i32>(-1, 0, 0), vec3<i32>(1, 0, 0),
        vec3<i32>(0, -1, 0), vec3<i32>(0, 1, 0),
        vec3<i32>(0, 0, -1), vec3<i32>(0, 0, 1)
    );
    
    for (var i = 0; i < 6; i = i + 1) {
        let np = ip + dirs6[i];
        let n_liq = get_liquid(np);
        if (n_liq.y > 0.05) {
            if (n_liq.x == 2.0) { // Neighbor has Lava
                var touches_water = false;
                var touches_oil = false;
                for (var j = 0; j < 6; j = j + 1) {
                    let nnp = np + dirs6[j];
                    let nn_liq = get_liquid(nnp);
                    if (nn_liq.y > 0.05) {
                        if (nn_liq.x == 1.0) { touches_water = true; }
                        if (nn_liq.x == 4.0) { touches_oil = true; }
                    }
                }
                if (touches_water) {
                    reaction_spawn_id = 1.0; // Steam
                    reaction_spawn_vol = 1.0;
                } else if (touches_oil) {
                    reaction_spawn_id = 4.0; // Smoke
                    reaction_spawn_vol = 1.0;
                }
            } else if (n_liq.x == 1.0) { // Neighbor has Water
                var touches_lava = false;
                for (var j = 0; j < 6; j = j + 1) {
                    let nnp = np + dirs6[j];
                    let nn_liq = get_liquid(nnp);
                    if (nn_liq.y > 0.05 && nn_liq.x == 2.0) { touches_lava = true; }
                }
                if (touches_lava) {
                    reaction_spawn_id = 1.0; // Steam
                    reaction_spawn_vol = 1.0;
                }
            } else if (n_liq.x == 4.0) { // Neighbor has Oil
                var touches_lava = false;
                for (var j = 0; j < 6; j = j + 1) {
                    let nnp = np + dirs6[j];
                    let nn_liq = get_liquid(nnp);
                    if (nn_liq.y > 0.05 && nn_liq.x == 2.0) { touches_lava = true; }
                }
                if (touches_lava) {
                    reaction_spawn_id = 4.0; // Smoke
                    reaction_spawn_vol = 1.0;
                }
            }
        }
    }
    
    if (reaction_spawn_vol > 0.0) {
        spawn_gas_id = reaction_spawn_id;
        spawn_gas_vol = reaction_spawn_vol;
    }

    if (spawn_gas_vol > 0.0) {
        next_id = spawn_gas_id;
        next_vol = min(1.0, next_vol + spawn_gas_vol);
    }

    // --- 4b. Explosion Propagation ---
    var in_explosion = false;
    if (is_explosion_center(ip)) {
        in_explosion = true;
    } else {
        for (var i = 0; i < 4; i = i + 1) {
            if (is_explosion_center(ip + neighbors[i])) { in_explosion = true; break; }
        }
        if (is_explosion_center(below_p) || is_explosion_center(above_p)) {
            in_explosion = true;
        }
    }
    if (in_explosion) {
        next_id = 3.0; // Fire
        next_vol = 1.0;
    }

    // --- 4c. Wood/Coal Burning Spawning Fire/Smoke ---
    if (next_id == 0.0 || next_id == 4.0) { // Empty or Smoke
        var spawn_fire = false;
        let dirs = array<vec3<i32>, 6>(
            vec3<i32>(-1, 0, 0), vec3<i32>(1, 0, 0),
            vec3<i32>(0, -1, 0), vec3<i32>(0, 1, 0),
            vec3<i32>(0, 0, -1), vec3<i32>(0, 0, 1)
        );
        for (var i = 0; i < 6; i = i + 1) {
            let np = ip + dirs[i];
            let sol = get_solid(np);
            let is_sol_block = sol.y * 0.5 < 0.008;
            if (is_sol_block && (sol.x == 3.0 || sol.x == 4.0)) { // Wood/Coal
                // Check if this solid block touches fire or lava
                for (var j = 0; j < 6; j = j + 1) {
                    let nnp = np + dirs[j];
                    let g = get_gas(nnp);
                    if (g.x == 3.0 && g.y > 0.1) { spawn_fire = true; break; }
                    let l = get_liquid(nnp);
                    if (l.x == 2.0 && l.y > 0.1) { spawn_fire = true; break; }
                }
            }
            if (spawn_fire) { break; }
        }
        if (spawn_fire) {
            let rand_val = fract(sin(dot(vec3<f32>(ip) + vec3<f32>(u.time), vec3<f32>(12.9898, 78.233, 45.164))) * 43758.5453);
            if (rand_val < 0.4) {
                next_id = 4.0; // Smoke
                next_vol = 0.8;
            } else {
                next_id = 3.0; // Fire
                next_vol = 1.0;
            }
        }
    }

    // Steam condensation on ceiling
    if (next_id == 1.0 && next_vol > 0.05) {
        if (is_solid(above_p)) {
            next_vol = max(0.0, next_vol - 0.02);
        }
    }

    // --- 5. Evaporate, decay and clamp ---
    let next_props = get_gas_props(next_id);
    next_vol = max(0.0, next_vol - next_props.decay);

    if (next_vol < 0.01) {
        next_vol = 0.0;
        next_id = 0.0;
    }
    
    next_vol = clamp(next_vol, 0.0, 1.0);
    if (next_vol == 0.0) {
        next_id = 0.0;
    }

    if (abs(next_vol - self_vol) < 0.001) {
        next_sleep = min(next_sleep + 1.0, 10.0);
    } else {
        next_sleep = 0.0;
    }
    

    
    if (next_vol > 0.0) {
        next_age = next_age + 1.0;
    } else {
        next_age = 0.0;
    }

    output_buffer[idx] = vec4<f32>(next_id, next_vol, next_age, next_sleep);
}
