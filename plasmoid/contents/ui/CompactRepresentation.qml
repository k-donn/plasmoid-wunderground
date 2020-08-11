import QtQuick 2.0
import org.kde.plasma.plasmoid 2.0
import org.kde.plasma.core 2.0 as PlasmaCore

Item {
    PlasmaCore.IconItem {
        source: "weather"

        width: parent.width
        height: parent.height

        MouseArea {
            anchors.fill: parent
            onClicked: {
                plasmoid.expanded = !plasmoid.expanded
            }
        }

        PlasmaCore.ToolTipArea {
            anchors.fill: parent
            icon: "weather"
            mainText: showData ? weatherData["imperial"]["temp"] : "Waiting for data"
        }
    }
}
