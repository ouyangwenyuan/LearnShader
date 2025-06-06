Shader "Ouyang/Learn/Specular/Chapter_7_tex"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _DiffuseColor ("Diffuse Color", Color) = (1,1,1,1)
        _SpecularColor ("Specular Color", Color) = (1,1,1,1)
        _Gloss ("Gloss", Range(8.0, 256)) = 20
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
                fixed3 worldPos: TEXCOORD2; // 顶点坐标转成时间坐标系
            };

            sampler2D _MainTex;
            float4 _MainTex_ST; // ST 是 scale 和 translation 的缩写， 可以让我们得到纹理的缩放和平移（偏移）值。_MainTex_ST.xy 存储的是缩放值，_MainTex_ST.zw 存储的是偏移值
            fixed4 _DiffuseColor;
            fixed4 _SpecularColor;
            float _Gloss;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv * _MainTex_ST.xy + _MainTex_ST.zw;
                // o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                // 获取世界空间的法线
                // fixed3 worldNormal = normalize(mul(v.normal, (float3x3)unity_worldToObject));
                // fixed3 worldNormal = normalize(UnityObjectToWorldNormal(v.normal));
                o.worldNormal = UnityObjectToWorldNormal(v.normal);
                o.worldPos = mul(unity_ObjectToWorld,v.vertex).xyz;
                // UNITY_TRANSFER_FOG(o,o.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // sample the texture
                fixed3 albedo = tex2D(_MainTex, i.uv).rgb *_DiffuseColor.rgb;
                // apply fog
                // UNITY_APPLY_FOG(i.fogCoord, albedo);
                // 获取环境光
                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz * albedo;
                // 获取世界空间的光照方向
                // 如果场景中有多个光源，且有的类型不是平行光，_WorldSpaceLightPos0 变量得不到正确的结果
                fixed3 lightDir = normalize(_WorldSpaceLightPos0.xyz);
                fixed3 worldNormal = normalize(i.worldNormal.xyz);
                // 计算漫反射强度 在"LightMode"="ForwardBase"的情况下， _LightColor0 变量可访问该pass处理的光源的颜色和强度信息
                // saturate 函数的作用是将输入值限制在0到1之间
                fixed3 diffuse = albedo.rgb * max(0, dot(worldNormal, lightDir)) * _LightColor0.rgb;

                // 在世界坐标中计算视角方向
                fixed3 viewDir = normalize(_WorldSpaceCameraPos.rgb - i.worldPos.rgb);
                // blinn phong 模型 没有使用反射方向，而是引入一个新的矢量，通过对视角方向和光照方向相加后归一化所得
                // fixed3 reflectDir = normalize(reflect(-lightDir, worldNormal));
                fixed3 halfDir = normalize(lightDir + viewDir);
                // 计算镜面反射强度
                fixed3 specular = _SpecularColor.rgb * _LightColor0.rgb * pow(max(0, dot(viewDir, halfDir)), _Gloss);

                fixed4 col1 = fixed4(diffuse + ambient + specular, 1.0);
                return col1;
            }
            ENDCG
        }
    }
}
