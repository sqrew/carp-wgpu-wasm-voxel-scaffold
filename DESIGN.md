# Subterranean Voxel Alchemy — Design Scratchpad

Core design north star: **tiny rules, massive simulation leverage**. Every player verb, creature, and plant should plug directly into the GPU voxel cellular automata, 3D structural stress field, luminescence GI, and rigidbody physics rather than living in isolated scripts.

---

## 1. Foundational Player Verbs

### The 3-Phase Alchemist's Rig (`Solid Sack + Liquid Flask + Gas Bellows`) *(v1 Shipped)*
- **Three Dedicated Phase Vessels (`1` / `2` / `3` + Scroll Wheel)**: Instead of a generic inventory bar, the player carries three permanent vessels mirroring the engine's exact three simulation layers (`Solid` / `Liquid` / `Gas`), with `X` purging only the currently equipped vessel:
  - **`[1]` Solid Sack (Dredge & Pack)**: `RMB` chews smooth SDF bites out of cave walls and rubble (triggering live Voronoi stress fractures!) and vacuums chunks into a single-material pouch; `LMB` lobs a heavy arc—**Sand** and **Gunpowder** cascade out as falling CA piles/fuses, while cohesive solids (**Wood**, **Coal**, **Slime**, **C4**, **Ice**, **Stone**, **Crystal**) extrude solid 3D mounds onto surfaces with live CPU physics collision.
  - **`[2]` Liquid Flask (Siphon & Firehose)**: `RMB` ("Big Succ") siphons **Liquids** cleanly through surface smoke/steam; `LMB` ("Squirt Till It Hurt") fires a high-pressure parabolic stream with entity knockback.
  - **`[3]` Gas Bellows (Inhale & Gust / Flamethrower)**: `RMB` draws a wide intake cone to snag rising **Methane** pockets or **Fire** straight off a burning match; `LMB` blasts a sweeping `2–9m` volumetric plume/flamethrower cone with heavy airblast knockback.
  - **Infinite Emergent Recipes & Lantern Synergy**: Pack **Wood** (`1`) + squirt **Oil** (`2`) + strike a **Match** (`Z`) to build a permanent campfire torch in pitch-black caves; hang **Methane** (`3`) in a ceiling dome + paint an **Oil** fuse (`2`) up the wall; or hold glowing **Crystal/Amethyst/Rad-Ore** (`1`), **Lava/Ambrosia** (`2`), or **Fire** (`3`) as a live colored hand-lantern in `field-sim-wgsl`.

### Off-Hand Matchbox / Flint Snap *(v1 Shipped — Infinite for Testing)*
- **Physical Cave Scout & Igniter**: `Z` or `Middle-Click` strikes a spark shower at your off-hand and flicks a bouncing, self-emissive burning match (`CompBody` sphere + warm flickering amber GI in `field-sim-wgsl` + `MAT_FIRE` ignition in `gas-sim-wgsl`).
- **Sim-True Snuffing & Chains**: Tumbling matches light up dark vertical shafts on the way down, ignite **Oil**, **Wood**, **Coal**, **Methane**, **Volatile Gel**, **Gunpowder**, and **C4**, melt **Ice**, and hiss out (`*tssst!*` -> rising **Steam** + smoke + dark charred stick) the instant they hit **Water** (`TAG_EXTINGUISHER`).
- **Emergent "Fire-in-a-Bottle" Flamethrower**: Because burning matches emit live `MAT_FIRE` (`TAG_LUMINESCENT`) into the gas sim, siphoning a match's flame plume (`RMB`) bottles pure **Fire**—turning your vessel into both a warm hand-lantern and a pocket flamethrower (`LMB`).
- **Survival Light Progression *(Planned)***:
  - Make **Matches / Flint Snaps** a finite, scavenged/crafted survival resource (`Coal`/`Wood` + `Sulfur`/`Gunpowder`) so every peek down an abyss or detonation counts, and turn the **Flashlight (`L`)** into a coveted mid/late-game found relic/powerup rather than a free spawn toggle!
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

### Stress-Based Noisy Visual Cracking *(v1 + Material Cleavage Profiles Shipped)*
- **Live GPU Load Readout (`light_texture.a`)**: `field-sim-wgsl` packs temporally smoothed, normalized 3D compressive/tensile/shear stress + cantilever span amplification (`96.0 - my_w`) + 1-voxel surface dilation into `light_buffer.a` alongside GI RGB block light.
- **Per-Material 3D Voronoi Cleavage & Seam Continuity**: `voxel-wgsl` carves continuous world-space 3D Voronoi fault lines shaped by material geology—sharp folded-noise (`abs(n_lo)`) lightning kinks in **Ice** and **Obsidian**, straight polyhedral crystal facets with glowing inner veins in **Crystal**/**Amethyst**/**Rad-Ore**, vertical fibrous splits in **Wood**, and horizontal bedding planes in **Stone**/**Coal**—bleeding seamlessly across mixed material boundaries.

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
