Shader "Piexl/NumberCube"
{
	Properties
	{
		_MainTex ("Number", 2D) = "white" {}
		_BorderTex ("Border", 2D) = "white" {}
		_Color("Color",Color)=(0.3,0.3,0.3,1)
		_NumberAlpha("NumberAlpha", Float) = 1
		_BorderAlpha("BorderAlpha", Float) = 1
		_AmbientPower("AmbientPower",Float) = 1
		_DiffuseMax("DiffuseMax",Color) = (0.4,0.4,0.4,1)
	}
	SubShader
	{
		Tags { 
		"Queue"="Transparent"
		//"Queue"="Geometry"
		"RenderType"="Opaque"
		"LightMode"="ForwardBase"
		//"RenderType"="Transparent"
		}
		ZWrite On
		Cull Back
		LOD 100

		Pass
		{
			Blend SrcAlpha OneMinusSrcAlpha

			CGPROGRAM
			//#pragma mult_compile_fwdbase

			#pragma vertex vert
			#pragma fragment frag

			#include "UnityCG.cginc"
			#include "Lighting.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				float3 normal: NORMAL;
			};

			struct v2f
			{
				float4 vertex : SV_POSITION;
				//fixed3 difuseK: TEXCOORD1;
				fixed4 surfaceCol: TEXCOORD2;
			};

			fixed4 _Color;
			fixed _AmbientPower;
			fixed4 _DiffuseMax;

			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);

                fixed3 worldNormal = normalize(mul(v.normal, (float3x3)unity_WorldToObject));
                fixed3 worldLight = normalize(_WorldSpaceLightPos0.xyz);

                fixed3 difuseK = _LightColor0.rgb * saturate(dot(worldNormal, worldLight));

				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz * _AmbientPower;
				fixed3 rgb = _Color.rgb * max(difuseK,_DiffuseMax.rgb) + ambient;
				if(v.normal.z == 1){
					rgb*=0.95;
				}
				if(v.normal.y == -1){
					rgb *= 0.8;
				}
				o.surfaceCol = fixed4(rgb, _Color.a);
				return o;
			}
						
			fixed4 frag (v2f i) : SV_Target
			{
				return i.surfaceCol;
				//return fixed4(_Color.rgb * max(i.difuseK,fixed3(0.4,0.4,0.4)) + ambient, _Color.a);
			}
			ENDCG
		}
	
		Pass{
			Blend SrcAlpha OneMinusSrcAlpha
		
			CGPROGRAM

			#pragma vertex vert
			#pragma fragment frag

			#include "UnityCG.cginc"
			#include "Lighting.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
				float4 vertex : SV_POSITION;
			};

			sampler2D _MainTex;
			float4 _MainTex_ST;
			sampler2D _BorderTex;
			fixed _NumberAlpha;
			fixed _BorderAlpha;

			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				return o;
			}
						
			fixed4 frag (v2f i) : SV_Target
			{
				fixed4 col = tex2D(_MainTex, i.uv) * _NumberAlpha;
				fixed4 colBorder = tex2D(_BorderTex, i.uv) * _BorderAlpha;

				return col + colBorder;
			}
			ENDCG
		}
	}
}
