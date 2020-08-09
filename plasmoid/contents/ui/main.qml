import QtQuick 2.0
import QtQuick.Layouts 1.0
import QtQuick.Controls 2.0
import org.kde.plasma.plasmoid 2.0
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as PlasmaComponents
import "../code/format-data.js" as FormatData
import "../code/pws-api.js" as StationAPI

Item {
    property var weatherData: null
    property bool showData: false
    property string stationID: plasmoid.configuration.stationID

    function printDebug(msg) {
        console.log("[debug] " + msg)
    }

    function updateWeatherData() {
        printDebug("getting new weather data")
        StationAPI.getWeatherData()
    }

    onStationIDChanged: {
        printDebug("id changed")
        StationAPI.getWeatherData()
    }

    Timer {
        interval: 5000
        running: showData
        repeat: true
        onTriggered: updateWeatherData()
    }

    PlasmaCore.IconItem {
        source: "weather"

        width: parent.width
        height: parent.height
    }

    Plasmoid.preferredRepresentation: Plasmoid.compactRepresentation

    Plasmoid.fullRepresentation: FullRepresentation {
        Layout.minimumWidth: label.implicitWidth
        Layout.minimumHeight: label.implicitHeight
        Layout.preferredWidth: 475
        Layout.preferredHeight: 310
    }
}