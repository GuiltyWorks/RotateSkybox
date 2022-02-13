// Copyright (c) 2019 Guilty
// MIT License
// GitHub : https://github.com/Guilty-VRChat/OriginalShader
// Twitter : guilty_vrchat
// Gmail : guilty0546@gmail.com directional inversion

Shader "Guilty/Rotate6SidedSkybox" {
    Properties {
        [Toggle(XAR)] _XAxisRotation ("X-Axis Rotation", float) = 0
        [Toggle(YAR)] _YAxisRotation ("Y-Axis Rotation", float) = 0
        [Toggle(ZAR)] _ZAxisRotation ("Z-Axis Rotation", float) = 0
        _XRotationSpeed ("X-Axis Rotation Speed", Range(0, 100)) = 5
        _XDefaultDegree ("X-Axis Default Degree", Range(0, 360)) = 0
        [Toggle] _XDirectionalInversion("X-Directional Inversion", float) = 0
        _YRotationSpeed ("Y-Axis Rotation Speed", Range(0, 100)) = 5
        _YDefaultDegree ("Y-Axis Default Degree", Range(0, 360)) = 0
        [Toggle] _YDirectionalInversion("Y-Directional Inversion", float) = 0
        _ZRotationSpeed ("Z-Axis Rotation Speed", Range(0, 100)) = 5
        _ZDefaultDegree ("Z-Axis Default Degree", Range(0, 360)) = 0
        [Toggle] _ZDirectionalInversion("Z-Directional Inversion", float) = 0
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

        #pragma multi_compile XAR YAR ZAR

        #include "UnityCG.cginc"

        float _XRotationSpeed, _XDefaultDegree, _XDirectionalInversion, _YRotationSpeed, _YDefaultDegree, _YDirectionalInversion, _ZRotationSpeed, _ZDefaultDegree, _ZDirectionalInversion;
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

        v2f vert(appdata_t v) {
            //#ifdef XAR
                v.vertex.zy = float2(((v.vertex.z * cos(((_Time.y * cos(_XDirectionalInversion * UNITY_PI) * (1 - cos(_XRotationSpeed / 100 * UNITY_PI / 2)) * 360) + _XDefaultDegree) * UNITY_PI / 180.0)) + (v.vertex.y * (-sin(((_Time.y * cos(_XDirectionalInversion * UNITY_PI) * (1 - cos(_XRotationSpeed / 100 * UNITY_PI / 2)) * 360) + _XDefaultDegree) * UNITY_PI / 180.0)))), ((v.vertex.z * sin(((_Time.y * cos(_XDirectionalInversion * UNITY_PI) * (1 - cos(_XRotationSpeed / 100 * UNITY_PI / 2)) * 360) + _XDefaultDegree) * UNITY_PI / 180.0)) + (v.vertex.y * cos(((_Time.y * cos(_XDirectionalInversion * UNITY_PI) * (1 - cos(_XRotationSpeed / 100 * UNITY_PI / 2)) * 360) + _XDefaultDegree) * UNITY_PI / 180.0))));
            //#endif
            #ifdef YAR
                v.vertex.xz = float2(((v.vertex.x * cos(((_Time.y * cos(_YDirectionalInversion * UNITY_PI) * (1 - cos(_YRotationSpeed / 100 * UNITY_PI / 2)) * 360) + _YDefaultDegree) * UNITY_PI / 180.0)) + (v.vertex.z * (-sin(((_Time.y * cos(_YDirectionalInversion * UNITY_PI) * (1 - cos(_YRotationSpeed / 100 * UNITY_PI / 2)) * 360) + _YDefaultDegree) * UNITY_PI / 180.0)))), ((v.vertex.x * sin(((_Time.y * cos(_YDirectionalInversion * UNITY_PI) * (1 - cos(_YRotationSpeed / 100 * UNITY_PI / 2)) * 360) + _YDefaultDegree) * UNITY_PI / 180.0)) + (v.vertex.z * cos(((_Time.y * cos(_YDirectionalInversion * UNITY_PI) * (1 - cos(_YRotationSpeed / 100 * UNITY_PI / 2)) * 360) + _YDefaultDegree) * UNITY_PI / 180.0))));
            #endif
            #ifdef ZAR
                v.vertex.yx = float2(((v.vertex.y * cos(((_Time.y * cos(_ZDirectionalInversion * UNITY_PI) * (1 - cos(_ZRotationSpeed / 100 * UNITY_PI / 2)) * 360) + _ZDefaultDegree) * UNITY_PI / 180.0)) + (v.vertex.x * (-sin(((_Time.y * cos(_ZDirectionalInversion * UNITY_PI) * (1 - cos(_ZRotationSpeed / 100 * UNITY_PI / 2)) * 360) + _ZDefaultDegree) * UNITY_PI / 180.0)))), ((v.vertex.y * sin(((_Time.y * cos(_ZDirectionalInversion * UNITY_PI) * (1 - cos(_ZRotationSpeed / 100 * UNITY_PI / 2)) * 360) + _ZDefaultDegree) * UNITY_PI / 180.0)) + (v.vertex.x * cos(((_Time.y * cos(_ZDirectionalInversion * UNITY_PI) * (1 - cos(_ZRotationSpeed / 100 * UNITY_PI / 2)) * 360) + _ZDefaultDegree) * UNITY_PI / 180.0))));
            #endif

            v2f o;
            UNITY_SETUP_INSTANCE_ID(v);
            UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
            o.vertex = UnityObjectToClipPos(v.vertex);
            o.texcoord = v.texcoord;
            return o;
        }

        half4 skybox_frag(v2f i, sampler2D smp, half4 smpDecode) {
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
            half4 frag(v2f i) : SV_Target {
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
            half4 frag(v2f i) : SV_Target {
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
            half4 frag(v2f i) : SV_Target {
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
            half4 frag(v2f i) : SV_Target {
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
            half4 frag(v2f i) : SV_Target {
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
            half4 frag(v2f i) : SV_Target {
                return skybox_frag(i,_DownTex, _DownTex_HDR);
            }
            ENDCG
        }
    }
}
