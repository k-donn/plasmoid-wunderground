import QtQuick 2.0
import QtQuick.Layouts 1.0
import QtQuick.Controls 2.0
import org.kde.plasma.plasmoid 2.0

Item {
    function showSettings() {
        plasmoid.action("configure").trigger()
    }

    Button {
        visible: configActive
        anchors.centerIn: parent
        text: "Configure Wunderground"
        icon.name: "settings"
        onClicked: showSettings()
    }
}
