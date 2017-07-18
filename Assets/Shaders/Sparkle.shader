Shader "Custom/Sparkle"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_NoiseSizeCoeff("_NoiseSizeCoeff (Bigger => larger glitter spots)", Float) = 0.61
		_NoiseDensity("NoiseDensity (Bigger => larger glitter spots)", Float) = 53.0

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
			// make fog work
			#pragma multi_compile_fog
			
			#include "UnityCG.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
				UNITY_FOG_COORDS(1)
				float4 vertex : SV_POSITION;
			};


			fixed3 mod289(fixed3 x) {
			  return x - floor(x * (1.0 / 289.0)) * 289.0;
			}

			fixed4 mod289(fixed4 x) {
			  return x - floor(x * (1.0 / 289.0)) * 289.0;
			}

			fixed4 permute(fixed4 x) {
			     return mod289(((x*34.0)+1.0)*x);
			}

			fixed4 taylorInvSqrt(fixed4 r)
			{
			  return 1.79284291400159 - 0.85373472095314 * r;
			}


			//FIXME: make as parameter
			float _NoiseSizeCoeff; // Bigger => larger glitter spots
			float _NoiseDensity;  // Bigger => larger glitter spots



			static const fixed2  C = fixed2(1.0/6.0, 1.0/3.0) ;
			static const fixed4  D = fixed4(0.0, 0.5, 1.0, 2.0);
			float snoise(fixed3 v)
			  { 

			  // First corner
			  fixed3 i  = floor(v + dot(v, C.yyy) );
			  fixed3 x0 =   v - i + dot(i, C.xxx) ;

			  // Other corners
			  fixed3 g = step(x0.yzx, x0.xyz);
			  fixed3 l = 1.0 - g;
			  fixed3 i1 = min( g.xyz, l.zxy );
			  fixed3 i2 = max( g.xyz, l.zxy );

			  //   x0 = x0 - 0.0 + 0.0 * C.xxx;
			  //   x1 = x0 - i1  + 1.0 * C.xxx;
			  //   x2 = x0 - i2  + 2.0 * C.xxx;
			  //   x3 = x0 - 1.0 + 3.0 * C.xxx;
			  fixed3 x1 = x0 - i1 + C.xxx;
			  fixed3 x2 = x0 - i2 + C.yyy; // 2.0*C.x = 1/3 = C.y
			  fixed3 x3 = x0 - D.yyy;      // -1.0+3.0*C.x = -0.5 = -D.y

			  // Permutations
			  i = mod289(i); 
			  fixed4 p = permute( permute( permute( 
			             i.z + fixed4(0.0, i1.z, i2.z, 1.0 ))
			           + i.y + fixed4(0.0, i1.y, i2.y, 1.0 )) 
			           + i.x + fixed4(0.0, i1.x, i2.x, 1.0 ));

			  // Gradients: 7x7 points over a square, mapped onto an octahedron.
			  // The ring size 17*17 = 289 is close to a multiple of 49 (49*6 = 294)
			  float n_ = 0.142857142857; // 1.0/7.0
			  fixed3  ns = n_ * D.wyz - D.xzx;

			  fixed4 j = p - 49.0 * floor(p * ns.z * ns.z);  //  mod(p,7*7)

			  fixed4 x_ = floor(j * ns.z);
			  fixed4 y_ = floor(j - 7.0 * x_ );    // mod(j,N)

			  fixed4 x = x_ *ns.x + ns.yyyy;
			  fixed4 y = y_ *ns.x + ns.yyyy;
			  fixed4 h = 1.0 - abs(x) - abs(y);

			  fixed4 b0 = fixed4( x.xy, y.xy );
			  fixed4 b1 = fixed4( x.zw, y.zw );

			  fixed4 s0 = floor(b0)*2.0 + 1.0;
			  fixed4 s1 = floor(b1)*2.0 + 1.0;
			  fixed4 sh = -step(h, fixed4( 0,0,0,0 ));

			  fixed4 a0 = b0.xzyw + s0.xzyw*sh.xxyy ;
			  fixed4 a1 = b1.xzyw + s1.xzyw*sh.zzww ;

			  fixed3 p0 = fixed3(a0.xy,h.x);
			  fixed3 p1 = fixed3(a0.zw,h.y);
			  fixed3 p2 = fixed3(a1.xy,h.z);
			  fixed3 p3 = fixed3(a1.zw,h.w);

			  // Normalise gradients
			  fixed4 norm = taylorInvSqrt(fixed4(dot(p0,p0), dot(p1,p1), dot(p2, p2), dot(p3,p3)));
			  p0 *= norm.x;
			  p1 *= norm.y;
			  p2 *= norm.z;
			  p3 *= norm.w;

			  // Mix final noise value
			  fixed4 m = max(_NoiseSizeCoeff - fixed4(dot(x0,x0), dot(x1,x1), dot(x2,x2), dot(x3,x3)), 0.0);
			  m = m * m;
			  return _NoiseDensity * dot( m*m, fixed4( dot(p0,x0), dot(p1,x1), 
			                                dot(p2,x2), dot(p3,x3) ) );
			}

			
			fixed3 linearLight( fixed3 s, fixed3 d )
			{
				return 2.0 * s + d - 1.0;
			}


			sampler2D _MainTex;
			float4 _MainTex_ST;
			
			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = mul(UNITY_MATRIX_MVP, v.vertex);
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				UNITY_TRANSFER_FOG(o,o.vertex);
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				// sample the texture
				fixed4 col = tex2D(_MainTex, i.uv);
				
				fixed3 pos =  fixed3(i.uv * fixed2( 3. , 1.) - fixed2(0., _Time.y * .00005), _Time.y * .006);   
    			float n =  smoothstep(.50, 1.0, snoise(pos * 80.)) * 8.;
	
				fixed3 noiseGreyShifted = min((fixed3(n,n,n) + 1.) / 3. + .3, fixed3(1.,1.,1.)) * .91;
				
				col = fixed4(linearLight(noiseGreyShifted, col), 1.0);
				return col;
			}
			ENDCG
		}
	}
}