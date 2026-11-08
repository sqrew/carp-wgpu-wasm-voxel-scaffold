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

- **The 3 Matter-Phase Ecomancers (`Solidmancer`, `Liquidmancer`, `Gasmancer`) *(v2 Shipped — 256-Segmented Phase Range + Distinct 3D Silhouettes)***:
  - **Segmented `1024` Phase-Range Bending (`floor(mat_id / 256)`)**: Because the engine's `1024` material ID space is cleanly segmented by `256` (`Phase 0 Solid: 0..255`, `Phase 1 Liquid: 256..511`, `Phase 2 Gas: 512..767`), Ecomancers do not lock to a single `mat_id` or require lookup tables—they simply check `floor(vmat / 256) == floor(mmat / 256)`. Each warlock rips *any* material within its `256`-wide phase segment into its 4-orb physical `CompBody` halo (prioritizing nearby reactive/exotic veins while happily wrenching common stone, water, or steam), mixing multiple reagents in orbit at once and casting the exact `orb_mat` of whichever Halo Orb it expends!
  - **Three Unmistakable 3D Raymarched Silhouettes (`eval_mancer_sdf`, `pos_type.w = 5.0 / 6.0 / 7.0`)**:
    1. **Solidmancer (*Lithomancer*, `0..255`, `pos_type.w = 5.0`, `165–185 HP`)**: Broad, chiseled basalt/obsidian monolith cloak with **twin floating tectonic shoulder pauldrons** and a **jagged 4-point diamond/obelisk crown**. Wrenches `2.35m` bites out of walls (`Stone`, `Sand`, `Crystal`, `Gold`, `Gunpowder`, `C4`, `Spore Pod`), raises 3-pillar tectonic bulwarks, and smothers floor hazards by slamming solid orbs at its feet.
    2. **Liquidmancer (*Hydromancer*, `256..511`, `pos_type.w = 6.0`, `150 HP`)**: Flowing pelagic amphora / jellyfish-bell skirt with a **high-crested wave collar**, glossy wet specular sheen, scrolling caustic wave-bands, and a **bobbing twin-ring droplet chalice crown**. Siphons `3.55m` waves from any pool (`Water`, `Lava`, `Acid`, `Oil`, `Blood`, `Ambrosia`), **drinks/absorbs any liquid** it touches or is sprayed with to mend HP and condense free Halo Orbs, and drowns corridors in pressurized fluid torrents.
    3. **Gasmancer (*Aeromancer*, `512..767`, `pos_type.w = 7.0`, `135 HP`)**: **Inverted cyclone / djinn-vortex warlock** whose billowing upper tempest-shroud spirals down into a **corkscrewing tornado tail** at the bottom, crowned by **fast-spinning twin-gyroscope wind rings**. Vacuums `4.35m` gas vortices (`Steam`, `Smoke`, `Fire`, `Methane`, `Chlorine`, `Nitro`, `Spore Cloud`), **inhales any gas or open flame** on contact to heal and condense orbs, and ignites flammable/explosive clouds with `MatchBook` sparks.
  - **Matter-Conserving & Material-Reactive Rubble / Orb Settling (`AppEvent.SettleBoulder` / `EditingSystem.settle-boulder!`)**: Kicked/shattered wall boulders and expired dropped Halo Orbs never vanish into thin air—when their lifetime ends, they return their matter directly into the local 3D world (`Granular` cascades as falling CA grains, `Brittle` shatters with crystal sparks, `Flammable/Explosive` chars or pops, and `Cohesive Solids` weld a smooth SDF mound back into the cave floor/wall).
  - **Ouroboric Slime Ranching & Living Havens *(Planned)***:
    - **Undisturbed Cavern Homesteader**: Left alone out of combat, a Phase Bender terraforms a personal Haven and pitches halo snacks into wandering `mat = 0` **Grey Slimes** to breed a locked elemental guard-slime herd (`1 Locked + 1 Grey` mitosis) while accumulating excreted transmuted reagents (`24k Gold Nuggets`, `Crystal`, `Rad-Ore`, `Ambrosia`).
