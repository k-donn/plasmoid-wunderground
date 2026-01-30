pragma ComponentBehavior: Bound

/*
 * Copyright 2022  Rafal (Raf) Liwoch
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
import QtQuick.Controls
import QtQuick.Layouts
import org.kde.kirigami as Kirigami
import org.kde.plasma.components as PlasmaComponents
import org.kde.plasma.plasmoid
import "../code/utils.js" as Utils

ColumnLayout {
    id: todayRoot

    property string currentLegendText: "temperature"
    property var staticRange: ["cloudCover", "humidity", "precipitationChance"]
    property var availableReadings: ["temperature", "uvIndex", "pressure", "cloudCover", "humidity", "precipitationChance", "precipitationRate", "snowPrecipitationRate", "wind"]

    // Chart dimensions and calculations
    property int yGridCount: 11
    property double yIncrementPixels: 0
    property double minValue: 0
    property double maxValue: 0
    property double valueRange: 1
    property double sampleWidth: 0

    // Color theme properties
    property bool textColorLight: ((Kirigami.Theme.textColor.r + Kirigami.Theme.textColor.g + Kirigami.Theme.textColor.b) / 3) > 0.5
    property color gridColor: textColorLight ? Qt.tint(Kirigami.Theme.textColor, '#80000000') : Qt.tint(Kirigami.Theme.textColor, '#80FFFFFF')
    property color gridColorHighlight: textColorLight ? Qt.tint(Kirigami.Theme.textColor, '#50000000') : Qt.tint(Kirigami.Theme.textColor, '#50FFFFFF')
    property color lineColor: Kirigami.Theme.highlightColor

    // Models for grid lines
    ListModel {
        id: horizontalGridModel
    }

    TextMetrics {
        id: textMetrics
        font.family: Kirigami.Theme.defaultFont.family
        font.pixelSize: 11
        text: "999999"
    }

    ColumnLayout {
        Layout.alignment: Qt.AlignHCenter | Qt.AlignTop
        // Layout.leftMargin: 3 * Kirigami.Units.gridUnit
        // Layout.rightMargin: 3 * Kirigami.Units.gridUnit
        // Layout.topMargin: 2 * Kirigami.Units.gridUnit
        // Layout.bottomMargin: 3 * Kirigami.Units.gridUnit

        Item {
            id: mainChartItem

            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.minimumHeight: Kirigami.Units.gridUnit * 7 * 1.3
            Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter

            // Main chart area with grid and canvas
            Item {
                id: chartContainer
                anchors.fill: parent
                

                // Graph area boundary (defined first for reference by other elements)
                Rectangle {
                    id: graphArea
                    anchors.top: parent.top
                    anchors.left: parent.left
                    anchors.leftMargin: 45
                    anchors.topMargin: 20
                    width: parent.width - 145
                    height: parent.height - 40
                    color: "transparent"
                    border.color: todayRoot.gridColor
                    border.width: 1
                }

                // Buffer area for x-axis (below graph)
                Rectangle {
                    id: bufferArea
                    anchors.top: graphArea.top
                    anchors.left: graphArea.left
                    height: graphArea.height + 30
                    width: graphArea.width
                    color: "transparent"
                }

                // Grid lines (horizontal)
                ListView {
                    id: horizontalGridView

                    model: horizontalGridModel
                    anchors.fill: graphArea
                    interactive: false

                    delegate: Item {
                        required property int value
                        required property int index

                        height: graphArea.height / (todayRoot.yGridCount - 1)
                        width: graphArea.width

                        Rectangle {
                            id: horizontalLine
                            width: parent.width
                            height: 1
                            color: parent.index % 2 === 0 ? todayRoot.gridColorHighlight : todayRoot.gridColor
                            anchors.top: parent.top
                        }

                        // Y-axis label
                        PlasmaComponents.Label {
                            text: {
                                var val = todayRoot.maxValue - (parent.value * todayRoot.valueRange / (todayRoot.yGridCount - 1))
                                return val.toFixed(1)
                            }
                            width: textMetrics.width
                            height: textMetrics.height
                            horizontalAlignment: Text.AlignRight
                            anchors.left: horizontalLine.left
                            anchors.top: horizontalLine.top
                            anchors.leftMargin: -textMetrics.width-8
                            anchors.topMargin: -textMetrics.height / 2
                        }
                    }
                }

                // X-axis grid lines and labels
                ListView {
                    id: horizontalAxisView

                    model: hourlyModel
                    anchors.fill: bufferArea
                    interactive: false
                    orientation: ListView.Horizontal
                    clip: true

                    delegate: Item {
                        required property string time
                        required property int index

                        height: bufferArea.height
                        width: bufferArea.width / (hourlyModel.count - 1)

                        Rectangle {
                            id: verticalLine
                            width: 1
                            height: graphArea.height
                            color: parent.index % 2 === 0 ? todayRoot.gridColorHighlight : todayRoot.gridColor
                            anchors.top: parent.top
                        }

                        PlasmaComponents.Label {
                            text: Qt.formatDateTime(parent.time, plasmoid.configuration.dayChartTimeFormat)
                            font.pointSize: textSize.tiny
                            horizontalAlignment: Text.AlignHCenter
                            visible: parent.index % 2 === 0
                            anchors.top: verticalLine.bottom
                            anchors.horizontalCenter: verticalLine.horizontalCenter
                            anchors.topMargin: 2
                        }
                    }
                }

                // Canvas for drawing the curve
                Canvas {
                    id: dataCanvas

                    anchors.fill: graphArea
                    contextType: '2d'

                    Path {
                        id: dataPath
                        startX: 0
                    }

                    onPaint: {
                        var ctx = getContext("2d")
                        if (ctx !== null) {
                            ctx.clearRect(0, 0, width, height)
                            ctx.strokeStyle = todayRoot.lineColor
                            ctx.lineWidth = 2
                            ctx.path = dataPath
                            ctx.stroke()
                        }
                    }

                    Connections {
                        target: todayRoot
                        function onCurrentLegendTextChanged() {
                            dataCanvas.requestPaint()
                        }
                    }
                }

                

                // Legend label
                PlasmaComponents.Label {
                    id: legendLabel

                    property var unitInterval: (todayRoot.currentLegendText === "precipitationRate" || todayRoot.currentLegendText === "snowPrecipitationRate" ? i18nc("per 12 hours, please keep it short", "/12h") : "")

                    text: propInfoDict[todayRoot.currentLegendText].name + " " + Utils.wrapInBrackets(propInfoDict[todayRoot.currentLegendText].unit, unitInterval)
                    font.pointSize: textSize.small
                    font.weight: Font.Bold
                    anchors.horizontalCenter: graphArea.horizontalCenter
                    anchors.top: bufferArea.bottom
                    anchors.topMargin: 8
                }

                // Y-axis label
                PlasmaComponents.Label {
                    text: {
                        if (todayRoot.currentLegendText === "temperature") {
                            return "°C"
                        }
                        return ""
                    }
                    font.pointSize: textSize.tiny
                    anchors.left: parent.left
                    anchors.top: graphArea.top
                    visible: text !== ""
                }

                // Property selection list on the right
                ListView {
                    id: iconsListView

                    anchors.left: graphArea.right
                    anchors.leftMargin: 8
                    anchors.top: graphArea.top
                    anchors.bottom: graphArea.bottom
                    width: 80
                    model: todayRoot.availableReadings
                    clip: true
                    focus: true

                    highlight: Rectangle {
                        color: Kirigami.Theme.highlightColor
                        radius: 2
                    }

                    delegate: ChartMetricsSelectionDelegate {}
                }
            }
        }
    }

    // Functions for building and processing chart data
    function buildChartData() {
        if (hourlyModel.count === 0) {
            return
        }

        // Find min/max values for current legend text
        minValue = null
        maxValue = null

        for (var i = 0; i < hourlyModel.count; i++) {
            var obj = hourlyModel.get(i)
            var value = parseFloat(obj[currentLegendText]) || 0

            if (minValue === null) {
                minValue = value
                maxValue = value
            } else {
                if (value < minValue) minValue = value
                if (value > maxValue) maxValue = value
            }
        }

        // Add padding to range
        valueRange = Math.max(maxValue - minValue, 1)
        minValue = minValue - (valueRange * 0.1)
        maxValue = maxValue + (valueRange * 0.1)
        valueRange = maxValue - minValue

        // Clear and rebuild grid
        horizontalGridModel.clear()
        for (var j = 0; j < yGridCount; j++) {
            horizontalGridModel.append({ value: j })
        }

        // Calculate dimensions
        sampleWidth = graphArea.width / Math.max(hourlyModel.count - 1, 1)
        yIncrementPixels = graphArea.height / (yGridCount - 1)

        // Build curve
        buildCurve()
    }

    function buildCurve() {
        if (hourlyModel.count === 0) {
            return
        }

        var pathElements = []
        var startX = true

        for (var i = 0; i < hourlyModel.count; i++) {
            var obj = hourlyModel.get(i)
            var value = parseFloat(obj[currentLegendText]) || 0

            // Map value to Y coordinate (inverted because canvas Y goes down)
            var normalizedValue = (value - minValue) / valueRange
            var y = graphArea.height - (normalizedValue * graphArea.height)
            var x = i * sampleWidth

            if (startX) {
                dataPath.startY = y
                startX = false
            }

            pathElements.push(Qt.createQmlObject(
                'import QtQuick 2.0; PathCurve { x: ' + x + '; y: ' + y + ' }',
                graphArea,
                "pathElement" + i
            ))
        }

        dataPath.pathElements = pathElements
        dataCanvas.requestPaint()
    }

    // React to data changes
    onCurrentLegendTextChanged: {
        buildChartData()
    }

    Connections {
        target: hourlyModel
        function onCountChanged() {
            buildChartData()
        }
    }

    Component.onCompleted: {
        buildChartData()
    }
}
