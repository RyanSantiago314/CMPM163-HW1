Shader "Custom/RenderToTexture_CA"
{
	Properties
	{
		_MainTex("Texture", 2D) = "white" {} 
    }
	SubShader
	{
		Tags { "RenderType" = "Opaque" }
		
		Pass
		{

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag

			#include "UnityCG.cginc"
            
            uniform float4 _MainTex_TexelSize;
           
            
			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv: TEXCOORD0;
			};

			struct v2f
			{
				float4 vertex : SV_POSITION;
				float2 uv: TEXCOORD0;
			};
   
			v2f vert(appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = v.uv;
				return o;
			}
            
           
            sampler2D _MainTex;
            
			fixed4 frag(v2f i) : SV_Target
			{
            
                float2 texel = float2(
                    _MainTex_TexelSize.x, 
                    _MainTex_TexelSize.y 
                );
                
                float cx = i.uv.x;
                float cy = i.uv.y;
                
                float4 C = tex2D( _MainTex, float2( cx, cy ));   
                
                float up = i.uv.y + texel.y * 1;
                float down = i.uv.y + texel.y * -1;
                float right = i.uv.x + texel.x * 1;
                float left = i.uv.x + texel.x * -1;
                
                float4 arr[8];
                
                arr[0] = tex2D(  _MainTex, float2( cx   , up ));   //N
                arr[1] = tex2D(  _MainTex, float2( right, up ));   //NE
                arr[2] = tex2D(  _MainTex, float2( right, cy ));   //E
                arr[3] = tex2D(  _MainTex, float2( right, down )); //SE
                arr[4] = tex2D(  _MainTex, float2( cx   , down )); //S
                arr[5] = tex2D(  _MainTex, float2( left , down )); //SW
                arr[6] = tex2D(  _MainTex, float2( left , cy ));   //W
                arr[7] = tex2D(  _MainTex, float2( left , up ));   //NW

                int preyCount = 0;
                int predCount = 0;
                for(int i=0;i<8;i++){
                    if (arr[i].r >= .5 && arr[i].g == 0) {
                        predCount++;
                    }
                    else if (arr[i].r >= .5 && arr[i].g >= .5 && arr[i].b >= .5) {
                        preyCount++;
                    }
                }
                        
                if (C.r >= .5 && C.g >= .5 && C.b >= .5) { //prey cell is alive
                    if (predCount >= 2) {
                        //predators reproduce if there is enough food
                        return float4(1.0, 0.0, 0.0, 1.0);
                    }
                    if (preyCount >= 2 && preyCount <= 6) {
                        //Any live cell with two or three live neighbours lives on to the next generation.

                        return float4(1.0, 1.0, 1.0, 1.0);
                    }
                    else {
                        //Any live cell with fewer than two live neighbours dies, as if caused by underpopulation.
                        //Any live cell with more than three live neighbours dies, as if by overpopulation.

                        return float4(0.0, 0.0, 0.0, 1.0);
                    }
                }
                else if (C.r >= 1 && C.g == 0) //predator is alive
                {
                    if (preyCount >= 2 && preyCount < 8 && (predCount == 1 || predCount == 2))
                    {
                        //predator continues living if it has companions and is not overrun by prey
                        return float4(1.0, 0.0, 0.0, 1.0);
                    }
                    if (predCount == 2) {
                        //Any live predator with two fellow predator neighbours lives on to the next generation.

                        return float4(1.0, 0.0, 0.0, 1.0);
                    }
                    else
                    {
                        return float4(0.0, 0.0, 0.0, 1.0);
                    }
                }
                else { //cell is dead
                    if (preyCount == 2) {
                        //Any dead cell with exactly two live prey becomes a prey cell, as if by reproduction.

                        return float4(1.0,1.0,1.0,1.0);
                    } 
                    if (preyCount >= 2 && (predCount == 2 || predCount == 3))
                    {
                        //Any dead cell with 2 or 3 predator neighbors and enough prey around it becomes a predator as if through reproduction
                        return float4 (1.0, 0, 0, 1.0);
                    }
                    else {
                        return float4(0.0,0.0,0.0,1.0);

                    }
                }
                
            }

			ENDCG
		}

	}
	FallBack "Diffuse"
}