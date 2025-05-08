Shader "Ouyang/Learn/Unlit/Chapger_2_1"
{
    Properties
    {
        _Color ("Color", Color) = (1,1,1,1)
        _MainTex ("Texture", 2D) = "white" {}
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"
            #include "Common.cginc"

            sampler2D _MainTex;
            float4 _Color;
            float4 _MainTex_ST;

            appdata_full vert (appdata_full v)
            {
                v.vertex = UnityObjectToClipPos(v.vertex);
                // v.texcoord.xy = TRANSFORM_TEX(v.texcoord, _MainTex);
                v.color = _Color;
                return v;
            }

            float4 frag (appdata_full v) : SV_Target
            {
                float4 col = tex2D(_MainTex,v.texcoord.xy)*v.color;
                return col;
            }
            ENDCG
        }
    }
}
