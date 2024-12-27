/*
 * Copyright 2024  Kevin Donnelly
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

import QtQml
import QtQuick
import QtQuick.Layouts
import org.kde.plasma.plasmoid
import org.kde.kirigami as Kirigami
import org.kde.plasma.core as PlasmaCore
import "../code/utils.js" as Utils
import "../code/pws-api.js" as StationAPI

PlasmoidItem {
    id: root

    property var weatherData: {
        "stationID": "",
        "uv": 0,
        "obsTimeLocal": "",
        "isNight": false,
        "winddir": 0,
        "lat": 0,
        "lon": 0,
        "sunrise": "2020-08-09T07:00:10-0500",
        "sunset": "2020-08-09T20:00:10-0500",
        "solarRad": 0,
        "humidity": 0,
        "details": {
            "temp": 0,
            "windSpeed": 0,
            "windGust": 0,
            "dewpt": 0,
            "solarRad": 0,
            "precipRate": 0,
            "pressure": 0,
            "pressureTrend": "Steady",
            "pressureTrendCode": 0,
            "pressureDelta": 0,
            "precipTotal": 0,
            "elev": 0
        },
        "aq": {
            "aqi": 0,
            "aqhi": 0,
            "aqDesc": "Good",
            "aqColor": "FFFFFF",
            "aqPrimary": "PM2.5",
            "primaryDetails": {
                "phrase": "Particulate matter <2.5 microns",
                "amount": 0,
                "unit": "ug/m3",
                "desc": "Moderate",
                "index": 0
            }
        }
    }
    property ListModel forecastModel: ListModel {}
    property ListModel hourlyModel: ListModel {
ListElement {date:"2024-12-27T20:00:00.000Z"
time:"2024-12-27T20:00:00.000Z"
iconCode:26
temperature:6
cloudCover:100
humidity:97
precipitationChance:9
precipitationRate:0
snowPrecipitationRate:0
wind:15
num:1
golfIndex:3
uvIndex:1
pressure:1022.82}
ListElement {date:"2024-12-27T21:00:00.000Z"
time:"2024-12-27T21:00:00.000Z"
iconCode:26
temperature:6
cloudCover:100
humidity:95
precipitationChance:11
precipitationRate:0
snowPrecipitationRate:0
wind:15
num:2
golfIndex:3
uvIndex:0
pressure:1022.43}
ListElement {date:"2024-12-27T22:00:00.000Z"
time:"2024-12-27T22:00:00.000Z"
iconCode:26
temperature:6
cloudCover:100
humidity:96
precipitationChance:13
precipitationRate:0
snowPrecipitationRate:0
wind:15
num:3
golfIndex:3
uvIndex:0
pressure:1022.32}
ListElement {date:"2024-12-27T23:00:00.000Z"
time:"2024-12-27T23:00:00.000Z"
iconCode:26
temperature:7
cloudCover:98
humidity:89
precipitationChance:15
precipitationRate:0
snowPrecipitationRate:0
wind:15
num:4
golfIndex:0
uvIndex:0
pressure:1022.32}
ListElement {date:"2024-12-28T00:00:00.000Z"
time:"2024-12-28T00:00:00.000Z"
iconCode:26
temperature:7
cloudCover:99
humidity:90
precipitationChance:16
precipitationRate:0
snowPrecipitationRate:0
wind:13
num:5
golfIndex:0
uvIndex:0
pressure:1022.53}
ListElement {date:"2024-12-28T01:00:00.000Z"
time:"2024-12-28T01:00:00.000Z"
iconCode:26
temperature:7
cloudCover:99
humidity:91
precipitationChance:17
precipitationRate:0
snowPrecipitationRate:0
wind:14
num:6
golfIndex:0
uvIndex:0
pressure:1022.63}
ListElement {date:"2024-12-28T02:00:00.000Z"
time:"2024-12-28T02:00:00.000Z"
iconCode:11
temperature:7
cloudCover:100
humidity:93
precipitationChance:48
precipitationRate:0.2
snowPrecipitationRate:0
wind:13
num:7
golfIndex:0
uvIndex:0
pressure:1022.52}
ListElement {date:"2024-12-28T03:00:00.000Z"
time:"2024-12-28T03:00:00.000Z"
iconCode:11
temperature:8
cloudCover:100
humidity:93
precipitationChance:52
precipitationRate:0.57
snowPrecipitationRate:0
wind:13
num:8
golfIndex:0
uvIndex:0
pressure:1022.39}
ListElement {date:"2024-12-28T04:00:00.000Z"
time:"2024-12-28T04:00:00.000Z"
iconCode:12
temperature:8
cloudCover:100
humidity:95
precipitationChance:79
precipitationRate:0.77
snowPrecipitationRate:0
wind:12
num:9
golfIndex:0
uvIndex:0
pressure:1022.09}
ListElement {date:"2024-12-28T05:00:00.000Z"
time:"2024-12-28T05:00:00.000Z"
iconCode:12
temperature:8
cloudCover:100
humidity:99
precipitationChance:69
precipitationRate:0.91
snowPrecipitationRate:0
wind:10
num:10
golfIndex:0
uvIndex:0
pressure:1021.79}
ListElement {date:"2024-12-28T06:00:00.000Z"
time:"2024-12-28T06:00:00.000Z"
iconCode:12
temperature:8
cloudCover:100
humidity:100
precipitationChance:88
precipitationRate:1.1
snowPrecipitationRate:0
wind:9
num:11
golfIndex:0
uvIndex:0
pressure:1021.49}
ListElement {date:"2024-12-28T07:00:00.000Z"
time:"2024-12-28T07:00:00.000Z"
iconCode:12
temperature:8
cloudCover:100
humidity:100
precipitationChance:93
precipitationRate:2.15
snowPrecipitationRate:0
wind:8
num:12
golfIndex:0
uvIndex:0
pressure:1021.49}
ListElement {date:"2024-12-28T08:00:00.000Z"
time:"2024-12-28T08:00:00.000Z"
iconCode:12
temperature:8
cloudCover:100
humidity:100
precipitationChance:85
precipitationRate:1.23
snowPrecipitationRate:0
wind:9
num:13
golfIndex:0
uvIndex:0
pressure:1021.21}
ListElement {date:"2024-12-28T09:00:00.000Z"
time:"2024-12-28T09:00:00.000Z"
iconCode:12
temperature:8
cloudCover:100
humidity:100
precipitationChance:78
precipitationRate:1.56
snowPrecipitationRate:0
wind:9
num:14
golfIndex:0
uvIndex:0
pressure:1021.09}
ListElement {date:"2024-12-28T10:00:00.000Z"
time:"2024-12-28T10:00:00.000Z"
iconCode:12
temperature:9
cloudCover:100
humidity:100
precipitationChance:74
precipitationRate:0.79
snowPrecipitationRate:0
wind:8
num:15
golfIndex:0
uvIndex:0
pressure:1021.09}
ListElement {date:"2024-12-28T11:00:00.000Z"
time:"2024-12-28T11:00:00.000Z"
iconCode:11
temperature:9
cloudCover:100
humidity:100
precipitationChance:68
precipitationRate:0.49
snowPrecipitationRate:0
wind:7
num:16
golfIndex:0
uvIndex:0
pressure:1021.29}
ListElement {date:"2024-12-28T12:00:00.000Z"
time:"2024-12-28T12:00:00.000Z"
iconCode:12
temperature:9
cloudCover:100
humidity:100
precipitationChance:71
precipitationRate:0.61
snowPrecipitationRate:0
wind:8
num:17
golfIndex:0
uvIndex:0
pressure:1021.59}
ListElement {date:"2024-12-28T13:00:00.000Z"
time:"2024-12-28T13:00:00.000Z"
iconCode:11
temperature:9
cloudCover:100
humidity:100
precipitationChance:65
precipitationRate:0.45
snowPrecipitationRate:0
wind:7
num:18
golfIndex:3
uvIndex:0
pressure:1021.99}
ListElement {date:"2024-12-28T14:00:00.000Z"
time:"2024-12-28T14:00:00.000Z"
iconCode:11
temperature:9
cloudCover:99
humidity:100
precipitationChance:56
precipitationRate:3.15
snowPrecipitationRate:0
wind:8
num:19
golfIndex:3
uvIndex:0
pressure:1022.49}
ListElement {date:"2024-12-28T15:00:00.000Z"
time:"2024-12-28T15:00:00.000Z"
iconCode:11
temperature:9
cloudCover:98
humidity:100
precipitationChance:58
precipitationRate:1.79
snowPrecipitationRate:0
wind:9
num:20
golfIndex:3
uvIndex:0
pressure:1022.89}
ListElement {date:"2024-12-28T16:00:00.000Z"
time:"2024-12-28T16:00:00.000Z"
iconCode:11
temperature:10
cloudCover:98
humidity:97
precipitationChance:44
precipitationRate:0.3
snowPrecipitationRate:0
wind:10
num:21
golfIndex:3
uvIndex:1
pressure:1022.8}
ListElement {date:"2024-12-28T17:00:00.000Z"
time:"2024-12-28T17:00:00.000Z"
iconCode:11
temperature:10
cloudCover:98
humidity:96
precipitationChance:50
precipitationRate:0.69
snowPrecipitationRate:0
wind:9
num:22
golfIndex:3
uvIndex:1
pressure:1021.99}
}
    property ListModel alertsModel: ListModel {}

    property string errorStr: ""
    property string iconCode: "32" // 32 = sunny
    property string conditionNarrative: ""

    property int showCONFIG: 1
    property int showLOADING: 2
    property int showERROR: 4
    property int showDATA: 8

    property int appState: showDATA
    // QML does not let you property bind items part of ListModels.
    // The TopPanel shows the high/low values which are items part of forecastModel
    // These are updated in pws-api.js to overcome that limitation
    property int currDayHigh: 0
    property int currDayLow: 0

    property bool showForecast: false

    property string stationID: plasmoid.configuration.stationID
    property int unitsChoice: plasmoid.configuration.unitsChoice
    property bool useLegacyAPI: plasmoid.configuration.useLegacyAPI

    property bool inTray: false
    // Metric units change based on precipitation type
    property bool isRain: true

    property var textSize: ({
        normal: plasmoid.configuration.propPointSize,
        small: plasmoid.configuration.propPointSize - 1,
        tiny: plasmoid.configuration.propPointSize - 2
    })

    property Component fr: FullRepresentation {
        Layout.preferredWidth: 600
        Layout.preferredHeight: 340
    }

    property Component cr: CompactRepresentation {
        // Layout.preferredWidth: 16
        // Layout.preferredHeight: 16
    }

    function printDebug(msg) {
        if (plasmoid.configuration.logConsole) {
            console.log("[debug] [main.qml] " + msg);
        }
    }

    function printDebugJSON(json) {
        if (plasmoid.configuration.logConsole) {
            console.log("[debug] [main.qml] " + JSON.stringify(json));
        }
    }

    function updateWeatherData() {
        printDebug("Getting new weather data");
        StationAPI.getCurrentData(function() {
            StationAPI.getForecastData(StationAPI.getHourlyData)
        });
    }

    function updateCurrentData() {
        printDebug("Getting new current data");
        StationAPI.getCurrentData();
    }

    function updateForecastData() {
        printDebug("Getting new forecast data");
        StationAPI.getForecastData(StationAPI.getHourlyData);
    }

    onStationIDChanged: {
        printDebug("Station ID changed");

        // Show loading screen after ID change
        appState = showLOADING;
        updateWeatherData();
    }

    onUnitsChoiceChanged: {
        printDebug("Units changed");

        // A user could configure units but not station id. This would trigger improper request.
        if (stationID != "") {
            // Show loading screen after units change
            appState = showLOADING;
            updateWeatherData();
        }
    }

    onUseLegacyAPIChanged: {
        printDebug("Forecast API changed");
        updateForecastData();
    }

    onWeatherDataChanged: {
        printDebug("Weather data changed");
    }

    onAppStateChanged: {
        printDebug("State is: " + appState);
    }

    Component.onCompleted: {
        // Plasma::Containment::Type::CustomEmbedded = 129
        // Plasma::Types::FormFactor::Horizonal = 2
        inTray = plasmoid.containment.containmentType == 129 && plasmoid.formFactor == 2;
        plasmoid.configurationRequiredReason = i18n("Set the weather station to pull data from.");
        plasmoid.backgroundHints = PlasmaCore.Types.ConfigurableBackground;
    }

    Timer {
        interval: plasmoid.configuration.refreshPeriod * 1000
        running: appState != showCONFIG
        repeat: true
        onTriggered: updateCurrentData()
    }

    Timer {
        interval: 60 * 60 * 1000
        running: appState != showCONFIG
        repeat: true
        onTriggered: updateForecastData()
    }

    toolTipTextFormat: Text.RichText
    toolTipMainText: {
        if (appState == showCONFIG) {
            return i18n("Please Configure");
        } else if (appState == showDATA) {
            return stationID;
        } else if (appState == showLOADING) {
            return i18n("Loading...");
        } else if (appState == showERROR) {
            return i18n("Error...");
        }
    }
    toolTipSubText: {
        var subText = "";
        if (appState == showDATA) {
            subText += i18nc("Do not edit HTML tags. 'Temp' means temperature", "<font size='4'>Temp: %1</font><br />", Utils.currentTempUnit(Utils.toUserTemp(weatherData["details"]["temp"]),plasmoid.configuration.tempPrecision));
            subText += i18nc("Do not edit HTML tags.", "<font size='4'>Feels: %1</font><br />", Utils.currentTempUnit(Utils.feelsLike(weatherData["details"]["temp"], weatherData["humidity"], weatherData["details"]["windSpeed"]), plasmoid.configuration.feelsPrecision));
            subText += i18nc("Do not edit HTML tags. 'Wnd Spd' means Wind Speed", "<font size='4'>Wnd spd: %1</font><br />", Utils.currentSpeedUnit(Utils.toUserSpeed(weatherData["details"]["windSpeed"])));
            subText += "<font size='4'>" + weatherData["obsTimeLocal"] + "</font>";
        } else if (appState == showERROR) {
            subText = errorStr;
        }
        return subText;
    }

    Plasmoid.contextualActions: [
        PlasmaCore.Action {
            text: i18n("Refresh weather")
            icon.name: "view-refresh-symbolic"
            // icon.color: Kirigami.Theme.textColor
            visible: appState == showDATA
            enabled: appState == showDATA
            onTriggered: updateWeatherData()
        }
    ]

    // preferredRepresentation: compactRepresentation
    fullRepresentation: fr
    compactRepresentation: cr
}
