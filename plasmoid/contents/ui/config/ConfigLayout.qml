import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import org.kde.kirigami as Kirigami
import org.kde.kcmutils as KCM

KCM.SimpleKCM {

    id: appearancePage
    property int cfg_layoutType
    property int cfg_widgetOrder

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

    Component.onCompleted: {
        cfg_layoutTypeChanged()
    }

    ButtonGroup {
        id: layoutTypeGroup
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

    GridLayout {
        anchors.left: parent.left
        anchors.right: parent.right
        columns: 3

        Label {
            text: i18n("Layout type") + ":"
            Layout.alignment: Qt.AlignVCenter | Qt.AlignRight
        }
        RadioButton {
            id: layoutTypeRadioHorizontal
            ButtonGroup.group: layoutTypeGroup
            text: i18n("Horizontal")
            onCheckedChanged: if (checked) cfg_layoutType = 0;
        }
        Label {
            text: i18n("Layout type is not available in the system tray")
            Layout.rowSpan: 3
            Layout.preferredWidth: 250
            wrapMode: Text.WordWrap
        }
        Item {
            width: 2
            height: 2
            Layout.rowSpan: 2
        }
        RadioButton {
            id: layoutTypeRadioVertical
            ButtonGroup.group: layoutTypeGroup
            text: i18n("Vertical")
            onCheckedChanged: if (checked) cfg_layoutType = 1;
        }
        RadioButton {
            id: layoutTypeRadioCompact
            ButtonGroup.group: layoutTypeGroup
            text: i18n("Compact")
            onCheckedChanged: if (checked) cfg_layoutType = 2;
        }

        Item {
            width: 2
            height: 10
            Layout.columnSpan: 3
        }

        Label {
            text: i18n("Widget order") + ":"
            Layout.alignment: Qt.AlignVCenter | Qt.AlignRight
        }
        RadioButton {
            id: widgetOrderIconFirst
            ButtonGroup.group: widgetOrderGroup
            text: i18n("Icon first")
            onCheckedChanged: if (checked) cfg_widgetOrder = 0;
        }
        Label {
            text: i18n("Widget order is not available in either the system tray or the Compact layout")
            Layout.rowSpan: 3
            Layout.preferredWidth: 250
            wrapMode: Text.WordWrap
        }
        Item {
            width: 2
            height: 2
            Layout.rowSpan: 2
        }
        Item {
            width: 2
            height: 2
            Layout.columnSpan: 1
        }
        RadioButton {
            id: widgetOrderTextFirst
            ButtonGroup.group: widgetOrderGroup
            text: i18n("Text first")
            onCheckedChanged: if (checked) cfg_widgetOrder = 1;
        }

        Item {
            width: 2
            height: 18
            Layout.columnSpan: 3
        }

        Label {
            text: i18n("Top Margin") + ":"
            Layout.alignment: Qt.AlignVCenter | Qt.AlignRight
        }

        Item {
            SpinBox {
                id: topOuterMargin
                Layout.alignment: Qt.AlignVCenter
                anchors.verticalCenter: parent.verticalCenter
                stepSize: 1
                from: -999
                value: cfg_topOuterMargin
                to: 999
                onValueChanged: {
                    cfg_topOuterMargin = topOuterMargin.value
                }
            }
            Label {
                anchors.verticalCenter: parent.verticalCenter
                anchors.left:topOuterMargin.right
                anchors.leftMargin: 4
                text: i18nc("pixels", "px")
            }
        }

        Item {
            width: 2
            height: 14
            Layout.columnSpan: 3
        }

        Label {
            text: i18n("Inner Margin") + ":"
            Layout.alignment: Qt.AlignVCenter | Qt.AlignRight
        }

        Item {
            SpinBox {
                id: innerMargin
                Layout.alignment: Qt.AlignVCenter
                anchors.verticalCenter: parent.verticalCenter
                stepSize: 1
                from: -999
                value: cfg_innerMargin
                to: 999
                onValueChanged: {
                    cfg_innerMargin = innerMargin.value
                }
            }
            Label {
                anchors.verticalCenter: parent.verticalCenter
                anchors.left:innerMargin.right
                anchors.leftMargin: 4
                text: i18nc("pixels", "px")
            }
        }

        Item {
            width: 2
            height: 14
            Layout.columnSpan: 3
        }

        Label {
            text: i18n("Right Margin") + ":"
            Layout.alignment: Qt.AlignVCenter | Qt.AlignRight
        }

        Item {
            SpinBox {
                id: rightOuterMargin
                Layout.alignment: Qt.AlignVCenter
                anchors.verticalCenter: parent.verticalCenter
                // decimals: 0
                stepSize: 1
                from: -999
                value: cfg_rightOuterMargin
                to: 999
                onValueChanged: {
                    cfg_rightOuterMargin = rightOuterMargin.value
                }
            }
            Label {
                anchors.verticalCenter: parent.verticalCenter
                anchors.left:rightOuterMargin.right
                anchors.leftMargin: 4
                text: i18nc("pixels", "px")
            }
        }

        Item {
            width: 2
            height: 14
            Layout.columnSpan: 3
        }

        Label {
            text: i18n("Bottom Margin") + ":"
            Layout.alignment: Qt.AlignVCenter | Qt.AlignRight


        }

        Item {
            SpinBox {
                id: bottomOuterMargin
                Layout.alignment: Qt.AlignVCenter
                anchors.verticalCenter: parent.verticalCenter
                stepSize: 1
                from: -999
                value: cfg_bottomOuterMargin
                to: 999
                onValueChanged: {
                    cfg_bottomOuterMargin = bottomOuterMargin.value
                }
            }

            Label {
                anchors.verticalCenter: parent.verticalCenter
                anchors.left:bottomOuterMargin.right
                anchors.leftMargin: 4
                text: i18nc("pixels", "px")
            }
        }

    }
}