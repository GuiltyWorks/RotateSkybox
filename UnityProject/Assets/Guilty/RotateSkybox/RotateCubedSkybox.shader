// Copyright (c) 2022 Guilty
// MIT License
// GitHub : https://github.com/GuiltyWorks
// Twitter : @GuiltyWorks_VRC
// EMail : guiltyworks@protonmail.com

Shader "Guilty/RotateCubedSkybox" {
    Properties {
        [NoScaleOffset] _Tex ("Cubemap   (HDR)", Cube) = "grey" {}
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

        Pass {
            CGPROGRAM

            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_instancing
            #pragma target 2.0

            #include "UnityCG.cginc"

            struct appdata_t {
                float4 vertex : POSITION;
                float3 texcoord : TEXCOORD0;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            struct v2f {
                float4 vertex : SV_POSITION;
                float3 texcoord : TEXCOORD0;
                UNITY_VERTEX_OUTPUT_STEREO
            };

            float4 _Rotation;
            float4 _Speed;
            samplerCUBE _Tex;
            half4 _Tex_HDR;
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

            fixed4 frag(v2f i) : SV_Target {
                half4 tex = texCUBE(_Tex, i.texcoord);
                half3 c = DecodeHDR(tex, _Tex_HDR);
                c *= _Tint.rgb * unity_ColorSpaceDouble.rgb;
                c *= _Exposure;
                return half4(c, 1);
            }

            ENDCG
        }
    }

    Fallback Off
    CustomEditor "RotateSkybox.RotateSkyboxInspector"
}
