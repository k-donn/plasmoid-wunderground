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
import org.kde.plasma.components 2.0 as PlasmaComponents
import "../code/utils.js" as Utils

Item {
    ConfigBtn {
        id: configBtn

        anchors.fill: parent

        visible: configActive
    }

    Item {
        id: errorMsgs

        anchors.fill: parent

        PlasmaComponents.Label {
            visible: errorStr != null
            anchors.centerIn: parent
            text: "Error: " + errorStr
        }
    }

    Item {
        id: loadingMsg

        anchors.fill: parent

        PlasmaComponents.Label {
            visible: loadingData
            anchors.centerIn: parent
            text: "Loading data..."
        }
    }

    Item {
        id: weatherInfo

        // Show once data is fetched and
        // don't show while switching stations
        visible: showData && !loadingData

        anchors.fill: parent

        GridLayout {
            id: grid

            columns: 3
            columnSpacing: parent.width / 10

            rows: 4


            PlasmaComponents.Label {
                id: temp
                text: weatherData["imperial"]["temp"].toFixed(1) + "°F"
                font {
                    bold: true
                    pointSize: 30
                }
                color: Utils.heatColor(weatherData["imperial"]["temp"])
            }
            PlasmaComponents.Label {
                id: windDir
                text: "Wind dir:" + weatherData["winddir"] + "°"
            }
            PlasmaComponents.Label {
                id: windLabel
                text: "WIND & GUST"
                font {
                    bold: true
                    pointSize: 13
                }
            }

            PlasmaComponents.Label {
                id: feelsLike
                text: "Feels like " + Utils.feelsLike(weatherData["imperial"]["temp"], weatherData["humidity"], weatherData["imperial"]["windSpeed"]) + "° F"
            }
            PlasmaComponents.Label {
                id: windDirCard
                text: Utils.windDirToCard(weatherData["winddir"])
            }
            PlasmaComponents.Label {
                id: wind
                text: weatherData["imperial"]["windSpeed"] + " / " + weatherData["imperial"]["windGust"] + " mph"
            }


            PlasmaComponents.Label {
                id: dewLabel
                text: "DEWPOINT"
                font {
                    bold: true
                    pointSize: 13
                }
            }
            PlasmaComponents.Label {
                id: precipRateLabel
                text: "PRECIP RATE"
                font {
                    bold: true
                    pointSize: 13
                }
            }
            PlasmaComponents.Label {
                id: pressureLabel
                text: "PRESSURE"
                font {
                    bold: true
                    pointSize: 13
                }
            }

            PlasmaComponents.Label {
                id: dew
                text: weatherData["imperial"]["dewpt"] + "° F"
                font.pointSize: 10
            }
            PlasmaComponents.Label {
                id: precipRate
                text: weatherData["imperial"]["precipRate"] + " in/hr"
                font.pointSize: 10
            }
            PlasmaComponents.Label {
                id: pressure
                text: weatherData["imperial"]["pressure"].toFixed(2) + " inHG"
                font.pointSize: 10
            }

            PlasmaComponents.Label {
                id: humidityLabel
                text: "HUMIDITY"
                font {
                    bold: true
                    pointSize: 13
                }
            }
            PlasmaComponents.Label {
                id: precipAccLabel
                text: "PRECIP ACCUM"
                font {
                    bold: true
                    pointSize: 13
                }
            }
            PlasmaComponents.Label {
                id: uvLabel
                text: "UV"
                font {
                    bold: true
                    pointSize: 13
                }
            }

            PlasmaComponents.Label {
                id: humidity
                text: weatherData["humidity"] + "%"
            }
            PlasmaComponents.Label {
                id: precipAcc
                text: weatherData["imperial"]["precipTotal"] + " in"
            }
            PlasmaComponents.Label {
                id: uv
                text: weatherData["uv"]
            }
        }

        PlasmaComponents.Label {
            id: updatedAt
            anchors {
                right: parent.right
                bottom: parent.bottom
            }
            text: weatherData["obsTimeLocal"]
            verticalAlignment: Text.AlignBottom
        }

        PlasmaComponents.Label {
            id: currStation
            anchors {
                left: parent.left
                bottom: parent.bottom
            }
            text: weatherData["stationID"]
            verticalAlignment: Text.AlignBottom
        }
    }
}
