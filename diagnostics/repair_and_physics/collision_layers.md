# 3D Collision Layers Architecture

This document outlines the standard 3D collision layer configuration defined in `project.godot` and utilized across all scenes and scripts.

## Layer Matrix Definition

| Layer # | Layer Name | Bit Value | Primary Occupants | Collides With (Mask) | Purpose |
|:---:|:---|:---:|:---|:---|:---|
| **1** | **Environment** | `1` (`0x1`) | Ground, Buildings, Road Surfaces, Helipads, Street Lamps, Antennas, Perimeter Barriers | `1, 2, 4, 8` | World geometry, obstacles, and boundary containment. |
| **2** | **Player1** | `2` (`0x2`) | Player 1 `CharacterBody3D` | `1, 6, 7, 8, 9` | Environment collision, NPC bumping, car collisions, tokens. |
| **3** | **Player2** | `4` (`0x4`) | Player 2 `CharacterBody3D` | `1, 6, 7, 8, 9` | Environment collision, NPC bumping, car collisions, tokens. |
| **4** | **AttackP1** | `8` (`0x8`) | Player 1 Melee Hitbox & Projectiles | `1, 4` (Hit Environment & P2/Enemies) | Registers hits against opponents without hitting Player 1. |
| **5** | **AttackP2** | `16` (`0x10`) | Player 2 Melee Hitbox & Projectiles | `1, 2` (Hit Environment & P1/Enemies) | Registers hits against opponents without hitting Player 2. |
| **6** | **NPC** | `32` (`0x20`) | Citizen NPCs `CharacterBody3D` | `1, 2, 4, 8` | Environment, Player, and Vehicle collision. |
| **7** | **HostileNPC** | `64` (`0x40`) | Syndicate Enemies `CharacterBody3D` | `1, 2, 4, 8, 16` | Environment, Players, and incoming attacks. |
| **8** | **Vehicle** | `128` (`0x80`) | Traffic Cars `CharacterBody3D` | `1, 2, 4, 6, 7, 8` | Road surfaces, other vehicles, and pedestrians. |
| **9** | **Collectible** | `256` (`0x100`) | Hero Tokens `Area3D` | `2, 4` (Players only) | Overlap trigger for token pickup. |

---

## Detailed Collision Interactions

### 1. Player vs Environment
- Ground platform (`180m x 2m x 180m`) has `collision_layer = 1`.
- Buildings use precise `BoxShape3D` matching their visual dimensions with roof caps.
- Street lamps and antennas use `CylinderShape3D` collision bodies on layer 1.
- Perimeter boundaries (`16m` high walls) prevent characters from falling off the edge of the world into the void.

### 2. Camera Occlusion & Clipping Prevention
- The `ThirdPersonCamera` utilizes a `SpringArm3D` with a `SphereShape3D` (radius `0.25m`).
- `collision_mask = 1` ensures the camera collides strictly with Environment layer 1 (walls, roofs, ground).
- When a building or wall stands between the player and the camera, the arm dynamically contracts down to `min_distance = 1.5m` rather than clipping through geometry or showing backfaces.
- Camera instantly snaps to target if distance exceeds `15m` (e.g. respawning or teleporting).

### 3. Fighting Arena Rooftop Barriers
- The rooftop arena (`scenes/arena.tscn`) features physical perimeter walls (`BoxShape3D_wall_fb` and `BoxShape3D_wall_lr`) alongside a programmatic clamp in `player.gd` (`_clamp_to_arena_bounds`) locking positions to `±14.5m` on X and Z.
- Projectiles collide against layer 1 (arena barriers and floor), triggering particle impacts and despawning cleanly.
