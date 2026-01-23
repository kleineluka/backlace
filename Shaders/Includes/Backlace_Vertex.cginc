#ifndef BACKLACE_VERTEX_CGINC
#define BACKLACE_VERTEX_CGINC


// [ ♡ ] ────────────────────── [ ♡ ]
//
//       Forward Vertex Shader
//
// [ ♡ ] ────────────────────── [ ♡ ]


FragmentData Vertex(VertexData v)
{
    FragmentData i;
    UNITY_SETUP_INSTANCE_ID(v);
    UNITY_INITIALIZE_OUTPUT(FragmentData, i);
    UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(i);
    // set up audio link values
    #if defined(_BACKLACE_AUDIOLINK)
        BacklaceAudioLinkData al_data = CalculateAudioLinkEffects();
        i.alChannel1 = float4(al_data.emission, al_data.rim, al_data.hueShift, al_data.matcap);
        i.alChannel2 = float4(al_data.pathing, al_data.glitter, al_data.iridescence, al_data.decalHue);
        i.alChannel3 = float2(al_data.decalEmission, al_data.decalOpacity);
        v.vertex.xyz *= _VertexManipulationScale * al_data.vertexScale; // scale
    #else // _BACKLACE_AUDIOLINK
        v.vertex.xyz *= _VertexManipulationScale; // scale
    #endif // _BACKLACE_AUDIOLINK
    // vertex manipulation (continued)
    v.vertex.xyz += _VertexManipulationPosition; // position
    // vertex distortion
    #if defined(_BACKLACE_VERTEX_DISTORTION)
        ApplyVertexDistortion(v.vertex, mul(unity_ObjectToWorld, v.vertex).xyz, v.color);
    #endif // _BACKLACE_VERTEX_DISTORTION
    // boilerplate assignments
    i.vertex = v.vertex;
    i.pos = UnityObjectToClipPos(v.vertex); 
    i.normal = UnityObjectToWorldNormal(v.normal);
    i.worldPos = mul(unity_ObjectToWorld, v.vertex);
    i.worldObjectCenter = mul(unity_ObjectToWorld, float4(0, 0, 0, 1)).xyz;
    i.tangentDir = v.tangentDir;
    i.uv = v.uv;
    i.uv1 = v.uv1;
    i.uv2 = v.uv2;
    i.uv3 = v.uv3;
    // ps1 effect
    #if defined(_BACKLACE_PS1)
        ApplyPS1Vertex(i, v);
    #endif // _BACKLACE_PS1
    // for screen related effects
    i.scrPos = ComputeScreenPos(i.pos);
    // flat model feature
    #if defined(_BACKLACE_FLAT_MODEL)
        FlattenModel(v.vertex, v.normal, i.pos, i.worldPos, i.normal);
    #endif // _BACKLACE_FLAT_MODEL
    UNITY_TRANSFER_SHADOW(i, v.uv);
    UNITY_TRANSFER_FOG(i, i.pos);
    #if defined(LIGHTMAP_ON)
        i.lightmapUV = v.uv1 * unity_LightmapST.xy + unity_LightmapST.zw;
    #endif // LIGHTMAP_ON
    #if defined(DYNAMICLIGHTMAP_ON)
        i.dynamicLightmapUV = v.uv2 * unity_DynamicLightmapST.xy + unity_DynamicLightmapST.zw;
    #endif // DYNAMICLIGHTMAP_ON
    #if defined(_BACKLACE_MATCAP)
        float3 worldN = UnityObjectToWorldNormal(v.normal);
        float3 viewN = mul((float3x3)UNITY_MATRIX_V, worldN);
        i.matcapUV = viewN.xy * 0.5 + 0.5;
    #endif // _BACKLACE_MATCAP
    return i;
}


#endif // BACKLACE_VERTEX_CGINC