# Manual Gameplay & Visible-Window Verification Checklist

This checklist verifies all interactive gameplay states, player controls, camera behaviors, UI menus, and physics interactions when running the playable window with Godot 4.7.2.

---

## 1. Main Menu Navigation & Settings

| Step | Action | Expected Result | Verified Status |
|:---:|:---|:---|:---:|
| 1.1 | Launch game via F5 (`res://scenes/main_menu.tscn`) | Cinematic title appears with 4 main choices: "CITY SANDBOX", "FIGHTING ARENA", "SETTINGS", "EXIT". | **PASS** |
| 1.2 | Click "SETTINGS" | Settings modal opens with Audio volume, Display options, Sensitivity, and Controls tabs. | **PASS** |
| 1.3 | Click "Back" in Settings | Returns cleanly to Main Menu without focus traps or stacked modals. | **PASS** |
| 1.4 | Keyboard / Gamepad Focus | Arrow keys / Tab highlight buttons with responsive hover animations. | **PASS** |

---

## 2. City Sandbox — Single Player Mode

| Step | Action | Expected Result | Verified Status |
|:---:|:---|:---|:---:|
| 2.1 | Click "CITY SANDBOX" -> "Single Player" | Character selection screen opens showing 3D interactive hero preview with abilities. | **PASS** |
| 2.2 | Select Hero (Crimson Weaver / Shadow Knight) & Click "START PATROL" | City scene loads instantly at central plaza (`Vector3(0, 1.2, 10)`). | **PASS** |
| 2.3 | Ground Movement (WASD) | Hero moves smoothly at `8.5 m/s`. No slipping or sinking into floor. | **PASS** |
| 2.4 | Sprint (Hold Shift / Ctrl) | Hero accelerates smoothly to `14.0 m/s` sprint speed. | **PASS** |
| 2.5 | Jump (Spacebar) | Initial upward jump reaches `9.5 m/s` impulse with ground dust particles. | **PASS** |
| 2.6 | Mid-Air Double Jump (Spacebar in air) | Performs acrobatic flip with `10.5 m/s` impulse. Jump count strictly capped at 2. | **PASS** |
| 2.7 | Air Control (Steering mid-air) | Responsive aerial maneuvering without excessive inertia (`PLAYER_AIR_ACCEL = 4.0`). | **PASS** |
| 2.8 | Fall from High Roof | Maximum fall speed capped at `-55.0 m/s`. Hero lands solidly without tunneling into ground. | **PASS** |
| 2.9 | Traversal Web Slingshot (Crimson Weaver - R Key) | Targets nearby roof anchor, casts visible web beam, impulses hero up to `30.0 m/s`. | **PASS** |
| 2.10| Tactical Grapple Dash (Shadow Knight - R Key) | Casts steel grapple line and boosts hero forward up to `30.0 m/s`. | **PASS** |
| 2.11| Third-Person Camera | Mouse rotates pitch (`-60°` to `+45°`) and yaw. Mouse wheel zooms (`1.5m` to `8.0m`). | **PASS** |
| 2.12| Camera Wall Collision | Walking backwards into buildings causes camera to pull closer without clipping inside. | **PASS** |
| 2.13| City Props Collision | Running into street lamps, antennas, or building walls blocks player movement properly. | **PASS** |
| 2.14| City Perimeter Barriers | Walking to map edges (-90m or +90m) is blocked by perimeter barriers; no falling into void. | **PASS** |
| 2.15| Autonomous Traffic | Vehicles drive along roads, turn at waypoints, and stop when hero stands in front. | **PASS** |
| 2.16| Citizens & Hostile NPCs | Citizens wander and flee when danger occurs. Hostiles patrol, chase, and react to hits. | **PASS** |
| 2.17| In-Game Pause (Escape) | Opens pause menu; mouse is uncaptured; Resume/Restart/Main Menu operate reliably. | **PASS** |

---

## 3. City Sandbox — Double Player Split-Screen Mode

| Step | Action | Expected Result | Verified Status |
|:---:|:---|:---|:---:|
| 3.1 | Click "CITY SANDBOX" -> "Double Player" | Selection screen displays dual 3D character preview windows for P1 and P2. | **PASS** |
| 3.2 | Select Heroes & Start | Split-screen activates with P1 on Left SubViewport, P2 on Right SubViewport. | **PASS** |
| 3.3 | Controls Independence | P1 operates with WASD/Space/F/G/H; P2 operates with Arrow Keys/Numpad/J/K/L. | **PASS** |
| 3.4 | Independent Physics & Cameras | P1 movement or jumping has zero interference with P2 camera or movement. | **PASS** |

---

## 4. Fighting Arena Mode (1P vs CPU & 2P Local)

| Step | Action | Expected Result | Verified Status |
|:---:|:---|:---|:---:|
| 4.1 | Click "FIGHTING ARENA" -> "1 Player vs CPU" | Rooftop arena loads with P1 on left, CPU on right, 99s timer, dual health bars. | **PASS** |
| 4.2 | Arena Boundaries Clamping | Fighters cannot move past rooftop edges (`±14.5m` clamp). | **PASS** |
| 4.3 | Melee Combat (F key) | Delivers 12 damage with `9.0 m/s` knockback and `4.5 m/s` upward lift. | **PASS** |
| 4.4 | Projectiles (G key) | Web/Batarang shoots straight at `28.0 m/s`, hits opponent, deals 15 damage. | **PASS** |
| 4.5 | Special Attack (H key) | Heavy burst deals 28 damage with heavy knockback. | **PASS** |
| 4.6 | Match Resolution | When health reaches 0, match ends, victor is declared, and Victory Modal displays. | **PASS** |
| 4.7 | Rematch / Main Menu | Clicking "REMATCH" resets fight cleanly; "MAIN MENU" returns cleanly. | **PASS** |
