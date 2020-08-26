/*
 * Copyright 2020  Kevin Donnelly
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
import QtQuick 2.0
import QtQuick.Layouts 1.0
import QtQuick.Controls 2.0
import org.kde.plasma.plasmoid 2.0
import org.kde.plasma.core 2.0 as PlasmaCore
import "../code/utils.js" as FormatData
import "../code/pws-api.js" as StationAPI

Item {
    property var errorStr: null
    property var weatherData: null
    property var tooltipSubText: ""

    property bool showData: false
    property bool loadingData: false
    property bool configActive: true

    property string stationID: plasmoid.configuration.stationID

    property Component fr: FullRepresentation { 
        Layout.minimumWidth: 480
        Layout.minimumHeight: 320
    }

    property Component cr: CompactRepresentation {}

    function printDebug(msg) {
        console.log("[debug] " + msg)
    }

    function updateWeatherData() {
        printDebug("getting new weather data")
        StationAPI.getWeatherData()
    }

    function updateTooltipSubText() {
        var subText = ""

        subText += "<font size='4'>" + weatherData["imperial"]["temp"] + "°F</font><br />"
        subText += "<font size='4'>" + weatherData["imperial"]["windSpeed"] + " mph</font><br />"
        subText += "<br />"
        subText += "<font size='4'>" + weatherData["obsTimeLocal"] + "</font>"

        tooltipSubText = subText
    }

    onStationIDChanged: {
        printDebug("id changed")
        // If the station ID is set, no need to show config btn
        configActive = false;
        loadingData = true;

        StationAPI.getWeatherData()
    }

    onWeatherDataChanged: {
        printDebug("weather data changed")
        if (errorStr == null) {
            updateTooltipSubText()
        }
    }

    Timer {
        interval: 5000
        running: showData
        repeat: true
        onTriggered: updateWeatherData()
    }

    Plasmoid.fullRepresentation: fr
    Plasmoid.compactRepresentation: cr

}
