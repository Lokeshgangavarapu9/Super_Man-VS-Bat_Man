# Graphics & Atmospheric Changes

## Overview

Visual quality and atmosphere have been upgraded inspired by the coastal aesthetics of GTA-mini and Vice City, while maintaining 100% original geometry and shaders without copyrighted assets.

---

## Key Graphics Improvements

### 1. Environment & Lighting

- **WorldEnvironment:**
  - Upgraded to ACES Filmic tonemapper with 1.05 exposure for cinematic contrast.
  - Added subtle bloom/glow (`intensity = 0.35`, `bloom = 0.12`).
  - Added coastal distance fog (`color = #94AED1`, `density = 0.0018`, `depth_begin = 35.0m`, `depth_end = 240.0m`).
  - Adjusted procedural sky colors with soft coastal amber horizon (`Color(0.7, 0.45, 0.35)`) and deep blue apex (`Color(0.18, 0.38, 0.65)`).
- **Directional Sunlight:**
  - Energy set to `1.35` with warm sunlight tint (`Color(1.0, 0.92, 0.82)`).
  - PSSM 4-Split directional shadows configured with `250.0m` max distance and `1.2` shadow blur.

### 2. City Surfaces & Props

- **Asphalt & Roadway Markings:**
  - Dark slate asphalt material (`Color(0.14, 0.16, 0.18)`, roughness `0.8`).
  - Elevated double-yellow dividing lines and crosswalks.
  - Perimeter barriers (`PerimeterBarrier_0` through `3`) to ensure players never fall through edges into infinity.
- **Waterfront & Plaza:**
  - Emissive shoreline water material with subtle specular gloss.
  - Palm trees, decorative planters, and street lamp posts in central plaza.

### 3. Character Previews

- Character-selection screens in both **Single Player** and **Double Player** feature real 3D SubViewports with dedicated directional key-lights and fill-lights.
- Dynamic 360° turntable rotation displays the selected hero model (Crimson Weaver or Shadow Knight) with custom stylized materials, glowing eyes/emblems, and capes.
