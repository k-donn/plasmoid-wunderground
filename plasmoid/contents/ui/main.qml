/*
 * Copyright 2021  Kevin Donnelly
 * Copyright 2022  Rafal (Raf) Liwoch
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
import "../code/utils.js" as Utils
import "../code/pws-api.js" as StationAPI

Item {
    id: root

    //that's a hack to check if we have a translation file for the given Locale
    property string currentLocale: getDisplayLocale()

    property var weatherData: null
    property var flatWeatherData: {}
    property string applicationStateText: i18n("All set")
    property var currentDetailsModel: ListModel {}
    property var dayInfo: null
    property var singleDayModel: ListModel { }
    property var forecastDetailsModel: ListModel { }
    property var hourlyChartModel: ListModel {
        ListElement {
                date: ""
                time: ""
                iconCode:100
                temperature: 0
                cloudCover: 0
                humidity: 0
                precipitationChance: 0
                precipitationRate: 0
                snowPrecipitationRate: 0
                wind: 0
                golfIndex: 0
                pressure: 0
                uvIndex: 0
            }
        }
    property var dailyChartModel: ListModel {
        ListElement{
                date: ""
                iconCode:100
                temperature: 0
                cloudCover: 0
                humidity: 0
                precipitationChance: 0
                precipitationRate: 0
                snowPrecipitationRate: 0
                wind: 0
                isDay: false
            }
        }
    property var dictVals : ({
        temperature: {
            name: i18n("Temperature"),
            code: "temperature",
            icon: "wi-thermometer.svg",
            unit: Utils.currentTempUnit("", false)
        },
        uvIndex: {
            name: i18n("UV Index"),
            code: "uvIndex",
            icon: "wi-horizon-alt.svg",
            unit: ""
        },
        pressure: {
            name: i18n("Pressure"),
            code: "pressure",
            icon: "wi-barometer.svg",
            unit: Utils.currentPresUnit("", false)
        },
        cloudCover: {
            name: i18n("Cloud Cover"),
            code: "cloudCover",
            icon: "wi-cloud.svg",
            unit: "%"
        },
        humidity: {
            name: i18n("Humidity"),
            code: "humidity",
            icon: "wi-humidity.svg",
            unit: "%"
        },
        precipitationChance: {
            name: i18n("Precipitation Chance"),
            code: "precipitationChance",
            icon: "wi-umbrella.svg",
            unit: "%"
        },
        precipitationRate: {
            name: i18n("Precipitation Rate"),
            code: "precipitationRate",
            icon: "wi-rain.svg",
            unit: Utils.currentPrecipUnit("", true, false)
        },
        snowPrecipitationRate: {
            name: i18n("Snow Precipitation Rate"),
            code: "snowPrecipitationRate",
            icon: "wi-snow.svg",
            unit: Utils.currentPrecipUnit("", false, false)
        },
        wind: {
            name: i18n("Wind / Gust"),
            code: "wind",
            icon: "wi-strong-wind.svg",
            unit: Utils.currentSpeedUnit("", false)
        },
        precipitationAcc: {
            name: i18n("Precipitation Accumulation"),
            code: "precipitationAcc",
            icon: "wi-flood.svg",
            unit: Utils.currentPrecipUnit("", true, false)
        },
        dewPoint: {
            name: i18n("Dew Point"),
            code: "dewPoint",
            icon: "wi-raindrop.svg",
            unit: Utils.currentTempUnit("", false)
        },
        windDirection: {
            name: i18n("Wind Direction"),
            code: "windDirection",
            icon: "wi-storm-warning.svg",
            unit: ""
        }                                      
    })

    property var textSize: ({
        normal: plasmoid.configuration.propPointSize,
        small: plasmoid.configuration.propPointSize - 1,
        tiny: plasmoid.configuration.propPointSize - 2
    })

    property ListModel forecastModel: ListModel {}
    property string errorStr: ""
    property string toolTipSubText: ""
    property string iconCode: "32" // 32 = sunny
    property string conditionNarrative: ""
    property string narrativeText: ""

    // TODO: add option for showFORECAST and showFORECASTERROR
    property int showCONFIG: 1
    property int showLOADING: 2
    property int showERROR: 4
    property int showDATA: 8

    property int appState: showCONFIG

    // QML does not let you property bind items part of ListModels.
    // The TopPanel shows the high/low values which are items part of forecastModel
    // These are updated in pws-api.js to overcome that limitation
    property int currDayHigh: 0
    property int currDayLow: 0

    property bool showForecast: false

    property string stationID: plasmoid.configuration.stationID
    property int unitsChoice: plasmoid.configuration.unitsChoice

    property bool inTray: false
    // Metric units change based on precipitation type
    property bool isRain: true

    property Component fr: FullRepresentation {
        Layout.minimumWidth: units.gridUnit * 16 *2.6
        Layout.preferredWidth: units.gridUnit * 16 *2.6
        Layout.minimumHeight: units.gridUnit * 12 *2.6
        Layout.preferredHeight: units.gridUnit * 12 *2.6
    }

    property Component cr: CompactRepresentation {
        Layout.minimumWidth: 110
        Layout.preferredWidth: 110
    }

    function printDebug(msg) {
        if (plasmoid.configuration.logConsole) {console.log("[debug] [main.qml] " + msg)}
    }

    function printDebugJSON(json) {
        if (plasmoid.configuration.logConsole) {console.log("[debug] [main.qml] " + JSON.stringify(json))}
    }

    function updateWeatherData() {
        printDebug("Getting new weather data")

        StationAPI.getCurrentData()
        StationAPI.getForecastData("daily", 7);
        StationAPI.getForecastData("hourly", 24);

        updatetoolTipSubText()
    }

    function updateCurrentData() {
        printDebug("Getting new current data")

        StationAPI.getCurrentData()

        updatetoolTipSubText()
    }

    function updateForecastData() {
        printDebug("Getting new forecast data")

        StationAPI.getForecastData("daily", 7);
        StationAPI.getForecastData("hourly", 24);

        updatetoolTipSubText()

        dailyChartModel.sync()
        forecastDetailsModel.sync()
        forecastModel.sync()
    }

    function updatetoolTipSubText() {
        var subText = ""
        
        //todo 

        toolTipSubText = subText;
    }

    onUnitsChoiceChanged: {
        printDebug("Units changed")

        // A user could configure units but not station id. This would trigger improper request.
        if (stationID != "") {
            // Show loading screen after units change
            appState = showLOADING;

            updateWeatherData();
        }
    }

    onStationIDChanged: {
        printDebug("Station ID changed")

        // Show loading screen after ID change
        appState = showLOADING;

        updateWeatherData();
    }

    onWeatherDataChanged: {
        printDebug("Weather data changed")
    }

    onAppStateChanged: {
        printDebug("State is: " + appState)

        // The state could now be an error, the tooltip displays the error
        updatetoolTipSubText()
    }

    Component.onCompleted: {
        inTray = (plasmoid.parent !== null && (plasmoid.parent.pluginName === 'org.kde.plasma.private.systemtray' || plasmoid.parent.objectName === 'taskItemContainer'))

        plasmoid.configurationRequiredReason = i18n("Set the weather station to pull data from.")

        plasmoid.backgroundHints = PlasmaCore.Types.ConfigurableBackground
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
    
    Plasmoid.toolTipItem: Loader {
        id: tooltipLoader

        Layout.minimumWidth: item ? item.width : 0
        Layout.maximumWidth: item ? item.width : 0
        Layout.minimumHeight: item ? item.height : 0
        Layout.maximumHeight: item ? item.height : 0

        source: getTootipTemplate()
    }


    function getTootipTemplate() {
        if (appState == showCONFIG) {
            applicationStateText = i18n("Please Configure");
            return "TooltipBasic.qml"
        } else if (appState == showLOADING) {
            applicationStateText = i18n("Loading...");
            return "TooltipBasic.qml"
        } else if (appState == showERROR) {
            applicationStateText = i18n("Error...");
            return "TooltipBasic.qml"
        } else if (appState == showDATA) {
            applicationStateText = i18n("All set");
            return "Tooltip.qml"            
        } else {
            applicationStateText = i18n("Undefined Error...");
            return "TooltipBasic.qml"
        }
    }

    function getDisplayLocale() {
        var systemLocale = Qt.locale().uiLanguages[0]
        var testString = i18nc("Please put your language code here","en-US")
        var hasTranslationForLocale = (testString === systemLocale ? true : false)

        if(hasTranslationForLocale) {
            return systemLocale;
        } else {
            return "en-US";
        }
    }

    Plasmoid.fullRepresentation: fr
    Plasmoid.compactRepresentation: cr


}