- **The 4 Force / Field Benders (`Thermomancer`, `Baromancer`, `Gravimancer`, `Chronomancer`) *(Planned — Next Up)***:
  - Running on the exact same levitating warlock core (`MancerBank`), these 4 specialists bend the continuous physical fields in `field_in/out` instead of voxel matter:
  - **1. Thermomancer (`T` Temperature Specialist — `field.x` high 12 bits + `solid_buffer.z` Fourier Heat)**:
    - **Entropy Inversion (Heat-Siphon -> Flash-Boil)**: Drains heat from water pools or the player (`T -> 0.0`, flash-freezing lakes into `Ice` and inflicting frost-slow) to charge a **Superheated Plasma Halo**, then dumps `T -> 1.0` across the chamber—flash-boiling **Water** into blinding **Steam**, auto-igniting dry **Wood / Oil / Methane** without open flames, and cooking off sealed **Gunpowder / C4** seams through solid rock.
  - **2. Baromancer (`P` Pressure & Overpressure Cave-In Specialist — `field.x` low 12 bits)**:
    - **Pneumatic Pillar Shear (Weaponized Cave-Ins)**: Because `field-sim-wgsl` converts adjacent air overpressure (`max_adj_P > 0.28`) into `115×` solid shear stress, a Baromancer spiking `P -> 1.0` inside a cavern **structurally overloads and shears load-bearing rock pillars**, dropping the cave roof onto your head!
    - **Vacuum Implosion & Schlieren Air-Cannon**: Pulls a deep low-pressure sink (`P -> 0.0`) that drags poison gases, fire plumes, and the player inward, then releases an Eikonal-refracted (`solid_buffer.z`) concussive shockwave that ragdolls everything across the room.
  - **3. Gravimancer (`G` Gravity + Eikonal Lensing Specialist — `field.z` low 12 bits)**:
    - **Thrown Singularity Wells**: Hurls mini Black-Hole / White-Hole orbs that visibly bend light around their event horizon (`solid_buffer.z` gravitational lensing) and yank players, boulders, Slimes, Hoppers, and Gold nuggets inward for `2.2s` before blasting outward.
    - **Gravity-Flip Ceiling Slam (`Reverse-G -> 3G Crush`)**: Inverts local gravity (`G -> 0.05`) for `1.5s` so **cave pools, sand, boulders, Slimes, and you all fall UPWARD into the cave ceiling**, then snaps its fingers and slams gravity to **`3×` downward (`+55 m/s²`)**, cratering everything back into the cavern floor.
  - **4. Chronomancer (`tau` Time-Dilation Specialist — `field.z` high 12 bits)**:
    - **Bullet-Time Stasis Bubble**: Projects a viscous `tau -> 0.08` temporal field where liquids/gases crawl in slow-motion, player locomotion turns syrupy, and **any `[5]` Wand bolts, `[Z]` Matches, or `[4]` thrown boulders entering the bubble freeze suspended in mid-air** while the Chronomancer strafes around you and lines up its halo orbs—releasing all suspended projectiles at full speed the instant the bubble pops!
    - **Temporal Rewind ("Recall") & Overclock**: Snaps itself (or you!) backward along a 3-second position ring-buffer, or overclocks local CA reactions and its own cast cadence (`tau -> 1.0`).
