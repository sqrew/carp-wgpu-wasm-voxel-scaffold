# Subterranean Voxel Alchemy — Design Scratchpad

Core design north star: **tiny rules, massive simulation leverage**. Every player verb, creature, and plant should plug directly into the GPU voxel cellular automata, 3D structural stress field, luminescence GI, and rigidbody physics rather than living in isolated scripts.

---

## 1. Foundational Player Verbs

### The 5-Slot Alchemist's Belt (`Sack + Flask + Bellows + Gauntlet & Boot + Alchemical Wand`) *(v1 Shipped)*
- **Three Phase Vessels + Kinetic Intent + Composable Spell Launcher (`1` / `2` / `3` / `4` / `5` + Scroll Wheel)**: Mirrors the engine's three simulation layers (`Solid` / `Liquid` / `Gas`), dedicated empty-handed Push/Pull kinetics (`[4]`), and a composable 3-part wand slot (`[5]`), with `X` purging only the active vessel (or dropping a held object):
  - **`[1]` Solid Sack (Dredge & Pack)**: `RMB` chews smooth SDF bites out of cave walls and rubble (triggering live Voronoi stress fractures!) and vacuums chunks into a single-material pouch; `LMB` lobs a heavy arc—**Sand** and **Gunpowder** cascade out as falling CA piles/fuses, while cohesive solids (**Wood**, **Coal**, **Slime**, **C4**, **Ice**, **Stone**, **Crystal**) extrude solid 3D mounds onto surfaces with live CPU physics collision.
  - **`[2]` Liquid Flask (Siphon & Firehose)**: `RMB` ("Big Succ") siphons **Liquids** cleanly through surface smoke/steam; `LMB` ("Squirt Till It Hurt") fires a high-pressure parabolic stream with entity knockback.
  - **`[3]` Gas Bellows (Inhale & Gust / Flamethrower)**: `RMB` draws a wide intake cone to snag rising **Methane** pockets or **Fire** straight off a burning match; `LMB` blasts a sweeping `2–9m` volumetric plume/flamethrower cone with heavy airblast knockback.
  - **`[4]` Gauntlet & Boot (Push / Pull Kinetic & Interact Intent)**: Safe "hands-free" physical interaction so grabbing or kicking never accidentally dumps reagents:
    - **`RMB` Hazard Tug, Spring Carry & Wall Wrench (Pull)**: Locks onto dynamic `CompBody` entities up to `14.5m` away and violently yanks/reels them (`14.5–25.5 m/s` + ledge-clearing hop) straight into **Acid / Lava / Fire** traps between you and them, catching them in a smooth close-range spring grasp (`<= 2.25m`; `Hold RMB + Click LMB` cannonball-punts at `30.5 m/s`!). Pressing `RMB` on a close solid wall (`<= 8.8m`) wrenches out a material-true physical boulder (`Slime` super-bouncy, `Ice` frictionless curling stone, `Crystal/Amethyst/Rad-Ore` glowing cave lantern, `Spore Pod` puffing live `MAT_SPORE_CLOUD` gas) straight into your grip.
    - **`LMB` Seismic Boot Kick & Weaponized Cave-Ins (Push)**: Boots nearby entities in a wide front cone (`26 m/s`), splashes shallow liquid puddles, and reads live GPU structural load (`light_texture.a` via `raycast-wgsl`)—kicking an overloaded pillar (`>= 22%` load) or brittle **Crystal / Ice / Glass / Coal / Obsidian / Spore Pod** shatters a massive `r = 2.2m` chunk into 3 tumbling rubble boulders (`SHATTER!`) to sever support and drop cavern roofs onto enemies below.
  - **`[5]` Alchemical Wand System (`WandChassis × SpellPayload × WandMod`)**: Zero-malloc `24`-slot swept SDF + entity projectile launcher (`LMB` casts, `RMB` cycles wands while stowed wands passively recharge mana; flying bolts emit colored 3D cave GI via `critter_lights` with `cl.w = -1.0`):
    - **6 Starter Wands**: **`Spark Ricochet`** (`2×` cave-wall normal bounce + split-on-hit spark shrapnel), **`Emerald Bore`** (piercing mining lance that chews `3` consecutive `r = 1.42m` SDF tunnel bites per bolt to snipe stressed pillars at range), **`Meteor Staff`** (arcing fireball leaving a live `MAT_FIRE` wake + `r = 2.2m` crater shockwave), **`Cryo-Architect`** (extrudes solid `MAT_ICE` bridges/domes onto surfaces and flash-petrifies Lava/Burning Dittamoebas into **Obsidian** boulders), **`Venom Scattergun`** (`3×` multicast **Acid** globs that pit rock and dissolve lakes), and **`Amethyst Seeker`** (3D-homing arcane bolts that curve into nearby Dittamoebas and splash golden **Ambrosia**).
  - **Infinite Emergent Recipes & Lantern Synergy**: Pack **Wood** (`1`) + squirt **Oil** (`2`) + strike a **Match** (`Z`) to build a permanent campfire torch in pitch-black caves; flood a trench with **Acid** (`2`) then swap to **`[4]`** and yank targets off ledges right into the vat; snipe a distant load-bearing pillar with **`Emerald Bore`** (`5`); or carry a wrenched **Crystal** boulder (`4`), **Lava/Ambrosia** (`2`), **Fire** (`3`), or a charged **Wand** (`5`) as a live colored hand-lantern in `field-sim-wgsl`.

