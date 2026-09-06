
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

struct LiquidProps {
    density: f32,
    g_rate: f32,
    l_rate: f32,
}

fn get_liq_props(id: f32) -> LiquidProps {
    if (id < 0.5) { return LiquidProps(0.0, 0.0, 0.0); }
    let mat_id = clamp(u32(round(id)), 0u, 255u);
    let mat = materials[256u + mat_id];
    let tags = bitcast<u32>(mat.tags);
    
    var g = min(1.0, 0.4 / max(mat.density, 0.1));
    var l = min(1.0, 0.2 / max(mat.density, 0.1));
    if ((tags & TAG_STICKY) != 0u) {
        g = g * 0.05;
        l = l * 0.02;
    }
    return LiquidProps(mat.density, g, l);
}

@group(0) @binding(0) var<storage, read>       input_buffer: array<vec4<f32>>;
@group(0) @binding(1) var<storage, read_write> output_buffer: array<vec4<f32>>;
@group(0) @binding(2) var<uniform>             u: Uniforms;
@group(0) @binding(3) var<storage, read_write> solid_buffer: array<vec4<f32>>;
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

fn get_liquid(p: vec3<i32>) -> vec4<f32> {
    let wrapped = (p + vec3<i32>(160)) % 160;
    let val = textureLoad(liquid_texture, wrapped, 0);
    return val;
}

