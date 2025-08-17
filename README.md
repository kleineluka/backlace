# Backlace 💗
Base Toon Shader for VRChat & Unity. Forked from [Toony Rebuild](https://github.com/VRLabs/Toony-Standard-Rebuild/tree/main) which is under the [MIT License](https://github.com/VRLabs/Toony-Standard-Rebuild/blob/main/LICENSE). More information (license, features, etc.) will be added as the shader is (re-)built.

## Code Structure

- `Backlace.shader`: The main shader file.
- `Includes/`: Contains shader include files that are used by the main shader.
    - `Backlace_Universal.cginc`: Contains shared code between all (or mostly all) passes.
    - `Backlace_Forward.cginc`: Contains shared code between the base and add passes.
    - `Backlace_Vertex.cginc`: Contains vertex shader code.
    - `Backlace_Base.cginc`: Contains code specific to the base pass.
    - `Backlace_Add.cginc`: Contains code specific to the add pass.
    - `Backlace_Shadow.cginc`: Contains code specific to the shadow pass.
    - `Backlace_Meta.cginc`: Contains code specific to the meta pass.

Throughout the code, you may see `// todo:` comments. If you want to contribute, feel free to pick up any of these todos and submit a pull request!

## License

Anything in the [Editor](https://github.com/kleineluka/backlace/tree/main/Resources/Luka_Backlace/Editor) folder in this repository is strictly not for redistribution under any circumstances. This code is provided as a demo UI, and has all of my socials and metadata hard-coded, so you do not want to redistribute this anyways.

The shader itself will be very permissive, but I have yet to decide on a license.

## Notice

This shader is intended as a base for other shaders, not necessarily a stand-alone shader. It is also primarily intended for *me*, but I figured it may be helpful to share with the community, as I am also using tools from the community in this process.
