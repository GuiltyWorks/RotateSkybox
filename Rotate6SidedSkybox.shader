// Copyright (c) 2019 Guilty
// MIT License
// GitHub : https://github.com/Guilty-VRChat/OriginalShader
// Twitter : guilty_vrchat
// Gmail : guilty0546@gmail.com

Shader "Guilty/Rotate6SidedSkybox" {
    Properties {
        [Toggle(XAR)] _XAxisRotation ("X-Axis Rotation", float) = 0
        [Toggle(YAR)] _YAxisRotation ("Y-Axis Rotation", float) = 0
        [Toggle(ZAR)] _ZAxisRotation ("Z-Axis Rotation", float) = 0
        _XRotationSpeed ("X-Axis Rotation Speed", Range(0, 100)) = 1
        _XDefaultDegree ("X-Axis Default Degree", Range(0, 360)) = 0
        _YRotationSpeed ("Y-Axis Rotation Speed", Range(0, 100)) = 1
        _YDefaultDegree ("Y-Axis Default Degree", Range(0, 360)) = 0
        _ZRotationSpeed ("Z-Axis Rotation Speed", Range(0, 100)) = 1
        _ZDefaultDegree ("Z-Axis Default Degree", Range(0, 360)) = 0
        _Tint ("Tint Color", Color) = (.5, .5, .5, .5)
        [Gamma] _Exposure ("Exposure", Range(0, 8)) = 1.0
        [NoScaleOffset] _FrontTex ("Front [+Z]   (HDR)", 2D) = "grey" {}
        [NoScaleOffset] _BackTex ("Back [-Z]   (HDR)", 2D) = "grey" {}
        [NoScaleOffset] _LeftTex ("Left [+X]   (HDR)", 2D) = "grey" {}
        [NoScaleOffset] _RightTex ("Right [-X]   (HDR)", 2D) = "grey" {}
        [NoScaleOffset] _UpTex ("Up [+Y]   (HDR)", 2D) = "grey" {}
        [NoScaleOffset] _DownTex ("Down [-Y]   (HDR)", 2D) = "grey" {}
    }

    SubShader {
        Tags {"Queue"="Background" "RenderType"="Background" "PreviewType"="Skybox"}
        Cull Off ZWrite Off

        CGINCLUDE
        #include "UnityCG.cginc"

        //float _XAxisRotation, _YAxisRotation, _ZAxisRotation;
        float _XRotationSpeed, _XDefaultDegree, _YRotationSpeed, _YDefaultDegree, _ZRotationSpeed, _ZDefaultDegree;
        half4 _Tint;
        half _Exposure;

        struct appdata_t {
            float4 vertex : POSITION;
            float2 texcoord : TEXCOORD0;
            UNITY_VERTEX_INPUT_INSTANCE_ID
        };

        struct v2f {
            float4 vertex : SV_POSITION;
            float2 texcoord : TEXCOORD0;
            UNITY_VERTEX_OUTPUT_STEREO
        };

        v2f vert (appdata_t v) {
            float temp;
            #ifdef XAR
                temp = v.vertex.z;
                v.vertex.z = (v.vertex.z * cos(((_Time.x * 2 * _XRotationSpeed) + _XDefaultDegree) * UNITY_PI / 180.0)) + (v.vertex.y * (-sin(((_Time.x * 2 * _XRotationSpeed) + _XDefaultDegree) * UNITY_PI / 180.0)));
                v.vertex.y = (temp * sin(((_Time.x * 2 * _XRotationSpeed) + _XDefaultDegree) * UNITY_PI / 180.0)) + (v.vertex.y * cos(((_Time.x * 2 * _XRotationSpeed) + _XDefaultDegree) * UNITY_PI / 180.0));
            #endif
            #ifdef YAR
                temp = v.vertex.x;
                v.vertex.x = (v.vertex.x * cos(((_Time.x * 2 * _YRotationSpeed) + _YDefaultDegree) * UNITY_PI / 180.0)) + (v.vertex.z * (-sin(((_Time.x * 2 * _YRotationSpeed) + _YDefaultDegree) * UNITY_PI / 180.0)));
                v.vertex.z = (temp * sin(((_Time.x * 2 * _YRotationSpeed) + _YDefaultDegree) * UNITY_PI / 180.0)) + (v.vertex.z * cos(((_Time.x * 2 * _YRotationSpeed) + _YDefaultDegree) * UNITY_PI / 180.0));
            #endif
            #ifdef ZAR
                temp = v.vertex.y;
                v.vertex.y = (v.vertex.y * cos(((_Time.x * 2 * _ZRotationSpeed) + _ZDefaultDegree) * UNITY_PI / 180.0)) + (v.vertex.x * (-sin(((_Time.x * 2 * _ZRotationSpeed) + _ZDefaultDegree) * UNITY_PI / 180.0)));
                v.vertex.x = (temp * sin(((_Time.x * 2 * _ZRotationSpeed) + _ZDefaultDegree) * UNITY_PI / 180.0)) + (v.vertex.x * cos(((_Time.x * 2 * _ZRotationSpeed) + _ZDefaultDegree) * UNITY_PI / 180.0));
            #endif

            /*float alpha = ((_Time.x * 2 * _XRotationSpeed * _XAxisRotation) + _XDefaultDegree) * UNITY_PI / 180.0;
            float sina, cosa;
            sincos(alpha, sina, cosa);
            float2x2 m = float2x2(cosa, -sina, sina, cosa);
            v.vertex.yz = float2(mul(m, v.vertex.yz));

            alpha = ((_Time.x * 2 * _YRotationSpeed * _YAxisRotation) + _YDefaultDegree) * UNITY_PI / 180.0;
            sincos(alpha, sina, cosa);
            m = float2x2(cosa, -sina, sina, cosa);
            v.vertex.xz = float2(mul(m, v.vertex.xz));

            alpha = ((_Time.x * 2 * _ZRotationSpeed * _ZAxisRotation) + _ZDefaultDegree) * UNITY_PI / 180.0;
            sincos(alpha, sina, cosa);
            m = float2x2(cosa, -sina, sina, cosa);
            v.vertex.xy = float2(mul(m, v.vertex.xy));*/

            v2f o;
            UNITY_SETUP_INSTANCE_ID(v);
            UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
            o.vertex = UnityObjectToClipPos(v.vertex);
            o.texcoord = v.texcoord;
            return o;
        }

        half4 skybox_frag (v2f i, sampler2D smp, half4 smpDecode) {
            half4 tex = tex2D (smp, i.texcoord);
            half3 c = DecodeHDR (tex, smpDecode);
            c = c * _Tint.rgb * unity_ColorSpaceDouble.rgb;
            c *= _Exposure;
            return half4(c, 1);
        }

        ENDCG

        Pass {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma target 3.0
            sampler2D _FrontTex;
            half4 _FrontTex_HDR;
            half4 frag (v2f i) : SV_Target {
                return skybox_frag(i,_FrontTex, _FrontTex_HDR);
            }
            ENDCG
        }
        Pass {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma target 3.0
            sampler2D _BackTex;
            half4 _BackTex_HDR;
            half4 frag (v2f i) : SV_Target {
                return skybox_frag(i,_BackTex, _BackTex_HDR);
            }
            ENDCG
        }
        Pass {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma target 3.0
            sampler2D _LeftTex;
            half4 _LeftTex_HDR;
            half4 frag (v2f i) : SV_Target {
                return skybox_frag(i,_LeftTex, _LeftTex_HDR);
            }
            ENDCG
        }
        Pass {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma target 3.0
            sampler2D _RightTex;
            half4 _RightTex_HDR;
            half4 frag (v2f i) : SV_Target {
                return skybox_frag(i,_RightTex, _RightTex_HDR);
            }
            ENDCG
        }
        Pass {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma target 3.0
            sampler2D _UpTex;
            half4 _UpTex_HDR;
            half4 frag (v2f i) : SV_Target {
                return skybox_frag(i,_UpTex, _UpTex_HDR);
            }
            ENDCG
        }
        Pass {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma target 3.0
            sampler2D _DownTex;
            half4 _DownTex_HDR;
            half4 frag (v2f i) : SV_Target {
                return skybox_frag(i,_DownTex, _DownTex_HDR);
            }
            ENDCG
        }
    }
}
