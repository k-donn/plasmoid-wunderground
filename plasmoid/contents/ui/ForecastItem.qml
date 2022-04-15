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
import org.kde.plasma.extras 2.0 as PlasmaExtras
import "../code/utils.js" as Utils
import "../code/pws-api.js" as Api


GridLayout{
    columns: 8
    rows: 1
    id: forecastScroller

    property int itemEl: 0
    property int cardHeight: 130
    property int cardWidth: 75

    //property int detailsValueSize: textSize.small
    property var currentDate: new Date()
    property string currentIcon: ""
    property string currentNarrativeType: "day"
    
    function dateString(format) {
        return Qt.formatDate(currentDate, format);
    }

    GridLayout {
        id: factsView
        columns: 6
        rows: 4

        Layout.columnSpan: 8
        Layout.alignment: Qt.AlignVCenter | Qt.AlignHCenter
        Layout.topMargin: 2  * units.gridUnit

        opacity: 1
        Layout.fillWidth: true


        RowLayout {
            id: forecastRow
            Layout.alignment: Qt.AlignVCenter | Qt.AlignHCenter
            Layout.columnSpan: 6
            Layout.fillWidth: true

            Layout.minimumHeight: 140

            ListView {
                id: forecastListView

                Layout.alignment: Qt.AlignVCenter| Qt.AlignHCenter
                width: parent.width


                orientation: ListView.Horizontal
                model: forecastModel
                delegate: weatherDelegate
                highlight: Rectangle {
                    color:PlasmaCore.Theme.complementaryFocusColor
                    Layout.fillWidth:true
                    opacity: 0.2
                    radius: 5
                }
                focus: true
            }
        }

        Component {
            id: weatherDelegate

            ColumnLayout {
                id: weatherDelegateLayout
                width: forecastListView.width/8


                states: [
                State {
                    name: "expanded"
                    PropertyChanges { target: factsView; opacity: 1 }
                }
                ]

                transitions: [
                Transition {
                    NumberAnimation {
                        duration: 200;
                    }
                }
                ]

                PlasmaComponents.Label {
                    text: dayOfWeek

                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    horizontalAlignment: Text.AlignHCenter
                    font.weight: Font.Bold
                }
                PlasmaComponents.Label {
                    text: shortDesc

                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    horizontalAlignment: Text.AlignHCenter
                    elide: Text.ElideRight
                    MouseArea {
                        id: shortDescMouseHover
                        anchors.fill: parent
                        hoverEnabled: true
                    }

                    ToolTip.visible: shortDescMouseHover.containsMouse
                    ToolTip.text: shortDesc
                }
                PlasmaCore.SvgItem {
                    id: icon
                    Layout.alignment: Qt.AlignVCenter | Qt.AlignHCenter

                    Layout.minimumWidth: units.iconSizes.large
                    Layout.minimumHeight: units.iconSizes.large
                    Layout.preferredWidth: Layout.minimumWidth
                    Layout.preferredHeight: Layout.minimumHeight

                    svg: PlasmaCore.Svg {
                        imagePath: plasmoid.file("", Utils.getIconForCodeAndStyle(iconCode, plasmoid.configuration.iconStyleChoice))
                    }
                    MouseArea {
                        id: mouseArea
                        anchors.fill:parent


                        onEntered: {
                            forecastListView.currentIndex = index
                                itemEl = index
                                currentDate = new Date(forecastModel.get(itemEl).fullForecast["fcst_valid_local"])

                                singleDayModel.clear()
                                singleDayModel.append(Object.values(forecastDetailsModel.get(index)))

                                currentIcon = iconCode
                                parent.state = "expanded"
                        }

                        hoverEnabled: true
                    }

                }
                PlasmaComponents.Label {
                    id: tempHighLabel
                    text: Utils.currentTempUnit(high)

                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    horizontalAlignment: Text.AlignHCenter
                }
                PlasmaComponents.Label {
                    id: tempLowLabel
                    text: Utils.currentTempUnit(low)

                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    horizontalAlignment: Text.AlignHCenter
                }

            }
        }

        Item {
            id: dateShader
            Layout.columnSpan: 6
            Layout.rowSpan: 1

            Layout.fillWidth: true
            Layout.leftMargin: units.gridUnit
            Layout.rightMargin: units.gridUnit

            Layout.minimumHeight: dateField.height

            Rectangle {
                width: parent.width
                height: parent.height
                Layout.fillWidth: true
                Layout.fillHeight: true
                color: PlasmaCore.Theme.complementaryFocusColor
                radius: 5
                opacity: 0.3
            }
            
            Layout.alignment: Qt.AlignVCenter | Qt.AlignLeft


            GridLayout {
                id: dateField
                columns:4
                rows: 2
                columnSpacing: 10
                rowSpacing: 5
                flow: GridLayout.TopToBottom

                PlasmaComponents.Label {
                    id: dayLabel
                    Layout.rowSpan: 2
                    Layout.preferredWidth: plasmoid.configuration.propPointSize * 6
                    font.pointSize: plasmoid.configuration.propPointSize * 3
                    font.weight: Font.Light
                    text: forecastScroller.dateString("dd")
                    opacity: 0.6
                }

                PlasmaExtras.Heading {
                    id: dayHeading
                    Layout.preferredWidth: forecastScroller.width / 3 - dayLabel.width
                    level: 1
                    font.pointSize: plasmoid.configuration.propPointSize * 1.2
                    elide: Text.ElideRight
                    font.weight: Font.Bold
                    text: Qt.locale(currentLocale).dayName(currentDate.getDay())
                }
                PlasmaComponents.Label {
                    id: dateHeading
                    Layout.preferredWidth: forecastScroller.width / 3 - dayLabel.width
                    font.pointSize: textSize.small

                    elide: Text.ElideRight
                    text: Qt.locale(currentLocale).standaloneMonthName(currentDate.getMonth())
                    + forecastScroller.dateString(" yyyy")
                }

                GridLayout {
                    id: sunMoonSetRiseGrid
                    columns: 2
                    rows: 2

                    Layout.rowSpan: 2
                    Layout.columnSpan: 1
                    Layout.alignment: Qt.AlignVCenter | Qt.AlignHCenter

                    columnSpacing: 0
                    rowSpacing: 0

                    Layout.preferredWidth: forecastScroller.width / 3


                    RowLayout {
                        Layout.preferredWidth: parent.width / 2

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
                            Layout.preferredWidth: parent.width / 2
                            horizontalAlignment: Text.AlignHCenter
                            text: Api.extractTime(forecastModel.get(itemEl).fullForecast.sunrise, false)
                            font {
                                pointSize: textSize.small
                            }
                        }
                    }
                    RowLayout {
                        Layout.preferredWidth: parent.width / 2

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
                            Layout.preferredWidth: parent.width / 2
                            horizontalAlignment: Text.AlignHCenter
                            text: Api.extractTime(forecastModel.get(itemEl).fullForecast.sunset, false)
                            font {
                                //weight: Font.Bold
                                pointSize: textSize.small
                            }
                        }
                    }
                    RowLayout {
                        Layout.preferredWidth: parent.width / 2

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
                            Layout.preferredWidth: parent.width / 2
                            horizontalAlignment: Text.AlignHCenter
                            text: Api.extractTime(forecastModel.get(itemEl).fullForecast.moonrise, false)
                            font {
                                pointSize: textSize.small
                            }
                        }
                    }
                    RowLayout {
                        Layout.preferredWidth: parent.width / 2

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
                            Layout.preferredWidth: parent.width / 2
                            horizontalAlignment: Text.AlignHCenter
                            text: Api.extractTime(forecastModel.get(itemEl).fullForecast.moonset, false)
                            font {
                                pointSize: textSize.small
                            }
                        }
                    }
                }

                RowLayout{
                    id: moonRow

                    Layout.preferredWidth: forecastScroller.width / 6 * 2

                    Layout.columnSpan: 1
                    Layout.rowSpan: 2
                    Layout.alignment: Qt.AlignVCenter | Qt.AlignHCenter

                    PlasmaCore.SvgItem {
                        id: moonIcon
                        svg: PlasmaCore.Svg {
                            id: moonSvg
                            imagePath: plasmoid.file("", "icons/fullRepresentation/" + Utils.getMoonPhaseIcon(forecastModel.get(itemEl).fullForecast.lunar_phase))
                        }

                        Layout.minimumWidth: units.iconSizes.medium
                        Layout.minimumHeight: units.iconSizes.medium
                        Layout.preferredWidth: Layout.minimumWidth
                        Layout.preferredHeight: Layout.minimumHeight
                    }
                    PlasmaComponents.Label {
                        id: moonLabel
                        horizontalAlignment: Text.AlignHCenter
                        text: forecastModel.get(itemEl).fullForecast.lunar_phase
                        font {
                            weight: Font.Bold
                            pointSize: textSize.small
                        }
                    }

                }
            }

        }

        PlasmaComponents.Label {
            Layout.columnSpan: 6
            Layout.rowSpan: 1
            Layout.fillWidth: true
            Layout.leftMargin: units.gridUnit
            Layout.rightMargin: units.gridUnit

            Layout.alignment: Qt.AlignVCenter | Qt.AlignHCenter
            Layout.minimumHeight: (plasmoid.configuration.propPointSize) * 5
            id: narrativeLabel

            text: forecastModel.get(itemEl).fullForecast.narrative
            font {
                weight: Font.Bold
                italic: false
                pointSize: plasmoid.configuration.propPointSize
            }
            wrapMode: Text.WordWrap
            verticalAlignment: Text.AlignVCenter
            horizontalAlignment: Text.AlignHCenter
        }

        RowLayout {
            id: detailsRow

            Layout.columnSpan: 6
            Layout.fillWidth: true
            Layout.minimumHeight: 100

            ListView {
                id: detailsListView
                width: parent.width

                orientation: ListView.Horizontal
                model: singleDayModel
                delegate: detailsDelegate
                section.property: "size"
                section.criteria: ViewSection.FullString
                section.delegate: sectionHeading

            }
        }
        Component {
            id: detailsDelegate

            ColumnLayout {
                id: weatherDelegateLayout
                width: detailsListView.width / 7

                property var unitInterval: (name === "precipitationRate" || name === "snowPrecipitationRate" ? "/12h" : "")

                PlasmaCore.SvgItem {
                    id: detailsIcon
                    Layout.alignment: Qt.AlignVCenter | Qt.AlignHCenter
                    svg: PlasmaCore.Svg {
                        id: detailsIconSvg
                        imagePath: plasmoid.file("", "icons/fullRepresentation/" + dictVals[name].icon)
                    }

                    Layout.preferredWidth: parent.width/3
                    Layout.preferredHeight: parent.width/3
                }
                PlasmaComponents.Label {
                    id: dayValId
                    horizontalAlignment: Text.AlignHCenter
                    Layout.fillWidth: true
                    Layout.fillHeight: true

                    text: dayVal == -1000 ? "n/a" : `${dayVal} ${dictVals[name].unit}${parent.unitInterval}`
                    font {
                        //weight: Font.Bold
                        pointSize: textSize.small
                    }
                }
                PlasmaComponents.Label {
                    id: nightValId
                    horizontalAlignment: Text.AlignHCenter
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    opacity: 0.75

                    text: `${nightVal} ${dictVals[name].unit}${parent.unitInterval}`
                    font {
                        pointSize: textSize.small
                    }
                }
            }
        }




    }
}





