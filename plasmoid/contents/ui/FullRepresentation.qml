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
    function printDebug(msg) {
        console.log("[debug] " + msg)
    }

    CenteredConfigBtn {
        id: configBtn

        visible: appState == showCONFIG

        height: parent.height
        width: parent.width
    }

    Item {
        id: errorMsgs

        visible: appState == showERROR

        anchors.fill: parent

        ColumnLayout {
            height: parent.height
            width: parent.width

            PlasmaComponents.Label {
                Layout.fillWidth: true
                Layout.fillHeight: true
                verticalAlignment: Text.AlignVCenter
                horizontalAlignment: Text.AlignHCenter
                text: "Error: " + errorStr
                wrapMode: Text.WordWrap
            }
        }
    }

    Item {
        id: loadingMsg

        visible: appState == showLOADING

        anchors.fill: parent

        ColumnLayout {
            height: parent.height
            width: parent.width

            PlasmaComponents.Label {
                Layout.fillWidth: true
                Layout.fillHeight: true
                verticalAlignment: Text.AlignVCenter
                horizontalAlignment: Text.AlignHCenter
                text: "Loading data..."
            }
        }

    }

    Item {
        id: weatherInfo

        // Show once data is fetched and
        // don't show while switching stations
        visible: appState == showDATA

        anchors.fill: parent

        ColumnLayout {
            width: parent.width
            height: parent.height

            GridLayout {
                id: grid

                columns: 3
                rows: 4

                // Take up all the width and 3/4 the height
                Layout.preferredWidth: parent.width
                Layout.preferredHeight: parent.height * 0.75

                Layout.alignment: Qt.AlignTop

                PlasmaComponents.Label {
                    id: temp
                    text: weatherData["details"]["temp"].toFixed(1) + Utils.currentTempUnit()
                    font {
                        bold: true
                        pointSize: 30
                    }
                    color: Utils.heatColor(weatherData["details"]["temp"])
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
                    text: "Feels like " + Utils.feelsLike(weatherData["details"]["temp"], weatherData["humidity"], weatherData["details"]["windSpeed"]).toFixed(2) + Utils.currentTempUnit()
                }
                PlasmaComponents.Label {
                    id: windDirCard
                    text: Utils.windDirToCard(weatherData["winddir"])
                }
                PlasmaComponents.Label {
                    id: wind
                    text: weatherData["details"]["windSpeed"] + " / " + weatherData["details"]["windGust"] + Utils.currentSpeedUnit()
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
                    text: weatherData["details"]["dewpt"] + Utils.currentTempUnit()
                    font.pointSize: 10
                }
                PlasmaComponents.Label {
                    id: precipRate
                    text: weatherData["details"]["precipRate"] + Utils.currentPrecipUnit() + "/hr"
                    font.pointSize: 10
                }
                PlasmaComponents.Label {
                    id: pressure
                    text: weatherData["details"]["pressure"].toFixed(2) + Utils.currentPresUnit()
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
                    text: weatherData["details"]["precipTotal"] + Utils.currentPrecipUnit()
                }
                PlasmaComponents.Label {
                    id: uv
                    text: weatherData["uv"]
                }
            }

            RowLayout {
                Layout.preferredWidth: parent.width
                Layout.alignment: Qt.AlignBottom

                PlasmaComponents.Label {
                    id: updatedAt
                    Layout.fillWidth: true
                    text: weatherData["obsTimeLocal"]
                    verticalAlignment: Text.AlignBottom
                }

                PlasmaComponents.Label {
                    id: currStation
                    Layout.fillWidth: true
                    text: weatherData["stationID"] + "   " + weatherData["details"]["elev"] + Utils.currentElevUnit()
                    verticalAlignment: Text.AlignBottom
                    horizontalAlignment: Text.AlignRight
                }
            }
        }
    }
}