fn get_gas(p: vec3<i32>) -> vec4<f32> {
    let wrapped = (p + vec3<i32>(160)) % 160;
    let val = textureLoad(gas_texture, wrapped, 0);
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
    let dummy_val = input_buffer[0] + solid_buffer[0] + vec4<f32>(materials[0].id);
    if (dummy_val.x > 999999.0) {
        output_buffer[idx] = textureLoad(gas_texture, vec3<i32>(0), 0);
    }

    let x = idx % 160u;
    let y = (idx / 160u) % 160u;
    let z = idx / 25600u;
    let ip = vec3<i32>(i32(x), i32(y), i32(z));

    // --- 0. Explosion Carving (runs only at the center of explosions) ---
    if (is_explosion_center(ip)) {
        for (var dx = -3; dx <= 3; dx = dx + 1) {
            for (var dy = -3; dy <= 3; dy = dy + 1) {
                for (var dz = -3; dz <= 3; dz = dz + 1) {
                    let tp = ip + vec3<i32>(dx, dy, dz);
                    let d = distance(vec3<f32>(ip), vec3<f32>(tp));
                    if (d <= 3.5) {
                        let wrapped = (tp + vec3<i32>(160)) % 160;
                        let s_idx = u32(wrapped.x) + u32(wrapped.y) * 160u + u32(wrapped.z) * 25600u;
                        solid_buffer[s_idx] = vec4<f32>(0.0, 1.0, 0.0, 0.0); // Clear solid block!
                    }
                }
            }
        }
    }

    let sol_val = get_solid(ip);
    let sol_id = sol_val.x;
    let is_sol_block = sol_val.y * 0.5 < 0.008;
    if (is_sol_block) {
        // Wood (3.0) or Coal (4.0) catches fire and burns away
        if (sol_id == 3.0 || sol_id == 4.0) {
            var touches_fire = false;
            let dirs = array<vec3<i32>, 6>(
                vec3<i32>(-1, 0, 0), vec3<i32>(1, 0, 0),
                vec3<i32>(0, -1, 0), vec3<i32>(0, 1, 0),
                vec3<i32>(0, 0, -1), vec3<i32>(0, 0, 1)
            );
            for (var i = 0; i < 6; i = i + 1) {
                let np = ip + dirs[i];
                let g = get_gas(np);
                if (g.x == 3.0 && g.y > 0.1) { touches_fire = true; break; }
                let l = get_liquid(np);
                if (l.x == 2.0 && l.y > 0.1) { touches_fire = true; break; }
            }
            if (touches_fire) {
                let rand_val = fract(sin(dot(vec3<f32>(ip) + vec3<f32>(u.time), vec3<f32>(12.9898, 78.233, 45.164))) * 43758.5453);
                var burn_chance = 0.01; // Wood (1% chance per frame = ~1.6 seconds average)
                if (sol_id == 4.0) {
                    burn_chance = 0.002; // Coal (0.2% chance per frame = ~8.3 seconds average)
                }
                if (rand_val < burn_chance) {
                    solid_buffer[idx] = vec4<f32>(0.0, 1.0, 0.0, 0.0);
                }
            }
        }
        output_buffer[idx] = vec4<f32>(0.0);
        return;
    }

    let self_liq = get_liquid(ip);
    let self_vol = self_liq.y;
    var next_id = self_liq.x;
    var next_vol = self_vol;
    var next_age = self_liq.z;
    var next_sleep = self_liq.w;
    
    if (next_sleep >= 10.0) {
        let n1 = get_liquid(ip + vec3<i32>(-1,0,0)).w;
        let n2 = get_liquid(ip + vec3<i32>(1,0,0)).w;
        let n3 = get_liquid(ip + vec3<i32>(0,-1,0)).w;
        let n4 = get_liquid(ip + vec3<i32>(0,1,0)).w;
        let n5 = get_liquid(ip + vec3<i32>(0,0,-1)).w;
        let n6 = get_liquid(ip + vec3<i32>(0,0,1)).w;
        let my_gas = get_gas(ip).w;
        if (n1 >= 10.0 && n2 >= 10.0 && n3 >= 10.0 && n4 >= 10.0 && n5 >= 10.0 && n6 >= 10.0 && my_gas >= 10.0 && u.edit_params.y == 0.0) {
             output_buffer[idx] = self_liq;
             return;
        }
    }

    let self_props = get_liq_props(self_liq.x);

    let below_p = ip + vec3<i32>(0, -1, 0);
    let above_p = ip + vec3<i32>(0, 1, 0);

    let neighbors = array<vec3<i32>, 4>(
        vec3<i32>(-1, 0, 0),
        vec3<i32>(1, 0, 0),
        vec3<i32>(0, 0, -1),
        vec3<i32>(0, 0, 1)
    );

    // --- 1. Density Buoyancy Swapping (1-to-1 parity matching) ---
    var swapped = false;
    let frame_step = i32(u.time) % 2;
    let is_even_pair = (ip.y % 2) == frame_step;

    if (self_vol > 0.05) {
        if (is_even_pair) {
            // Look down
            if (ip.y > 0 && !is_solid(below_p)) {
                let below = get_liquid(below_p);
                let below_props = get_liq_props(below.x);
                if (below.y > 0.05 && self_props.density > below_props.density) {
                    next_id = below.x;
                    next_vol = below.y;
                    swapped = true;
                }
            }
        } else {
            // Look up
            if (ip.y < 159 && !is_solid(above_p)) {
                let above = get_liquid(above_p);
                let above_props = get_liq_props(above.x);
                if (above.y > 0.05 && above_props.density > self_props.density) {
                    next_id = above.x;
                    next_vol = above.y;
                    swapped = true;
                }
            }
        }
    }

    // --- 2. Gravity & Lateral Flow (only calculated if not swapped) ---
    var net_flow = 0.0;
    var max_inflow = 0.0;

    if (!swapped) {
        let g_rate = self_props.g_rate;
        let l_rate = self_props.l_rate;

        // Downward gravity flow
        if (!is_solid(below_p)) {
            let below = get_liquid(below_p);
            let below_props = get_liq_props(below.x);
            if (below.y <= 0.05 || self_props.density >= below_props.density) {
                let flow_out = min(self_vol, max(0.0, 1.0 - below.y)) * g_rate;
                net_flow -= flow_out;
            }
        }
        if (!is_solid(above_p)) {
            let above = get_liquid(above_p);
            let above_props = get_liq_props(above.x);
            if (self_vol <= 0.05 || above_props.density >= self_props.density) {
                let flow_in = min(above.y, max(0.0, 1.0 - self_vol)) * above_props.g_rate;
                net_flow += flow_in;
                if (flow_in > max_inflow) {
                    max_inflow = flow_in;
                    next_id = above.x;
                }
            }
        }

        // Lateral flow
        for (var i = 0; i < 4; i = i + 1) {
            let np = ip + neighbors[i];
            if (!is_solid(np)) {
                let n_liq = get_liquid(np);
                let n_props = get_liq_props(n_liq.x);
                if (self_vol > n_liq.y && (n_liq.y <= 0.05 || self_props.density >= n_props.density)) {
                    let flow_out = (self_vol - n_liq.y) * l_rate;
                    net_flow -= flow_out;
                }
                if (n_liq.y > self_vol && (self_vol <= 0.05 || n_props.density >= self_props.density)) {
                    let flow_in = (n_liq.y - self_vol) * n_props.l_rate;
                    net_flow += flow_in;
                    if (flow_in > max_inflow) {
                        max_inflow = flow_in;
                        next_id = n_liq.x;
                    }
                }
            }
        }

        next_vol = next_vol + net_flow;
    }

    // --- 3. Spawn liquid if click is active ---
    if (u.hit_pos.w > 0.5) {
        let world_pos = get_world_pos(ip, u.cam_pos.xyz);
        let dist = distance(world_pos, u.hit_pos.xyz);
        if (dist <= u.brush_radius && u.edit_params.x > 0.5) {
            next_id = u.edit_params.x;
            next_vol = min(1.0, next_vol + u.edit_params.y);
        }
    }

    // --- 3.5. Steam condensation ---
    let my_gas = get_gas(ip);
    if (my_gas.x == 1.0 && my_gas.y > 0.05) {
        if (is_solid(above_p)) {
            if (next_vol <= 0.05 || next_id == 1.0) {
                next_id = 1.0; // Water
                next_vol = min(1.0, next_vol + 0.02);
            }
        }
    }

    // --- 4. Multi-Phase Reactions ---
    var react_empty = false;
    let below_liq = get_liquid(below_p);
    let above_liq = get_liquid(above_p);
    if (next_vol > 0.05) {
        if (next_id == 1.0) { // Water
            for (var i = 0; i < 4; i = i + 1) {
                let n_liq = get_liquid(ip + neighbors[i]);
                if (n_liq.y > 0.05 && n_liq.x == 2.0) { react_empty = true; break; }
            }
            if (below_liq.y > 0.05 && below_liq.x == 2.0) { react_empty = true; }
            if (above_liq.y > 0.05 && above_liq.x == 2.0) { react_empty = true; }
        } else if (next_id == 2.0) { // Lava
            // React with Water
            for (var i = 0; i < 4; i = i + 1) {
                let n_liq = get_liquid(ip + neighbors[i]);
                if (n_liq.y > 0.05 && n_liq.x == 1.0) { react_empty = true; break; }
            }
            if (below_liq.y > 0.05 && below_liq.x == 1.0) { react_empty = true; }
            if (above_liq.y > 0.05 && above_liq.x == 1.0) { react_empty = true; }

            // React with Oil
            for (var i = 0; i < 4; i = i + 1) {
                let n_liq = get_liquid(ip + neighbors[i]);
                if (n_liq.y > 0.05 && n_liq.x == 4.0) { react_empty = true; break; }
            }
            if (below_liq.y > 0.05 && below_liq.x == 4.0) { react_empty = true; }
            if (above_liq.y > 0.05 && above_liq.x == 4.0) { react_empty = true; }
        } else if (next_id == 3.0) { // Acid
            var touches_water = false;
            for (var i = 0; i < 4; i = i + 1) {
                let n_liq = get_liquid(ip + neighbors[i]);
                if (n_liq.y > 0.05 && n_liq.x == 1.0) { touches_water = true; break; }
            }
            if (below_liq.y > 0.05 && below_liq.x == 1.0) { touches_water = true; }
            if (above_liq.y > 0.05 && above_liq.x == 1.0) { touches_water = true; }

            if (touches_water) {
                next_id = 1.0; // Dilutes to Water
            } else {
                var dissolved_solid = false;
                let dirs = array<vec3<i32>, 6>(
                    vec3<i32>(-1, 0, 0), vec3<i32>(1, 0, 0),
                    vec3<i32>(0, -1, 0), vec3<i32>(0, 1, 0),
                    vec3<i32>(0, 0, -1), vec3<i32>(0, 0, 1)
                );
                for (var i = 0; i < 6; i = i + 1) {
                    let sp = ip + dirs[i];
                    if (sp.x >= 0 && sp.x < 160 && sp.y >= 0 && sp.y < 160 && sp.z >= 0 && sp.z < 160) {
                        let sol = get_solid(sp);
                        let is_sol_block = sol.y * 0.5 < 0.008;
                        let sol_id = sol.x;
                        if (is_sol_block) {
                            if (sol_id == 2.0 || sol_id == 3.0) { // Grass/Wood
                                dissolved_solid = true;
                                let s_idx = u32(sp.x) + u32(sp.y) * 160u + u32(sp.z) * 25600u;
                                solid_buffer[s_idx] = vec4<f32>(0.0, 1.0, 0.0, 0.0);
                                break;
                            } else if (sol_id == 1.0) { // Stone
                                let rand_val = fract(sin(dot(vec3<f32>(ip) + vec3<f32>(u.time), vec3<f32>(12.9898, 78.233, 45.164))) * 43758.5453);
                                if (rand_val < 0.02) { // 2% chance
                                    dissolved_solid = true;
                                    let s_idx = u32(sp.x) + u32(sp.y) * 160u + u32(sp.z) * 25600u;
                                    solid_buffer[s_idx] = vec4<f32>(0.0, 1.0, 0.0, 0.0);
                                    break;
                                }
                            }
                        }
                    }
                }
                if (dissolved_solid) {
                    react_empty = true;
                }
            }
        } else if (next_id == 4.0) { // Oil
            // Burned by Lava
            for (var i = 0; i < 4; i = i + 1) {
                let n_liq = get_liquid(ip + neighbors[i]);
                if (n_liq.y > 0.05 && n_liq.x == 2.0) { react_empty = true; break; }
            }
            if (below_liq.y > 0.05 && below_liq.x == 2.0) { react_empty = true; }
            if (above_liq.y > 0.05 && above_liq.x == 2.0) { react_empty = true; }
        }
    }

    // Vaporize liquid if next to an explosion
    var adjacent_to_explosion = false;
    if (is_explosion_center(ip)) {
        adjacent_to_explosion = true;
    } else {
        for (var i = 0; i < 4; i = i + 1) {
            if (is_explosion_center(ip + neighbors[i])) { adjacent_to_explosion = true; break; }
        }
        if (is_explosion_center(below_p) || is_explosion_center(above_p)) {
            adjacent_to_explosion = true;
        }
    }
    if (adjacent_to_explosion) {
        react_empty = true;
    }

    if (react_empty) {
        next_vol = 0.0;
        next_id = 0.0;
        // Turn into Solid Stone if it was a Lava/Water collision (and NOT an explosion!)
        if (!adjacent_to_explosion && (self_liq.x == 1.0 || self_liq.x == 2.0)) {
            solid_buffer[idx] = vec4<f32>(1.0, -1.0, 0.0, 0.0);
        }
    }

    // --- 5. Evaporate and clamp ---
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
    
    if (next_id == 5.0 && next_sleep >= 10.0 && next_vol > 0.05) {
        next_id = 0.0;
        next_vol = 0.0;
        let s_idx = u32(ip.x) + u32(ip.y) * 160u + u32(ip.z) * 25600u;
        solid_buffer[s_idx] = vec4<f32>(1.0, -0.5, 0.0, 0.0);
    }
    
    if (next_vol > 0.0) {
        next_age = next_age + 1.0;
    } else {
        next_age = 0.0;
    }

    output_buffer[idx] = vec4<f32>(next_id, next_vol, next_age, next_sleep);
}
