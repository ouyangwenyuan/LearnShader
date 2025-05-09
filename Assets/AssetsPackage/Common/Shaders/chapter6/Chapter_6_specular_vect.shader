// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Ouyang/Learn/Specular/Chapter_6_specular_vect"
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
            // 光照相关的头文件
            #include "Lighting.cginc"

            struct appdata
            {
                float4 vertex : POSITION; // 模型的顶点坐标（模型空间）传入
                float2 uv : TEXCOORD0;
                float4 normal : NORMAL;  // 将模型空间的法线向量填充进NORMAL 变量
            };

            struct v2f
            {
                float3 color: COLOR; // 存储的颜色信息，不是必须使用COLOR 语义，ye可以使用TEXCOOD0
                float4 vertex : SV_POSITION;
                float2 uv : TEXCOORD0;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            // Diffuse Color
            fixed4 _DiffuseColor;
            fixed4 _SpecularColor;
            float _Gloss;

            v2f vert (appdata v)
            {
                v2f o;
                // 模型空间坐标转换到裁剪空间坐标
                o.vertex = UnityObjectToClipPos(v.vertex);
                // o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                UNITY_TRANSFER_FOG(o,o.vertex);
                // 获取环境光
                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;
                // 获取世界空间的法线
                // fixed3 worldNormal = normalize(mul(v.normal, (float3x3)unity_worldToObject));
                fixed3 worldNormal = normalize(UnityObjectToWorldNormal(v.normal));
                // 获取世界空间的光照方向
                // 如果场景中有多个光源，且有的类型不是平行光，_WorldSpaceLightPos0 变量得不到正确的结果
                fixed3 lightDir = normalize(_WorldSpaceLightPos0.xyz);
                // 计算漫反射强度 在"LightMode"="ForwardBase"的情况下， _LightColor0 变量可访问该pass处理的光源的颜色和强度信息
                // saturate 函数的作用是将输入值限制在0到1之间
                fixed3 diffuse = _DiffuseColor.rgb * saturate(dot(worldNormal, lightDir)) * _LightColor0.rgb;

                // 在世界坐标系中计算反射方向
                fixed3 reflectDir = normalize(reflect(-lightDir, worldNormal));
                // 在世界坐标中计算视角方向
                fixed3 viewDir = normalize(_WorldSpaceCameraPos - mul(unity_ObjectToWorld, v.vertex).xyz);
                // 计算镜面反射强度
                fixed3 specular = _SpecularColor.rgb * _LightColor0.rgb * pow(saturate(dot(reflectDir, viewDir)), _Gloss);
                o.color = (diffuse + ambient + specular);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // sample the texture
                fixed4 col = tex2D(_MainTex, i.uv);
                // // apply fog
                UNITY_APPLY_FOG(i.fogCoord, col);
                fixed4 col1 =  fixed4(i.color, 1.0);
                return col1;
            }
            ENDCG
        }
    }
    Fallback "Diffuse" // 备用着色器
}
