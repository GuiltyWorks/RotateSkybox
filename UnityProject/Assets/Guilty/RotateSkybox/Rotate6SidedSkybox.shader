// Copyright (c) 2022 Guilty
// MIT License
// GitHub : https://github.com/GuiltyWorks
// Twitter : @GuiltyWorks_VRC
// EMail : guiltyworks@protonmail.com

Shader "Guilty/Rotate6SidedSkybox" {
    Properties {
        [NoScaleOffset] _FrontTex ("Front [+Z]   (HDR)", 2D) = "grey" {}
        [NoScaleOffset] _BackTex ("Back [-Z]   (HDR)", 2D) = "grey" {}
        [NoScaleOffset] _LeftTex ("Left [+X]   (HDR)", 2D) = "grey" {}
        [NoScaleOffset] _RightTex ("Right [-X]   (HDR)", 2D) = "grey" {}
        [NoScaleOffset] _UpTex ("Up [+Y]   (HDR)", 2D) = "grey" {}
        [NoScaleOffset] _DownTex ("Down [-Y]   (HDR)", 2D) = "grey" {}
        _Tint ("Tint Color", Color) = (0.5, 0.5, 0.5, 0.5)
        [Gamma] _Exposure ("Exposure", Range(0.0, 8.0)) = 1.0
        _Rotation ("Rotation", Vector) = (0.0, 0.0, 0.0, 0.0)
        _Speed ("Speed", Vector) = (0.0, 0.0, 0.0, 0.0)
    }

    SubShader {
        Tags {
            "Queue" = "Background"
            "RenderType" = "Background"
            "PreviewType" = "Skybox"
        }
        Cull Off
        ZWrite Off

        CGINCLUDE

        #include "UnityCG.cginc"

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

        float4 _Rotation;
        float4 _Speed;
        half4 _Tint;
        half _Exposure;

        float4 euler_to_quaternion(float3 rotation) {
            rotation.x += UNITY_PI;
            rotation *= 0.5;
            rotation.xy = -rotation.yx;
            return float4(cos(rotation.z) * cos(rotation.x) * cos(rotation.y) + sin(rotation.z) * sin(rotation.x) * sin(rotation.y),
                          sin(rotation.z) * cos(rotation.x) * cos(rotation.y) - cos(rotation.z) * sin(rotation.x) * sin(rotation.y),
                          cos(rotation.z) * sin(rotation.x) * cos(rotation.y) + sin(rotation.z) * cos(rotation.x) * sin(rotation.y),
                          cos(rotation.z) * cos(rotation.x) * sin(rotation.y) - sin(rotation.z) * sin(rotation.x) * cos(rotation.y));
        }

        float3 rotate(float3 position, float3 rotation) {
            float4 q = euler_to_quaternion(rotation * UNITY_PI / 180.0);
            return (q.w * q.w - dot(q.xyz, q.xyz)) * position + 2.0 * q.xyz * dot(q.xyz, position) + 2.0 * q.w * cross(q.xyz, position);
        }

        v2f vert(appdata_t v) {
            v.vertex.xyz = rotate(v.vertex.xyz, _Rotation.xyz);
            v.vertex.xyz = rotate(v.vertex.xyz, _Speed.xyz * _Time.y);
            v2f o;
            UNITY_INITIALIZE_OUTPUT(v2f, o);
            UNITY_SETUP_INSTANCE_ID(v);
            UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
            o.vertex = UnityObjectToClipPos(v.vertex);
            o.texcoord = v.texcoord;
            return o;
        }

        half4 skybox_frag(v2f i, sampler2D smp, half4 smpDecode) {
            half4 tex = tex2D(smp, i.texcoord);
            half3 c = DecodeHDR(tex, smpDecode);
            c *= _Tint.rgb * unity_ColorSpaceDouble.rgb;
            c *= _Exposure;
            return half4(c, 1);
        }

        ENDCG

        Pass {
            CGPROGRAM

            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_instancing
            #pragma target 3.0

            sampler2D _FrontTex;
            half4 _FrontTex_HDR;

            half4 frag(v2f i) : SV_Target {
                return skybox_frag(i, _FrontTex, _FrontTex_HDR);
            }

            ENDCG
        }

        Pass {
            CGPROGRAM

            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_instancing
            #pragma target 3.0

            sampler2D _BackTex;
            half4 _BackTex_HDR;

            half4 frag(v2f i) : SV_Target {
                return skybox_frag(i, _BackTex, _BackTex_HDR);
            }

            ENDCG
        }

        Pass {
            CGPROGRAM

            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_instancing
            #pragma target 3.0

            sampler2D _LeftTex;
            half4 _LeftTex_HDR;

            half4 frag(v2f i) : SV_Target {
                return skybox_frag(i, _LeftTex, _LeftTex_HDR);
            }

            ENDCG
        }

        Pass {
            CGPROGRAM

            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_instancing
            #pragma target 3.0

            sampler2D _RightTex;
            half4 _RightTex_HDR;

            half4 frag(v2f i) : SV_Target {
                return skybox_frag(i, _RightTex, _RightTex_HDR);
            }

            ENDCG
        }

        Pass {
            CGPROGRAM

            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_instancing
            #pragma target 3.0

            sampler2D _UpTex;
            half4 _UpTex_HDR;

            half4 frag(v2f i) : SV_Target {
                return skybox_frag(i, _UpTex, _UpTex_HDR);
            }

            ENDCG
        }

        Pass {
            CGPROGRAM

            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_instancing
            #pragma target 3.0

            sampler2D _DownTex;
            half4 _DownTex_HDR;

            half4 frag(v2f i) : SV_Target {
                return skybox_frag(i, _DownTex, _DownTex_HDR);
            }

            ENDCG
        }
    }

    CustomEditor "RotateSkybox.RotateSkyboxInspector"
}
