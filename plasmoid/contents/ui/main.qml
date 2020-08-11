import QtQuick 2.0
import QtQuick.Layouts 1.0
import QtQuick.Controls 2.0
import org.kde.plasma.plasmoid 2.0
import org.kde.plasma.core 2.0 as PlasmaCore
import "../code/format-data.js" as FormatData
import "../code/pws-api.js" as StationAPI

Item {
    property var weatherData: null
    property bool showData: false
    property bool configActive: true
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

    Plasmoid.fullRepresentation: FullRepresentation { 
        Layout.minimumWidth: 480
        Layout.minimumHeight: 320
    }
    Plasmoid.compactRepresentation: CompactRepresentation { }

}