- **The 4 Exotic / Systemic Benders (`Electromancer`, `Biomancer`, `Photomancer`, `Alchemancer`) *(Planned)***:
  - **5. Electromancer / Magnemancer (`V, M` Voltage & Lorentz Railgun Specialist — `field.y`)**:
    - Electrifies `CONDUCTIVE` **Water / Acid / Blood** trenches from afar, discharges chain-lightning down **Gold** seams, rips `MAT_GOLD` nuggets and metallic boulders into a spinning Lorentz-coil halo, and **railgun-launches** them at Mach-2 (while magnetically deflecting incoming `[5]` Wand bolts).
  - **6. Biomancer / Mycomancer (Living Flora, `4-Receptor` Pheromones & Slime Shepherd — `field.w`)**:
    - Floods the wind with `Siren Stank` / `Apex Fear` (`field.w`) to whip every **Cave Hopper** and **Dittamoeba** in the cavern into a synchronized frenzy focused on you, rapid-grows `MAT_SPORE_POD` / `MAT_PLANT` vine cages around your boots, and force-evolves nearby Slimes into instant mitosis.
  - **7. Photomancer / Umbramancer (`light_buffer.rgb` + Eikonal Schlieren Mirage Specialist)**:
    - Bends positive GI and negative **Darklight**: plunges a chamber into pitch-black Darklight that swallows your `[F]` Flashlight beam, projects 3D **Eikonal Schlieren mirror-decoy mirages** (`solid_buffer.z`), and fires focused solar-laser beams that flash-cure photopolymer **Amber** or scorch rock into **Lava**.
  - **8. Alchemancer / Transmutemancer (`1024 × 1024` Reaction Matrix Catalyst Specialist)**:
    - The ultimate *Noita / SS13* chaos warlock—transmutes materials in-place (`Water` pool under your feet -> `Acid` or `Oil`; `Stone` cover -> `Gunpowder` or `Glass`, or turns the air in your lungs into `Methane`).
  - **The Dualmancer (`Mancer(archetype_a, archetype_b)`) *(Planned Boss Archetype)***:
    - **Split-Robe 2+2 Halo Warlock**: High-tier dual-attuned warlock combining any 2 Matter-Phase or Field domains (`Napalm Dualmancer: Liquid + Gas`, `Galvanic Stormmancer: Liquid + Electro`, `Thermobaric Dualmancer: Gas + Baro/Thermo`, or the apex `Spacetimemancer: Chrono + Gravi`).
- **Ambient-Fed Typed Simplemob (`Brute(mat_id)`)**:
  - **Turf-Powered Melee Bruiser**: Reads local GPU neighborhood probes (`critter_probes`) every tick—swelling in radius, speed, armor, and glow while standing on or near its home element, and visibly starving when kited onto hostile turf:
    - **Cinder / Magma Brute**: White-hot juggernaut near `Lava`/`Fire`; kite it into cold wet rock (or douse with `[2]` Water) and its shell cools into sluggish, brittle crust you can `[4]` kick-shatter.
    - **Frost Brute / Spore Brute**: Skates and regenerates on `Ice` or living `Mycelium` carpet, steaming or wilting the moment you burn or melt the floor out from under it.
  - **Zero-Scripted Duo Synergy**: Put an `Ecomancer(mat_id)` and `Brute(mat_id)` in the same cavern and no "support AI" is needed—every attack the Ecomancer weaves naturally terraforms the arena into power-turf for its bruiser buddy.
- **Typed Alchemical Worms (`Worm(diet_mat -> excrete_mat)`)**:
  - **Living Tunnelers & Mobile Refineries**: Multi-segment raymarched `smin` metaball worms that actively sniff out preferred strata to nom, carve smooth peristaltic 3D tunnels (draining perched Lava/Acid lakes and severing stressed pillars), and excrete transmuted materials out their tail:
    - **Coal / Dirt Worm**: Chews meandering tubes through soft `Dirt`/`Coal`/`Wood` and poops out slick `Oil` trails or `Gunpowder` fuses down the tunnel.
    - **Slag / Magma Worm**: Bores glowing tubes through `Stone` + `Lava` seams, excreting cooled `Obsidian` crusts and occasional `24k Gold` nuggets.
    - **Frost / Crystal Worm**: Eats `Water`/`Ice` pockets and leaves frictionless `Ice` luge-tubes and crystal spires in its wake.
    - **Acid / Rot Worm**: Dissolves dense rock barriers into tempting shortcuts lined with hazardous `Acid` or `Mycelium`.
- **SS13 Blob**: Creeping, self-expanding cellular/core organism that colonizes caverns and converts biomass/stone; immune to simple pokes, forcing chemical warfare (**Fire** plumes, **Acid** moats, **C4** breaches, or starving its substrate).
- **SS13 Shadowling / Nightmare *(Planned)***:
  - **Apex Darkness Predator (`light_texture.rgb` + `[F]` Flashlight + `[Z]` Matches)**: Coupled directly to local GPU illumination and the 3D light gradient ($\nabla \text{Light}$) in `raycast-wgsl`:
    - **In Pitch Darkness (`light < 0.18`)**: Cloaked in writhing abyssal tendrils that emit **Negative GI (Darklight)** into `light_buffer.rgb` (visibly swallowing ambient cave light as it stalks), regenerating health, moving at `1.8×` speed, and **Shadow-Jaunting** (blinking between shadow pockets to ambush from behind).
    - **Light-Snuffer Sabotage**: Actively hunts and snuffs out floor `[Z]` Matches, turns nearby `Fire` into `Smoke`, corrupts glowing `Crystal` seams into dark `Obsidian`, and briefly flickers/dims your `[F]` Flashlight on melee claw hits.
    - **In Bright Light (`light > 0.38`) — Exposed & Sizzling**: Shining your **`[F]` Flashlight** in its face, tossing a **`[Z]` Match** at its feet, spraying **`[3]` Fire**, or holding a glowing **`Crystal` boulder / `Lava` flask** boils off its shadow-carapace in plumes of `MAT_SMOKE`, **locks out its Shadow-Jaunt**, deals continuous **Light-Burn DoT**, exposes its solid body to **`2.5×` damage**, and forces it to either flee down $-\nabla \text{Light}$ into the nearest dark alcove or lunge in desperation.
