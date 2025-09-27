<p align="left">
  <img src="./.assets/backlace.png" alt="Backlace Logo" width="500"/>
</p>

---

> *Remember that time when I told you to relax? You need some inner-#!&$&%!-peace!*

Backlace is a versatile anime (as well as toon/pbr) shader for Unity and VRChat. Despite mainly serving as a starting point for future projects, you will find that Backlace is packed with a wide range of features- from anime character shading, to screen-space rim lighting, to procedural glitter. 

Integrating into Backlace are some of my other open-source shader projects, such as [Dazzle 🎶](https://github.com/kleineluka/dazzle) providing the user interface and [Premonition 👁️](https://github.com/kleineluka/premonition) providing the compact shader generation.

## Features 🌈
Backlace comes in three variants: Default, Grabpass, and Outline. While Default has most features, some features are exclusive to the other two variants in order to save on performance (ex. not rendering an additional outline pass and not capturing the screen as a grabpass texture).

<details>
  <summary><b>Shader Features</b></summary>

- Basic Texture Features (Albedo, Normal, etc.)
- Multiple Lighting Models (Backlace, PoiCustom, OpenLit, Standard, Mochie)
- Various Specular Modes (PBR, Anisotropic, Toon, Hair, Cloth)
- Various Diffuse Modes (PBR, Ramp Toon, Anime Toon)
- Light Direction Modes (Backlace, Forced, View Direction)
- Vertex Manipulation
- UV Manipulation
- UV Effects (Triplanar, Screenspace, Flipbook, Flowmap)
- Emission
- Light Limiting
- Rim Lighting
- Clearcoat
- Matcap
- Decal (2 Slots)
- Texture Post-Processing
- Cubemap Reflection
- Parallax Mapping (Fasty and Fancy)
- Subsurface Scattering
- Detail Mapping
- Dissolve Effect
- Pathing
- Depth Rim Lighting
- Shadow Map
- Glitter
- Distance Fading
- Iridescence
- Shadow Textures
- Flatten Model (2D Effect)
- World Aligned Textures
- VRChat Mirror Detection
- Touch Interactions
- Dithering
- Vertex Distortion (Wave, Jumble, Wind, Breathing)
- Low Precision (PS1/Low-Poly)
- Refraction (Grabpass Variant Only)
- Fake Screen Space Reflections (Planar and Raymarched) (Grabpass Variant Only)
- Outline (Outline Variant Only)
</details>

<details>
  <summary><b>Third-Party Features</b></summary>

- AudioLink
- Super Plug Shader *(also need it installed)*
- LTCGI *(also need it installed)*
</details>

<details>
  <summary><b>Material Presets</b></summary>

Some preset values for the shader are also provided to help give you a starting point for various (typically more complex) materials. Some require specific variants to work.
- Fabric (Any Variant)
- Wet (Fun Variant)
- Slime (Fun Variant)
- Crystal (Fun Variant)
</details>

## Where Backlace Is Used 🌨️
This section will be updated when I make things with it!

## Building Off Of Backlace 🫧

> [!NOTE] 
> This section is for developers who want to build off of Backlace. If you just want to use Backlace on your avatar, game, etc., you can skip this section. ( \*︾▽︾)

Backlace is split into various .cginclude files to make it editing, building, and maintaining easier.
- `Backlace_Forward.cginc`, `Backlace_Outline.cginc`, `Backlace_Shadow.cginc`, `Backlace_Meta.cginc`, and `Backlace_Geometry.cginc` (optional, not used by default) contain the various passes of the shader.
- `Backlace_Vertex.cginc` and `Backlace_Fragment.cginc` contain the vertex and fragment shaders for the Forward pass.
- `Backlace_Lighting.cginc` contains the various lighting modes, while `Backlace_Shading.cginc` contains the various surface properties and shading code.
- `Backlace_Effects.cginc` contains the various effects exclusive to the Fun variant.
- `Backlace_Keywords.cginc`, `Backlace_Properties.cginc`, and `Backlace_Universal.cginc` contain various helper code used throughout the shader.
- Third-party code (such as AudioLink) go into their own files, such as `Backlace_AudioLink.cginc`.

What you edit depends on what you want to do. A good place to start is with `Backlace_Fragment.cginc` and working backwards from there to see what you need to change.

## License ✨
Anything in the [Editor](https://github.com/kleineluka/backlace/tree/main/Resources/Luka_Backlace/Editor) folder is exempt from this license as it is a separate project used to build Backlace's UI. Backlace itself is licensed under the Backlace License (Version 1.0). For the full legal terms, please see the LICENSE file included in this repository. 

**TL;DR** —
- You **are free to** use Backlace in any project, personal or commercial, for free.
- You **must** give visible credit to "Backlace" in your project and (if creating a derivative shader) interface. For something like a game, a footnote in the game's credits is sufficient!
- You **may not** sell Backlace as a standalone product - naturally, you have to build off of it to include it in a commercial product (ex. a shader that uses Backlace as a base or a game that uses Backlace to shade its characters).

If you have any questions, or feel these terms are too restrictive, please feel free to reach out to me! I only add these clauses to make sure that maintaining Backlace is sustainable for me. 💗

## Attributions 🎨
- This shader was originally a fork of the [Toony Standard Rebuild](https://github.com/VRLabs/Toony-Standard-Rebuild) shader by VRLabs, which is under the MIT license. However, essentially all of that code has been replaced, removed, or rewritten.
- Various lighting modes are derived from other projects, specifically [Poiyomi Toon](https://github.com/poiyomi/PoiyomiToonShader), [lilToon/OpenLit](https://github.com/lilxyzw/lilToon), and [Mochies Unity Shaders](https://github.com/MochiesCode/Mochies-Unity-Shaders/). Thesse are all under the MIT license and usages are limited to lighting modes with those names (ex. \"Poi Custom\", \"OpenLit\", \"Mochies\").
- The 2D effect in the Fun variant is inspired directly by [Lyuma's Waifu2D Shader](https://github.com/lyuma/LyumaShader), which is under the MIT license. Although  please note it is simplified and their code is better if a flat model is purely the goal of your project!
- AudioLink features, and a lot of the boilerplate code in `Backlace_AudioLink.cginc`, are from [AudioLink](https://github.com/llealloo/audiolink), which is under a modified MIT license.
- Original inspiration for the Raymarched SSR feature came from [orel1's SSR module](github.com/orels1/orels-Unity-Shaders), which is an implementation of [Mochie's](https://github.com/MochiesCode/Mochies-Unity-Shaders/) fork of ERROR.mdl's SSR. Both are under MIT licenses. While Backlace's idea stemmed from there, the implementation here is much simpler and modified.