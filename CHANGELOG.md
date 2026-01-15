## Version 2.0.0
- Normal map toggle for better performance, allow deriving normal from albedo as well
- New UI tab "Shading" (and old "Shading" was renamed to "Stylise")
- Parallax was moved to "Effects"
- Shadow Textures was moved to "Stylise"
- Move "Outline Stencil" options to the "Outline" tab
- Global Illumination toggle in Rendering tab
- Optimise shadow caster pass to skip unnecessary compilation
- Support multi-instancing better now (hopefully?)
- Greatly reduce shader variants, keywords, and compilation time
- Change normal calculations to use gram-schmidt orthogonalization
- Avoid potential resampling in specular modes by pre-calculating terms, and fixed other Specular bugs
- Renamed Procedural Anime to Halftone Anime mode
- Added HiFi Anime mode, Skin Anime mode, and Wrapped Anime mode
- Allow multiple ramp maps to be used and cycled through (up to 10)
- Grabpass features (Refraction, SSR) now optionally allow the use of a custom texture in place of the grabpass
- Reduced max raymarch steps in SSR to 35 (from 50) for more reasonable limits

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