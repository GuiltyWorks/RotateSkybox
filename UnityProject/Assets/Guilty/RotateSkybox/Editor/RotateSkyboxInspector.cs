// Copyright (c) 2022 Guilty
// MIT License
// GitHub : https://github.com/GuiltyWorks
// Twitter : @GuiltyWorks_VRC
// EMail : guiltyworks@protonmail.com

using UnityEditor;
using UnityEngine;
using System;

namespace RotateSkybox {
    public class RotateSkyboxInspector : ShaderGUI {
        #region MaterialProperties
        MaterialProperty Tex;
        MaterialProperty FrontTex;
        MaterialProperty BackTex;
        MaterialProperty LeftTex;
        MaterialProperty RightTex;
        MaterialProperty UpTex;
        MaterialProperty DownTex;
        MaterialProperty Tint;
        MaterialProperty Exposure;
        MaterialProperty Rotation;
        MaterialProperty Speed;
        #endregion

        public override void OnGUI(MaterialEditor materialEditor, MaterialProperty[] props) {
            Material material = materialEditor.target as Material;
            Shader shader = material.shader;

            bool isCubed = shader.name.Contains("Cubed");
            bool is6Sided = shader.name.Contains("6Sided");

            Tex = FindProperty("_Tex", props, false);
            FrontTex = FindProperty("_FrontTex", props, false);
            BackTex = FindProperty("_BackTex", props, false);
            LeftTex = FindProperty("_LeftTex", props, false);
            RightTex = FindProperty("_RightTex", props, false);
            UpTex = FindProperty("_UpTex", props, false);
            DownTex = FindProperty("_DownTex", props, false);
            Tint = FindProperty("_Tint", props, false);
            Exposure = FindProperty("_Exposure", props, false);
            Rotation = FindProperty("_Rotation", props, false);
            Speed = FindProperty("_Speed", props, false);

            EditorGUIUtility.labelWidth = 0.0f;

            EditorGUI.BeginChangeCheck();

            if (isCubed) {
                UIHelper.ShurikenHeader("Texture");
                UIHelper.DrawWithGroup(() => {
                    materialEditor.ShaderProperty(Tex, "Cubemap   (HDR)");
                    materialEditor.ShaderProperty(Tint, "Tint Color");
                    materialEditor.ShaderProperty(Exposure, "Exposure");
                });
            }

            if (is6Sided) {
                UIHelper.ShurikenHeader("Texture");
                UIHelper.DrawWithGroup(() => {
                    materialEditor.ShaderProperty(FrontTex, "Front [+Z]   (HDR)");
                    materialEditor.ShaderProperty(BackTex, "Back [-Z]   (HDR)");
                    materialEditor.ShaderProperty(LeftTex, "Left [+X]   (HDR)");
                    materialEditor.ShaderProperty(RightTex, "Right [-X]   (HDR)");
                    materialEditor.ShaderProperty(UpTex, "Up [+Y]   (HDR)");
                    materialEditor.ShaderProperty(DownTex, "Down [-Y]   (HDR)");
                    materialEditor.ShaderProperty(Tint, "Tint Color");
                    materialEditor.ShaderProperty(Exposure, "Exposure");
                });
            }

            UIHelper.ShurikenHeader("Rotation");
            UIHelper.DrawWithGroup(() => {
                UIHelper.Vector3Property(Rotation, "Rotation");
                UIHelper.Vector3Property(Speed, "Speed");
            });

            EditorGUI.EndChangeCheck();
        }
    }

    static class UIHelper {
        static int HEADER_HEIGHT = 22;

        public static void DrawShaderPropertySameLine(this MaterialEditor editor, MaterialProperty property) {
            Rect r = EditorGUILayout.GetControlRect(true, 0, EditorStyles.layerMaskField);
            r.y -= HEADER_HEIGHT;
            r.height = MaterialEditor.GetDefaultPropertyHeight(property);
            editor.ShaderProperty(r, property, " ");
        }

        private static Rect DrawShuriken(string title, Vector2 contentOffset) {
            var style = new GUIStyle("ShurikenModuleTitle");
            style.margin = new RectOffset(0, 0, 8, 0);
            style.font = new GUIStyle(EditorStyles.boldLabel).font;
            style.border = new RectOffset(15, 7, 4, 4);
            style.fixedHeight = HEADER_HEIGHT;
            style.contentOffset = contentOffset;
            var rect = GUILayoutUtility.GetRect(16.0f, HEADER_HEIGHT, style);
            GUI.Box(rect, title, style);
            return rect;
        }

