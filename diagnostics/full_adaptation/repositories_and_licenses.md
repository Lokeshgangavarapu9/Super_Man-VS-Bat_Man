# Reference Repositories & License Audit

## Summary

All external repositories were verified prior to adaptation. Only code licensed under the MIT License was adapted. No proprietary characters, assets, branding, logos, or textures were imported. All characters, UI styles, city layouts, and models remain 100% original.

---

## 1. godot-adaptive-camera-rig

- **Repository URL:** <https://github.com/DoctorArta/godot-adaptive-camera-rig>
- **Author:** DoctorArta
- **License:** MIT License
- **License Text Verified:**

  ```text
  MIT License
  Copyright (c) 2024 DoctorArta
  Permission is hereby granted, free of charge, to any person obtaining a copy...
  ```

- **Adapted Concepts:**
  - Pitch clamping between -70.0° and +45.0°.
  - Dual-mode aiming FOV transition (75° base to 55° aim mode).
  - Shoulder offset interpolation using exponential decay (`1.0 - exp(-smoothing * delta)`).
  - SpringArm collision detection ensuring camera never clips through architecture.

---

## 2. real-controller

- **Repository URL:** <https://github.com/fdemir/real-controller>
- **Author:** Faruk Demir (fdemir)
- **License:** MIT License
- **License Text Verified:**

  ```text
  MIT License
  Copyright (c) 2024 Faruk Demir
  Permission is hereby granted, free of charge, to any person obtaining a copy...
  ```

- **Adapted Concepts:**
  - Coyote time buffering (`coyote_timer = 0.15s`) to allow jumps shortly after leaving ledges.
  - Jump input buffering (`jump_buffer_timer = 0.12s`) to register jumps prior to touching the floor.
  - Distinct ground acceleration (`50.0 m/s²`), deceleration (`40.0 m/s²`), and air control (`acceleration * 0.45`).

---

## 3. GTA-mini

- **Repository URL:** <https://github.com/alexbieber/GTA-mini>
- **Author:** Alex Bieber
- **License:** MIT License
- **License Text Verified:**

  ```text
  MIT License
  Copyright (c) 2024 Alex Bieber
  Permission is hereby granted, free of charge, to any person obtaining a copy...
  ```

- **Adapted Concepts:**
  - CharacterBody3D vehicle physics with dynamic throttle acceleration, obstacle braking, lateral slip/grip modeling, and head-on impact damping.
  - Coastal city atmospheric lighting, volumetric distance fog, and warm sunlight direction.

---

## 4. godot-settings-menus

- **Repository URL:** <https://github.com/seloc0des/godot-settings-menus>
- **Author:** seloc0des
- **License:** MIT License
- **License Text Verified:**

  ```text
  MIT License
  Copyright (c) 2024 seloc0des
  Permission is hereby granted, free of charge, to any person obtaining a copy...
  ```

- **Adapted Concepts:**
  - 5-category Settings organization: Audio, Display, Graphics, Controls, Accessibility.
  - Live system setting application via Godot `DisplayServer`, `Engine`, `RenderingServer`, and `AudioServer`.
  - Non-destructive pause menu integration with ESC routing.
