// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Custom/MouseInput"
{
    Properties
    {
        _Color("Main Color", Color) = (1, 1, 1, 1)
        _mX("Mouse X", Float) = 0
        _mY("Mouse Y", Float) = 0
    }
    
    SubShader
    {
        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            
            uniform float4 _Color;
            uniform float _mX;
            uniform float _mY;
            
            struct VertexShaderInput
            {
                float4 vertex: POSITION;
            };
            
            struct VertexShaderOutput
            {
                float4 pos: SV_POSITION;
            };
            
            VertexShaderOutput vert(VertexShaderInput v)
            {
                VertexShaderOutput o;
                o.pos = UnityObjectToClipPos(v.vertex);
                
                return o;
            }
            
            float4 frag(VertexShaderOutput i):SV_TARGET
            {
                float val = _mX/_ScreenParams.x;
                return float4(val, val, val, 1);
            }
       
            
            ENDCG
        }
    }
}