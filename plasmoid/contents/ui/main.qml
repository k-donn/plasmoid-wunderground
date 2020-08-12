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
    property var weatherData: null
    property var tooltipSubText: ""
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

    function updateTooltipSubText() {
        var subText = ""

        subText += "<font size='4' style='font-family: weathericons'>" + weatherData["imperial"]["temp"] + "°F</font><br />"
        subText += "<font size='4' style='font-family: weathericons'>" + weatherData["imperial"]["windSpeed"] + " mph</font><br />"
        subText += "<br />"
        subText += "<font size='4' style='font-family: weathericons'>" + weatherData["obsTimeLocal"] + "</font>"

        tooltipSubText = subText
    }

    onStationIDChanged: {
        printDebug("id changed")
        StationAPI.getWeatherData()
    }

    onWeatherDataChanged: {
        printDebug("weather data changed")
        if (weatherData != null) {
            updateTooltipSubText()
        }
    }

    FontLoader {
        source: '../fonts/weathericons-regular-webfont-2.0.10.ttf'
    }

    Timer {
        interval: 5000
        running: showData
        repeat: true
        onTriggered: updateWeatherData()
    }

    Plasmoid.preferredRepresentation: Plasmoid.compactRepresentation
    Plasmoid.fullRepresentation: FullRepresentation { 
        Layout.minimumWidth: 480
        Layout.minimumHeight: 320
    }
    Plasmoid.compactRepresentation: CompactRepresentation { }

}
