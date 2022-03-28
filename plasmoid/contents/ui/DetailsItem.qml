/*
 * Copyright 2021  Kevin Donnelly
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
import org.kde.plasma.components 2.0 as PlasmaComponents
import "../code/utils.js" as Utils

GridLayout {
    id: detailsRoot

    columns: 4
    rows: 4

    ColumnLayout {
        id: sunRiseSetCol
        Layout.columnSpan: 1
        Layout.alignment: Qt.AlignVCenter | Qt.AlignHCenter

        RowLayout {
            PlasmaCore.SvgItem {
                id: sunRiseIcon
                Layout.alignment: Qt.AlignVCenter | Qt.AlignHCenter
                svg: PlasmaCore.Svg {
                    id: sunRiseSvg
                    imagePath: plasmoid.file("", "icons/fullRepresentation/wi-sunrise.svg")
                }

                Layout.minimumWidth: units.iconSizes.smallMedium
                Layout.minimumHeight: units.iconSizes.smallMedium
                Layout.preferredWidth: Layout.minimumWidth
                Layout.preferredHeight: Layout.minimumHeight
            }

            PlasmaComponents.Label {
                id: sunRiseData
                Layout.alignment: Qt.AlignVCenter | Qt.AlignHCenter
                text: dayInfo["sunrise"]
                font {
                    //weight: Font.Bold
                    pointSize: plasmoid.configuration.propPointSize
                }
            }
        }
        RowLayout {
            PlasmaCore.SvgItem {
                id: sunSetIcon
                Layout.alignment: Qt.AlignVCenter | Qt.AlignHCenter
                svg: PlasmaCore.Svg {
                    id: sunSetSvg
                    imagePath: plasmoid.file("", "icons/fullRepresentation/wi-sunset.svg")
                }

                Layout.minimumWidth: units.iconSizes.smallMedium
                Layout.minimumHeight: units.iconSizes.smallMedium
                Layout.preferredWidth: Layout.minimumWidth
                Layout.preferredHeight: Layout.minimumHeight
            }

            PlasmaComponents.Label {
                id: sunSetData
                Layout.alignment: Qt.AlignVCenter | Qt.AlignHCenter
                text: dayInfo["sunset"]
                font {
                    //weight: Font.Bold
                    pointSize: plasmoid.configuration.propPointSize
                }
            }
        }
    }

    GridLayout {
        id: temperatureCol
        Layout.columnSpan: 2
        columns: 2
        rows: 2


        Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter

        PlasmaCore.SvgItem {
            Layout.rowSpan:2
            id: temperatureIcon
            Layout.alignment: Qt.AlignVCenter | Qt.AlignHCenter
            svg: PlasmaCore.Svg {
                id: temperatureIconSvg
                imagePath: plasmoid.file("", "icons/fullRepresentation/wi-thermometer.svg")
            }

            Layout.minimumWidth: units.iconSizes.huge
            Layout.minimumHeight: units.iconSizes.huge
            Layout.preferredWidth: Layout.minimumWidth
            Layout.preferredHeight: Layout.minimumHeight
        }
        ColumnLayout {
            PlasmaComponents.Label {
                id: temp
                Layout.alignment: Qt.AlignVCenter | Qt.AlignHCenter
                text: Utils.currentTempUnit(weatherData["details"]["temp"])
                font {
                    pointSize: plasmoid.configuration.tempPointSize
                }
                color: Utils.heatColor(weatherData["details"]["temp"])
            }


            PlasmaComponents.Label {
                id: feelsLike
                Layout.alignment: Qt.AlignVCenter | Qt.AlignHCenter
                text: i18n("Feels like %1", Utils.currentTempUnit(Utils.feelsLike(weatherData["details"]["temp"], weatherData["humidity"], weatherData["details"]["windSpeed"])))
                font {
                    weight: Font.Bold
                    pointSize: plasmoid.configuration.propPointSize
                }
            }
        }
    }

    ColumnLayout {
        id: moonRiseSetCol
        Layout.columnSpan: 1
        Layout.alignment: Qt.AlignVCenter | Qt.AlignHCenter
        RowLayout {
            PlasmaCore.SvgItem {
                id: moonRiseIcon
                Layout.alignment: Qt.AlignVCenter | Qt.AlignHCenter
                svg: PlasmaCore.Svg {
                    id: moonRiseSvg
                    imagePath: plasmoid.file("", "icons/fullRepresentation/wi-moonrise.svg")
                }

                Layout.minimumWidth: units.iconSizes.smallMedium
                Layout.minimumHeight: units.iconSizes.smallMedium
                Layout.preferredWidth: Layout.minimumWidth
                Layout.preferredHeight: Layout.minimumHeight
            }

            PlasmaComponents.Label {
                id: moonRiseData
                Layout.alignment: Qt.AlignVCenter | Qt.AlignHCenter
                text: dayInfo["moonrise"]
                font {
                    //weight: Font.Bold
                    pointSize: plasmoid.configuration.propPointSize
                }
            }
        }
        RowLayout {
            PlasmaCore.SvgItem {
                id: moonSetIcon
                Layout.alignment: Qt.AlignVCenter | Qt.AlignHCenter
                svg: PlasmaCore.Svg {
                    id: moonSetSvg
                    imagePath: plasmoid.file("", "icons/fullRepresentation/wi-moonset.svg")
                }

                Layout.minimumWidth: units.iconSizes.smallMedium
                Layout.minimumHeight: units.iconSizes.smallMedium
                Layout.preferredWidth: Layout.minimumWidth
                Layout.preferredHeight: Layout.minimumHeight
            }

            PlasmaComponents.Label {
                id: moonSetData
                Layout.alignment: Qt.AlignVCenter | Qt.AlignHCenter
                text: dayInfo["moonset"]
                font {
                    //weight: Font.Bold
                    pointSize: plasmoid.configuration.propPointSize
                }
            }
        }
    }

    RowLayout{
        id: narrativeTextRow
        Layout.columnSpan: 4
        Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter

        PlasmaComponents.Label {
            id: narrative
            text: narrativeText
            Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
            font {
                italic: true
                pointSize: plasmoid.configuration.propPointSize
            }
            horizontalAlignment: Text.AlignHCenter
            wrapMode: Text.WordWrap
            Layout.fillWidth: true
            Layout.leftMargin: 20
            Layout.rightMargin: 10
        }
    }

    ColumnLayout {
        id: windDirectionCol
        spacing: 5
        Layout.alignment: Qt.AlignVCenter | Qt.AlignHCenter

        PlasmaCore.SvgItem {
            id: windDirectionIcon
            Layout.alignment: Qt.AlignVCenter | Qt.AlignHCenter
            svg: PlasmaCore.Svg {
                id: svg
                imagePath: plasmoid.file("", "icons/wind-barbs/" + Utils.getWindBarb(weatherData["details"]["windSpeed"]) + ".svg")
            }

            rotation: weatherData["winddir"] - 270

            Layout.minimumWidth: units.iconSizes.medium
            Layout.minimumHeight: units.iconSizes.medium
            Layout.preferredWidth: Layout.minimumWidth
            Layout.preferredHeight: Layout.minimumHeight
        }

        PlasmaComponents.Label {
            id: windDirectionLabel1
            Layout.alignment: Qt.AlignVCenter | Qt.AlignHCenter
            text: i18n("Wind from")
            font {
                pointSize: plasmoid.configuration.propPointSize - 1
            }
        }
        PlasmaComponents.Label {
            id: windDirectionData
            Layout.alignment: Qt.AlignVCenter | Qt.AlignHCenter
            text: Utils.windDirToCard(weatherData["winddir"])
            font {
                weight: Font.Bold
                pointSize: plasmoid.configuration.propPointSize
            }
        }
    }


    ColumnLayout {
        id: windCol
        spacing: 5
        Layout.alignment: Qt.AlignVCenter | Qt.AlignHCenter

        PlasmaCore.SvgItem {
            id: windIcon
            Layout.alignment: Qt.AlignVCenter | Qt.AlignHCenter
            svg: PlasmaCore.Svg {
                id: windSvg
                imagePath: plasmoid.file("", "icons/fullRepresentation/wi-strong-wind.svg")
            }

            Layout.minimumWidth: units.iconSizes.medium
            Layout.minimumHeight: units.iconSizes.medium
            Layout.preferredWidth: Layout.minimumWidth
            Layout.preferredHeight: Layout.minimumHeight
        }
        PlasmaComponents.Label {
            id: windLabel1
            Layout.alignment: Qt.AlignVCenter | Qt.AlignHCenter
            text: i18n("WIND & GUST")
            font {
                pointSize: plasmoid.configuration.propPointSize - 1
            }
        }

        PlasmaComponents.Label {
            id: windData
            Layout.alignment: Qt.AlignVCenter | Qt.AlignHCenter
            text: weatherData["details"]["windSpeed"] + " / " + Utils.currentSpeedUnit(weatherData["details"]["windGust"])
            font {
                weight: Font.Bold
                pointSize: plasmoid.configuration.propPointSize
            }
        }
    }

    ColumnLayout {
        id: dewPtCol
        spacing: 5
        Layout.alignment: Qt.AlignVCenter | Qt.AlignHCenter

        PlasmaCore.SvgItem {
            id: dewPtIcon
            Layout.alignment: Qt.AlignVCenter | Qt.AlignHCenter
            svg: PlasmaCore.Svg {
                id: dewPtSvg
                imagePath: plasmoid.file("", "icons/fullRepresentation/wi-raindrop.svg")
            }

            Layout.minimumWidth: units.iconSizes.medium
            Layout.minimumHeight: units.iconSizes.medium
            Layout.preferredWidth: Layout.minimumWidth
            Layout.preferredHeight: Layout.minimumHeight
        }
        PlasmaComponents.Label {
            id: dewPtLabel1
            Layout.alignment: Qt.AlignVCenter | Qt.AlignHCenter
            text: i18n("DEWPOINT")
            font {
                pointSize: plasmoid.configuration.propPointSize - 1
            }
        }

        PlasmaComponents.Label {
            id: dewPtData
            Layout.alignment: Qt.AlignVCenter | Qt.AlignHCenter
            text: Utils.currentTempUnit(weatherData["details"]["dewpt"])
            font {
                weight: Font.Bold
                pointSize: plasmoid.configuration.propPointSize
            }
        }
    }

    ColumnLayout {
        id: precipRateCol
        spacing: 5
        Layout.alignment: Qt.AlignVCenter | Qt.AlignHCenter

        PlasmaCore.SvgItem {
            id: precipRateIcon
            Layout.alignment: Qt.AlignVCenter | Qt.AlignHCenter
            svg: PlasmaCore.Svg {
                id: precipRateSvg
                imagePath: plasmoid.file("", "icons/fullRepresentation/wi-raindrops.svg")
            }

            Layout.minimumWidth: units.iconSizes.medium
            Layout.minimumHeight: units.iconSizes.medium
            Layout.preferredWidth: Layout.minimumWidth
            Layout.preferredHeight: Layout.minimumHeight
        }
        PlasmaComponents.Label {
            id: precipRateLabel1
            Layout.alignment: Qt.AlignVCenter | Qt.AlignHCenter
            text: i18nc("Precipitation rate", "PRECIP RATE")
            font {
                pointSize: plasmoid.configuration.propPointSize - 1
            }
        }
        PlasmaComponents.Label {
            id: precipRateData
            Layout.alignment: Qt.AlignVCenter | Qt.AlignHCenter
            text: Utils.currentPrecipUnit(weatherData["details"]["precipRate"], isRain) + "/hr"
            font {
                weight: Font.Bold
                pointSize: plasmoid.configuration.propPointSize
            }
        }
    }

    ColumnLayout {
        id: pressureCol
        spacing: 5
        Layout.alignment: Qt.AlignVCenter | Qt.AlignHCenter

        PlasmaCore.SvgItem {
            id: pressureIcon
            Layout.alignment: Qt.AlignVCenter | Qt.AlignHCenter
            svg: PlasmaCore.Svg {
                id: pressureSvg
                imagePath: plasmoid.file("", "icons/fullRepresentation/wi-barometer.svg")
            }

            Layout.minimumWidth: units.iconSizes.medium
            Layout.minimumHeight: units.iconSizes.medium
            Layout.preferredWidth: Layout.minimumWidth
            Layout.preferredHeight: Layout.minimumHeight
        }
        PlasmaComponents.Label {
            id: pressureLabel1
            Layout.alignment: Qt.AlignVCenter | Qt.AlignHCenter
            text: i18n("PRESSURE")
            font {
                pointSize: plasmoid.configuration.propPointSize - 1
            }
        }
        PlasmaComponents.Label {
            id: pressureData
            Layout.alignment: Qt.AlignVCenter | Qt.AlignHCenter
            text: Utils.currentPresUnit(weatherData["details"]["pressure"])
            font {
                weight: Font.Bold
                pointSize: plasmoid.configuration.propPointSize
            }
        }
    }

    ColumnLayout {
        id: humidityCol
        spacing: 5
        Layout.alignment: Qt.AlignVCenter | Qt.AlignHCenter

        PlasmaCore.SvgItem {
            id: humidityIcon
            Layout.alignment: Qt.AlignVCenter | Qt.AlignHCenter
            svg: PlasmaCore.Svg {
                id: humiditySvg
                imagePath: plasmoid.file("", "icons/fullRepresentation/wi-humidity.svg")
            }

            Layout.minimumWidth: units.iconSizes.medium
            Layout.minimumHeight: units.iconSizes.medium
            Layout.preferredWidth: Layout.minimumWidth
            Layout.preferredHeight: Layout.minimumHeight
        }
        PlasmaComponents.Label {
            id: humidityLabel1
            Layout.alignment: Qt.AlignVCenter | Qt.AlignHCenter
            text: i18n("HUMIDITY")
            font {
                pointSize: plasmoid.configuration.propPointSize - 1
            }
        }

        PlasmaComponents.Label {
            id: humidityData
            Layout.alignment: Qt.AlignVCenter | Qt.AlignHCenter
            text: weatherData["humidity"] + "%"
            font {
                weight: Font.Bold
                pointSize: plasmoid.configuration.propPointSize
            }
        }
    }

    ColumnLayout {
        id: precipAccCol
        spacing: 5
        Layout.alignment: Qt.AlignVCenter | Qt.AlignHCenter

        PlasmaCore.SvgItem {
            id: precipAccIcon
            Layout.alignment: Qt.AlignVCenter | Qt.AlignHCenter
            svg: PlasmaCore.Svg {
                id: precipAccSvg
                imagePath: plasmoid.file("", "icons/fullRepresentation/wi-flood.svg")
            }

            Layout.minimumWidth: units.iconSizes.medium
            Layout.minimumHeight: units.iconSizes.medium
            Layout.preferredWidth: Layout.minimumWidth
            Layout.preferredHeight: Layout.minimumHeight
        }
        PlasmaComponents.Label {
            id: precipAccLabel1
            Layout.alignment: Qt.AlignVCenter | Qt.AlignHCenter
            text: i18nc("Precipitation accumulation", "PRECIP ACCUM")
            font {
                pointSize: plasmoid.configuration.propPointSize - 1
            }
        }
        PlasmaComponents.Label {
            id: precipAccData
            Layout.alignment: Qt.AlignVCenter | Qt.AlignHCenter
            text: Utils.currentPrecipUnit(weatherData["details"]["precipTotal"], isRain)
            font {
                weight: Font.Bold
                pointSize: plasmoid.configuration.propPointSize
            }
        }
    }

    ColumnLayout {
        id: uvCol
        spacing: 5
        Layout.alignment: Qt.AlignVCenter | Qt.AlignHCenter

        PlasmaCore.SvgItem {
            id: uvIcon
            Layout.alignment: Qt.AlignVCenter | Qt.AlignHCenter
            svg: PlasmaCore.Svg {
                id: uvSvg
                imagePath: plasmoid.file("", "icons/fullRepresentation/wi-horizon-alt.svg")
            }

            Layout.minimumWidth: units.iconSizes.medium
            Layout.minimumHeight: units.iconSizes.medium
            Layout.preferredWidth: Layout.minimumWidth
            Layout.preferredHeight: Layout.minimumHeight
        }
        PlasmaComponents.Label {
            id: uvLabel1
            Layout.alignment: Qt.AlignVCenter | Qt.AlignHCenter
            text: i18nc("Ultra Violet", "UV")
            font {
                pointSize: plasmoid.configuration.propPointSize - 1
            }
        }
        PlasmaComponents.Label {
            id: uvData
            Layout.alignment: Qt.AlignVCenter | Qt.AlignHCenter
            text: weatherData["uv"]
            font {
                weight: Font.Bold
                pointSize: plasmoid.configuration.propPointSize
            }
        }
    }
}
