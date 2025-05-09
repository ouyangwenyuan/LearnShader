Shader "Ouyang/Learn/Unlit/Chapter_6_diffuse_half_lambert"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _DiffuseColor ("Diffuse Color", Color) = (1,1,1,1)
    }
    SubShader
    {
         // LightMode 用于定义渲染的光照模式，只有定义了正确的光照模式，才能取到Unity一些内置的光照变量
        Tags {"LightMode" = "ForwardBase" }
        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // make fog work
            #pragma multi_compile_fog

            #include "UnityCG.cginc"
            #include "Lighting.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                float4 normal : NORMAL;  // 将模型空间的法线向量填充进NORMAL 变量
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                UNITY_FOG_COORDS(1)
                float4 vertex : SV_POSITION;
                fixed3 worldNormal: TEXCOORD1; // 世界坐标的法线向量
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            fixed4 _DiffuseColor;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                // 获取世界空间的法线
                // fixed3 worldNormal = normalize(mul(v.normal, (float3x3)unity_worldToObject));
                // fixed3 worldNormal = normalize(UnityObjectToWorldNormal(v.normal));
                o.worldNormal = UnityObjectToWorldNormal(v.normal);
                UNITY_TRANSFER_FOG(o,o.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // sample the texture
                fixed4 col = tex2D(_MainTex, i.uv);
                // apply fog
                UNITY_APPLY_FOG(i.fogCoord, col);
                // 获取环境光
                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;
                // 获取世界空间的光照方向
                // 如果场景中有多个光源，且有的类型不是平行光，_WorldSpaceLightPos0 变量得不到正确的结果
                fixed3 lightDir = normalize(_WorldSpaceLightPos0.xyz);
                fixed3 worldNormal = normalize(i.worldNormal.xyz);
                // 计算漫反射强度 在"LightMode"="ForwardBase"的情况下， _LightColor0 变量可访问该pass处理的光源的颜色和强度信息
                // saturate 函数的作用是将输入值限制在0到1之间
                // fixed3 diffuse = _DiffuseColor.rgb * saturate(dot(worldNormal, lightDir)) * _LightColor0.rgb;  // 兰伯特模型
                fixed3 diffuse = _DiffuseColor.rgb * (dot(worldNormal, lightDir)*0.5 + 0.5) * _LightColor0.rgb;  // 半兰伯特模型，将结果从[-1，1] 映射到[0,1]范围内
                fixed4 col1 = fixed4(diffuse + ambient, 1.0);
                return col1;
            }
            ENDCG
        }
    }
}
