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


            Item {
                id: dateField
                
                height: dateElement.height + 2 * units.smallSpacing
                width: parent.width

                Item {
                    id: dateElement

                    height: dayLabel.paintedHeight

                    anchors {
                        left: parent.left
                        leftMargin: units.smallSpacing
                        verticalCenter: parent.verticalCenter
                    }
                    PlasmaComponents.Label {
                        id: dayLabel
                        
                        width: plasmoid.configuration.propPointSize * 6
                        height: dayLabel.paintedHeight

                        anchors {
                            left: parent.left
                        }

                        font.pointSize: plasmoid.configuration.propPointSize * 3
                        font.weight: Font.Light
                        text: forecastScroller.dateString("dd")
                        opacity: 0.6
                    }
    
                    PlasmaExtras.Heading {
                        id: dayHeading
                        
                        width: forecastScroller.width / 3 - dayLabel.width
                        height: dayHeading.paintedHeight
                        
                        anchors {
                            left: dayLabel.right
                            top: dayLabel.top
                            topMargin: units.smallSpacing
                        }

                        level: 1
                        font.pointSize: plasmoid.configuration.propPointSize * 1.2
                        elide: Text.ElideRight
                        font.weight: Font.Bold
                        text: Qt.locale(currentLocale).dayName(currentDate.getDay())
                    }
                    PlasmaComponents.Label {
                        id: dateHeading
                        
                        width: forecastScroller.width / 3 - dayLabel.width
                        height: dateHeading.paintedHeight

                        anchors {
                            left: dayLabel.right
                            top: dayHeading.bottom
                            topMargin: units.smallSpacing
                        }

                        font.pointSize: textSize.small
                        elide: Text.ElideRight
                        text: Qt.locale(currentLocale).standaloneMonthName(currentDate.getMonth()) + forecastScroller.dateString(" yyyy")
                    }
                }


                Item {
                    id: sunMoonSetRiseGrid

                    width: forecastScroller.width / 3
                    height: parent.height
                    
                    anchors {
                        centerIn: parent
                    }


                    Item {
                        id: sunRiseElement

                        width: parent.width / 2
                        height: sunRiseData.paintedHeight

                        anchors {
                            right: parent.horizontalCenter
                            rightMargin: units.smallSpacing
                            bottom: sunMoonSetRiseGrid.verticalCenter
                            bottomMargin: units.smallSpacing
                        }

                        PlasmaCore.SvgItem {
                            id: sunRiseIcon

                            width: units.iconSizes.smallMedium
                            height: units.iconSizes.smallMedium

                            anchors {
                                right: sunRiseData.left
                                rightMargin: 2 * units.smallSpacing
                                verticalCenter: parent.verticalCenter
                            }

                            svg: PlasmaCore.Svg {
                                id: sunRiseSvg
                                imagePath: plasmoid.file("", "icons/fullRepresentation/wi-sunrise.svg")
                            }
                        }

                        PlasmaComponents.Label {
                            id: sunRiseData

                            width: parent.width / 2

                            anchors {
                                right: parent.right
                                verticalCenter: parent.verticalCenter
                            }

                            font {
                                pointSize: textSize.small
                            }

                            text: Api.extractTime(forecastModel.get(itemEl).fullForecast.sunrise, false)
                        }
                    }
                    Item {
                        id: sunSetElement

                        width: parent.width / 2
                        height: sunSetData.paintedHeight

                        anchors {
                            right: parent.horizontalCenter
                            rightMargin: units.smallSpacing
                            top: sunMoonSetRiseGrid.verticalCenter
                            topMargin: units.smallSpacing
                        }

                        PlasmaCore.SvgItem {
                            id: sunSetIcon
                            
                            width: units.iconSizes.smallMedium
                            height: units.iconSizes.smallMedium

                            anchors {
                                right: sunSetData.left
                                rightMargin: 2 * units.smallSpacing
                                verticalCenter: parent.verticalCenter
                            }

                            svg: PlasmaCore.Svg {
                                id: sunSetSvg
                                imagePath: plasmoid.file("", "icons/fullRepresentation/wi-sunset.svg")
                            }
                        }

                        PlasmaComponents.Label {
                            id: sunSetData
                            
                            width: parent.width / 2
                            height: sunSetData.paintedHeight
                            
                            anchors {
                                right: parent.right
                                verticalCenter: parent.verticalCenter
                            }

                            font {
                                pointSize: textSize.small
                            }

                            text: Api.extractTime(forecastModel.get(itemEl).fullForecast.sunset, false)
                        }
                    }
                    Item {
                        id: moonSetElement
                        
                        width: parent.width / 2
                        height: moonSetData.paintedHeight

                        anchors {
                            left: parent.horizontalCenter
                            leftMargin: units.smallSpacing
                            bottom: sunMoonSetRiseGrid.verticalCenter
                            bottomMargin: units.smallSpacing
                        }

                        PlasmaCore.SvgItem {
                            id: moonSetIcon

                            width: units.iconSizes.smallMedium
                            height: units.iconSizes.smallMedium

                            anchors {
                                left: parent.left
                                verticalCenter: parent.verticalCenter
                            }

                            svg: PlasmaCore.Svg {
                                id: moonSetSvg
                                imagePath: plasmoid.file("", "icons/fullRepresentation/wi-moonset.svg")
                            }
                        }

                        PlasmaComponents.Label {
                            id: moonSetData

                            width: parent.width / 2
                            height: moonSetData.paintedHeight
                            
                            anchors {
                                left: moonSetIcon.right
                                leftMargin: 2 * units.smallSpacing
                                verticalCenter: parent.verticalCenter
                            }

                            font {
                                pointSize: textSize.small
                            }
                            text: Api.extractTime(forecastModel.get(itemEl).fullForecast.moonset, false)
                        }
                    }
                    Item {
                        id: moonRiseElement

                        width: parent.width / 2
                        height: moonRiseData.paintedHeight

                        anchors {
                            left: parent.horizontalCenter
                            leftMargin: units.smallSpacing
                            top: sunMoonSetRiseGrid.verticalCenter
                            topMargin: units.smallSpacing
                        }

                        PlasmaCore.SvgItem {
                            id: moonRiseIcon
                            
                            width: units.iconSizes.smallMedium
                            height: units.iconSizes.smallMedium

                            anchors {
                                left: parent.left
                                verticalCenter: parent.verticalCenter
                            }

                            svg: PlasmaCore.Svg {
                                id: moonRiseSvg
                                imagePath: plasmoid.file("", "icons/fullRepresentation/wi-moonrise.svg")
                            }
                        }

                        PlasmaComponents.Label {
                            id: moonRiseData

                            width: parent.width / 2
                            height: moonRiseData.paintedHeight
                            
                            anchors {
                                left: moonRiseIcon.right
                                leftMargin: 2 * units.smallSpacing
                                verticalCenter: parent.verticalCenter
                            }

                            font {
                                pointSize: textSize.small
                            }
                            text: Api.extractTime(forecastModel.get(itemEl).fullForecast.moonrise, false)
                        }
                    }
                }

                Item{
                    id: moonRow

                    width: forecastScroller.width / 6 * 2
                    height: parent.height

                    anchors {
                        right: parent.right
                        rightMargin: units.smallSpacing
                    }

                    PlasmaCore.SvgItem {
                        id: moonIcon

                        width: units.iconSizes.medium
                        height: units.iconSizes.medium

                        anchors {
                            right: moonLabel.left
                            rightMargin: units.smallSpacing
                            verticalCenter: parent.verticalCenter
                        }

                        svg: PlasmaCore.Svg {
                            id: moonSvg
                            imagePath: plasmoid.file("", "icons/fullRepresentation/" + Utils.getMoonPhaseIcon(forecastModel.get(itemEl).fullForecast.lunar_phase_code))
                        }

                        
                    }
                    PlasmaComponents.Label {
                        id: moonLabel
                         
                        anchors {
                            right: parent.right
                            verticalCenter: parent.verticalCenter
                        }
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