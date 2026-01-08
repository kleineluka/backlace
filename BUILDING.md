## Building Off Of Backlace 🫧
> [!NOTE] 
> This section is for developers who want to build off of Backlace. If you just want to use Backlace on your avatar, game, etc., you can skip this section. ( \*︾▽︾)

Backlace is split into various `.cginclude` files to make it editing, building, and maintaining easier. For those unaware, `.cginclude` files are similar to `.h` or header files in C/C++ ~ they contain code that is included into other shader files.
- `Backlace_Forward.cginc`, `Backlace_Outline.cginc`, `Backlace_Shadow.cginc`, `Backlace_Meta.cginc`, and `Backlace_Geometry.cginc` (optional, not used by default) contain the various passes of the shader.
- `Backlace_Vertex.cginc` and `Backlace_Fragment.cginc` contain the vertex and fragment shaders for the Forward pass. **This is likely where you’ll want to start if you’re building off of Backlace.**
- `Backlace_Lighting.cginc` contains the various lighting modes and code to gather lighting information (ex. light direction, light color, shadowing, etc.).
- `Backlace_Shading.cginc` contains the various surface properties and shading code (ex. normals, anime diffuse, specular).
- `Backlace_Effects.cginc` contains the various effects that are typically gatekept by keywords (ex. vertex distortion or pathing).
- `Backlace_Keywords.cginc` and `Backlace_Properties.cginc` contain properties reused through multiple passes.
- `Backlace_Universal.cginc` contains various helper code used throughout the shader.
- Third-party code (such as AudioLink) go into their own files, such as `Backlace_AudioLink.cginc`.

---
What you edit depends on what you want to do. A good place to start is with `Backlace_Fragment.cginc` and working backwards from there to see what you need to change. This modular practice also makes it easy to dynamically add different versions of the shader (ex. `Outline` or `Grabpass`) - we can just add a new define (ex. `BACKLACE_GRABPASS`) and use that to conditionally compile code.