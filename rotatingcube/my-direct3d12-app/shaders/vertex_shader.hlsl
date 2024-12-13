float4 main(float4 position : POSITION) : SV_POSITION
{
    // Transform the vertex position to clip space
    return position;
}