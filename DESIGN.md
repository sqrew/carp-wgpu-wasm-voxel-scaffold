# Subterranean Voxel Alchemy — Design Scratchpad

Core design north star: **tiny rules, massive simulation leverage**. Every player verb, creature, and plant should plug directly into the GPU voxel cellular automata, 3D structural stress field, luminescence GI, and rigidbody physics rather than living in isolated scripts.

---

## 1. Foundational Player Verbs

### Alchemical Flask *(v1 Shipped)*
- **Single-Element Siphon & Firehose**: `Right-Click` ("Big Succ") vacuums real cave pools and gas pockets into a locked, non-reacting bottle; `Left-Click` ("Squirt Till It Hurt") fires a gravity-arcing stream that splashes reactive voxels and blasts physics bodies backward; `X` purges/dumps.
- **Emergent Tech & Future Hooks**:
  - Sweeping/pulsing the stream hangs mid-air **"fluid ropes"** across chasms (great for mid-air Lava+Water stone bridges or gel arcs).
  - Holding `LUMINESCENT` reagents (**Lava**, **Acid**, **Ambrosia**, **Volatile Gel**, **Fire**) acts as a live colored hand-lantern in `field-sim-wgsl`.
  - *Later*: Multi-flask belt (`1–4`), **Throw Flask** (lob vial as a physics projectile that shatters on impact in a pressurized splash).

### Off-Hand Igniter ("Flint Snap")
- **Zero-Setup Detonator**: Always-available off-hand flick that tosses a tiny ballistic spark (`IGNITER` + spark particles) without needing to hunt down natural Lava first.
- **1–2 Combo Loop**: Hose a corridor in **Oil**, coat a pillar in **Volatile Gel**, or flood a ceiling pocket with **Methane** from your Flask -> *Snap!* -> watch the whole plume chain-detonate across the CA sim.
- *Optional Sister Variant*: Static/Piezo arc snap that discharges into `CONDUCTIVE` **Water** puddles and **Gold** veins.

### Seismic Boot Kick
- **Close-Range Impulse + Collapse Trigger**: Heavy physical kick (`CompBody` knockback for boulders, barrels, spore pods, and enemies) paired with a localized stress shockwave in `field-sim-wgsl`.
- **Weaponized Cave-Ins**: Spot an overloaded or acid-thinned load-bearing pillar -> kick it -> sever support and drop tons of cavern roof onto whatever is underneath.

### Stains & "Portal-Gel" Footing *(Gravity-On Play)*
- **Material-Driven Movement & Survival**: Hook existing `Materials` bitflags (`SLIPPERY`, `BOUNCY`, `STICKY`, `IGNITER`, `EXTINGUISHER`, `TOXIC`, `HEALING`) into player/entity locomotion (`Flying Mode` off) and temporary body coatings ("stains"):
  - **Oil / Ice (`SLIPPERY`)**: High-speed frictionless cave surfing down slopes.
  - **Slime (`BOUNCY` / `STICKY`)**: Squirt instant bounce pads to launch up vertical shafts or cling to walls.
  - **Burning vs. Wet (`IGNITER` / `EXTINGUISHER`)**: Catch fire near Lava/Fire; squirt **Water** straight overhead (or dive into a pool) to douse yourself in a burst of **Steam** and gain brief fire resistance.
  - **Ambrosia (`HEALING`)**: Coat/stand in golden puddles to mend health.

### Voxel-Anchored Piton / Grapple
- **Physical Subterranean Swinging**: Launch a tethered piton into solid rock to swing across `y = -192` abysses while firing your Flask mid-arc.
- **Sim-True Anchors**: The piton checks its host voxel every tick—anchoring into brittle crystal, overloaded rock, or stone dissolving in **Acid** rips the chunk right out of the ceiling.

---

## 2. Visual & Structural Feedback

### Stress-Based Noisy Visual Cracking *(v1 Shipped)*
- **Live GPU Load Readout (`light_texture.a`)**: `field-sim-wgsl` packs temporally smoothed, normalized 3D compressive/tensile/shear stress + cantilever span amplification (`96.0 - my_w`) + 1-voxel surface dilation into `light_buffer.a` alongside GI RGB block light.
- **3D Voronoi Fissures & Splinters**: `voxel-wgsl` carves continuous domain-warped 3D Voronoi fault lines, tangent-beveled lips, secondary splinter webs (`>30%` strain), and glowing inner crystal veins (`TAG_LUMINESCENT`) as load propagates across cave walls and arches before collapse.

---

## 3. Subterranean Ecology

### Alien Cave Vegetation
- **Reactive Underground Flora**:
  - Hanging bioluminescent tendrils, giant fungal shelves, spore bulbs (`MAT_SPORE_POD`), and thirsty root lattices.
  - **Living CA Tie-In**: `materials.carp` already supports `ORGANIC + HEALING -> SPREAD ORGANIC`, `ORGANIC + TOXIC -> TOXIC_SLUDGE`, and `FLAMMABLE`. Alien vines can drink spilled **Water / Blood / Ambrosia** to grow climbable bridges, puff `MAT_SPORE_CLOUD` when kicked, or shrivel/ignite under **Acid** and **Fire**.

---

## 4. Sim-Native Enemies

- **Noita Worm**: Multi-segment burrowing leviathan that physically carves smooth 3D tunnels through rock strata—draining perched Lava/Acid lakes into lower chambers and severing structural pillars as it hunts.
- **SS13 Blob**: Creeping, self-expanding cellular/core organism that colonizes caverns and converts biomass/stone; immune to simple pokes, forcing chemical warfare (**Fire** plumes, **Acid** moats, **C4** breaches, or starving its substrate).
- **SS13 Shadowling**: Apex darkness predator coupled directly to `light_buffer` GI—fast and lethal in pitch-black vaults, but burned, stunned, or forced to retreat by `LUMINESCENT` crystals, **Fire** jets, flashlight beams, or a glowing **Lava / Ambrosia** flask.
- **Elemental "Ditto" (Alchemical Mimic)**: Samples nearby voxel fluids/gases (including whatever you just squirted at it!), adopts that reagent's color, tags, and immunities, and violently expels pressurized eruptions of it back across the room.
