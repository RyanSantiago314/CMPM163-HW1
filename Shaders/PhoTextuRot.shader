Shader "CM163/PhoTextuRot"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Color ("Color", Color) = (1, 1, 1, 1)
        _Shininess("Shininess", Float) = 10 //Shininess
        _SpecColor("Specular Color", Color) = (1, 1, 1, 1) //Specular highlights color
        _Blend("Blend", Range(0,1)) = 0.5
        _Speed("Speed", Float) = 1.0
    }
    SubShader
    {

        Pass
        {
            Tags { "LightMode" = "ForwardAdd" } //Important! In Unity, point lights are calculated in the the ForwardAdd pass
            //Blend One One //Turn on additive blending if you have more than one point light

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
    
            #include "UnityCG.cginc"

            uniform float4 _LightColor0; //From UnityCG
            uniform float4 _Color;
            uniform float4 _SpecColor;
            uniform float _Shininess;
            uniform float _Speed;
            float _Blend;

            struct VertexShaderInput
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                float3 normal : NORMAL;
            };

            struct VertexShaderOutput
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
                float3 normal : NORMAL;
                float3 vertexInWorldCoords : TEXCOORD1;
            };

            float3x3 getRotationMatrixY(float theta) {

                float s = -sin(theta);
                float c = cos(theta);
                return float3x3(c, 0, s, 0, 1, 0, -s, 0, c);
            }

            sampler2D _MainTex;

            VertexShaderOutput vert (VertexShaderInput v)
            {
                VertexShaderOutput o;
                const float PI = 3.14159;

                float rad = fmod(_Time.y * -_Speed, PI*2.0); //Loop clockwise

                float3x3 rotationMatrix = getRotationMatrixY(rad);

                float3 rotatedVertex = mul(rotationMatrix, v.vertex.xyz);

                float4 xyz = float4(rotatedVertex, 1.0);
                
                o.vertexInWorldCoords = mul(unity_ObjectToWorld, v.vertex); //Vertex position in WORLD coords
                o.normal = v.normal; //Normal 
                o.vertex = UnityObjectToClipPos(xyz);
                o.uv = v.uv; 
                return o;
            }

            float4 frag (VertexShaderOutput i) : SV_Target
            {
                float3 P = i.vertexInWorldCoords.xyz;
                float3 N = normalize(i.normal);
                float3 V = normalize(_WorldSpaceCameraPos - P);
                float3 L = normalize(_WorldSpaceLightPos0.xyz - P);
                float3 H = normalize(L + V);

                float3 Kd = _Color.rgb; //Color of object
                float3 Ka = float3(0.1,0.1,0.1); //UNITY_LIGHTMODEL_AMBIENT.rgb; //Ambient light
                float3 Ks = _SpecColor.rgb; //Color of specular highlighting
                float3 Kl = _LightColor0.rgb; //Color of light


                //AMBIENT LIGHT 
                float3 ambient = Ka;


                //DIFFUSE LIGHT
                float diffuseVal = max(dot(N, L), 0);
                float3 diffuse = Kd * Kl * diffuseVal;


                //SPECULAR LIGHT
                float specularVal = pow(max(dot(N,H), 0), _Shininess);

                if (diffuseVal <= 0) {
                    specularVal = 0;
                }

                float3 specular = Ks * Kl * specularVal;

                //FINAL COLOR OF FRAGMENT
                float4 lite = float4(ambient + diffuse + specular, 1.0);
                // sample the texture
                float4 col = tex2D(_MainTex, i.uv);
                return lerp(col, lite, _Blend);
            }
            ENDCG
        }
    }
}
