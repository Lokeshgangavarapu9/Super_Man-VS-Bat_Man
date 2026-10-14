# Manual & Visual Runtime Test Results

## Visual & Playable Runtime Tests (Rendered Godot Window)

All visual verification tests were executed against real running Godot 4.7.2 Forward+ Vulkan window instances.

| Test ID | Test Scenario | Verified Visual Behavior | Status | Evidence Screenshot |
|---|---|---|---|---|
| **VIS-01** | **Main Menu Presentation** | Displays original title "SUPERHERO SHOWDOWN: OPEN-WORLD CITY SANDBOX & FIGHTING ARENA" with 4 primary action buttons: 1. CITY, 2. FIGHTING GAME, 3. SETTINGS, 4. EXIT. Dark charcoal styling with cyan highlight. | **PASS** | [`1_main_menu.png`](file:///c:/Users/LOKESH/gotbot%20game/diagnostics/full_adaptation/screenshots/1_main_menu.png) |
| **VIS-02** | **City Submenu Routing** | Clicking "1. CITY" cleanly presents Single Player, Double Player, and Back buttons without overlapping or blocking. | **PASS** | [`2_city_submenu.png`](file:///c:/Users/LOKESH/gotbot%20game/diagnostics/full_adaptation/screenshots/2_city_submenu.png) |
| **VIS-03** | **Single Player Hero Preview** | Selecting Single Player opens hero customization with a live, illuminated, rotating 3D preview of Crimson Weaver or Shadow Knight inside a SubViewport with dedicated directional lighting. | **PASS** | [`3_single_player_preview.png`](file:///c:/Users/LOKESH/gotbot%20game/diagnostics/full_adaptation/screenshots/3_single_player_preview.png) |
| **VIS-04** | **Double Player Hero Previews** | Selecting Double Player opens split hero selection with two independent live 3D character preview turntables for Player 1 and Player 2. | **PASS** | [`4_double_player_preview.png`](file:///c:/Users/LOKESH/gotbot%20game/diagnostics/full_adaptation/screenshots/4_double_player_preview.png) |
| **VIS-05** | **5-Tab Settings Modal** | Settings window features 5 distinct tabs: **Audio** (Master, Music, SFX sliders), **Display** (Window Mode, Resolution, VSync, FPS Limit), **Graphics** (Shadows, Traffic, Crowd, Fog & Glow), **Controls** (Complete keyboard, mouse & gamepad mappings for P1 and P2), and **Accessibility** (Look Sensitivity, Screen Shake toggle, Colorblind filters). | **PASS** | [`5_settings_tabs.png`](file:///c:/Users/LOKESH/gotbot%20game/diagnostics/full_adaptation/screenshots/5_settings_tabs.png) |
| **VIS-06** | **Fighting Game Submenu** | Fighting submenu presents "1 Player vs CPU" (with Easy, Normal, Hard difficulty buttons), "2 Players vs Each Other", and "Back". | **PASS** | [`6_fighting_submenu.png`](file:///c:/Users/LOKESH/gotbot%20game/diagnostics/full_adaptation/screenshots/6_fighting_submenu.png) |
| **VIS-07** | **Fighting Rooftop Arena** | Arena renders full 3D rooftop stage, perimeter hazard boundaries, dual superhero models, combat health bars, damage trail animations, and fighting camera lock-on. | **PASS** | [`7_fighting_arena.png`](file:///c:/Users/LOKESH/gotbot%20game/diagnostics/full_adaptation/screenshots/7_fighting_arena.png) |
| **VIS-08** | **City Single Player Gameplay** | Open-world Coastal City renders in 3D: asphalt roads, painted lane markings, skyscrapers, waterfront, central plaza, autonomous cruising vehicles, walking pedestrians, mission markers, and third-person SpringArm camera with smooth exponential damping and aim FOV. | **PASS** | [`8_city_single_player.png`](file:///c:/Users/LOKESH/gotbot%20game/diagnostics/full_adaptation/screenshots/8_city_single_player.png) |
| **VIS-09** | **City Double Player Split-Screen** | Both heroes spawn safely into the city with two horizontal viewports, independent camera controls, and discrete HUD indicators without viewport blackouts or input collisions. | **PASS** | [`9_city_double_player.png`](file:///c:/Users/LOKESH/gotbot%20game/diagnostics/full_adaptation/screenshots/9_city_double_player.png) |

---

## Separately Labeled Headless Automation Test Results

The following test suites were executed in headless mode to guarantee strict regression-free code execution:

### 1. Scene & Script Validation Suite (`test_runner.gd`)
- **Total Validations:** 24/24 (10 scenes, 14 scripts)
- **Result:** **100% PASS**
- **Log:** All scenes instantiated successfully; all scripts parsed with 0 errors.

### 2. Physics & Movement Audit Suite (`diagnostics/repair_and_physics/physics_validation.gd`)
- **Total Tests:** 44/44
- **Result:** **100% PASS**
- **Key Verified Systems:**
  - Authoritative `PhysicsConfig` loading from `res://data/gameplay_physics_config.tres`.
  - Gravity applied at 24.0 m/s² strictly when `not is_on_floor()`.
  - Terminal fall velocity clamped to 55.0 m/s.
  - Coyote time (0.15s) and jump buffering (0.12s) verified.
  - Air control (22.5 m/s²) strictly separated from ground acceleration (50.0 m/s²).
  - Traversal impulse clamped to 30.0 m/s cap.
  - Vehicle speed (11.0 m/s), steering (6.0), and obstacle deceleration verified.
  - Camera SpringArm collision against Environment layer 1 verified.

### 3. City Sandbox Simulation Suite (`city_simulation_test.gd`)
- **Total Tests:** 10/10
- **Result:** **100% PASS**
- **Verified Systems:** Procedural districts, autonomous traffic, hostile NPC AI & combat responses, Crimson Weaver traversal, Shadow Knight gadgets, collectibles, missions, and double-player split-screen viewports.

### 4. Fighting Arena Combat Suite (`gameplay_simulation_test.gd`)
- **Total Tests:** 9/9
- **Result:** **100% PASS**
- **Verified Systems:** Fighter initialization, arena boundary clamping, opponent facing, jump gravity, melee hitboxes, projectiles, special attacks, dual health bars, and defeat/victory triggers.
