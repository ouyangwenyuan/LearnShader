shader "Ouyang/Learn/Chapter8/alphatest" {
    Properties {
        _MainTex ("Texture", 2D) = "white" {}
        _Color ("Color", Color) = (1,1,1,1)
        _AlphaCutoff ("Alpha Cutoff", Range(0, 1)) = 0.5
    }
    SubShader {
        tags { "Queue" = "AlphaTest" "IgnoreProjector" ="True" "RenderType" = "TransparentCutout" }

        LOD 100
        Pass {
            Tags { "LightMode" = "ForwardBase" }
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"
            #include "Lighting.cginc"
            #include "Common.cginc"

            fixed4 _Color;
            sampler2D _MainTex;
            float4 _MainTex_ST;
            fixed _AlphaCutoff;
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
                // discard if alpha is less than cutoff
                // clip(col.a - _AlphaCutoff);
                if (col.a < _AlphaCutoff) {
                    discard;
                }
                fixed3 albedo = col.rgb * _Color.rgb;
                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz * albedo;
                // apply lighting
                fixed3 worldNormal = normalize(i.worldNormal);
                fixed3 worldPos = i.worldPos;
                fixed3 lightDir = normalize(_WorldSpaceLightPos0.xyz - worldPos);

                fixed3 diffuse = _LightColor0.rgb * max(0, dot(worldNormal, lightDir)) * albedo;
                return fixed4(diffuse + ambient, 1.0);
            }
            ENDCG
        }
    }
    FallBack "Transparent/Cutout/VertexLit"
}