/*
 * Copyright 2021  Kevin Donnelly
 * Copyright 2022  Rafal Liwoch
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

import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.2
import QtGraphicalEffects 1.12

import org.kde.kirigami 2.4 as Kirigami
import org.kde.kquickcontrols 2.0

import org.kde.quickcharts 1.0 as Charts
import org.kde.quickcharts.controls 1.0 as ChartsControls

import org.kde.plasma.plasmoid 2.0
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as PlasmaComponents
import org.kde.plasma.extras 2.0 as PlasmaExtras
import "../code/utils.js" as Utils
import "../code/pws-api.js" as Api


ColumnLayout{
    id: todayRoot

    property string currentLegendText: "temperature"
    property var staticRange: ["cloudCover","humidity","precipitationChance"]

    property var availableReadings: [ "temperature", "cloudCover", "humidity", "precipitationChance", "precipitationRate", "snowPrecipitationRate", "wind"]

    ColumnLayout {
        Layout.alignment: Qt.AlignHCenter | Qt.AlignTop
        Layout.leftMargin: 3  * units.gridUnit
        Layout.rightMargin: 3  * units.gridUnit
        Layout.topMargin: 2  * units.gridUnit
        Layout.bottomMargin: 2  * units.gridUnit

        Item {
            id: mainChartItem
            Layout.fillWidth: true

            Layout.minimumHeight:  units.gridUnit * 7 *2.6

            Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter

            Charts.LineChart {
                id: lineChart

                anchors.fill: parent
                smooth: true

                valueSources: [
                Charts.ModelSource { roleName: "temperature"; model: dailyChartModel }
                ]


                yRange.automatic: true
                yRange.increment: 5

                colorSource: Charts.SingleValueSource { value: PlasmaCore.Theme.buttonTextColor }
                fillColorSource: Charts.ColorGradientSource {
                    baseColor: PlasmaCore.Theme.complementaryFocusColor
                    itemCount: 3
                }
                nameSource: Charts.SingleValueSource { value: currentLegendText } //todo //

                indexingMode: Charts.Chart.IndexEachSource

                pointDelegate: Item {
                    id: pointItem
                    Rectangle {
                        anchors.centerIn: parent
                        width: plasmoid.configuration.propPointSize;
                        height: width
                        radius: width / 2;
                        color: parent.Charts.LineChart.color


                        PlasmaComponents.Label {
                            anchors.right: parent.left
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.rightMargin: (plasmoid.configuration.propPointSize - 2)/2

                            text: pointItem.Charts.LineChart.value

                            horizontalAlignment: Text.AlignHCenter
                            font.pointSize: plasmoid.configuration.propPointSize - 2
                        }

                        MouseArea {
                            id: mouse
                            anchors.fill: parent
                            hoverEnabled: true
                        }

                        ToolTip.visible: mouse.containsMouse
                        ToolTip.text: "%1: %2".arg(parent.Charts.LineChart.name).arg(parent.Charts.LineChart.value)
                    }
                }
            }
            Charts.GridLines {
                id: verticalLines

                anchors.fill: lineChart

                chart: lineChart
                opacity:1

                direction: Charts.GridLines.Vertical;

                major.frequency: 10
                major.lineWidth: 2
                major.color: Qt.rgba(0.8, 0.8, 0.8, 0.1)

                minor.frequency: 5
                minor.lineWidth: 1
                minor.color: Qt.rgba(0.8, 0.8, 0.8, 0.1)
            }
            Charts.GridLines {
                id: horizontalLines

                anchors.fill: lineChart

                chart: lineChart
                opacity:1

                major.frequency: 2
                major.lineWidth: 1
                major.color: Qt.rgba(0.8, 0.8, 0.8, 0.3)

                minor.frequency: 1
                minor.lineWidth: 1
                minor.color: Qt.rgba(0.8, 0.8, 0.8, 0.1)
            }

            Charts.AxisLabels {
                id: yAxisLabels

                anchors {
                    right: parent.left
                    top: parent.top
                    bottom: parent.bottom
                    rightMargin: (plasmoid.configuration.propPointSize - 2)/2
                }

                direction: Charts.AxisLabels.VerticalBottomTop
                delegate:  PlasmaComponents.Label {
                    id: xAxisLabelId
                    font.pointSize: plasmoid.configuration.propPointSize -2
                    horizontalAlignment: Text.AlignHCenter

                    text: Charts.AxisLabels.label
                }
                source: Charts.ChartAxisSource {
                    chart: lineChart;
                    axis: Charts.ChartAxisSource.YAxis;
                    itemCount: 5 }
            }

            Charts.AxisLabels {
                id: xAxisLabels
                constrainToBounds: false
                anchors {
                    left: parent.left
                    right: parent.right
                    top: lineChart.bottom
                }

                delegate: PlasmaComponents.Label {
                    id: xAxisLabelId
                    rotation: 0
                    Layout.fillWidth: true
                    font.pointSize: plasmoid.configuration.propPointSize -2
                    horizontalAlignment: Text.AlignHCenter


                    text:
                    "<b>" + dailyChartModel.get(Charts.AxisLabels.label).date + "</b>"
                    //+ "<br\>" + dailyChartModel.get(Charts.AxisLabels.label).time
                }
                source: Charts.ChartAxisSource {
                    chart: lineChart;
                    axis: Charts.ChartAxisSource.XAxis;
                    itemCount: 8
                }
            }


            Charts.AxisLabels {
                id: xAxisLabelsWeatherDay
                constrainToBounds: false
                direction: AxisLabels.HorizontalLeftRight
                source: Charts.ChartAxisSource {
                    chart: lineChart;
                    axis: Charts.ChartAxisSource.XAxis;
                    itemCount: 15
                }

                anchors {
                    left: lineChart.left
                    right: lineChart.right
                    bottom: lineChart.top
                    bottomMargin: units.gridUnit/4
                }

                delegate:
                PlasmaCore.SvgItem {
                    property var weatherElement: dailyChartModel.get(Charts.AxisLabels.label)

                    opacity: weatherElement.isDay ? 1 : 0.25
                    id: xAxisLabelWeatherDayId

                    svg: PlasmaCore.Svg {
                        id: xAxisLabelWeatherDaySvg
                        imagePath: plasmoid.file("", "icons/" + weatherElement.iconCode + ".svg")
                    }


                    width: units.iconSizes.smallMedium - 2
                    height: units.iconSizes.smallMedium - 2
                }

            }

            Rectangle {
                id: legendId

                anchors {
                    top: xAxisLabels.bottom
                    horizontalCenter: lineChart.horizontalCenter
                }
                width: legendLabel.width * 1.25
                height: legendLabel.height * 1

                color: PlasmaCore.Theme.complementaryFocusColor
                radius: 2

                PlasmaComponents.Label {
                    id: legendLabel
                    anchors.centerIn: parent

                    property var unitInterval: (currentLegendText === "precipitationRate" || currentLegendText === "snowPrecipitationRate" ? "/12h" : "")

                    Layout.alignment: Qt.AlignVCenter | Qt.AlignHCenter
                    text: `${dictVals[currentLegendText].name} [${dictVals[currentLegendText].unit}${unitInterval}]`
                    font {
                        weight: Font.Bold
                        pointSize: plasmoid.configuration.propPointSize - 1
                    }
                }

            }

            ListView {
                id: iconsListView

                anchors.left: parent.right
                anchors.top: lineChart.top
                anchors.bottom: LineChart.bottom

                width: units.gridUnit * 2
                height: lineChart.height
                model: availableReadings
                highlight: Rectangle {
                    color: PlasmaCore.Theme.complementaryFocusColor
                    Layout.fillWidth:true
                    radius: 2
                }
                focus: true
                delegate: iconsDelegate
            }
            Component {
                id: iconsDelegate
                Column {
                    PlasmaCore.SvgItem {
                        id: iconHolder

                        svg: PlasmaCore.Svg {
                            id: iconSvg
                            imagePath: plasmoid.file("", "icons/fullRepresentation/" + dictVals[availableReadings[index]].icon)
                        }

                        Layout.minimumWidth: units.gridUnit * 2
                        Layout.minimumHeight: units.gridUnit * 2
                        width: Layout.minimumWidth
                        height: Layout.minimumHeight

                        MouseArea {
                            anchors.fill: parent
                            hoverEnabled: true

                            onEntered: {
                                iconsListView.currentIndex = index
                            }
                            onPressed: {
                                currentLegendText = availableReadings[index]
                                lineChart.nameSource.value = currentLegendText
                                if(staticRange.includes(currentLegendText)) {
                                    lineChart.yRange.automatic = false
                                    lineChart.yRange.from = 0
                                    lineChart.yRange.to = 100
                                } else {
                                    lineChart.yRange.automatic = true
                                }
                                lineChart.valueSources[0].roleName = currentLegendText
                            }
                        }
                    }
                }
            }
        }
    }

}








