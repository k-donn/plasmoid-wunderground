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
import org.kde.plasma.components 2.0 as PlasmaComponents
import "../code/utils.js" as Utils

GridLayout {
    id: detailsRoot

    columns: 4
    rows: 3

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
                    pointSize: plasmoid.configuration.propPointSize * 3
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
        Layout.topMargin: 2 * units.gridUnit
        Layout.bottomMargin: 2 * units.gridUnit

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

    GridView {
        Layout.columnSpan:4
        id: dayDetailsView

        model: currentDetailsModel
        Layout.alignment: Qt.AlignVCenter | Qt.AlignHCenter
        Layout.fillWidth: true
        Layout.fillHeight: true

        cellWidth: detailsRoot.width/4
        cellHeight: singleMetricDelegate.height
        
        
        delegate: singleMetricDelegate
    }
    Component {
        id: singleMetricDelegate


        
    ColumnLayout {
        width: detailsRoot.width/4
        
        spacing: 5

        PlasmaCore.SvgItem {
            id: windDirectionIcon
            Layout.alignment: Qt.AlignVCenter | Qt.AlignHCenter
            svg: PlasmaCore.Svg {
                id: svg
                imagePath: getImage(name, val, val2)
            }

            rotation: name === "windDirection" ? val - 270 : 0

            Layout.minimumWidth: units.iconSizes.medium
            Layout.minimumHeight: units.iconSizes.medium
            Layout.preferredWidth: Layout.minimumWidth
            Layout.preferredHeight: Layout.minimumHeight
        }

    
        PlasmaComponents.Label {          
            id: windDirectionLabel1
            Layout.alignment: Qt.AlignVCenter | Qt.AlignHCenter
            Layout.fillWidth: true
            Layout.fillHeight: true
            
            horizontalAlignment: Text.AlignHCenter
            text: dictVals[name].name 
            font {
                pointSize: textSize.small
            }
        }
        PlasmaComponents.Label {                
            id: windDirectionData
            Layout.alignment: Qt.AlignVCenter | Qt.AlignHCenter
            Layout.fillWidth: true
            Layout.fillHeight: true            
            horizontalAlignment: Text.AlignHCenter
            text: (val2 !== null ? Utils.getValue(name, val, val2) : Utils.getValue(name, val))
            font {
                weight: Font.Bold
                pointSize: plasmoid.configuration.propPointSize
            }
        }

        function getImage(metricName, val, val2)
        {
            if(metricName ==="windDirection") {
                return plasmoid.file("", "icons/wind-barbs/" + Utils.getWindBarb(val2) + ".svg")
            } else if (metricName === "windSpeed") {
                return plasmoid.file("", "icons/fullRepresentation/" + dictVals[metricName].icon)
            } else {
                return plasmoid.file("", "icons/fullRepresentation/" + dictVals[metricName].icon)
            }
        }

    }}
}
