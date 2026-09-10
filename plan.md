Let's build a proper Wand system so the player can interact with the cellular automata simulation!

Currently, the player can only spam SDF spheres by pressing 'R'. We should replace that with a robust system where:
1. The player holds a "Wand" tool.
2. Clicking the mouse shoots a projectile out of the wand.
3. The projectile is an ECS Entity with a `Transform`, `Velocity`, and `Projectile` component.
4. We need a `ProjectileSystem` that moves them forward and checks for collisions with the SDF terrain using raymarching.
5. On impact, the projectile despawns and triggers an explosion of Cellular Automata voxels (e.g. Acid, Fire, Sand, Water) at the impact point using `AppEvent.ModifyVoxel`.