- **`smin` Slurping Ditto-Amoeba / Grey Slime Ecology *(v2 Shipped — Wild Cave Spawner + `T` Toss)***:
  - **Raymarched `smin` Pseudopod & Wet Meniscus**: Translucent cave-jelly organism (`CritterSystem` + `map_entities_full` in `shaders_render.carp`) with internal floating organelle eyespots, refracted cave transmission, swelling stomach vacuole, amoeba-to-amoeba membrane merging, and a live `solid_texture` surface-tension meniscus foot that clings effortlessly to floors, vertical cliffs, and ceilings (`-∇sdf` suction).
  - **Grey Stem-Cell Baseline & Permanent Element Locking**: Every wild and `T`-tossed slime starts as a sleek `0.36m` neutral silver **Grey Slime** (`mat = 0`). The first reactive element it eats (via 24-ray GPU chemoreception, Gold Nugget schlorp, `[1..3]` Rig spray, or `[5]` Wand splash—ignoring dull filler stone/soil/sand) **permanently locks its breed**! Once locked, its smell rays strictly seek its own element family (plus universal golden **Ambrosia** chow) without ever being overwritten by stray floor dirt.
  - **Chonk Growth (`0.36m → 0.92m`) & `1 Locked + 1 Grey` Mitosis**: As `fill` climbs `0 → 100%`, locked slimes visibly swell up to `0.92m` (~`16.6×` volume!)—gaining heavier lumbering gait, higher `Slime` trampoline bounce, stronger spicy knockback, and wider explosive craters (`4.55m`). At max chonk, they pinch into a symmetric 2-lobe `smin` dumbbell, **excrete a transmuted reagent** (`Coal -> Crystal`, `Toxic Sludge/Spore Pod -> Ambrosia`, `Sand -> Glass`, `Acid -> Rad-Ore`, `Stone/Lava/Gold -> 2× 20g Gold Nuggets`), and split into **1 locked breeder daughter** (`0.42m`, keeping your ranch line alive) + **1 fresh `0.36m` Grey baby** ready to imprint or relocate!
  - **Slime Cosmetics & Schlorped Trinkets *(Planned)***: Tiny physical crowns, wizard hats, skull caps, pebbles—and a mandatory **Tophat & Gold-Rimmed Monocle** perched jauntily on **24k Gold Slimes** (`mat == 5`)!—that Dittamoebas schlorp onto their dome (or suspend crookedly inside their translucent jelly) and pass down to their locked daughter on mitosis.
  - **Living Slime Symbiote Armor (Wearable Torso Jelly) *(Planned)***:
    - **Slip On a Calm Little Symbiote**: Instead of punting a friendly slime (`[4]`), drape it right over your torso as living, translucent reactive armor! It rides calmly on your chest with its little organelle eyes blinking outward, soaking hits and granting breed-typed protection as long as its `fill` gauge stays fed with its locked nutrient:
      - **Lava / Coal Vest**: Thermal & ignition immunity (sips `Coal`/`Oil`/`Lava` snacks to stay warm).
      - **Slime / Ice Vest**: Cushions kinetic impacts, boulder crushes, and fall damage (or flash-chills melee attackers).
      - **Crystal / Rad-Ore Vest**: Hands-free 3D bioluminescent chest-lantern against **Shadowlings**.
      - **Ambrosia Vest**: Slow passive `HP` regeneration whenever topped up—while wearing a **Volatile / Gunpowder Slime** by mistake turns *you* into a walking reactive ERA brick on the first stray spark!
  - **SS13 Xenobiology Slime Cores *(Planned)***:
    - **Diegetic Internal Core**: The glowing spherical vacuole already raymarched inside each Dittamoeba's belly ([shaders_render.carp](file:///home/sqrew/Desktop/carp-wgpu-wasm-voxel-scaffold/src/shaders_render.carp)) physically crystallizes into a reagent-tuned **Slime Core** (`CompBody` glowing pearl)—shed during rare reagent mitosis (enabling cozy underground slime ranching!) or popped loose on trauma/shatter.
    - **Nom for Biological Powerups (`[4]` Hold + Eat)**: Crunch a core like a forbidden gummy for reagent-matched player mutations—**Slime Core** (bounce-pad legs + zero fall damage), **Crystal / Rad-Ore Core** (personal bioluminescent GI aura in dark caves), **Lava Core** (fireproof skin), **Ice Core** (frost-walker boots that flash-freeze **Water**/**Lava** underfoot), **Ambrosia Core** (regeneration / vitality boost).
    - **True SS13 Catalyst Reactions**: Instead of eating a core, hose it on the cave floor with `[2]` / `[3]` activators (**Water**, **Blood**, **Ambrosia**, **Acid**, **Fire**) to trigger breed-specific Xenobio reactions—erupting reagent geysers, instant crystal/ice architecture, spore smoke screens, or fresh helper slimes.
- **Slime Predators (`Proboscis Assassin` & `Abyssal Ceiling Siphonophore`) *(Planned)***:
  - **Proboscis Assassin ("Slurp-Tick")**: Spindly, translucent ambush arthropod with a rigid needle proboscis and a crystal-clear glass abdomen that specifically hunts chonky (`fill > 50%`) slimes:
    - **Visible SDF Drain & Stolen-Element Spit**: Harpoons a fat slime and pumps—visibly deflating the victim (`0.92m → 0.42m`) while its own glass abdomen swells and glows with the **stolen `mat_id`**, immediately weaponizing that exact reagent (**Lava** magma darts, armor-melting **Acid** snipes, or **Ambrosia** hyper-regeneration).
    - **Trojan Fatboi Counterplay ("Poisoning the Well")**: Because it blindly drinks `mat_id + fill`, you can deliberately fatten a **Volatile Gel / Gunpowder / C4 Slime**, let the greedy bastard slurp the live bomb into its glass gut, and flick a single `[Z]` match at it.
    - **Slime-Armor & Flask Mugger**: Dives straight for your chest if you're wearing **Living Slime Symbiote Armor** to drink your vest off you—or stabs your `[2]` Liquid Flask directly (letting you hot-swap to **Acid** or **Lava** mid-grapple!).
  - **Abyssal Ceiling Siphonophore**: *Half-Life* Barnacle meets deep-sea colonial jellyfish—hangs from dark cavern vaults trailing glowing lure-filaments that spoof **Ambrosia** scent in `critter_probes` to bait wandering slimes underneath, reels them upward, and stores stolen reagents in hanging glass bladders you can `[4]` tug-of-war back or pop like volatile piñatas.

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

## 6. Subterranean Economy & Cave Plumbing

Zero crafting menus, zero dead inventory spreadsheets—every step from resource extraction to refining and shopping happens physically inside the 3D simulation:

- **Minable 24-Karat Gold Seams & Nugget Ecology *(v1 Shipped)***:
  - **Universal Liberation (`World.edit-sdf!`)**: Carving `MAT_GOLD` veins across all 8 biomes via `[1]` Solid Sack (without clogging your Sack!), `[4]` Kick/Wrench, `[5]` Mining Wands, or explosive slimes pops physical tumbling **24k Gold Nuggets** (`CompBody`, `10–25g`) with view-dependent metallic facet glints and magnetic pouch pickup (`<= 4.15m`).
  - **Gold-Schlorping Little Scamps**: Leave nuggets uncollected on the cave floor and wandering **Dittamoebas** greedily schlorp them up—turning into glowing **24k Gold Slimes** that double ore payouts (`2× 20g`) when corralled through mitosis!
- **Pressurized Crustal Geysers & Fumaroles *(Planned)***:
  - **Rhythmic CA Vents**: Mineral chimneys deep in rock strata that cyclically pump **Steam**, **Methane**, **Toxic Gas**, **Spore Cloud**, or superheated mist into the live gas/liquid grid.
  - **Cap-and-Detonate / Plumbing**: Seal a **Methane Geyser** under a `[1]` Stone/Ice dome to pressurize an entire cavern into a fuel-air bomb waiting for one `[Z]` match, or carve diagonal ducts off a **Steam Geyser** to create natural updraft elevators.
  - **Passive Slime Ranching**: Park **Dittamoebas** beside a **Spore** or **Methane Geyser** so they graze infinite plumes and farm mitosis + **Slime Cores** hands-free.
- **Zero-GUI Typed Refineries -> Physical `CompBody` Ingots *(Planned)***:
  - **World-Powered Crucibles & Stamp-Presses**: Ancient smelters/stills found in cavern ruins with a physical intake funnel on top (pour via `[1]`/`[2]` or route carved trenches from lakes/geysers) and a firebox underneath (heat via **Coal + Match**, **Lava**, **Methane** ducts, or a parked **Magma Dittamoeba**).
  - **Chemistry-Preserving Bullion (`CompBody` Bricks)**: Finished batches *KA-CHUNK* out heavy, physics-simulated ingots alongside raw **Gold**—each retaining live material traits:
    - **Gold Bullion**: Ultra-dense currency brick that doubles as a devastating `[4]` kinetic projectile to shatter stressed pillars.
    - **Refined Rad-Bar**: High-value currency + glowing green hand-lantern that mutates nearby Dittamoebas.
    - **Nitro-Bullion**: Sells for 5× **Gold**—unless a stray spark hits your loot pile on the trek out and detonates your own bank account.
- **SS13 Pneumatic Cargo Chute / Greed Maw *(Planned)***:
  - **Diegetic Exchange**: Spend wealth by `[4]`-chucking physical **Gold nuggets**, **Refined Ingots**, or **Slime Cores** straight into subterranean pneumatic chutes/altars, which assay the haul and blast down physical supply capsules (matchboxes, empty ampoules, rig upgrades, pitons, or rare totems).
- **Piezo Stress-Crystal Seams & Galvanic Cave Batteries *(v1 Shipped)***:
  - **Structural Stress -> Live Voltage**: Overloaded `MAT_CRYSTAL (14)` and `MAT_AMETHYST (15)` pillars (`solid_stress > 0.58`) and Galvanic `MAT_GOLD (5) + MAT_ACID (259)` junctions discharge continuous voltage into `solid_buffer.z` (`-z`), electrifying adjacent `CONDUCTIVE` **Water / Acid / Blood** pools (`liquid_buffer.z` with crackling cyan-violet arcs), conducting down **Gold** veins to fuse **Sand** into **Fulgurite Glass**, and shocking players, Hoppers, and Ecomancers.
- **Thirsty Mycelium Bridges & Cordyceps Slimes *(Planned)***:
  - **Living Voxel Architecture**: Dormant fungal nodes on chasm rims drink **Water / Blood / Ambrosia** (`[2]`) or `MAT_SPORE_CLOUD` (`[3]`) to extrude bouncy `ORGANIC` bridges across `y = -192` abysses; **Spore-fed Dittamoebas** sprout little mushroom caps that passively trail spore clouds and seed bridges wherever they crawl.
- **Sympathetic Tuning Megacrystals *(Planned)***:
  - **Harmonic Shatter**: Striking a giant cavern tuning crystal (`[4]` Kick or `[5]` Wand) sends a shockwave that sympathetically shatters matching `BRITTLE` crystal formations across the chamber—opening hidden geodes, dropping crystal chandeliers, or cracking sealed ampoules simultaneously.

---

## 7. Subterranean Roguelite Run Loop (`Wands × Mobs × Perks`) *(Planned)*

The seeded biome stratigraphy (`Surface Meadow -> Mossy Karst -> Crystal Vaults -> Fungal Abyss -> Magma Core`) naturally forms a full vertical descent game:
- **Wands (`WandChassis × SpellPayload × WandMod`)**: Scavenge or socket distinct wands, spell payloads, and in-flight modifiers at subterranean altars/chutes so combat, mining, and alchemy share one unified projectile grammar.
- **Sim-Native Mobs**: Compact roster of creatures whose entire threat and counterplay run through the CA/SDF/GI simulation (**Dittamoebas**, **Megaslimes**, **Proboscis Assassins**, **Ceiling Siphonophores**, **Ecomancers / Chronomancers / Gravimancers / Dualmancers**, **Ambient-Fed Bruisers**, **Alchemical Worms**, **Shadowlings**, **Creeping Blobs**).
- **Physical Perks & Slime-Core Mutations**: Between strata (or by crunching rare **Slime Cores** / trading **Refined Ingots** at **Cargo Chutes**), stack physics-and-chemistry perks—*Frost-Walker Boots*, *Slime-Bounce Legs*, *Bioluminescent Aura*, *Vampiric Siphon*, *Volatile Ricochet*, *Extra Vessel Capacity*, or *Telekinetic Gauntlet Range*.

---

## 8. Master Ambient Field Architecture, Material Alignment & Implementation Roadmap

> **Core Engineering Rule (The 3-Gate Filter)**:
> 1. **Zero new full-grid compute passes or SSBOs** — Piggyback on `field_in`/`field_out` (in air voxels!), `.z` voxel state, and `light_buffer` (`rgb` signed light + `.a` structural stress).
> 2. **Finish & deepen existing systems before adding new ones** — Make current creatures (`Slimes`, `Hoppers`, `Ecomancers`), stains, and materials interlock first.
> 3. **One step at a time** — Playtest each step in the cavern before moving to the next.

### 8.1. Zero-New-Buffers Master Ambient Field Architecture *(Shipped)*
1. **`field_in / field_out` (`vec4<f32>`) Phase Sign Tag**:
   - **Rigid Solid Voxels (`sol.y <= 0.0 && sol.x > 0.0`)**: store `(compressive, tensile, shear, my_w)` with **`my_w > 0.0`** (`1.0 .. 96.0`).
   - **Air Voxels (`sol.y > 0.0`)**: store 10 continuous ambient fields with **`.w = -(1.0 + pack_quartet(rec)) <= -1.0`** so Air and Solid passes never contaminate each other across SDF edits:
     - `.x`: `pack_pair(Temperature T, Pressure P)` (`2 × 12-bit` in IEEE-754 mantissa; vertical `updraft_T` convective chimney above Lava, Fire, Lavamancers, and `[Z]` Matches)
     - `.y`: `pack_pair(Voltage V, Magnetic Potential M)` (`2 × 12-bit`)
     - `.z`: `pack_pair(Chrono tau, Gravity G)` (`2 × 12-bit`)
     - `.w`: `-(1.0 + pack_quartet(Prey/Blood, Siren Stank, Fear/Apex, Neuro-Spore))` (`4 × 6-bit` wind-advected biochemical receptors steered by `Cave Hoppers` via `@binding(1)` in `raycast-wgsl`, denatured at `> 350 °C`)
2. **`solid_buffer.z` (`solid_texture.b`, `rgba16float`)**:
   - In **Air Voxels**: stores Refractive Index Offset $\Delta n \in [-0.075, +0.075]$ for **3D Eikonal Schlieren Ray-Bending** in `voxel-wgsl` (`t > 1.3m`, capped at `±0.018 rad` total deflection, guarded against stained solid boundaries) across Lava/Match heat plumes, blast shockwaves, and the biphasic Predator Cloak around `Glass / Crystal / Amethyst / Obsidian` Ecomancers.
   - In **Solid Voxels**: stores **Fourier Heat (`0 < z < 2.0`)**, **Electric Voltage (`z < 0`)**, and **Surface Liquid Stains (`z = 2.0 + liq_id >= 2.5`)** on `TAG_STAINABLE` materials.
3. **Negative GI ("Darklight") in `light_buffer.rgb` (`rgba16float`)**:
   - Propagates both positive GI light and negative Darklight (`Obsidian + Miasma`, `Obsidian` Ecomancers, `Shadowlings`) across the 6-neighbor stencil, clamping `total_light` *after* summing in `voxel-wgsl` so Darklight devours ambient light and the player's `[F]` Flashlight beam.

### 8.2. Material & Reaction System Alignment Blueprint *(Shipped)*
- [x] **Alignment 1: Fix Self-Reaction Bug (`a != b`) & Complete 3-Phase Hand-Offs (`Solid <-> Liquid <-> Gas`)**
- [x] **Alignment 2: Toughness & Volume-Scaled Reaction Kinetics**
- [x] **Alignment 3: Two-Tier `build-reactions` (Tag Rules Base Layer + Explicit `set-reaction!` Alchemy Table) & Registry-Driven Colors**
- [x] **Alignment 4: Stains & "Portal-Gel" Surface Coating System (`TAG_STAINABLE`, `[WET]`, `[OILED]`, `[BLESSED]`, `[BOUNCY]`, `[BURNING]`) + Buoyant Smoke Plumes & Ceiling-Well Pooling**

### 8.3. Remaining Chronological Phases
- **Phase 1 (Core Ecomancer & 3 Matter-Phase Benders)**:
  - [x] **1.1.** `6.5s` Vulnerable Phase Re-Attunement Ritual (`state = 4`)
  - [x] **1.2.** Real-Time Robe Color-Shift Telegraph During the `6.5s` Ritual
  - [x] **1.3.** Reactive Phase-Wide Self-Preservation (Liquidmancers drink any liquid; Gasmancers inhale any gas/flame; Emergency Self-Douse + Hazard Escape Vault)
  - [x] **1.4.** Autonomous Halo Orb Shield-Parry, Predictive Velocity-Lead Aiming, `360°` Repulsor Nova, & Matter-Conserving Rubble/Orb Settling (`AppEvent.SettleBoulder`)
  - [x] **1.5.** **3 Matter-Phase Benders (`Solidmancer`, `Liquidmancer`, `Gasmancer`)**: `256`-segmented `mat_id` range matching (`floor(id / 256) == 0 / 1 / 2`) + mixed-reagent 4-orb halos + 3 distinct 3D raymarched SDF silhouettes (`pos_type.w = 5.0 / 6.0 / 7.0`)
  - [ ] **1.6.** `Dittamoeba` Slime Ranching & Slime-Bowling *(on hold per design sequence)*
- **Phase 2 (Cave Lightning — `CONDUCTIVE` & `SHOCKING`)**: ✅ Shipped
- **Phase 3 (Master Ambient Field Architecture, Negative GI & Eikonal Ray-Bending)**: ✅ Shipped
- **Phase 4 (Coupled `(T, P)` Thermodynamics & 4-Receptor Wind Chemotaxis)**: ✅ Shipped
- **Phase 5 (Material & Reaction Alignment + Stains System + Buoyant Smoke)**: ✅ Shipped
- **Phase 6 (Deep Alchemy & Creature Expansion)**:
  - [ ] **6.1.** Photochemistry & Darklight Ecology (`MAT_AMBER` flashlight-curing bridges)
  - [ ] **6.2.** Caustic Wood-Ash Lye (`MAT_LYE`) & Saponification (`Oil + Lye -> Soap`)
  - [ ] **6.3.** Active Chrono ($\tau$) & Gravity ($G$) Coupling (`TAG_ANTI_GRAVITY`)
- **Phase 7 (The Expanded 10-Mancer Roster & Shadowlings)**:
  - [ ] **7.1.** **The 4 Force / Field Benders (`Thermomancer`, `Baromancer`, `Gravimancer`, `Chronomancer`)**: Entropy-inverting `Thermomancer (T)`, pillar-shearing overpressure `Baromancer (P)`, Eikonal-lensed singularity & reverse-G `Gravimancer (G)`, and Bullet-Time stasis/rewind `Chronomancer (tau)`.
  - [ ] **7.2.** **The 4 Exotic / Systemic Benders (`Electromancer`, `Biomancer`, `Photomancer`, `Alchemancer`)**: Lorentz railgun `Electromancer (V, M)`, pheromone/flora `Biomancer (field.w)`, Darklight/Schlieren-mirage `Photomancer`, and in-place transmutation `Alchemancer`.
  - [ ] **7.3.** **Dualmancer (`Mancer(archetype_a, archetype_b)`) & SS13 Shadowling / Nightmare**: Split-robe `2+2` halo combo warlock + Darklight apex stalker (`light < 0.18` Shadow-Jaunt & Light-Snuffer).


