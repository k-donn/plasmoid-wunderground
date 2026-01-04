import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import org.kde.kirigami as Kirigami
import org.kde.plasma.components as PlasmaComponents
import org.kde.kcmutils as KCM
import "../lib" as Lib

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

    property alias cfg_tempAutoColor: tempAutoColor.checked
    property alias cfg_useDefaultPage: useDefaultPage.checked
    property alias cfg_defaultLoadPage: defaultLoadPage.currentIndex
    property alias cfg_showPresTrend: showPresTrend.checked


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

    Kirigami.FormLayout {
        anchors.fill: parent

        Kirigami.Separator {
            Kirigami.FormData.label: i18n("General")
            Kirigami.FormData.isSection: true
        }

        Lib.BackgroundToggle {}

        Kirigami.Separator {
            Kirigami.FormData.label: i18n("Full Representation")
            Kirigami.FormData.isSection: true
        }

        PlasmaComponents.CheckBox {
            id: tempAutoColor

            Kirigami.FormData.label: i18n("Auto-color temperature:")
        }

        PlasmaComponents.CheckBox {
            id: useDefaultPage

            Kirigami.FormData.label: i18n("Use default page:")
        }

        PlasmaComponents.ComboBox {
            id: defaultLoadPage

            enabled: useDefaultPage.checked

            model: [i18n("Weather Details"), i18n("Forecast"), i18n("Day Chart"), i18n("More Info")]

            Kirigami.FormData.label: i18n("Default page shown:")
        }
        PlasmaComponents.CheckBox {
            id: showPresTrend

            Kirigami.FormData.label: i18n("Show pressure trend:")
        }

        Kirigami.Separator {
            Kirigami.FormData.label: i18n("Compact Representation")
            Kirigami.FormData.isSection: true
        }

        PlasmaComponents.ComboBox {
            id: fontFamilyComboBox
            currentIndex: 0

            model: fontsModel
            textRole: "text"

            Kirigami.FormData.label: i18n("Choose a Font:")

            onCurrentIndexChanged: {
                var current = model.get(currentIndex)
                if (current) {
                    cfg_widgetFontName = currentIndex === 0 ? Kirigami.Theme.defaultFont.family : current.value
                }
            }
        }

        ColumnLayout {
            spacing: Kirigami.Units.smallSpacing

            Kirigami.FormData.label: i18n("Text size mode:")
            Kirigami.FormData.labelAlignment: Qt.AlignTop

            PlasmaComponents.RadioButton {
                id: textSizeModeFit
                ButtonGroup.group: textSizeModeGroup
                text: i18n("Automatic fit")
                onCheckedChanged: if (checked) cfg_textSizeMode = 0;
            }

            PlasmaComponents.RadioButton {
                id: textSizeModeFixed
                ButtonGroup.group: textSizeModeGroup
                text: i18n("Exact size")
                onCheckedChanged: if (checked) cfg_textSizeMode = 1;
            }
        }

        Row {
            Kirigami.FormData.label: i18n("Text size") + ":"

            PlasmaComponents.SpinBox {
                id: widgetFontSize
                stepSize: 1
                from: 4
                value: cfg_widgetFontSize
                to: 512
                onValueChanged: {
                    cfg_widgetFontSize = widgetFontSize.value
                }
            }
            PlasmaComponents.Label {
                text: i18nc("pixels", "px")
                anchors.verticalCenter: parent.verticalCenter
            }
        }

        PlasmaComponents.CheckBox {
            id: textVisible
            
            Kirigami.FormData.label: i18n("Text visible") + ":"
        }

        PlasmaComponents.CheckBox {
            id: textDropShadow

            Kirigami.FormData.label: i18n("Text drop shadow") + ":"
        }

        ColumnLayout {
            spacing: Kirigami.Units.smallSpacing

            Kirigami.FormData.label: i18n("Icon size mode:")
            Kirigami.FormData.labelAlignment: Qt.AlignTop

            PlasmaComponents.RadioButton {
                id: iconSizeModeFit
                ButtonGroup.group: iconSizeModeGroup
                text: i18n("Automatic fit")
                onCheckedChanged: if (checked) cfg_iconSizeMode = 0;
            }

            PlasmaComponents.RadioButton {
                id: iconSizeModeFixed
                ButtonGroup.group: iconSizeModeGroup
                text: i18n("Exact size")
                onCheckedChanged: if (checked) cfg_iconSizeMode = 1;
            }
        }

        Row {
            Kirigami.FormData.label: i18n("Icon size") + ":"

            PlasmaComponents.SpinBox {
                id: widgetIconSize
                stepSize: 1
                from: 4
                value: cfg_widgetIconSize
                to: 512
                onValueChanged: {
                    cfg_widgetIconSize = widgetIconSize.value
                }
            }
            PlasmaComponents.Label {
                text: i18nc("pixels", "px")
                anchors.verticalCenter: parent.verticalCenter
            }
        }

        PlasmaComponents.CheckBox {
            id: iconVisible

            Kirigami.FormData.label: i18n("Icon visible") + ":"
        }
        PlasmaComponents.CheckBox {
            id: iconDropShadow

            Kirigami.FormData.label: i18n("Icon drop shadow") + ":"
        }

        Row {
            Kirigami.FormData.label: i18n("System tray active timeout") + ":"

            PlasmaComponents.SpinBox {
                id: inTrayActiveTimeoutSec
                stepSize: 10
                from: 10
                to: 8000
                anchors.verticalCenter: parent.verticalCenter
            }
            PlasmaComponents.Label {
                text: i18nc("Abbreviation for seconds", "sec")
                anchors.verticalCenter: parent.verticalCenter
            }
        }
    }
}