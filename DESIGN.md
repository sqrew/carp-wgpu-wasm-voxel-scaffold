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

- **Ecomancer / Materialmancer (`Mancer(mat_id)`) *(v1 Shipped — Wild Cavern Spawner + `U` Summon)***:
  - **Born of the Substrate ("Evil Captain Planet")**: Levitating hooded cave-warlocks (`MancerSystem` + `eval_mancer_sdf` in `shaders_render.carp`) spawned out of a chamber's dominant material and parameterized by a single `mat_id` (Solid `1..17`, Liquid `257..264`, or Gas `513..520`). Obeys strict local conservation (*Avatar* bender rule)—ripping massive real `2.35m–4.35m` chunks, waves, and plumes out of nearby walls, pools, and clouds (via 20-ray GPU 3D supply scanning) into a 4-orb physical `CompBody` halo that can be `[4]` Gauntlet-hijacked or detonated mid-orbit. Draining or transmuting its supply starves it into desperate weak shoves.
  - **One 4-Move Brain, Wildly Emergent Personalities**:
    - **Lavamancer / Cryomancer / Lithomancer**: Hurls heavy halo orbs (`25.5 m/s`), raises 3-pillar tectonic bulwarks (`edit-bender-sdf!`), and channels `1.6s` corridor torrents that you can `[1/2/3]` `RMB` vacuum-parry into your vessel or `LMB` beam-clash in midair!
    - **Gunpowder / C4-Mancer**: Plasters 3-lobe explosive ankle-tombs around your boots, then strikes and flicks a real `MatchBook` burning match arc (`flick-igniter-match!`) while you scramble for `[3]` Bellows or `[2]` Water.
    - **Sporemancer**: Chokes sightlines in `MAT_SPORE_CLOUD` and raises reactive `MAT_SPORE_POD` barriers.
    - **Ambrosiamancer**: Runs the *exact same* furious aggro AI to aggressively pelt you (and nearby Hoppers!) with healing `MAT_AMBROSIA` geysers.
    - **Goldmancer**: Rare jackpot miniboss literally wrenching `24k Gold` veins into real `25g` collectable `GoldBank` nuggets in his halo and hurling his net worth at your head.
  - **Ouroboric Slime Ranching & Living Havens *(Planned)***:
    - **Undisturbed Cavern Homesteader**: Left alone out of combat, `Mancer(mat_id)` doesn't idle—it actively **terraforms a personal Haven** (lining basins, moats, and pedestals with its home `mat_id`) and **ranches nearby `Dittamoeba` Slimes**.
    - **Force-Fed Mitosis Loop (`Grey -> Locked Herd + Natural Loot Hoard`)**: The Mancer pitches halo snacks of its signature `mat_id` straight into wandering `mat = 0` **Grey Slimes** to imprint them onto its element, then keeps force-feeding its pets through `0.36m → 0.92m` chonk cycles. Because each mitosis yields **`1 Locked + 1 fresh Grey`** *and* excretes transmuted reagents (`Lava/Gold -> 2× 20g Gold Nuggets`, `Acid -> Rad-Ore`, `Coal -> Crystal`, `Spore/Toxic -> Ambrosia`), an undisturbed Mancer organically breeds a whole **elemental guard-slime herd** *and* accumulates a **real physical treasure hoard** in its den—zero fake biome scripts or loot-chest tables required!
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
- **SS13 Shadowling**: Apex darkness predator coupled directly to `light_buffer` GI—fast and lethal in pitch-black vaults, but burned, stunned, or forced to retreat by `LUMINESCENT` crystals, **Fire** jets, flashlight beams, or a glowing **Lava / Ambrosia** flask.
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
- **Sim-Native Mobs**: Compact roster of creatures whose entire threat and counterplay run through the CA/SDF/GI simulation (**Dittamoebas**, **Megaslimes**, **Proboscis Assassins**, **Ceiling Siphonophores**, **Ecomancers**, **Ambient-Fed Bruisers**, **Alchemical Worms**, **Shadowlings**, **Creeping Blobs**).
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
   - In **Air Voxels**: stores Refractive Index Offset $\Delta n \in [-0.075, +0.075]$ for **3D Eikonal Schlieren Ray-Bending** in `voxel-wgsl` (`t > 1.3m`, capped at `±0.018 rad` total deflection) across Lava/Match heat plumes, blast shockwaves, and the biphasic Predator Cloak around `Glass / Crystal / Amethyst / Obsidian` Ecomancers.
   - In **Solid Voxels**: stores **Fourier Heat (`+z`)** (driving `24k Gold` thermal bridges to auto-ignite sealed `Gunpowder`/`C4` and autoclave `Coal -> Crystal`) and **Electric Voltage (`-z`)** along `Gold` veins and Piezoelectric `Crystal`/`Amethyst`.
3. **Negative GI ("Darklight") in `light_buffer.rgb` (`rgba16float`)**:
   - Propagates both positive GI light and negative Darklight (`Obsidian + Miasma`, `Obsidian` Ecomancers) across the 6-neighbor stencil, clamping `total_light` *after* summing in `voxel-wgsl` so Darklight devours ambient light and the player's `[F]` Flashlight beam.

