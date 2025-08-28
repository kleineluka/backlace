# Backlace 💗
Backlace is a versatile PBR/Toon/Anime shader for Unity and VRChat whose primary function is to serve as a base for other shaders.

> [!CAUTION]
> **This is inherently not necessarily a replacement for all-in-one shaders (ex. LilToon, Poiyomi, etc.). As such, many features are a naïve implementation.** While fully usable as a stand-alone shader, it is much more lightweight.

## Features 🌈
Backlace comes in three variants: Core, Advanced, and Fun. Each variant builds off the previous one, adding more features and complexity.

**Core Features:**
- Basic Texture Features (Albedo, Normal, etc.)
- Multiple Lighting Models (Backlace, PoiCustom, OpenLit, Standard, Mochie)
- Various Specular Modes (PBR, Anisotropic, Toon, Hair, Cloth)
- Various Diffuse Modes (PBR, Ramp Toon, Anime Toon)
- Light Direction Modes (Backlace, Forced, View Direction)
- UV Manipulation
- UV Effects (Triplanar, Screenspace, Flipbook, Flowmap)
- Emission
- Light Limiting
- Rim Lighting
- Clearcoat
- Matcap
- Decal (2 Slots)
- Texture Post-Processing

**Advanced Features:**
- Cubemap Reflection
- Parallax Mapping (Fasty and Fancy)
- Subsurface Scattering
- Detail Mapping
- Dissolve Effect
- AudioLink Support (not yet implemented)

**Fun Features:**
- Glitter
- Distance Fading
- Iridescence
- Shadow Textures
- Flatten Model (2D Effect)
- World Aligned Textures

**Presets:**
- Fabric Texture
- Wet Surface

**Additional Perks:**
- Custom Editor
- Lightweight and Keyword Optimised
- VR Optimised

## Where Else Backlaced Is Used 🌨️
This section will be updated when I make things with it!

## Building Off Of Backlace 🫧
Backlace is split into a lot of CGInclude files to make it easier to edit, build off of, and maintain.
- You will find most of your actual passes/programs in `Backlace_Vertex.cginc`, `Backlace_Fragment.cginc`, `Backlace_Shadow.cginc`, and `Backlace_Meta.cginc`. There is also an additional `Backlace_Geometry.cginc` template that can be used to add geometry shaders if needed.
- Anything related to lighting modes goes into `Backlace_Lighting.cginc`, while anything related to surface properties and shading goes into `Backlace_Shading.cginc`.
- Extra effects that are not a core part of the shader go into `Backlace_Effects.cginc`.
- Universal helper files exist, such as `Backlace_Keywords.cginc`, `Backlace_Properties.cginc`, and `Backlace_Universal.cginc`.
- Third-party code (such as AudioLink) go into their own files, such as `Backlace_AudioLink.cginc`.

What you edit depends on what you want to do. A good place to start is with `Backlace_Fragment.cginc` and working backwards from there to see what you need to change.

## License ✨
Anything in the [Editor](https://github.com/kleineluka/backlace/tree/main/Resources/Luka_Backlace/Editor) folder in this repository is strictly not for redistribution under any circumstances. This code is provided as a demo UI, and has all of my socials and metadata hard-coded, so you do not want to redistribute this anyways.

The shader itself is under the **MIT license**, with the additional clauses that (1) you must credit Backlace/KleineLuka in your project if you use Backlace in any capacity and (2) the editor exemption stated above.

## Attributions 🎨
- This shader was originally a fork of the [Toony Standard Rebuild](https://github.com/VRLabs/Toony-Standard-Rebuil) shader by VRLabs, which is under the MIT license. However, most of the original code has been rewritten or removed.
- Various lighting modes are derived from other projects, specifically [Poiyomi Toon](https://github.com/poiyomi/PoiyomiToonShader), [lilToon/OpenLit](https://github.com/lilxyzw/lilToon), and [Mochies Unity Shaders](https://github.com/MochiesCode/Mochies-Unity-Shaders/). Thesse are all under the MIT license and usages are limited to lighting modes with those names (ex. \"Poi Custom\", \"OpenLit\", \"Mochies\").
- The 2D effect in the Fun variant is inspired directly by [Lyuma's Waifu2D Shader](https://github.com/lyuma/LyumaShader), which is under the MIT license. Although  please note it is simplified and their code is better if a flat model is purely the goal of your project!