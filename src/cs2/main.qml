import QtQuick 2.7
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.7
import Painter 1.0
import AlgWidgets 2.0
import AlgWidgets.Style 2.0
import "SPWidgets"

Rectangle {
    id: root
    color: AlgStyle.background.color.mainWindow
    height: mainLayout.height
    onHeightChanged: {
        if (height != mainLayout.height) {
            height = Qt.binding(function() {return mainLayout.height});
        }
    }

    property var parameters: [
        { parameter: "u_enable_live_preview",      key: "checked",      component: enableLivePreview },
        { parameter: "u_enable_pbr_validation",    key: "checked",      component: enablePBRValidation },
        { parameter: "u_pbr_limits",               key: "range",        component: pbrLimits },
        { parameter: "weapon",                     key: "currentIndex", component: weaponBox },
        { parameter: "u_finish_style",             key: "currentIndex", component: finishStyleBox },
        { parameter: "u_wear_amount",              key: "value",        component: wearAmount },
        { parameter: "u_tex_scale",                key: "value",        component: texureScale },
        { parameter: "u_ignore_weapon_size_scale", key: "checked",      component: ignoreTextureSizeScale },
        { parameter: "tex_rotation",               key: "range",        component: textureRotation },
        { parameter: "tex_offset_x",               key: "range",        component: textureOffsetX },
        { parameter: "tex_offset_y",               key: "range",        component: textureOffsetY },
        { parameter: "u_col0",                     key: "arrayColor",   component: color0 },
        { parameter: "u_col1",                     key: "arrayColor",   component: color1 },
        { parameter: "u_col2",                     key: "arrayColor",   component: color2 },
        { parameter: "u_col3",                     key: "arrayColor",   component: color3 },
        { parameter: "wear_limits",                key: "range",        component: wearLimits },
        { parameter: "u_use_pearl_mask",           key: "checked",      component: usePearlescentMask },
        { parameter: "u_pearl_scale",              key: "value",        component: pearlescentScale },
        { parameter: "u_use_roughness_tex",        key: "checked",      component: useRoughnessTexture },
        { parameter: "u_paint_roughness",          key: "value",        component: paintRoughness },
        { parameter: "u_use_normal_map",           key: "checked",      component: useNormalMap },
        { parameter: "u_use_material_mask",        key: "checked",      component: useMaterialMask },
        { parameter: "u_use_ao_tex",               key: "checked",      component: useAmbientOcclusion }
    ]

    function displayShaderParameters(shaderId) {
        try {
            for (const param of root.parameters) {
                param.component.key = param.key;
                param.component.parameter = param.parameter;
                if (param.parameter.startsWith("u_")) {
                    param.component.connectShaderParameter(shaderId);
                }
            }
        }
        catch(e) {
            alg.log.exception(e.message);
        }
    }

    function readShaderParameters() {
        var params = [];

        // first try to fetch the parameters saved inside the current opened project
        if (alg.project.settings.contains("CS2WT")) {
            params = alg.project.settings.value("CS2WT");

        // if there's no parameters saved try to fetch them from the plugin settings
        } else if (alg.settings.contains("CS2WT")) {
            params = alg.settings.value("CS2WT");
        }

        for (let i = 0; i < params.length; i++) {
            root.parameters[i].component.update(params[i].value);
        }
    }

    function writeShaderParameters() {
        var params = [];
        for (const param of root.parameters) {
            params.push({ parameter: param.parameter, value: param.component.control[param.key] })
        }
        alg.project.settings.setValue("CS2WT", params);
        alg.settings.setValue("CS2WT", params);
    }

    function importFromEconitem(url) {
        alg.log.warning(`Imported parameters from ${getFileName(url)}.econitem`);
    }

    function exportToEconitem(url) {
        alg.log.warning(`Exported parameters to ${getFileName(url)}.econitem`);
    }

    function getFileName(url) {
        return url.toString().split("/").pop().split(".")[0];
    }

    PainterPlugin {
        onComputationStatusChanged: {
            var meshName = getFileName(alg.project.lastImportedMeshUrl());

            if (weaponBox.control.currentValue != meshName) {
                weaponBox.control.currentIndex = weaponBox.control.model.findIndex(weapon => weapon.value === meshName);
            }
        }

        Component.onCompleted: {
            readShaderParameters();
        }

        onProjectAboutToSave: {
            writeShaderParameters();
        }
    }

    ColumnLayout {
        id: mainLayout
        width: root.width

    //     SPButton {
    //         visible: false
    //         text: "Save as defaults"

    //         onClicked: {
    //             var params = [];
    //             for (const param of root.parameters) {
    //                 params.push({ parameter: param.parameter, value: param.component.control[param.key] })
    //             }
    //             alg.settings.setValue("CS2WT", params);

    //             alg.log.warning("The current settings have been saved as defaults for future projects.");
    //         }
    //     }


        Item {
            Layout.fillWidth: true
            height: layout.height

            RowLayout {
                id: layout
                width: parent.width
                anchors.margins: 10
                spacing: 10

                SPButton {
                    id: exportButton
                    Layout.alignment: Qt.AlignHCenter
                    text: "Export to .econitem"
                    icon.source: "icons/icon_export.png"
                    icon.width: 18
                    icon.height: 18

                    onClicked: {
                        fileDialog.mode = SPFileDialog.Mode.SaveFile
                        fileDialog.title = "Export to .econitem"
                        fileDialog.open()
                    }
                }

                SPButton {
                    id: importButton
                    Layout.alignment: Qt.AlignHCenter
                    text: "Import from .econitem"
                    icon.source: "icons/icon_import.png"
                    icon.width: 18
                    icon.height: 18

                    onClicked: {
                        fileDialog.mode = SPFileDialog.Mode.OpenFile
                        fileDialog.title = "Import from .econitem"
                        fileDialog.open()
                    }
                }
            }

            SPFileDialog {
                id: fileDialog
                folder: "file:///C:\\Program Files (x86)\\Steam\\steamapps\\common\\Counter-Strike Global Offensive\\content\\csgo"
                nameFilters: ["EconItem files (*.econitem)"]

                onAccepted: {
                    fileDialog.folder = fileDialog.fileUrl;
                    if (fileDialog.mode === SPFileDialog.Mode.SaveFile) {
                        exportToEconitem(fileDialog.fileUrl)
                    } else {
                        importFromEconitem(fileDialog.fileUrl)
                    }
                }
            }
        }


        SPSeparator {
            Layout.fillWidth: true
        }

        SPParameterGroup {
            Layout.fillWidth: true
            expandable: false
            padding: 10
            background: Rectangle {
                color: Qt.rgba(1, 1, 1, 0.05)
                border.width: 1
                border.color: Qt.rgba(1, 1, 1, 0.1)
                radius: 10
            }

            SPParameter {
                id: enableLivePreview
                Layout.fillWidth: true
                text: "Live Preview"
                resettable: false
                SPButton {
                    checkable: true
                    text: checked ? "Enabled" : "Disabled"
                }
            }

            SPParameter {
                id: enablePBRValidation
                Layout.fillWidth: true
                text: "PBR Validation"
                resettable: false
                SPButton {
                    checkable: true
                    text: checked ? "Enabled" : "Disabled"
                }
            }

            SPParameter {
                id: pbrLimits
                visible: enablePBRValidation.control.checked
                SPRangeSlider {
                    text: "PBR Limits"
                    stepSize: 1
                    precision: 0
                    from: 0
                    to: 255
                }
            }
        }

        SPSeparator {
            Layout.fillWidth: true
        }

        ColumnLayout {
            Layout.bottomMargin: 10
            Layout.fillWidth: true
            spacing: 10
            enabled: enableLivePreview.control.checked

            SPParameterGroup {
                Layout.fillWidth: true
                text: "Common"

                SPParameter {
                    id: weaponBox
                    text: "Weapon"

                    SPComboBox {
                        model: [
                            { text: "AK-47", value: "ak47" },
                            { text: "AUG", value: "aug" },
                            { text: "AWP", value: "awp" },
                            { text: "PP-Bizon", value: "bizon" },
                            { text: "CZ75-Auto", value: "cz75a" },
                            { text: "Desert Eagle", value: "deagle" },
                            { text: "Dual Berettas", value: "elite" },
                            { text: "FAMAS", value: "famas" },
                            { text: "Five-SeveN", value: "fiveseven" },
                            { text: "Glock-18", value: "glock18" },
                            { text: "G3SG1", value: "g3sg1" },
                            { text: "Galil AR", value: "galilar" },
                            { text: "MAC-10", value: "mac10" },
                            { text: "M249", value: "m249" },
                            { text: "M4A1-S", value: "m4a1_silencer" },
                            { text: "M4A4", value: "m4a4" },
                            { text: "MAG-7", value: "mag7" },
                            { text: "MP5-SD", value: "mp5sd" },
                            { text: "MP7", value: "mp7" },
                            { text: "MP9", value: "mp9" },
                            { text: "Negev", value: "negev" },
                            { text: "Nova", value: "nova" },
                            { text: "P2000", value: "hkp2000" },
                            { text: "P250", value: "p250" },
                            { text: "P90", value: "p90" },
                            { text: "R8 Revolver", value: "revolver" },
                            { text: "Sawed-Off", value: "sawedoff" },
                            { text: "SCAR-20", value: "scar20" },
                            { text: "SG 553", value: "sg553" },
                            { text: "SSG 08", value: "ssg08" },
                            { text: "Tec-9", value: "tec9" },
                            { text: "UMP-45", value: "ump45" },
                            { text: "USP-S", value: "usp_silencer" },
                            { text: "XM1014", value: "xm1014" },
                            { text: "Zeus x27", value: "taser" }
                        ]
                        textRole: "text"
                        valueRole: "value"
                    }
                }

                SPParameter {
                    id: finishStyleBox
                    text: "Finish Style"

                    SPComboBox {
                        model: [
                            { text: "Solid Color", value: 0 },
                            { text: "Hydrographic", value: 1 },
                            { text: "Spray Paint", value: 2 },
                            { text: "Anodized", value: 3 },
                            { text: "Anodized Multicolored", value: 4 },
                            { text: "Anodized Airbrushed", value: 5 },
                            { text: "Custom Paint Job", value: 6 },
                            { text: "Patina", value: 7 },
                            { text: "Gunsmith", value: 8 }
                        ]
                        textRole: "text"
                        valueRole: "value"
                    }
                }

                SPSeparator { }

                SPParameter {
                    id: wearAmount
                    SPSlider {
                        text: "Wear Amount"
                        from: wearLimits.control.minValue
                        to: wearLimits.control.maxValue
                        stepSize: 0.01
                    }
                }

                SPParameter {
                    id: texureScale
                    SPSlider {
                        text: "Texture Scale"
                        from: -10
                        to: 10
                    }
                }

                SPParameter {
                    id: ignoreTextureSizeScale
                    text: "Ignore Weapon Size Scale:"
                    SPButton {
                        checkable: true
                        text: checked ? "Yes" : "No"
                    }
                }
            }

            SPParameterGroup {
                Layout.fillWidth: true
                text: "Texture Placement"

                SPParameter {
                    id: textureRotation
                    SPRangeSlider {
                        text: "Texture Rotation"
                        from: -360
                        to: 360
                        minValue: 0
                        maxValue: 0
                    }
                }

                SPParameter {
                    id: textureOffsetX
                    SPRangeSlider {
                        text: "Texture Offset X"
                        from: -1
                        to: 1
                        minValue: 0
                        maxValue: 0
                    }
                }

                SPParameter {
                    id: textureOffsetY
                    SPRangeSlider {
                        text: "Texture Offset Y"
                        from: -1
                        to: 1
                        minValue: 0
                        maxValue: 0
                    }
                }
            }

            SPParameterGroup {
                Layout.fillWidth: true
                visible: finishStyleBox.control.currentIndex != 6
                text: "Color"

                SPParameter {
                    id: color0
                    text: finishStyleBox.control.currentIndex > 6 ? "Base Metal" : "Base Coat"
                    SPColorButton { }
                }

                SPParameter {
                    id: color1
                    visible: finishStyleBox.control.currentIndex != 3
                    text: finishStyleBox.control.currentIndex > 6 ? "Patina Tint" : "Red Channel"
                    SPColorButton { }
                }

                SPParameter {
                    id: color2
                    visible: finishStyleBox.control.currentIndex != 3
                    text: finishStyleBox.control.currentIndex > 6 ? "Patina Wear" : "Green Channel"
                    SPColorButton { }
                }

                SPParameter {
                    id: color3
                    visible: finishStyleBox.control.currentIndex != 3
                    text: finishStyleBox.control.currentIndex > 6 ? "Grime" : "Blue Channel"
                    SPColorButton { }
                }
            }

            SPParameterGroup {
                Layout.fillWidth: true
                text: "Effects"

                SPParameter {
                    id: wearLimits
                    SPRangeSlider {
                        text: "Wear Limits"
                        from: 0
                        to: 1
                        minValue: 0
                        maxValue: 1
                    }
                }

                SPSeparator { }

                SPParameter {
                    id: usePearlescentMask
                    text: "Pearlescent Mask"
                    SPButton {
                        checkable: true
                        text: checked ? "Use" : "Do not use"
                    }
                }

                SPParameter {
                    id: pearlescentScale
                    SPSlider {
                        text: "Pearlescent Scale"
                        from: -6
                        to: 6
                    }
                }

                SPSeparator { }

                SPParameter {
                    id: useRoughnessTexture
                    property bool checked: true
                    text: "Roughness Texture"
                    SPButton {
                        checkable: true
                        text: checked ? "Use" : "Do not use"

                        onCheckedChanged: {
                            useRoughnessTexture.checked = checked
                        }
                    }
                }
                
                SPParameter {
                    id: paintRoughness
                    visible: !useRoughnessTexture.checked
                    SPSlider {
                        text: "Paint Roughness"
                        from: 0
                        to: 1
                    }
                }
            }

            SPParameterGroup {
                Layout.fillWidth: true
                
                text: "Advanced"
                toggled: false

                SPParameter {
                    id: useNormalMap
                    text: "Normal Map"
                    SPButton {
                        checkable: true
                        text: checked ? "Use" : "Do not use"
                    }
                }

                SPParameter {
                    id: useMaterialMask
                    text: "Material Mask"
                    SPButton {
                        checkable: true
                        text: checked ? "Use" : "Do not use"
                    }
                }

                SPParameter {
                    id: useAmbientOcclusion
                    text: "Ambient Occlusion"
                    SPButton {
                        checkable: true
                        text: checked ? "Use" : "Do not use"
                    }
                }
            }
        }
    }
}