### 8.2. Material & Reaction System Alignment Blueprint *(In Progress)*
Auditing [`src/materials.carp`](file:///home/sqrew/Desktop/carp-wgpu-wasm-voxel-scaffold/src/materials.carp) and [`src/shaders_sim.carp`](file:///home/sqrew/Desktop/carp-wgpu-wasm-voxel-scaffold/src/shaders_sim.carp) identified 5 concrete alignments needed to make the `1024×1024` reaction matrix airtight:
- [ ] **Alignment 1: Fix Self-Reaction Bug (`a != b`) & Complete 3-Phase Hand-Offs (`Solid <-> Liquid <-> Gas`)**:
  - Guard `Materials.build-reactions` with `(when (/= a b) ...)` so multi-tag materials (`Spore Pod 13` and `Spore Cloud 520`, which have both `ORGANIC` and `TOXIC`) stop reacting with themselves via Rule 9!
  - Add `Solid -> Liquid` (`256 <= rx.x < 512`) pickup in `liquid-sim-wgsl` before early-returning on `is_sol_block` so melting `Ice (8) -> Water (257)` and `Gold (5) -> Lava (258)` actually spawns the liquid instead of vanishing into thin air.
  - Add the missing `self_gas` (`next_vol > 0.05`) reaction loop in `gas-sim-wgsl` and include co-located `delta = (0,0,0)` fluid checks in both `liquid-sim-wgsl` and `gas-sim-wgsl`.
- [ ] **Alignment 2: Toughness & Volume-Scaled Reaction Kinetics**:
  - Weight per-frame reaction probability by `1.0 / max(1.0, toughness * 2.2)` and reactant fluid volume using a fast per-voxel frame hash—so `Sand` dissolves in `Acid` almost immediately, `Stone` pits gradually over ~12 frames, and `Coal` burns 10× longer than `Wood`/`Sponge` as a true furnace fuel.
- [ ] **Alignment 3: Two-Tier `build-reactions` (Tag Rules Base Layer + Explicit `set-reaction!` Alchemy Table) & Registry-Driven Colors**:
  - Fix missing tags (`FREEZABLE` on `Ice`, `FLAMMABLE` on `Spore Pod`), wire up `Materials.set-reaction!` for signature combinations (`Lava + Water -> Obsidian/Stone + Steam`, `Sand + Lava -> Glass + Lava`, `Coal + Fire -> Fire + Fire`, `Blood + Acid -> Volatile Gel + Toxic Gas`), and derive `boulder-color`, `slime-color`, and `gi-emission` from `Materials.registry`.
- [ ] **Alignment 4: Stains & "Portal-Gel" Surface Coating System (`TAG_STAINABLE`, `SLIPPERY`, `BOUNCY`, `STICKY`, `IGNITER`, `EXTINGUISHER`, `TOXIC`, `HEALING`)**:
  - Couple voxel surface contact (`solid_buffer.z` stain encoding or `raycast-wgsl` ground/fluid probes) and entity/player coatings so `Oil`/`Ice` grant high-speed cave surfing, `Slime` creates bounce pads, `Water` douses burning entities with a `Steam` burst + temporary wet fire-ward, and `Acid`/`Ambrosia` apply corrosive/healing stains.

### 8.3. Remaining Chronological Phases
- **Phase 1 (Ecomancer Polish)**:
  - [x] **1.1.** `6.5s` Vulnerable Elemental Re-Attunement Ritual (`state = 4`)
  - [ ] **1.2.** Real-Time Robe Color-Shift Telegraph During the `6.5s` Ritual
  - [ ] **1.3.** Reactive Elemental Self-Preservation (Self-Douse & Fire Absorption)
  - [ ] **1.4.** Emergency Halo Orb Shield-Parry
  - [ ] **1.5.** `Dittamoeba` Slime Ranching & Slime-Bowling
- **Phase 2 (Cave Lightning — `CONDUCTIVE` & `SHOCKING`)**: ✅ Shipped
- **Phase 3 (Master Ambient Field Architecture, Negative GI & Eikonal Ray-Bending)**: ✅ Shipped
- **Phase 4 (Coupled `(T, P)` Thermodynamics & 4-Receptor Wind Chemotaxis)**: ✅ Shipped
- **Phase 5 (Material & Reaction Alignment + Stains System)**: In Progress
- **Phase 6 (Deep Alchemy & Creature Expansion)**:
  - [ ] **6.1.** Photochemistry & Darklight Ecology (`MAT_AMBER` flashlight-curing bridges, `Shadowlings`)
  - [ ] **6.2.** Caustic Wood-Ash Lye (`MAT_LYE`) & Saponification (`Oil + Lye -> Soap`)
  - [ ] **6.3.** Active Chrono ($\tau$) & Gravity ($G$) Coupling (`TAG_ANTI_GRAVITY`)


