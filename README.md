<p align="left">
  <img src="./.assets/backlace.png" alt="Backlace Logo" width="500"/>
</p>

---

> *Remember that time when I told you to relax? You need some inner-#!&$&%!-peace!*

Backlace 🎀 is a versatile anime (also called "toon", "cel shaded", or "npr") shader for Unity and VRChat. You will find that Backlace is packed with a wide range of features- from anime character shading, to screen-space rim lighting, to procedural glitter. Get started with a single click for a typical fully-lit anime character or dive deep into the advanced settings like Pathing and Refraction! (─‿‿─)♡

## Features 🌈
- **Core Features:**
	- Render Settings/Presets, Alebdo, Normal, Emission
	- Texture Stitching, Texture Post-Processing, Decals
	- Vertex and UV Manipulation, UV Sets
	- Easy VRC Fallback Control
 - **Lighting:**
	 - Models: Backlace (Default), PoiCustom, OpenLit, Standard, Mochie
	 - Direction Modes: Backlace (Default), Forced, View Direction
	 - Diffuse Modes: PBR, Ramp Toon, Anime Toon
- **Specular:** Vertex Specular, PBR Specular, Anisotropic, Toon, Hair, Cloth
- **Shading:** Fresnel Rim, Depth Rim, Matcap, Cubemap, Clearcoat, Subsurface Scattering, Parallax Mapping, Detail Mapping, Shadow Mapping
- **Effects:** Dissolve, Distance Fading, Mirror Detection, Pathing, Glitter, Iridescence, Shadow Textures, World Aligned Textures, Dithering, Touch Interactions, Flatten Model, Vertex Distortion, Low-Precision (PS1), Refraction, (Fake) Screen Space Reflections
- **Shader Variants:** Default, Grabpass, Outline, All
- **Third Party Support:** AudioLink, Super Plug Shader, LTCGI Lighting
- **Custom UI** built with my Dazzle library!
- **Compact Shader Generation** with my Premonitions library!
- **Presets** system built in, alongside custom preset saving
- **9 Languages!** English, German, Japanese, French, Chinese, Spanish, Korean, Russian, and Cat :)

## Where Backlace Is Used 🌨️
This section will be updated when I make things with it!

- The official distribution of Backlace itself!

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

What you edit depends on what you want to do. A good place to start is with `Backlace_Fragment.cginc` and working backwards from there to see what you need to change. This modular practice also makes it easy to dynamically add different versions of the shader (ex. `Outline` or `Grabpass`) - we can just add a new define (ex. `BACKLACE_GRABPASS`) and use that to conditionally compile code.

## License ✨
Anything in the `Editor` and `Processor` folders (which are for Dazzle and Premonitions) are under their respective licenses and not under the Backlace License. Backlace itself is licensed under the Backlace License (Version 1.3). Please see the `LICENSE.md` file for the full terms.

**TL;DR** —
- You’re free to use Backlace in any project (personal or commercial) at no cost.
- You must credit “Backlace” somewhere visible (like your README, store page, or credits) with a link to the official GitHub.
- If you make a derivative shader or tool based on Backlace, please include more visible credit. This doesn't apply to avatars, worlds, or games that use such shaders.
- Anything you sell with Backlace must be transformative (adding significant new features or creativity). You can’t just rebrand or resell Backlace as-is.

If you’re unsure whether your use fits the license or just want to talk about it, feel free to reach out! 💗

## Attributions 🎨
- This shader was originally a fork of the [Toony Standard Rebuild](https://github.com/VRLabs/Toony-Standard-Rebuild) shader by VRLabs, which is under the MIT license. However, essentially all of that code has been replaced, removed, or rewritten.
- Various lighting modes are derived from other projects, specifically [Poiyomi Toon](https://github.com/poiyomi/PoiyomiToonShader), [lilToon/OpenLit](https://github.com/lilxyzw/lilToon), and [Mochies Unity Shaders](https://github.com/MochiesCode/Mochies-Unity-Shaders/). Thesse are all under the MIT license and usages are limited to lighting modes with those names (ex. \"Poi Custom\", \"OpenLit\", \"Mochies\").
- The 2D effect in the Fun variant is inspired directly by [Lyuma's Waifu2D Shader](https://github.com/lyuma/LyumaShader), which is under the MIT license. Although  please note it is simplified and their code is better if a flat model is purely the goal of your project!
- AudioLink features, and a lot of the boilerplate code in `Backlace_AudioLink.cginc`, are from [AudioLink](https://github.com/llealloo/audiolink), which is under a modified MIT license.
- Original inspiration for the Raymarched SSR feature came from [orel1's SSR module](github.com/orels1/orels-Unity-Shaders), which is an implementation of [Mochie's](https://github.com/MochiesCode/Mochies-Unity-Shaders/) fork of ERROR.mdl's SSR. Both are under MIT licenses. While Backlace's idea stemmed from there, the implementation here is much simpler and modified.
- Default textures (ex. ramps and noises) are from a variety of sources online, such as [Perlin Noise Maker](http://kitfox.com/projects/perlinNoiseMaker/), [OpenGameArt](https://opengameart.org/), and [Booth Matcap Pack 2](https://booth.pm/ja/items/5755167).
- The name is inspired by Miss Idiot Angel (literally me).