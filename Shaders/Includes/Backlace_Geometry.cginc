#ifndef BACKLACE_GEOMETRY_CGINC
#define BACKLACE_GEOMETRY_CGINC


// [ ♡ ] ────────────────────── [ ♡ ]
//
//         Geometry Shader
//    Warning: You probably don't 
//            need this!
//
// [ ♡ ] ────────────────────── [ ♡ ]


// geometry data
struct GeometryPrimitive
{
    FragmentData v[3];
};

// stackable geometry modification stages
[maxvertexcount(3)]
void Geometry(triangle FragmentData i[3], inout TriangleStream<FragmentData> triStream)
{
    // set up input triangle
    GeometryPrimitive prim;
    prim.v[0] = i[0];
    prim.v[1] = i[1];
    prim.v[2] = i[2];

    // stackable modification stage calls

    // output the modified triangle
    triStream.Append(prim.v[0]);
    triStream.Append(prim.v[1]);
    triStream.Append(prim.v[2]);
    triStream.RestartStrip();
}


#endif // BACKLACE_GEOMETRY_CGINC