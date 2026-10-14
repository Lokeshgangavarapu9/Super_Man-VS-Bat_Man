# Collision Layer & Mask Architecture

## Collision Layer Definitions

| Layer Bit | Value | Name | Description | Entities Assigned |
| --- | --- | --- | --- | --- |
| **Layer 1** | `1` | `Environment` | Static ground, roads, buildings, rooftops, barriers, and city props | Ground plane, building colliders, plaza surfaces, perimeter barriers, SpringArm collision |
| **Layer 2** | `2` | `Player 1` | Primary player character physical body | Player 1 `CharacterBody3D` |
| **Layer 3** | `4` | `Player 2` | Second player character physical body | Player 2 `CharacterBody3D` (Co-op / Local 1v1) |
| **Layer 4** | `8` | `P1 Melee Hitbox` | Player 1 melee punch attack volume | Player 1 `MeleeHitbox` Area3D |
| **Layer 5** | `16` | `P2 Melee Hitbox` | Player 2 melee punch attack volume | Player 2 `MeleeHitbox` Area3D |
| **Layer 6** | `32` | `Citizens / NPCs` | Neutral pedestrians walking sidewalks and plazas | `CitizenNPC` CharacterBody3D |
| **Layer 7** | `64` | `Hostile NPCs` | Syndicate / criminal enemies in city & arena | `HostileNPC` CharacterBody3D |
| **Layer 8** | `128` | `Vehicles` | Cruising sedans, sports cars, and police vehicles | `CityVehicle` CharacterBody3D |
| **Layer 9** | `256` | `Collectibles` | Superhero tokens and power crystals | `CityCollectible` Area3D |
| **Layer 10** | `512` | `Projectiles` | Thrown web pellets, batarangs, energy bolts | `Projectile` Area3D |

---

## Collision Mask Matrix (Who Collides With What)

| Entity | Layer | Mask | Interaction Rationale |
| --- | --- | --- | --- |
| **Player 1** | 2 | 1 \| 4 \| 64 \| 128 | Collides with Environment (1), Player 2 (4), Hostile NPCs (64), and Vehicles (128). |
| **Player 2** | 4 | 1 \| 2 \| 64 \| 128 | Collides with Environment (1), Player 1 (2), Hostile NPCs (64), and Vehicles (128). |
| **P1 Melee Hitbox** | 8 | 4 \| 64 | Overlaps and damages Player 2 (4) and Hostiles (64). Does NOT hit citizens or static walls. |
| **P2 Melee Hitbox** | 16 | 2 \| 64 | Overlaps and damages Player 1 (2) and Hostiles (64). |
| **Citizens (NPCs)** | 32 | 1 \| 2 \| 4 \| 128 | Walks on Environment (1), avoids running through players (2, 4) or vehicles (128). |
| **Hostile NPCs** | 64 | 1 \| 2 \| 4 \| 128 | Runs on Environment (1), targets and collides with players (2, 4). |
| **Vehicles** | 128 | 1 \| 2 \| 4 \| 32 \| 64 \| 128 | Hugs road floor (1), pushes/impacts players (2, 4), pedestrians (32, 64), and other cars (128). |
| **Camera SpringArm** | — | 1 | Strictly tests Environment (1) to prevent clipping through buildings without snagging on characters. |
| **Collectibles** | 256 | 2 \| 4 | Triggered only when Player 1 (2) or Player 2 (4) steps into the item zone. |
