## Version 2.2.0
- Rewrote some less-than-ideal lighting data calculations leftover from Toony Standard Rebuild
- Introduce "NPR" and "Cel" anime modes, starting to replace the old anime modes. I plan two more(?)
- Removed "Area Tint" from shading.
- Streamlined shadow mapping.
- Added "Manual Normals" feature in anime shading (for smoother shadows without SDF masking)

## Version 2.1.0
- New light direction modes, "Object Relative" and "Ambient Priority"
- Add Lighting Source modes "Backlace" and "Unity" (Backlace is a bit more expensive, but higher quality)
- Removed reused code and variables, hopefully helping register pressure

## Version 2.0.5
- Improved SSS thickness and changed from linear approximation to Beer's Law.
- Attenuation is applied across all relevant Effects now!
- Attenuation can now be manually controlled, if desired.

## Version 2.0.3
- All anime shading modes now have proper attenuation, sorry about that (╥﹏╥)

## Version 2.0.2
- Fixed old function call in HiFi Vertex Lighting

## Version 2.0.1
- Improve light checks
- Fix lightmaps not being assigned properly

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
- Stickers are merged into one, and support new settings! (screen space mapping, overlay mode, more pattern control)
- Add a "Silhouette/Backdrop" mode for Outline
- Improved Shadowcaster pass to sample less and do less work
- Added internal debugging functions
- Restructure folder hierarchy to prevent editor-only assets being included in builds (very small difference, but eh, it's something!)
- Introduce "World" and "World Outline" variants of the shader
- New "Stochastic Sampling" effect in the World variants of the shader, with heitz/contrast sampling and naïve/competitive blending
- New "Splatter Mapping" effect in the World variants of the shader, with triplanar and standard UV mapping modes
- Reduce sampler count by keeping secondary textures using shared samplers (ex. a distortion map will use the same sampler as the albedo of that effect). Will prevent edge cases of exceeding sampler limits on certain platforms.
- New "Texture Bombing" effect in the World variants of the shader, allowing for large-scale repeating decal textures with variation and spritesheet support
- Specular energy can now, optionally, be functional with various modes and limits

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