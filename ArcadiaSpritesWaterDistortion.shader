// ==============================================================================================
//  ArcadiaSpritesWaterDistortion.shader
// ==============================================================================================
// Project:		Beyond the Sky
// Version:		1.0.0
// Author: 		Federico Mercurio
//			EMail: mercurio@iperuraniaarts.com
//			Twitter: @fefe_mercurio
// Last modified:	22/05/2016
// ==============================================================================================

Shader "Sprites/Water Distortion"
{
	Properties
	{
		[PerRendererData] _Color ("Tint", Color) = (1,1,1,1)
		[NoScaleOffset] _DistortionTexture ("Distortion Texture", 2D) = "white" {}

		_RefractionX("X Refraction", Range(-0.1,0.1)) = 0.01
		_RefractionY("Y Refraction", Range(-0.1,0.1)) = 0.01

		_DistortionScrollX("X Scroll Speed", Range(-0.1,0.1)) = -0.1
		_DistortionScrollY("Y Scroll Speed", Range(-0.1,0.1)) = 0.1
		
		_DistortionScaleX("X Scale", float) = 1.0
		_DistortionScaleY("Y Scale", float) = 1.0
	}

	SubShader
	{
		Tags 
		{ 
			"Queue"="Transparent"
			"IgnoreProjector"="True"
			"RenderType"="Opaque" 
			"PreviewType"="Plane"
			"CanUseSrpiteAtlas"="True"
		}

		Cull Off
		Lighting Off
		ZWrite Off
		Fog { Mode Off }
		Blend One OneMinusSrcAlpha

		GrabPass { }

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#include "UnityCG.cginc"

			struct appdata_t
			{
				float4 vertex : POSITION;
				float4 color : COLOR;
				float2 texcoord : TEXCOORD0;
			};

			struct v2f
			{
				float4 vertex : SV_POSITION;
				fixed4 color : COLOR;
				half2 texcoord : TEXCOORD0;
				half2 grabcoord : TEXCOORD1;
			};

			fixed4 _Color;
			sampler2D _GrabTexture;
			float _DistortionScrollX;
			float _DistortionScrollY;
			float _RefractionX;
			float _RefractionY;
						
			v2f vert (appdata_t IN)
			{
				v2f OUT;
				OUT.vertex = mul(UNITY_MATRIX_MVP, IN.vertex);
				
				#if UNITY_UV_STARTS_AT_TOP
				float scale = -1.0;
				#else
				float scale = 1.0;
				#endif

				OUT.grabcoord = (float2(OUT.vertex.x, OUT.vertex.y * scale) + OUT.vertex.w) * 0.5;

				OUT.texcoord = IN.texcoord.xy;
				OUT.texcoord += _Time.gg * float2(_DistortionScrollX, _DistortionScrollY);

				OUT.grabcoord.x -= _RefractionX / 2;
				OUT.grabcoord.y -= _RefractionY / 2;

				OUT.color = IN.color * _Color;

				return OUT;
			}
			
			sampler2D _DistortionTexture;
			
			float _DistortionPower;
			float _DistortionScaleX;
			float _DistortionScaleY;

			fixed4 frag(v2f IN) : SV_Target
			{
				float2 distortionScale = float2(_DistortionScaleX, _DistortionScaleY);
				float2 refraction = float2(_RefractionX, _RefractionY);
				
				fixed4 c = tex2D(_GrabTexture, IN.grabcoord + (refraction * tex2D(_DistortionTexture, distortionScale * IN.texcoord))) * IN.color;
				c.rgb *= c.a;

				return c;
			}
			ENDCG
		}
	}
}
