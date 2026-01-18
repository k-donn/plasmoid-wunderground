/*
 * Copyright 2026  Kevin Donnelly
 *
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public License as
 * published by the Free Software Foundation; either version 2 of
 * the License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http: //www.gnu.org/licenses/>.
 */

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import org.kde.kirigami as Kirigami
import org.kde.kcmutils as KCM
import org.kde.plasma.components as PlasmaComponents
import "../lib" as Lib

KCM.SimpleKCM {

    id: appearancePage
    property int cfg_layoutType
    property int cfg_widgetOrder
    property int cfg_planarLayoutType

    property alias cfg_propHeadPointSize: propHeadPointSize.value
    property alias cfg_propPointSize: propPointSize.value
    property alias cfg_tempPointSize: tempPointSize.value
    property alias cfg_topIconMargins: topIconMargins.value

    property string cfg_leftOuterMargin: plasmoid.configuration.leftOuterMargin
    property string cfg_innerMargin: plasmoid.configuration.innerMargin
    property string cfg_rightOuterMargin: plasmoid.configuration.rightOuterMargin
    property string cfg_topOuterMargin: plasmoid.configuration.topOuterMargin
    property string cfg_bottomOuterMargin: plasmoid.configuration.bottomOuterMargin


    onCfg_layoutTypeChanged: {
        switch (cfg_layoutType) {
            case 0:
                layoutTypeGroup.checkedButton = layoutTypeRadioHorizontal;
                break;
            case 1:
                layoutTypeGroup.checkedButton = layoutTypeRadioVertical;
                break;
            case 2:
                layoutTypeGroup.checkedButton = layoutTypeRadioCompact;
                break;
            default:
        }
    }

    ButtonGroup {
        id: layoutTypeGroup

        Component.onCompleted: {
            cfg_layoutTypeChanged()
        }
    }

    onCfg_widgetOrderChanged: {
        switch (cfg_widgetOrder) {
            case 0:
                widgetOrderGroup.checkedButton = widgetOrderIconFirst;
                break;
            case 1:
                widgetOrderGroup.checkedButton = widgetOrderTextFirst;
                break;
            default:
        }
    }

    ButtonGroup {
        id: widgetOrderGroup

        Component.onCompleted: {
            cfg_widgetOrderChanged()
        }
    }

    onCfg_planarLayoutTypeChanged: {
        switch (cfg_planarLayoutType) {
            case 0:
                planarLayoutTypeGroup.checkedButton = planarLayoutTypeRadioFull;
                break;
            case 1:
                planarLayoutTypeGroup.checkedButton = planarLayoutTypeRadioCompact;
                break;
            default:
        }
    }

    ButtonGroup {
        id: planarLayoutTypeGroup

        Component.onCompleted: {
            cfg_planarLayoutTypeChanged()
        }
    }



    Kirigami.FormLayout {
        anchors.fill: parent

        Kirigami.Separator {
            Kirigami.FormData.label: i18n("General")
            Kirigami.FormData.isSection: true
        }

        ColumnLayout {
            Kirigami.FormData.label: i18n("Planar layout") + ":"
            Kirigami.FormData.labelAlignment: Qt.AlignTop

            RadioButton {
                id: planarLayoutTypeRadioFull
                ButtonGroup.group: planarLayoutTypeGroup
                text: i18n("Full Representation")
                onCheckedChanged: if (checked) cfg_planarLayoutType = 0;
            }

            RadioButton {
                id: planarLayoutTypeRadioCompact
                ButtonGroup.group: planarLayoutTypeGroup
                text: i18n("Compact Representation")
                onCheckedChanged: if (checked) cfg_planarLayoutType = 1;
            }

            PlasmaComponents.Label {
                text: i18n("Used on the desktop or in a desktop grouper")
            }
        }

        Kirigami.Separator {
            Kirigami.FormData.label: i18n("Full Representation")
            Kirigami.FormData.isSection: true
        }

        PlasmaComponents.SpinBox {
            id: propHeadPointSize

            editable: true

            Kirigami.FormData.label: i18n("Property header text size")
        }

        PlasmaComponents.SpinBox {
            id: propPointSize

            editable: true

            Kirigami.FormData.label: i18n("Property text size")
        }

        PlasmaComponents.SpinBox {
            id: tempPointSize

            editable: true

            Kirigami.FormData.label: i18n("Temperature text size")
        }

        Lib.ConfigComboBox {
            configKey: "detailsIconSize"

            model: [
                {
                    value: 16,
                    text: i18n("small (16x16)")
                },
                {
                    value: 22,
                    text: i18n("smallMedium (22x22)")
                },
                {
                    value: 32,
                    text: i18n("medium (32x32)")
                },
                {
                    value: 48,
                    text: i18n("large (48x48)")
                },
                {
                    value: 64,
                    text: i18n("huge (64x64)")
                },
                {
                    value: 128,
                    text: i18n("enormous (128x128)")
                }
            ]

            Kirigami.FormData.label: i18n("Details icon size:")
        }

        PlasmaComponents.SpinBox {
            id: topIconMargins

            editable: true

            Kirigami.FormData.label: i18n("Top panel icon margins:")
        }

        Kirigami.Separator {
            Kirigami.FormData.label: i18n("Compact Representation")
            Kirigami.FormData.isSection: true
        }

        ColumnLayout {
            Kirigami.FormData.label: i18n("Layout type") + ":"
            Kirigami.FormData.labelAlignment: Qt.AlignTop


            PlasmaComponents.RadioButton {
                id: layoutTypeRadioHorizontal
                ButtonGroup.group: layoutTypeGroup
                text: i18n("Horizontal")
                onCheckedChanged: if (checked) cfg_layoutType = 0;
            }

            PlasmaComponents.RadioButton {
                id: layoutTypeRadioVertical
                ButtonGroup.group: layoutTypeGroup
                text: i18n("Vertical")
                onCheckedChanged: if (checked) cfg_layoutType = 1;
            }

            PlasmaComponents.RadioButton {
                id: layoutTypeRadioCompact
                ButtonGroup.group: layoutTypeGroup
                text: i18n("Compressed")
                onCheckedChanged: if (checked) cfg_layoutType = 2;
            }

            PlasmaComponents.Label {
                text: i18n("Layout type is not available in the system tray")
            }
        }

        ColumnLayout {
            Kirigami.FormData.label: i18n("Widget order") + ":"
            Kirigami.FormData.labelAlignment: Qt.AlignTop


            PlasmaComponents.RadioButton {
                id: widgetOrderIconFirst
                ButtonGroup.group: widgetOrderGroup
                text: i18n("Icon first")
                onCheckedChanged: if (checked) cfg_widgetOrder = 0;
            }
            PlasmaComponents.RadioButton {
                id: widgetOrderTextFirst
                ButtonGroup.group: widgetOrderGroup
                text: i18n("Text first")
                onCheckedChanged: if (checked) cfg_widgetOrder = 1;
            }

            PlasmaComponents.Label {
                text: i18n("Widget order is not available in the system tray")
                wrapMode: Text.NoWrap
            }
        }

        Row {
            Kirigami.FormData.label: i18n("Top Margin") + ":"

            PlasmaComponents.SpinBox {
                id: topOuterMargin
                stepSize: 1
                from: -999
                value: cfg_topOuterMargin
                to: 999
                onValueChanged: {
                    cfg_topOuterMargin = topOuterMargin.value
                }
            }
            PlasmaComponents.Label {
                anchors.verticalCenter: parent.verticalCenter
                text: i18nc("pixels", "px")
            }
        }

        Row {
            Kirigami.FormData.label: i18n("Bottom Margin") + ":"

            PlasmaComponents.SpinBox {
                id: bottomOuterMargin
                stepSize: 1
                from: -999
                value: cfg_bottomOuterMargin
                to: 999
                onValueChanged: {
                    cfg_bottomOuterMargin = bottomOuterMargin.value
                }
            }
            PlasmaComponents.Label {
                anchors.verticalCenter: parent.verticalCenter
                text: i18nc("pixels", "px")
            }
        }

        Row {
            Kirigami.FormData.label: i18n("Left Margin") + ":"

            PlasmaComponents.SpinBox {
                id: leftOuterMargin
                stepSize: 1
                from: -999
                value: cfg_leftOuterMargin
                to: 999
                onValueChanged: {
                    cfg_leftOuterMargin = leftOuterMargin.value
                }
            }
            PlasmaComponents.Label {
                anchors.verticalCenter: parent.verticalCenter
                text: i18nc("pixels", "px")
            }
        }

        Row {
            Kirigami.FormData.label: i18n("Right Margin") + ":"

            PlasmaComponents.SpinBox {
                id: rightOuterMargin
                stepSize: 1
                from: -999
                value: cfg_rightOuterMargin
                to: 999
                onValueChanged: {
                    cfg_rightOuterMargin = rightOuterMargin.value
                }
            }
            PlasmaComponents.Label {
                anchors.verticalCenter: parent.verticalCenter
                text: i18nc("pixels", "px")
            }
        }

        Row {
            Kirigami.FormData.label: i18n("Inner Margin") + ":"

            PlasmaComponents.SpinBox {
                id: innerMargin
                stepSize: 1
                from: -999
                value: cfg_innerMargin
                to: 999
                onValueChanged: {
                    cfg_innerMargin = innerMargin.value
                }
            }
            PlasmaComponents.Label {
                anchors.verticalCenter: parent.verticalCenter
                text: i18nc("pixels", "px")
            }
        }
    }
}