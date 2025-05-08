Shader "Ouyang/Learn/Custom/VertFragShader"
{
    Properties{
        _MainTex ("Texture", 2D) = "white" {}
        _Color ("Color", Color) = (1,1,1,1)
    }
    SubShader{
        pass {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"

            fixed4 _Color;
            // struct a2f
            // {
            //     float4 vertex : POSITION;
            //     float3 normal : NORMAL;
            //     float4 texcoord : TEXCOORD0;
            // };
            struct v2f
            {
                fixed4 color : COLOR0;
                float4 clipPos : SV_POSITION;
            };

            v2f vert(appdata_full v)
            {
                v2f o;
                o.clipPos = UnityObjectToClipPos(v.vertex);
                // o.color = v.texcoord.rgb;
                // o.color = v.normal*0.5 + fixed3(0.5, 0.5, 0.5);

                // 可视化法线方向
                // o.color = fixed4(v.normal * 0.5 + fixed3(0.5, 0.5, 0.5), 1.0);
                // 可视化切线方向
                o.color = fixed4(v.tangent.xyz * 0.5 + fixed3(0.5, 0.5, 0.5), 1.0);
                // 可视化副切线方向
                // fixed3 binormal = cross(v.normal, v.tangent.xyz) * v.tangent.w;
                // o.color = fixed4(binormal * 0.5 + fixed3(0.5, 0.5, 0.5), 1.0);
                // 可视化第一组纹理坐标
                // o.color = fixed4(v.texcoord.xy, 0.0, 1.0);
                // 可视化第二组纹理坐标
                // o.color = fixed4(v.texcoord1.xy, 0.0, 1.0);
                // 可视化第一组纹理坐标的小数部分
                // o.color = frac(v.texcoord);
                // if (any(saturate(v.texcoord) - v.texcoord)) {
                // o.color.b = 0.5; }
                // o.color.a = 1.0;
                // 可视化第二组纹理坐标的小数部分
                // o.color = frac(v.texcoord1);
                // if (any(saturate(v.texcoord1) - v.texcoord1)) {
                //     o.color.b = 0.5; 
                // }
                // o.color.a = 1.0;
                // 可视化顶点颜色 
                // o.color = v.color * _Color;

                return o;
            }
            fixed4 frag(v2f v) : SV_Target
            {
                return v.color;
            }
            
            ENDCG
        }
    }
}
    // Properties
    // {
    //     _Color ("Color", Color) = (1,1,1,1)
    //     _MainTex ("Albedo (RGB)", 2D) = "white" {}
    //     _Glossiness ("Smoothness", Range(0,1)) = 0.5
    //     _Metallic ("Metallic", Range(0,1)) = 0.0
    // }
    // SubShader
    // {
    //     Tags { "RenderType"="Opaque" }
    //     LOD 200

    //     CGPROGRAM
    //     // Physically based Standard lighting model, and enable shadows on all light types
    //     #pragma surface surf Standard fullforwardshadows

    //     // Use shader model 3.0 target, to get nicer looking lighting
    //     #pragma target 3.0

    //     sampler2D _MainTex;
    //     #include "UnityCG.cginc"
    //     #include "Common.cginc"

    //     struct Input
    //     {
    //         float2 uv_MainTex;
    //     };

    //     half _Glossiness;
    //     half _Metallic;
    //     fixed4 _Color;

    //     // Add instancing support for this shader. You need to check 'Enable Instancing' on materials that use the shader.
    //     // See https://docs.unity3d.com/Manual/GPUInstancing.html for more information about instancing.
    //     // #pragma instancing_options assumeuniformscaling
    //     UNITY_INSTANCING_BUFFER_START(Props)
    //         // put more per-instance properties here
    //     UNITY_INSTANCING_BUFFER_END(Props)

    //     void surf (Input IN, inout SurfaceOutputStandard o)
    //     {
    //         // Albedo comes from a texture tinted by color
    //         fixed4 c = tex2D (_MainTex, IN.uv_MainTex) * _Color;
    //         o.Albedo = c.rgb;
    //         // Metallic and smoothness come from slider variables
    //         o.Metallic = _Metallic;
    //         o.Smoothness = _Glossiness;
    //         o.Alpha = c.a;
    //     }
    //     ENDCG
    // }
    // FallBack "Diffuse"
// }
