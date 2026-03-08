/*
 * Copyright 2026  Kevin Donnelly
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

import QtQuick
import QtQuick.Layouts
import org.kde.plasma.plasmoid
import org.kde.kirigami as Kirigami
import org.kde.plasma.components as PlasmaComponents
import org.kde.plasma.core as PlasmaCore
import "../code/utils.js" as Utils

ColumnLayout {
    id: detailsRoot

    // Top row: three columns
    RowLayout {
        Layout.preferredWidth: parent.width

        // Left: Sunrise and set times with total light time and time remaining
        ColumnLayout {
            Layout.fillWidth: true
            Layout.preferredWidth: 1
            PlasmaComponents.Label {
                text: i18n("Sunrise: %1", "10:10")
                font.pointSize: plasmoid.configuration.propPointSize
            }
            PlasmaComponents.Label {
                text: i18n("Sunset: %1","10:10")
                font.pointSize: plasmoid.configuration.propPointSize
            }
            PlasmaComponents.Label {
                text: i18n("Total light: %1", Utils.calculateTotalLightTime(weatherData["sunrise"], weatherData["sunset"]) || "N/A")
                font.pointSize: plasmoid.configuration.propPointSize
            }
            PlasmaComponents.Label {
                text: i18n("Time remaining: %1", Utils.calculateTimeRemaining(weatherData["sunset"]) || "N/A")
                font.pointSize: plasmoid.configuration.propPointSize
            }
        }

        // Center: Condition icon left of current temp, feels like, condition blurb
        RowLayout {
            Layout.fillWidth: true
            Layout.preferredWidth: 1
            Kirigami.Icon {
                source: weatherData["conditionIcon"] || "weather-clear"
                Layout.preferredWidth: Kirigami.Units.iconSizes.large
                Layout.preferredHeight: Kirigami.Units.iconSizes.large
            }
            ColumnLayout {
                PlasmaComponents.Label {
                    text: Utils.currentTempUnit(Utils.toUserTemp(weatherData["details"]["temp"]), plasmoid.configuration.tempPrecision)
                    font {
                        bold: true
                        pointSize: plasmoid.configuration.tempPointSize
                    }
                    color: plasmoid.configuration.tempAutoColor ? Utils.heatColor(weatherData["details"]["temp"], Kirigami.Theme.backgroundColor) : Kirigami.Theme.textColor
                }
                PlasmaComponents.Label {
                    text: i18n("Feels like %1", Utils.currentTempUnit(Utils.feelsLike(weatherData["details"]["temp"], weatherData["humidity"], weatherData["details"]["windSpeed"]), plasmoid.configuration.feelsPrecision))
                    font {
                        bold: true
                        pointSize: plasmoid.configuration.propPointSize
                    }
                }
                PlasmaComponents.Label {
                    text: weatherData["condition"] || "Clear"
                    font.pointSize: plasmoid.configuration.propPointSize - 1
                }
            }
        }

        // Right: Moon rise and set times and phase
        ColumnLayout {
            Layout.fillWidth: true
            Layout.preferredWidth: 1
            PlasmaComponents.Label {
                text: i18n("Moonrise: %1", weatherData["moonrise"] || "N/A")
                font.pointSize: plasmoid.configuration.propPointSize
            }
            PlasmaComponents.Label {
                text: i18n("Moonset: %1", weatherData["moonset"] || "N/A")
                font.pointSize: plasmoid.configuration.propPointSize
            }
            PlasmaComponents.Label {
                text: i18n("Phase: %1", weatherData["moonPhase"] || "N/A")
                font.pointSize: plasmoid.configuration.propPointSize
            }
        }
    }

    // Below: 2 row by 4 column grid of current conditions
    GridLayout {
        columns: 4
        rows: 2
        Layout.preferredWidth: parent.width
        uniformCellWidths: true
        uniformCellHeights: true

        // Wind
        ColumnLayout {
            Layout.alignment: Qt.AlignCenter
            Kirigami.Icon {
                id: topPanelIcon

                source: Utils.getWindBarbIcon(weatherData["details"]["windSpeed"])

                isMask: true
                color: Kirigami.Theme.textColor

                // wind barb icons are 270 degrees deviated from 0 degrees (north)
                rotation: weatherData["winddir"] - 270

                Layout.minimumWidth: Kirigami.Units.iconSizes.large
                Layout.minimumHeight: Kirigami.Units.iconSizes.large
                Layout.preferredWidth: Layout.minimumWidth
                Layout.preferredHeight: Layout.minimumHeight
                Layout.alignment: Qt.AlignCenter

                PlasmaCore.ToolTipArea {
                    anchors.fill: parent

                    interactive: true
                    mainText: i18n("Wind Barb")
                    subText: i18n("Wind direction and speed indicator")

                    mainItem: PlasmaComponents.Control {
                        implicitWidth: Math.max(implicitBackgroundWidth + leftPadding + rightPadding,
                                    implicitContentWidth + leftPadding + rightPadding)
                        implicitHeight: Math.max(implicitBackgroundHeight + topPadding + bottomPadding,
                                    implicitContentHeight + topPadding + bottomPadding)
                        
                        padding: Kirigami.Units.smallSpacing
                        
                        contentItem: ColumnLayout {
                            spacing: Kirigami.Units.smallSpacing
                            
                            PlasmaComponents.Label {
                                text: i18n("Wind Barb")
                                font.bold: true
                            }
                            
                            PlasmaComponents.Label {
                                text: i18n("Wind direction and speed indicator")
                                wrapMode: Text.WordWrap
                                font.pointSize: Kirigami.Theme.smallFont.pointSize
                            }
                            
                            PlasmaComponents.Button {
                                text: i18n("Learn more")
                                onClicked: Qt.openUrlExternally("https://en.wikipedia.org/wiki/Station_model#Plotted_winds")
                                Layout.alignment: Qt.AlignHCenter
                            }
                        }
                    }
                }
            }
            PlasmaComponents.Label {
                text: i18n("Wind from: %1 (%2°)", Utils.windDirToCard(weatherData["winddir"]), weatherData["winddir"])
                font.pointSize: plasmoid.configuration.propPointSize
                Layout.alignment: Qt.AlignCenter
            }
            PlasmaComponents.Label {
                text: Utils.toUserSpeed(weatherData["details"]["windSpeed"]).toFixed(plasmoid.configuration.windPrecision) + " " + Utils.rawSpeedUnit()
                font {
                    bold: true
                    pointSize: plasmoid.configuration.propPointSize
                }
                Layout.alignment: Qt.AlignCenter
            }
        }

        ColumnLayout {
            Layout.alignment: Qt.AlignCenter
            PlasmaComponents.Label {
                text: "\uF03F"
                font.family: "weather-icons"
                font.pixelSize: Kirigami.Units.iconSizes.medium
                horizontalAlignment: Text.AlignHCenter
                Layout.alignment: Qt.AlignCenter
            }
            PlasmaComponents.Label {
                text: i18n("Wind & Gust")
                font.pointSize: plasmoid.configuration.propPointSize
                Layout.alignment: Qt.AlignCenter
            }
            PlasmaComponents.Label {
                text: Utils.toUserSpeed(weatherData["details"]["windSpeed"]).toFixed(plasmoid.configuration.windPrecision) + " / " + Utils.currentSpeedUnit(Utils.toUserSpeed(weatherData["details"]["windGust"]), plasmoid.configuration.windPrecision)
                font {
                    bold: true
                    pointSize: plasmoid.configuration.propPointSize
                }
                Layout.alignment: Qt.AlignCenter
            }
        }

        // Dew Point
        ColumnLayout {
            Layout.alignment: Qt.AlignCenter
            PlasmaComponents.Label {
                text: "\uF04C"
                font.family: "weather-icons"
                font.pixelSize: Kirigami.Units.iconSizes.medium
                horizontalAlignment: Text.AlignHCenter
                Layout.alignment: Qt.AlignCenter
            }
            PlasmaComponents.Label {
                text: i18n("Dew Point")
                font.pointSize: plasmoid.configuration.propPointSize
                Layout.alignment: Qt.AlignCenter
            }
            PlasmaComponents.Label {
                text: Utils.currentTempUnit(Utils.toUserTemp(weatherData["details"]["dewpt"]), plasmoid.configuration.dewPrecision)
                font {
                    bold: true
                    pointSize: plasmoid.configuration.propPointSize
                }
                Layout.alignment: Qt.AlignCenter
            }
        }

        // Precipitation Rate
        ColumnLayout {
            Layout.alignment: Qt.AlignCenter
            PlasmaComponents.Label {
                text: "\uF04C"
                font.family: "weather-icons"
                font.pixelSize: Kirigami.Units.iconSizes.medium
                horizontalAlignment: Text.AlignHCenter
                Layout.alignment: Qt.AlignCenter
            }
            PlasmaComponents.Label {
                text: i18n("Precip Rate")
                font.pointSize: plasmoid.configuration.propPointSize
                Layout.alignment: Qt.AlignCenter
            }
            PlasmaComponents.Label {
                text: Utils.currentPrecipUnit(Utils.toUserPrecip(weatherData["details"]["precipRate"], isRain), isRain) + "/hr"
                font {
                    bold: true
                    pointSize: plasmoid.configuration.propPointSize
                }
                Layout.alignment: Qt.AlignCenter
            }
        }

        // Pressure
        ColumnLayout {
            Layout.alignment: Qt.AlignCenter
            PlasmaComponents.Label {
                text: "\uF00A"
                font.family: "weather-icons"
                font.pixelSize: Kirigami.Units.iconSizes.medium * 1.1
                horizontalAlignment: Text.AlignHCenter
                Layout.alignment: Qt.AlignCenter
            }
            PlasmaComponents.Label {
                text: i18n("Pressure")
                font.pointSize: plasmoid.configuration.propPointSize
                Layout.alignment: Qt.AlignCenter
            }
            PlasmaComponents.Label {
                text: Utils.currentPresUnit(Utils.toUserPres(weatherData["details"]["pressure"]))
                font {
                    bold: true
                    pointSize: plasmoid.configuration.propPointSize
                }
                Layout.alignment: Qt.AlignCenter
            }
        }

        // Humidity
        ColumnLayout {
            Layout.alignment: Qt.AlignCenter
            PlasmaComponents.Label {
                text: "\uF008"
                font.family: "weather-icons"
                font.pixelSize: Kirigami.Units.iconSizes.medium * 1.1
                horizontalAlignment: Text.AlignHCenter
                Layout.alignment: Qt.AlignCenter
            }
            PlasmaComponents.Label {
                text: i18n("Humidity")
                font.pointSize: plasmoid.configuration.propPointSize
                Layout.alignment: Qt.AlignCenter
            }
            PlasmaComponents.Label {
                text: weatherData["humidity"] + "%"
                font {
                    bold: true
                    pointSize: plasmoid.configuration.propPointSize
                }
                Layout.alignment: Qt.AlignCenter
            }
        }

        // Precipitation Accumulation
        ColumnLayout {
            Layout.alignment: Qt.AlignCenter
            PlasmaComponents.Label {
                text: "\uF04C"
                font.family: "weather-icons"
                font.pixelSize: Kirigami.Units.iconSizes.medium
                horizontalAlignment: Text.AlignHCenter
                Layout.alignment: Qt.AlignCenter
            }
            PlasmaComponents.Label {
                text: i18n("Precip Accum")
                font.pointSize: plasmoid.configuration.propPointSize
                Layout.alignment: Qt.AlignCenter
            }
            PlasmaComponents.Label {
                text: Utils.currentPrecipUnit(Utils.toUserPrecip(weatherData["details"]["precipTotal"], isRain), isRain)
                font {
                    bold: true
                    pointSize: plasmoid.configuration.propPointSize
                }
                Layout.alignment: Qt.AlignCenter
            }
        }

        // UV
        ColumnLayout {
            Layout.alignment: Qt.AlignCenter
            PlasmaComponents.Label {
                text: "\uF010"
                font.family: "weather-icons"
                font.pixelSize: Kirigami.Units.iconSizes.medium
                horizontalAlignment: Text.AlignHCenter
                Layout.alignment: Qt.AlignCenter
            }
            PlasmaComponents.Label {
                text: i18n("UV")
                font.pointSize: plasmoid.configuration.propPointSize
                Layout.alignment: Qt.AlignCenter
            }
            PlasmaComponents.Label {
                text: weatherData["uv"]
                font {
                    bold: true
                    pointSize: plasmoid.configuration.propPointSize
                }
                Layout.alignment: Qt.AlignCenter
            }
        }
    }
}
