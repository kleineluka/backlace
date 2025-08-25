#ifndef BACKLACE_VERTEX_CGINC
#define BACKLACE_VERTEX_CGINC

FragmentData Vertex(VertexData v)
{
    FragmentData i;
    UNITY_SETUP_INSTANCE_ID(v);
    UNITY_INITIALIZE_OUTPUT(FragmentData, i);
    UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(i);
    
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