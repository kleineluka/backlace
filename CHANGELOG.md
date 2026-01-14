## Version 2.0.0
- Normal map toggle for better performance, allow deriving normal from albedo as well
- New UI tab "Shading" (and old "Shading" was renamed to "Stylise")
- Parallax was moved to "Effects"
- Shadow Textures was moved to "Stylise"
- Move "Outline Stencil" options to the "Outline" tab
- Global Illumination toggle in Rendering tab
- Optimise shadow caster pass to skip unnecessary compilation
- Support multi-instancing better now (hopefully?)
- Switch all multi_compile to shader_feature_local for better performance
- Greatly reduce shader variants, keywords, and compilation time
- Specular now has two selections: Mode and Type. For instance, Special Mode can be Hair or Cloth type.

## Version 1.8.5
- Add shift support to B channel of hair specular map
- Add jitter support to hair specular

## Version 1.8
- More editor improvements (primarily the badge system)
- Much better preset handling, as well as an "optimise preset" option
- Better default values (Anime Diffuse starts on, default to white ramp map)
- "Glitch" mode for Vertex Distortion
- Bug fixes and optimisations (shadow calculations, outline drawing, ui errors, etc.)
- Additional Outline options
- Rewrote AudioLink integration for more control
- Expanded settings
- Updated license to Version 1.5
- Updated translations
- Code cleanup
- Legacy mode (for older hardware, support SM 3.0 instead of 5.0)
- **Stable and battle-tested release!**

## Version 1.5
- Editor improvements (cleaner, search bar, etc.)
- New parallax mapping modes (interior and layered)
- Many bug fixes
- SDF Shadow Shading feature for Anime Shading
- Compact shader generation fixes
- Outline rewrite and additional settings

## Version 1.0
- Release