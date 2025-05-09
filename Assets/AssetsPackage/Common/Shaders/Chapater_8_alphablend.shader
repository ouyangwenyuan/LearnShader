shader "Ouyang/Learn/Chapter8/alphablend" {
    Properties {
        _MainTex ("Texture", 2D) = "white" {}
        _Color ("Color", Color) = (1,1,1,1)
        _AlphaScale ("Alpha Scale", Range(0, 1)) = 1
    }
    SubShader {
        tags { "Queue" = "Transparent" "IgnoreProjector" ="True" "RenderType" = "Transparent" }
        // Pass{
        //     ZWrite On
        //     ColorMask 0
        // }
        Pass {
            Tags { "LightMode" = "ForwardBase" }
            ZWrite Off
            Blend SrcAlpha OneMinusSrcAlpha
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"
            #include "Lighting.cginc"
            #include "Common.cginc"

            fixed4 _Color;
            sampler2D _MainTex;
            float4 _MainTex_ST;
            fixed _AlphaScale;
            struct appdata {
                float4 vertex : POSITION;
                float4 texcoord : TEXCOORD0;
                float3 normal : NORMAL;
            };
            struct v2f {
                float4 vertex : SV_POSITION;
                fixed3 worldNormal: TEXCOORD0; // 世界坐标的法线向量
                fixed3 worldPos: TEXCOORD1; // 顶点坐标转成世界坐标系
                float2 uv : TEXCOORD2;
            };
            v2f vert (appdata v) {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.worldNormal = UnityObjectToWorldNormal(v.normal);
                o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
                o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);
                return o;
            }
            fixed4 frag(v2f i): SV_TARGET {
                // sample the texture
                fixed4 col = tex2D(_MainTex, i.uv);

                fixed3 albedo = col.rgb * _Color.rgb;
                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz * albedo;
                // apply lighting
                fixed3 worldNormal = normalize(i.worldNormal);
                fixed3 worldPos = i.worldPos;
                fixed3 lightDir = normalize(_WorldSpaceLightPos0.xyz - worldPos);

                fixed3 diffuse = _LightColor0.rgb * max(0, dot(worldNormal, lightDir)) * albedo;
                return fixed4(diffuse + ambient, col.a * _AlphaScale);
            }
            ENDCG
        }
    }
    FallBack "Transparent/VertexLit"
}