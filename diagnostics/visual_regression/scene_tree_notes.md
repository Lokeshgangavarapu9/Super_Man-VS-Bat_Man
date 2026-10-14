# Scene Tree Diagnosis Notes

## 1. Initial State Analysis & Architecture Faults

### A. City Mode Scene Tree (`res://scenes/city.tscn` & `scripts/city_manager.gd`)
- **Active Scene Root:** `City` (`Node3D`, script: `res://scripts/city_manager.gd`)
  - `WorldEnvironment` (SubResource `Environment_city`)
  - `DirectionalLight3D` (Sun light, shadows enabled)
  - `WorldContent` (`Node3D`)
    - `Ground` (`StaticBody3D`)
    - Road surfaces, beach, pier, plaza, fountain, skyscrapers (`SkyPiercerTower`, etc.)
    - Vehicles (`CharacterBody3D`, script `vehicle.gd`)
    - Citizens (`CharacterBody3D`, script `npc.gd`)
    - Hostiles (`CharacterBody3D`, script `hostile_npc.gd`)
    - `Player1` (`CharacterBody3D`, script `player.gd`)
    - `ThirdPersonCamera` (`Node3D`, script `third_person_camera.gd`) -> `SpringArm3D/Camera3D`
  - `SplitScreenContainer` (`HBoxContainer`, anchors 0 to 1 full screen) **[ROOT CAUSE OF BLANK GRAY SCREEN]**
    - `P1ViewportContainer` (`SubViewportContainer`, `stretch=true`, `size_flags_horizontal=3`)
      - `SubViewport` (Empty! No Camera3D child! No scene content!)
    - `P2ViewportContainer` (`SubViewportContainer`, `visible=false`)
      - `SubViewport`
  - `HUD` (`CanvasLayer`)
    - `MarginContainer` -> `TopHeader` (Health bars, Cooldowns, Token counter)
    - `ObjectiveCard` (Mission status card)
    - `CenterBanner`
    - `BottomControls`
    - `PauseMenu`

#### The Blank Gray Screen Bug Mechanism:
`SplitScreenContainer` is a fullscreen UI container placed directly in `city.tscn`. Inside it, `P1ViewportContainer` stretches across 100% of the screen. Because `P1ViewportContainer` contains a `SubViewport` without any `Camera3D` or nodes, Godot's renderer clears that SubViewport to the default project clear color (solid gray #303030).
Although the 3D city and player camera (`cam1`) were actively created under `WorldContent` in the root window viewport, `SplitScreenContainer` was drawn over the entire 3D window like an opaque gray blanket. The 2D `HUD` (`CanvasLayer`) was rendered on top of everything, producing the exact symptom: **HUD visible over a blank gray viewport**.

### B. Main Menu & Character Selection Hierarchy (`res://scenes/main_menu.tscn` & `scripts/main_menu.gd`)
- **Active Scene Root:** `MainMenu` (`Control`, script: `res://scripts/main_menu.gd`)
  - `Background` (`ColorRect`, dark theme)
  - `VBoxContainer`
    - `TitleBox` (Title, Subtitle)
    - `MainMenuButtons` (7 unorganized vertical buttons: Continue, Single Player, Double Player, Collection, Settings, Arena, Quit)
  - `SinglePlayerModal`
    - CardsBox with 2D text bullet points only (**NO 3D MODEL, NO PREVIEW VIEWPORT!**)
  - `DoublePlayerModal`
    - Columns with 2D buttons only (**NO 3D PREVIEW!**)
  - `ArenaModal`
    - Difficulty buttons colliding with launch button (**LAYOUT OVERLAP BUG**)

### C. Repair Architecture Plan
1. **City Viewport Hierarchy:**
   - In **Single Player Mode**: completely hide/disable `SplitScreenContainer` (`split_screen_container.visible = false`). The root window renders `WorldContent` and `p1_camera` directly with native resolution, post-processing, and zero SubViewport overhead.
   - In **Double Player Mode**:
     - When split-screen is enabled, mount `cam1` inside `P1Viewport/SubViewport` and `cam2` inside `P2Viewport/SubViewport`, both sharing `WorldContent.get_world_3d()`.
     - Alternatively, support a unified shared camera that tracks both players smoothly in the root viewport with split viewports as an option.
2. **Main Menu Redesign (Exactly 4 Primary Choices):**
   - 1. **CITY**
     - Submenu: `Single Player`, `Double Player`, `Back`
     - **Single Player Screen**: Large interactive 3D hero showcase (`SubViewport` with 3D hero model, rotating pedestal, lighting, stats, and "ENTER CITY" button).
     - **Double Player Screen**: Dual live 3D preview viewports (Player 1 left, Player 2 right) with independent hero selection, clear badges, and "LAUNCH CO-OP CITY" button.
   - 2. **FIGHTING GAME**
     - Submenu: `1 Player vs CPU`, `2 Players vs Each Other`, `Back`
     - Clean modern layout without overlapping buttons.
   - 3. **SETTINGS**
     - Audio, Sensitivity, Traffic & Population density sliders.
   - 4. **EXIT**
     - Clean exit with confirmation.
3. **Character 3D Preview Component:**
   - Create reusable `scenes/character_preview.tscn` with `SubViewport`, `Camera3D`, lighting, and animated hero mesh instance for Crimson Weaver & Shadow Knight.
