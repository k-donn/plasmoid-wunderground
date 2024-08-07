import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

TextField {
    id: configString
    Layout.fillWidth: true

    property string configKey: ''
    property alias value: configString.text
    readonly property string configValue: configKey ? plasmoid.configuration[configKey] : ""
    onConfigValueChanged: {
        if (!configString.focus && value != configValue) {
            value = configValue;
        }
    }
    property string defaultValue: ""

    text: configString.configValue
    onTextChanged: serializeTimer.restart()

    ToolButton {
        icon.name: "edit-clear"
        onClicked: configString.value = defaultValue

        anchors.top: parent.top
        anchors.right: parent.right
        anchors.bottom: parent.bottom

        width: height
    }

    Timer { // throttle
        id: serializeTimer
        interval: 300
        onTriggered: {
            if (configKey) {
                plasmoid.configuration[configKey] = value;
            }
        }
    }
}