        public static void ShurikenHeader(string title) {
            DrawShuriken(title,new Vector2(6.0f, -2.0f));
        }

        public static bool ShurikenFoldout(string title, bool display) {
            var rect = DrawShuriken(title, new Vector2(20.0f, -2.0f));
            var e = Event.current;
            var toggleRect = new Rect(rect.x + 4.0f, rect.y + 2.0f, 13.0f, 13.0f);
            if (e.type == EventType.Repaint) {
                EditorStyles.foldout.Draw(toggleRect, false, false, display, false);
            }
            if (e.type == EventType.MouseDown && rect.Contains(e.mousePosition)) {
                display = !display;
                e.Use();
            }
            return display;
        }

        public static void Vector2Property(MaterialProperty property, string name) {
            EditorGUI.BeginChangeCheck();
            Vector2 vector2 = EditorGUILayout.Vector2Field(name, new Vector2(property.vectorValue.x, property.vectorValue.y), null);
            if (EditorGUI.EndChangeCheck()) {
                property.vectorValue = new Vector4(vector2.x, vector2.y);
            }
        }

        public static void Vector3Property(MaterialProperty property, string name) {
            EditorGUI.BeginChangeCheck();
            Vector3 vector3 = EditorGUILayout.Vector3Field(name, new Vector3(property.vectorValue.x, property.vectorValue.y, property.vectorValue.z), null);
            if (EditorGUI.EndChangeCheck()) {
                property.vectorValue = new Vector4(vector3.x, vector3.y, vector3.z);
            }
        }

        public static void Vector4Property(MaterialProperty property, string name) {
            EditorGUI.BeginChangeCheck();
            Vector4 vector4 = EditorGUILayout.Vector2Field(name, property.vectorValue, null);
            if (EditorGUI.EndChangeCheck()) {
                property.vectorValue = vector4;
            }
        }

        public static void Vector2PropertyZW(MaterialProperty property, string name) {
            EditorGUI.BeginChangeCheck();
            Vector2 vector2 = EditorGUILayout.Vector2Field(name, new Vector2(property.vectorValue.x, property.vectorValue.y), null);
            if (EditorGUI.EndChangeCheck()) {
                property.vectorValue = new Vector4(vector2.x, vector2.y);
            }
        }

        public static void TextureScaleOffsetPropertyIndent(this MaterialEditor editor, MaterialProperty property) {
            EditorGUI.indentLevel++;
            editor.TextureScaleOffsetProperty(property);
            EditorGUI.indentLevel--;
        }

        public static void DrawWithGroup(Action action) {
            EditorGUILayout.BeginVertical(GUI.skin.box);
            action();
            EditorGUILayout.EndVertical();
        }

        public static void DrawWithGroupHorizontal(Action action) {
            EditorGUILayout.BeginHorizontal(GUI.skin.box);
            action();
            EditorGUILayout.EndHorizontal();
        }
    }

    internal class MaterialATSToggleDrawer : MaterialPropertyDrawer {
        public MaterialATSToggleDrawer() { }

        public MaterialATSToggleDrawer(string keyword) { }

        protected virtual void SetKeyword(MaterialProperty prop, bool on) { }

        static bool IsPropertyTypeSuitable(MaterialProperty prop) {
            return prop.type == MaterialProperty.PropType.Float || prop.type == MaterialProperty.PropType.Range;
        }

        public override float GetPropertyHeight(MaterialProperty prop, string label, MaterialEditor editor) {
            return base.GetPropertyHeight(prop, label, editor);
        }

        public override void OnGUI(Rect position, MaterialProperty prop, GUIContent label, MaterialEditor editor) {
            EditorGUI.BeginChangeCheck();
            bool value = Math.Abs(prop.floatValue) > 0.001f;
            EditorGUI.showMixedValue = prop.hasMixedValue;
            value = EditorGUI.Toggle(position, label, value);
            EditorGUI.showMixedValue = false;
            if (EditorGUI.EndChangeCheck()) {
                prop.floatValue = value ? 1.0f : 0.0f;
                SetKeyword(prop, value);
            }
        }

        public override void Apply(MaterialProperty prop) {
            base.Apply(prop);
            if (!IsPropertyTypeSuitable(prop)) {
                return;
            }
            if (prop.hasMixedValue) {
                return;
            }
            SetKeyword(prop, Math.Abs(prop.floatValue) > 0.001f);
        }
    }
}