### Off-Hand Matchbox / Flint Snap *(v1 Shipped — Infinite for Testing)*
- **Physical Cave Scout & Igniter**: `Z` or `Middle-Click` strikes a spark shower at your off-hand and flicks a bouncing, self-emissive burning match (`CompBody` sphere + warm flickering amber GI in `field-sim-wgsl` + `MAT_FIRE` ignition in `gas-sim-wgsl`).
- **Sim-True Snuffing & Chains**: Tumbling matches light up dark vertical shafts on the way down, ignite **Oil**, **Wood**, **Coal**, **Methane**, **Volatile Gel**, **Gunpowder**, and **C4**, melt **Ice**, and hiss out (`*tssst!*` -> rising **Steam** + smoke + dark charred stick) the instant they hit **Water** (`TAG_EXTINGUISHER`).
- **Emergent "Fire-in-a-Bottle" Flamethrower**: Because burning matches emit live `MAT_FIRE` (`TAG_LUMINESCENT`) into the gas sim, siphoning a match's flame plume (`RMB`) bottles pure **Fire**—turning your vessel into both a warm hand-lantern and a pocket flamethrower (`LMB`).
- **Survival Light Progression *(Planned)***:
  - Make **Matches / Flint Snaps** a finite, scavenged/crafted survival resource (`Coal`/`Wood` + `Sulfur`/`Gunpowder`) so every peek down an abyss or detonation counts, and turn the **Flashlight (`L`)** into a coveted mid/late-game found relic/powerup rather than a free spawn toggle!
  - *Optional Sister Variant*: Static/Piezo arc snap that discharges into `CONDUCTIVE` **Water** puddles and **Gold** veins.

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
- **`smin` Slurping Ditto-Amoeba *(v1 Shipped — Wild Cave Spawner + `T` Toss)***:
  - **Raymarched `smin` Pseudopod & Wet Meniscus**: Translucent cave-jelly organism (`CritterSystem` + `map_entities_full` in `shaders_render.carp`) with internal floating organelle eyespots, refracted cave transmission, swelling stomach vacuole, amoeba-to-amoeba membrane merging, and a live `solid_texture` surface-tension meniscus foot that clings effortlessly to floors, vertical cliffs, and ceilings (`-∇sdf` suction).
  - **24-Ray GPU Chemoreception & Live Feeding**: Scans nearby solids, liquids, and gases in `shaders_raycast.carp` (including bait poured from `[1]`/`[2]`/`[3]` or direct Rig streams!), stretches a 3-sphere polynomial `smin` trunk toward snacks in an inchworm reach-anchor-shlorp cycle, and carves smooth SDF bites / siphons fluids.
  - **Quirk Absorption, Counter-Reactions & Mitosis**: Absorbs reagent color, 3D GI light emission (`field-sim-wgsl`), physics (`Slime` -> super-bouncy living trampoline), and elemental vulnerabilities (`Lava`/`Fire` + `Water` -> `*tssst!*` flash-petrifies into a solid **Obsidian** boulder; `Volatile Gel`/`Gunpowder`/`C4`/`Methane` + fire or `[4]` Power-Punt wall impact -> `3.8m` crater detonation; `Oil`/`Wood`/`Coal` + fire -> panicked flaming streaker trailing `MAT_FIRE`; `Acid`/`Lava`/`Rad-Ore`/`Toxic Sludge` -> territorial sizzle hazard). Once full, pinches into a symmetric 2-lobe `smin` dumbbell, **excretes a transmuted reagent** (`Coal -> Crystal`, `Toxic Sludge/Spore Pod -> Ambrosia`, `Sand -> Glass`, `Acid -> Rad-Ore`), and splits into two daughter amoebas!
  - **SS13 Xenobiology Slime Cores *(Planned)***:
    - **Diegetic Internal Core**: The glowing spherical vacuole already raymarched inside each Dittamoeba's belly ([shaders_render.carp](file:///home/sqrew/Desktop/carp-wgpu-wasm-voxel-scaffold/src/shaders_render.carp)) physically crystallizes into a reagent-tuned **Slime Core** (`CompBody` glowing pearl)—shed during rare reagent mitosis (enabling cozy underground slime ranching!) or popped loose on trauma/shatter.
    - **Nom for Biological Powerups (`[4]` Hold + Eat)**: Crunch a core like a forbidden gummy for reagent-matched player mutations—**Slime Core** (bounce-pad legs + zero fall damage), **Crystal / Rad-Ore Core** (personal bioluminescent GI aura in dark caves), **Lava Core** (fireproof skin), **Ice Core** (frost-walker boots that flash-freeze **Water**/**Lava** underfoot), **Ambrosia Core** (regeneration / vitality boost).
    - **True SS13 Catalyst Reactions**: Instead of eating a core, hose it on the cave floor with `[2]` / `[3]` activators (**Water**, **Blood**, **Ambrosia**, **Acid**, **Fire**) to trigger breed-specific Xenobio reactions—erupting reagent geysers, instant crystal/ice architecture, spore smoke screens, or fresh helper slimes.

---

## 5. Landscape Toys & Relics *(Planned)*

Small, systemic physical objects (`CompBody`) scattered across meadows and cavern ledges that **both the player (`[4]` Gauntlet & Boot / `[1..3]` Vessels) and wandering critters** naturally mess with upon stumbling across them:

- **Dittamoeba Worship Totem -> Megaslime Boss**:
  - **Portable Relic**: Weird carved idol (`CompBody`, grabbable/throwable via `[4]`) occasionally found in hillside rings or deep cave shrines.
  - **Cult Circle**: Nearby **Dittamoebas** stop grazing, form a ring around the totem, and synchronously squish-bow in unison, charging its runes once `X` worshippers gather.
  - **Systemic Summoning (or Sabotage)**: Carry the totem to a slime herd (`[4]`), toss slimes into the circle, or deliberately feed slimes reagents to farm mitosis up to `X` cultists—or boot-kick the totem off a cliff mid-chant to cancel the ritual.
  - **`smin` Coalescence & Royal Core**: At full charge, all `X` worshippers lunge inward and `smin`-merge around the idol into a colossal **Megaslime Boss**—with the glowing totem suspended inside its translucent core like a crown/nucleus, inheriting the combined elemental quirks of the fused cultists (e.g., Magma + Slime = flaming sky-bouncing kaiju jelly) and dropping a multi-trait **Royal Slime Core** + frantic mini-slimes when defeated!
- **95%-Bounce Ricochet / Fetch Orbs**: Hyper-elastic spheres resting in terrain hollows—pinball 20+ times down dark shafts when punted (`[4]`), while wild Dittamoebas curiously boop and chase them around like puppies.
- **Fragile Alchemical Ampoules**: Sealed glowing glass flasks (`Ambrosia`, `Volatile Gel`, `Acid`, `Spore Cloud`) perched on ledges—roll harmlessly on gentle nudges, shatter into live CA splashes/plumes on high-speed impact or cave-ins.
- **Boing-Cap Bumper Pads**: Springy cave caps/trinkets that violently launch players, thrown ampoules, or wandering Dittamoebas skyward on contact.

---

## 6. Subterranean Economy & Cave Plumbing *(Planned)*

Zero crafting menus, zero dead inventory spreadsheets—every step from resource extraction to refining and shopping happens physically inside the 3D simulation:

- **Pressurized Crustal Geysers & Fumaroles**:
  - **Rhythmic CA Vents**: Mineral chimneys deep in rock strata that cyclically pump **Steam**, **Methane**, **Toxic Gas**, **Spore Cloud**, or superheated mist into the live gas/liquid grid.
  - **Cap-and-Detonate / Plumbing**: Seal a **Methane Geyser** under a `[1]` Stone/Ice dome to pressurize an entire cavern into a fuel-air bomb waiting for one `[Z]` match, or carve diagonal ducts off a **Steam Geyser** to create natural updraft elevators.
  - **Passive Slime Ranching**: Park **Dittamoebas** beside a **Spore** or **Methane Geyser** so they graze infinite plumes and farm mitosis + **Slime Cores** hands-free.
- **Zero-GUI Typed Refineries -> Physical `CompBody` Ingots**:
  - **World-Powered Crucibles & Stamp-Presses**: Ancient smelters/stills found in cavern ruins with a physical intake funnel on top (pour via `[1]`/`[2]` or route carved trenches from lakes/geysers) and a firebox underneath (heat via **Coal + Match**, **Lava**, **Methane** ducts, or a parked **Magma Dittamoeba**).
  - **Chemistry-Preserving Bullion (`CompBody` Bricks)**: Finished batches *KA-CHUNK* out heavy, physics-simulated ingots alongside raw **Gold**—each retaining live material traits:
    - **Gold Bullion**: Ultra-dense currency brick that doubles as a devastating `[4]` kinetic projectile to shatter stressed pillars.
    - **Refined Rad-Bar**: High-value currency + glowing green hand-lantern that mutates nearby Dittamoebas.
    - **Nitro-Bullion**: Sells for 5× **Gold**—unless a stray spark hits your loot pile on the trek out and detonates your own bank account.
    - **24-Karat Metallic Slimes**: Leave stamped ingots unguarded and wandering Dittamoebas can swallow one—turning into fast, clinking **Gold/Metal Slimes** (*Dragon Quest* style!) that double ore yield if corralled through mitosis.
- **SS13 Pneumatic Cargo Chute / Greed Maw**:
  - **Diegetic Exchange**: Spend wealth by `[4]`-chucking physical **Gold nuggets**, **Refined Ingots**, or **Slime Cores** straight into subterranean pneumatic chutes/altars, which assay the haul and blast down physical supply capsules (matchboxes, empty ampoules, rig upgrades, pitons, or rare totems).
- **Piezo Stress-Crystal Seams (Load-Driven Cave Generators)**:
  - **Structural Stress -> Live Voltage**: Special quartz seams embedded in load-bearing pillars that convert high `light_texture.a` compressive stress (`>= 65%` load) into periodic electrical sparks—electrifying adjacent `CONDUCTIVE` **Water** pools and **Gold** veins, igniting **Methane** leaks, or letting you pile `[1]` **Stone** onto an arch to intentionally overload a crystal into a shock trap.
- **Thirsty Mycelium Bridges & Cordyceps Slimes**:
  - **Living Voxel Architecture**: Dormant fungal nodes on chasm rims drink **Water / Blood / Ambrosia** (`[2]`) or `MAT_SPORE_CLOUD` (`[3]`) to extrude bouncy `ORGANIC` bridges across `y = -192` abysses; **Spore-fed Dittamoebas** sprout little mushroom caps that passively trail spore clouds and seed bridges wherever they crawl.
- **Sympathetic Tuning Megacrystals**:
  - **Harmonic Shatter**: Striking a giant cavern tuning crystal (`[4]` Kick or `[5]` Wand) sends a shockwave that sympathetically shatters matching `BRITTLE` crystal formations across the chamber—opening hidden geodes, dropping crystal chandeliers, or cracking sealed ampoules simultaneously.

---

## 7. Subterranean Roguelite Run Loop (`Wands × Mobs × Perks`) *(Planned)*

The seeded biome stratigraphy (`Surface Meadow -> Mossy Karst -> Crystal Vaults -> Fungal Abyss -> Magma Core`) naturally forms a full vertical descent game:
- **Wands (`WandChassis × SpellPayload × WandMod`)**: Scavenge or socket distinct wands, spell payloads, and in-flight modifiers at subterranean altars/chutes so combat, mining, and alchemy share one unified projectile grammar.
- **Sim-Native Mobs**: Compact roster of creatures whose entire threat and counterplay run through the CA/SDF/GI simulation (**Dittamoebas**, **Megaslimes**, **Shadowlings**, **Burrowing Worms**, **Creeping Blobs**).
- **Physical Perks & Slime-Core Mutations**: Between strata (or by crunching rare **Slime Cores** / trading **Refined Ingots** at **Cargo Chutes**), stack physics-and-chemistry perks—*Frost-Walker Boots*, *Slime-Bounce Legs*, *Bioluminescent Aura*, *Vampiric Siphon*, *Volatile Ricochet*, *Extra Vessel Capacity*, or *Telekinetic Gauntlet Range*.

