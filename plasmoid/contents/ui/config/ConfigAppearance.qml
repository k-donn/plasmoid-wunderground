import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import org.kde.kirigami as Kirigami
import org.kde.kcmutils as KCM

KCM.SimpleKCM {

    id: appearancePage

    property alias cfg_inTrayActiveTimeoutSec: inTrayActiveTimeoutSec.value
    property string cfg_widgetFontName: plasmoid.configuration.widgetFontName
    property string cfg_widgetFontSize: plasmoid.configuration.widgetFontSize
    property string cfg_widgetIconSize: plasmoid.configuration.widgetIconSize

    property alias cfg_textVisible: textVisible.checked
    property alias cfg_iconVisible: iconVisible.checked
    property alias cfg_textDropShadow: textDropShadow.checked
    property alias cfg_iconDropShadow: iconDropShadow.checked

    property int cfg_iconSizeMode
    property int cfg_textSizeMode


    ListModel {
        id: fontsModel
        Component.onCompleted: {
            var arr = []
            arr.push({text: i18nc("Use default font", "Default"), value: ""})

            var fonts = Qt.fontFamilies()
            var foundIndex = 0
            for (var i = 0, j = fonts.length; i < j; ++i) {
                if (fonts[i] === cfg_widgetFontName) {
                    foundIndex = i
                }
                arr.push({text: fonts[i], value: fonts[i]})
            }
            append(arr)
            if (foundIndex > 0) {
                fontFamilyComboBox.currentIndex = foundIndex + 1
            }
        }
    }

    onCfg_iconSizeModeChanged: {
        switch (cfg_iconSizeMode) {
            case 0:
                iconSizeModeGroup.checkedButton = iconSizeModeFit;
                break;
            case 1:
                iconSizeModeGroup.checkedButton = iconSizeModeFixed;
                break;
            default:
        }
    }

    Component.onCompleted: {
        cfg_iconSizeModeChanged()
    }

    ButtonGroup {
        id: iconSizeModeGroup
    }

    onCfg_textSizeModeChanged: {
        switch (cfg_textSizeMode) {
            case 0:
                textSizeModeGroup.checkedButton = textSizeModeFit;
                break;
            case 1:
                textSizeModeGroup.checkedButton = textSizeModeFixed;
                break;
            default:
        }
    }

    ButtonGroup {
        id: textSizeModeGroup

        Component.onCompleted: {
                cfg_textSizeModeChanged()
            }
    }

    GridLayout {
        anchors.left: parent.left
        anchors.right: parent.right
        columns: 3

        Label {
            text: i18n("Widget font") + ":"
            Layout.alignment: Qt.AlignVCenter | Qt.AlignRight
        }
        ComboBox {
            id: fontFamilyComboBox
            Layout.fillWidth: true
            currentIndex: 0
            Layout.minimumWidth: Kirigami.Units.gridUnit * 10
            Layout.maximumWidth: Kirigami.Units.gridUnit * 10

            model: fontsModel
            textRole: "text"

            onCurrentIndexChanged: {
                var current = model.get(currentIndex)
                if (current) {
                    cfg_widgetFontName = currentIndex === 0 ? Kirigami.Theme.defaultFont.family : current.value
                }
            }
        }

        Item {
            width: 2
            height: 5
            Layout.columnSpan: 3
        }

        Label {
            text: i18n("Text size mode") + ":"
            Layout.alignment: Qt.AlignVCenter | Qt.AlignRight
        }
        RadioButton {
            id: textSizeModeFit
            ButtonGroup.group: textSizeModeGroup
            text: i18n("Automatic fit")
            onCheckedChanged: if (checked) cfg_textSizeMode = 0;
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
            id: textSizeModeFixed
            ButtonGroup.group: textSizeModeGroup
            text: i18n("Exact size")
            onCheckedChanged: if (checked) cfg_textSizeMode = 1;
        }

        Item {
            width: 2
            height: 5
            Layout.columnSpan: 3
        }

        Label {
            text: i18n("Text size") + ":"
            Layout.alignment: Qt.AlignVCenter | Qt.AlignRight


        }
        Item {
            SpinBox {
                id: widgetFontSize
                Layout.alignment: Qt.AlignVCenter
                anchors.verticalCenter: parent.verticalCenter
                stepSize: 1
                from: 4
                value: cfg_widgetFontSize
                to: 512
                onValueChanged: {
                    cfg_widgetFontSize = widgetFontSize.value
                }
            }
            Label {
                anchors.verticalCenter: parent.verticalCenter
                anchors.left:widgetFontSize.right
                anchors.leftMargin: 4
                text: i18nc("pixels", "px")
            }
        }

        Item {
            width: 2
            height: 5
            Layout.columnSpan: 3
        }

        // Item {
            CheckBox {
                id: textVisible
                Layout.alignment: Qt.AlignVCenter | Qt.AlignRight
            }

            Label {
                text: i18n("Text visible")
                Layout.alignment: Qt.AlignVCenter | Qt.AlignLeft
                // Layout.leftMargin: 4
                // anchors.left: textVisible.right
                // anchors.leftMargin: 4
            }
        // }

        Item {
            width: 2
            height: 2
            Layout.columnSpan: 3
        }

        CheckBox {
            id: textDropShadow
            Layout.alignment: Qt.AlignVCenter | Qt.AlignRight
        }

        Label {
            text: i18n("Text drop shadow")
            Layout.alignment: Qt.AlignLeft
        }

        Item {
            width: 2
            height: 10
            Layout.columnSpan: 3
        }

        Label {
            text: i18n("Icon size mode") + ":"
            Layout.alignment: Qt.AlignVCenter | Qt.AlignRight
        }
        RadioButton {
            id: iconSizeModeFit
            ButtonGroup.group: iconSizeModeGroup
            text: i18n("Automatic fit")
            onCheckedChanged: if (checked) cfg_iconSizeMode = 0;
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
            id: iconSizeModeFixed
            ButtonGroup.group: iconSizeModeGroup
            text: i18n("Exact size")
            onCheckedChanged: if (checked) cfg_iconSizeMode = 1;
        }

        Item {
            width: 2
            height: 5
            Layout.columnSpan: 3
        }

        Label {
            text: i18n("Icon size") + ":"
            Layout.alignment: Qt.AlignVCenter | Qt.AlignRight


        }
        Item {
            SpinBox {
                id: widgetIconSize
                Layout.alignment: Qt.AlignVCenter
                anchors.verticalCenter: parent.verticalCenter
                stepSize: 1
                from: 4
                value: cfg_widgetIconSize
                to: 512
                onValueChanged: {
                    cfg_widgetIconSize = widgetIconSize.value
                }
            }
            Label {
                anchors.verticalCenter: parent.verticalCenter
                anchors.left:widgetIconSize.right
                anchors.leftMargin: 4
                text: i18nc("pixels", "px")
            }
        }

        Item {
            width: 2
            height: 5
            Layout.columnSpan: 3
        }

        // Item {
            CheckBox {
                id: iconVisible
                Layout.alignment: Qt.AlignVCenter | Qt.AlignRight
            }

            Label {
                text: i18n("Icon visible")
                Layout.alignment: Qt.AlignVCenter | Qt.AlignLeft
                // anchors.left: iconVisible.right
                // anchors.leftMargin: 4
            }
        // }

        Item {
            width: 2
            height: 2
            Layout.columnSpan: 3
        }

        CheckBox {
            id: iconDropShadow
            Layout.alignment: Qt.AlignVCenter | Qt.AlignRight
        }

        Label {
            text: i18n("Icon drop shadow")
            Layout.alignment: Qt.AlignLeft
        }

        Item {
            width: 2
            height: 15
            Layout.columnSpan: 3
        }

        Label {
            id: timeoutLabel
            text: i18n("System tray timeout") + ":" // Active tray timeout
            Layout.alignment: Qt.AlignVCenter | Qt.AlignRight
            height: inTrayActiveTimeoutSec.height
        }
        Item {
            SpinBox {
                id: inTrayActiveTimeoutSec
                Layout.alignment: Qt.AlignVCenter
                stepSize: 10
                from: 10
                to: 8000
                anchors.verticalCenter: parent.verticalCenter
            }
            Label {
                text: i18nc("Abbreviation for seconds", "sec")
                anchors.verticalCenter: parent.verticalCenter
                anchors.left:inTrayActiveTimeoutSec.right
                anchors.leftMargin: 4
            }
        }
    }
}