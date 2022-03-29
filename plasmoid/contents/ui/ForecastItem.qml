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
import "../code/pws-api.js" as Api


GridLayout{
    columns: 8
    rows: 2
    id: forecastScroller

    property var itemEl: forecastListView.get(1)
    property int cardHeight: 150
    property int cardWidth: 75
    property int viewPortWidth: 600
    property int viewPortHeight: 400
    property int detailsValueSize: plasmoid.configuration.propPointSize - 1


    ListView {
        id: forecastListView
        Layout.alignment: Qt.AlignTop | Qt.AlignHCenter
        height:cardHeight
        width: viewPortWidth
        orientation: ListView.Horizontal
        model: forecastModel
        delegate: weatherDelegate
        highlight: Rectangle {
            color: 'grey'
            Layout.fillWidth:true
            radius: 5
            Text {
                anchors.centerIn: parent
                color: 'white'
            }
        }
        focus: true
    }



    Component{
        id: weatherDelegate
        Item {
            width: cardWidth
            height: cardHeight

            Layout.alignment: Qt.AlignTop | Qt.AlignHCenter

            ColumnLayout {
                id: weatherDelegateLayout

                width: cardWidth
                height: cardHeight

                Layout.columnSpan: 1
                Layout.alignment: Qt.AlignVCenter | Qt.AlignHCenter

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
                        properties: "height,width,anchors.rightMargin,anchors.topMargin,opacity,contentY"
                    }
                }
                ]



                PlasmaComponents.Label {
                    Layout.alignment: Qt.AlignVCenter | Qt.AlignHCenter
                    text: date
                }
                PlasmaComponents.Label {
                    Layout.alignment: Qt.AlignVCenter | Qt.AlignHCenter
                    text: dayOfWeek
                }
                PlasmaComponents.Label {
                    Layout.alignment: Qt.AlignVCenter | Qt.AlignHCenter
                    text: shortDesc
                }
                PlasmaCore.SvgItem {
                    id: icon
                    Layout.alignment: Qt.AlignVCenter | Qt.AlignHCenter

                    Layout.minimumWidth: units.iconSizes.large
                    Layout.minimumHeight: units.iconSizes.large
                    Layout.preferredWidth: Layout.minimumWidth
                    Layout.preferredHeight: Layout.minimumHeight

                    svg: PlasmaCore.Svg {
                        imagePath: plasmoid.file("", "icons/" + iconCode + ".svg")
                    }

                    PlasmaCore.ToolTipArea {
                        id: tooltip

                        mainText: longDesc
                        subText: "<font size='4'>" +
                        "Feels like: " + Utils.currentTempUnit(feelsLike) + "<br/>" +
                        "Thunder: " + thunderDesc + "<br/>" +
                        "UV: " + UVDesc + "<br/>" +
                        "Snow: " + snowDesc + "<br/>" +
                        "Golf: " + golfDesc + "<br/>" +
                        "Sunrise: " + sunrise + "<br/>" +
                        "Sunset: " + sunset +
                        "</font>"

                        interactive: true

                        anchors.fill: parent
                    }
                    MouseArea {
                        id: mouseArea
                        anchors.fill:parent


                        onEntered: {
                            forecastListView.currentIndex = index
                                itemEl = index
                                parent.state = "expanded"
                        }

                        hoverEnabled: true
                    }

                }
                PlasmaComponents.Label {
                    Layout.alignment: Qt.AlignVCenter | Qt.AlignHCenter
                    text: Utils.currentTempUnit(high)
                }
                PlasmaComponents.Label {
                    Layout.alignment: Qt.AlignVCenter | Qt.AlignHCenter
                    text: Utils.currentTempUnit(low)
                }


            }




        }
    }


    GridLayout {
        id: factsView
        columns: 6
        rows: 3

        flow: GridLayout.TopToBottom
        Layout.preferredHeight: 200
        Layout.preferredWidth: viewPortWidth


        Layout.columnSpan: 8
        Layout.alignment: Qt.AlignVCenter | Qt.AlignHCenter

        opacity: 1



        PlasmaComponents.Label {
            id: narrativeLabel
            Layout.columnSpan: 6
            Layout.rowSpan: 1
            Layout.preferredWidth: viewPortWidth - 50
            Layout.preferredHeight: 40

            Layout.alignment: Qt.AlignVCenter | Qt.AlignHCenter

            text: "Day: " + forecastModel.get(itemEl).fullForecast["day"].narrative +
            " Night: " +  forecastModel.get(itemEl).fullForecast["night"].narrative
            //text: "test description test"
            font {
                //weight: Font.Bold
                italic: true
                pointSize: plasmoid.configuration.propPointSize - 1
            }
            wrapMode: Text.WordWrap

            horizontalAlignment: Text.AlignHCenter
        }


        GridLayout {
            id: sunMoonSetRiseGrid
            columns: 2
            rows: 3

            Layout.rowSpan: 2
            Layout.columnSpan: 2
            Layout.alignment: Qt.AlignVCenter | Qt.AlignHCenter


            flow: GridLayout.TopToBottom
            Layout.preferredWidth: viewPortWidth / 6 * 2

            RowLayout{
                id: moonRow

                Layout.preferredWidth: viewPortWidth / 6 * 2

                Layout.columnSpan: 2
                Layout.alignment: Qt.AlignVCenter | Qt.AlignHCenter

                PlasmaCore.SvgItem {
                    id: moonIcon
                    //Layout.alignment: Qt.AlignVCenter | Qt.AlignHCenter
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
                    //horizontalAlignment: Text.AlignHCenter
                    text: forecastModel.get(itemEl).fullForecast.lunar_phase
                    font {
                        pointSize: plasmoid.configuration.propPointSize - 1
                    }
                }

            }
            RowLayout {
                Layout.preferredWidth: viewPortWidth / 6

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
                    text: Api.extractTime(forecastModel.get(itemEl).fullForecast.sunrise, false)
                    font {
                        //weight: Font.Bold
                        pointSize: plasmoid.configuration.propPointSize
                    }
                }
            }
            RowLayout {
                Layout.preferredWidth: viewPortWidth / 6

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
                    text: Api.extractTime(forecastModel.get(itemEl).fullForecast.sunset, false)
                    font {
                        //weight: Font.Bold
                        pointSize: plasmoid.configuration.propPointSize
                    }
                }
            }
            RowLayout {
                Layout.preferredWidth: viewPortWidth / 6

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
                    text: Api.extractTime(forecastModel.get(itemEl).fullForecast.moonrise, false)
                    font {
                        //weight: Font.Bold
                        pointSize: plasmoid.configuration.propPointSize
                    }
                }
            }
            RowLayout {
                Layout.preferredWidth: viewPortWidth / 6

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
                    text: Api.extractTime(forecastModel.get(itemEl).fullForecast.moonset, false)
                    font {
                        //weight: Font.Bold
                        pointSize: plasmoid.configuration.propPointSize
                    }
                }
            }
        }

        GridLayout {
            id: detailsGrid
            columns: 4
            rows: 7

            Layout.rowSpan: 2
            Layout.columnSpan: 4
            Layout.alignment: Qt.AlignVCenter | Qt.AlignHCenter
            Layout.fillWidth: true

            columnSpacing: 5
            rowSpacing: 5

            Layout.preferredWidth: viewPortWidth / 6 * 4

            PlasmaComponents.Label {
                id: conditionHeaderLabel

                horizontalAlignment: Text.AlignRight

                Layout.preferredWidth: (viewPortWidth / 6 * 2) - 2 * units.iconSizes.smallMedium

                text: "Condition"
                font {
                    weight: Font.Bold
                    pointSize: plasmoid.configuration.propPointSize - 1
                }
            }
            PlasmaComponents.Label {
                id: dayHeaderLabel

                horizontalAlignment: Text.AlignHCenter

                Layout.preferredWidth: viewPortWidth / 6

                text: "Day"
                font {
                    weight: Font.Bold
                    pointSize: plasmoid.configuration.propPointSize - 1
                }
            }
            PlasmaComponents.Label {
                id: iconHeaderLabel

                horizontalAlignment: Text.AlignHCenter

                Layout.preferredWidth: units.iconSizes.smallMedium

                text: "."
                font {
                    weight: Font.Bold
                    pointSize: plasmoid.configuration.propPointSize - 1
                }
            }
            PlasmaComponents.Label {
                id: nightHeaderLabel

                horizontalAlignment: Text.AlignHCenter

                Layout.preferredWidth: viewPortWidth / 6

                text: "Night"
                font {
                    weight: Font.Bold
                    pointSize: plasmoid.configuration.propPointSize - 1
                }
            }
            // Temperature

            PlasmaComponents.Label {
                id: temperatureLabel
                Layout.preferredWidth: (viewPortWidth / 6 * 2) - 2 * units.iconSizes.smallMedium
                horizontalAlignment: Text.AlignRight
                //text: i18nc("Ultra Violet", "UV")
                text: "Temperature"
                font {
                    pointSize: plasmoid.configuration.propPointSize - 1
                }
            }
            PlasmaComponents.Label {
                id: temperatureDayValue
                horizontalAlignment: Text.AlignHCenter
                Layout.preferredWidth: viewPortWidth / 6

                text: Utils.currentTempUnit(forecastModel.get(itemEl).fullForecast["day"].temp)
                font {
                    weight: Font.Bold
                    pointSize: detailsValueSize
                }
            }
            PlasmaCore.SvgItem {
                id: temperatureIcon
                //Layout.alignment: Qt.AlignVCenter | Qt.AlignHCenter
                svg: PlasmaCore.Svg {
                    id: temperatureSvg
                    imagePath: plasmoid.file("", "icons/fullRepresentation/wi-thermometer.svg")
                }

                Layout.minimumWidth: units.iconSizes.smallMedium
                Layout.minimumHeight: units.iconSizes.smallMedium
                Layout.preferredWidth: Layout.minimumWidth
                Layout.preferredHeight: Layout.minimumHeight
            }
            PlasmaComponents.Label {
                id: temperatureNightValue
                horizontalAlignment: Text.AlignHCenter
                Layout.preferredWidth: viewPortWidth / 6

                text: Utils.currentTempUnit(forecastModel.get(itemEl).fullForecast["night"].temp)
                font {
                    weight: Font.Bold
                    pointSize: detailsValueSize
                }
            }
            // Temperature END

            // Humidity


            PlasmaComponents.Label {
                id: humidityLabel
                Layout.preferredWidth: (viewPortWidth / 6 * 2) - 2 * units.iconSizes.smallMedium
                horizontalAlignment: Text.AlignRight
                //text: i18nc("Ultra Violet", "UV")
                text: "Humidity"
                font {
                    pointSize: plasmoid.configuration.propPointSize - 1
                }
            }


            PlasmaComponents.Label {
                id: humidityDayValue
                horizontalAlignment: Text.AlignHCenter
                Layout.preferredWidth: viewPortWidth / 6
                text: forecastModel.get(itemEl).fullForecast["day"].rh + "%"
                font {
                    weight: Font.Bold
                    pointSize: detailsValueSize
                }
            }
            PlasmaCore.SvgItem {
                id: humidityIcon
                Layout.alignment: Qt.AlignVCenter | Qt.AlignRight
                svg: PlasmaCore.Svg {
                    id: humiditySvg
                    imagePath: plasmoid.file("", "icons/fullRepresentation/wi-humidity.svg")
                }

                Layout.minimumWidth: units.iconSizes.smallMedium
                Layout.minimumHeight: units.iconSizes.smallMedium
                Layout.preferredWidth: Layout.minimumWidth
                Layout.preferredHeight: Layout.minimumHeight
            }
            PlasmaComponents.Label {
                id: humidityNightValue
                horizontalAlignment: Text.AlignHCenter
                Layout.preferredWidth: viewPortWidth / 6
                text: forecastModel.get(itemEl).fullForecast["night"].rh + "%"
                font {
                    weight: Font.Bold
                    pointSize: detailsValueSize
                }
            }
            // Humidity END

            // Precipitation Chance


            PlasmaComponents.Label {
                id: precipitationChanceLabel
                Layout.preferredWidth: (viewPortWidth / 6 * 2) - 2 * units.iconSizes.smallMedium
                horizontalAlignment: Text.AlignRight
                //Layout.alignment: Qt.AlignVCenter | Qt.AlignRight
                //text: i18nc("Ultra Violet", "UV")
                text: "Precipitation Chance"
                font {
                    pointSize: plasmoid.configuration.propPointSize - 1
                }
            }
            PlasmaComponents.Label {
                id: precipitationChanceDayValue
                horizontalAlignment: Text.AlignHCenter
                Layout.preferredWidth: viewPortWidth / 6
                text: forecastModel.get(itemEl).fullForecast["day"].pop + "%"
                font {
                    weight: Font.Bold
                    pointSize: detailsValueSize
                }
            }
            PlasmaCore.SvgItem {
                id: precipitationChanceIcon
                //Layout.alignment: Qt.AlignVCenter | Qt.AlignHCenter
                svg: PlasmaCore.Svg {
                    id: precipitationChanceSvg
                    imagePath: plasmoid.file("", "icons/fullRepresentation/wi-umbrella.svg")
                }

                Layout.minimumWidth: units.iconSizes.smallMedium
                Layout.minimumHeight: units.iconSizes.smallMedium
                Layout.preferredWidth: Layout.minimumWidth
                Layout.preferredHeight: Layout.minimumHeight
            }
            PlasmaComponents.Label {
                id: precipitationChanceNightValue
                horizontalAlignment: Text.AlignHCenter
                Layout.preferredWidth: viewPortWidth / 6
                text: forecastModel.get(itemEl).fullForecast["night"].pop + "%"
                font {
                    weight: Font.Bold
                    pointSize: detailsValueSize
                }
            }
            // Precipitation Chance END

            // Precipitation Quantity

            PlasmaComponents.Label {
                id: precipitationQuantityLabel
                Layout.preferredWidth: (viewPortWidth / 6 * 2) - 2 * units.iconSizes.smallMedium
                horizontalAlignment: Text.AlignRight
                text: "Precipitation Quantity"
                font {
                    pointSize: plasmoid.configuration.propPointSize - 1
                }
            }
            PlasmaComponents.Label {
                id: precipitationQuantityDayValue
                horizontalAlignment: Text.AlignHCenter
                Layout.preferredWidth: viewPortWidth / 6
                text: Utils.currentPrecipUnit(forecastModel.get(itemEl).fullForecast["day"].qpf, true) + "/hr"
                font {
                    weight: Font.Bold
                    pointSize: detailsValueSize
                }
            }
            PlasmaCore.SvgItem {
                id: precipitationQuantityIcon
                //horizontalAlignment: Text.AlignHCenter
                svg: PlasmaCore.Svg {
                    id: precipitationQuantitySvg
                    imagePath: plasmoid.file("", "icons/fullRepresentation/wi-rain.svg")
                }

                Layout.minimumWidth: units.iconSizes.smallMedium
                Layout.minimumHeight: units.iconSizes.smallMedium
                Layout.preferredWidth: Layout.minimumWidth
                Layout.preferredHeight: Layout.minimumHeight
            }
            PlasmaComponents.Label {
                id: precipitationQuantityNightValue
                horizontalAlignment: Text.AlignHCenter
                Layout.preferredWidth: viewPortWidth / 6
                text: Utils.currentPrecipUnit(forecastModel.get(itemEl).fullForecast["night"].qpf, true) + "/hr"
                font {
                    weight: Font.Bold
                    pointSize: detailsValueSize
                }
            }
            // Precipitation Quantity END

            // Snow Quantity

            PlasmaComponents.Label {
                id: snowQuantityLabel
                Layout.preferredWidth: (viewPortWidth / 6 * 2) - 2 * units.iconSizes.smallMedium
                horizontalAlignment: Text.AlignRight
                text: "Snow Quantity"
                font {
                    pointSize: plasmoid.configuration.propPointSize - 1
                }
            }
            PlasmaComponents.Label {
                id: snowQuantityDayValue
                horizontalAlignment: Text.AlignHCenter
                Layout.preferredWidth: viewPortWidth / 6
                text: Utils.currentPrecipUnit(forecastModel.get(itemEl).fullForecast["day"].snow_qpf, false) + "/hr"
                font {
                    weight: Font.Bold
                    pointSize: detailsValueSize
                }
            }
            PlasmaCore.SvgItem {
                id: snowQuantityIcon
                //horizontalAlignment: Text.AlignHCenter
                svg: PlasmaCore.Svg {
                    id: snowQuantitySvg
                    imagePath: plasmoid.file("", "icons/fullRepresentation/wi-snow.svg")
                }

                Layout.minimumWidth: units.iconSizes.smallMedium
                Layout.minimumHeight: units.iconSizes.smallMedium
                Layout.preferredWidth: Layout.minimumWidth
                Layout.preferredHeight: Layout.minimumHeight
            }
            PlasmaComponents.Label {
                id: snowQuantityNightValue
                horizontalAlignment: Text.AlignHCenter
                Layout.preferredWidth: viewPortWidth / 6
                text: Utils.currentPrecipUnit(forecastModel.get(itemEl).fullForecast["night"].snow_qpf, false) + "/hr"
                font {
                    weight: Font.Bold
                    pointSize: detailsValueSize
                }
            }
            // Snow Quantity END
            // Wind Speed and Direction

            PlasmaComponents.Label {
                id: windSpdDirLabel
                Layout.preferredWidth: (viewPortWidth / 6 * 2) - 2 * units.iconSizes.smallMedium
                horizontalAlignment: Text.AlignRight
                text: "Wind Speed/Direction"
                font {
                    pointSize: plasmoid.configuration.propPointSize - 1
                }
            }
            PlasmaComponents.Label {
                id: windSpdDirDayValue
                horizontalAlignment: Text.AlignHCenter
                Layout.preferredWidth: viewPortWidth / 6
                text: Utils.currentSpeedUnit(forecastModel.get(itemEl).fullForecast["day"].wspd) +
                " " +
                Utils.windDirToCard(forecastModel.get(itemEl).fullForecast["day"].wdir)
                font {
                    weight: Font.Bold
                    pointSize: detailsValueSize
                }
            }
            PlasmaCore.SvgItem {
                id: windSpdDirIcon
                //Layout.alignment: Qt.AlignVCenter | Qt.AlignHCenter
                svg: PlasmaCore.Svg {
                    id: windSpdDirSvg
                    imagePath: plasmoid.file("", "icons/fullRepresentation/wi-strong-wind.svg")
                }

                Layout.minimumWidth: units.iconSizes.smallMedium
                Layout.minimumHeight: units.iconSizes.smallMedium
                Layout.preferredWidth: Layout.minimumWidth
                Layout.preferredHeight: Layout.minimumHeight
            }
            PlasmaComponents.Label {
                id: windSpdDirNightValue
                horizontalAlignment: Text.AlignHCenter
                Layout.preferredWidth: viewPortWidth / 6
                text: Utils.currentSpeedUnit(forecastModel.get(itemEl).fullForecast["night"].wspd) +
                " " + Utils.windDirToCard(forecastModel.get(itemEl).fullForecast["night"].wdir)
                font {
                    weight: Font.Bold
                    pointSize: detailsValueSize
                }
            }
            // Wind Speed and Direction END

            //PlasmaComponents.Label {
            //id: moonRiseData
            //horizontalAlignment: Text.AlignHCenter
            //text: forecastModel.get(itemEl).fullForecast["lunar_phase"]
            //font {
            //weight: Font.Bold
            //pointSize: plasmoid.configuration.propPointSize
            //}
            //}


            //Rectangle {
            ////width: detailsViewWidth
            ////height: detailsViewHeight
            ////anchors.fill: parent

            //gradient: Gradient {
            //GradientStop { position: 0.0; color: "#fed958" }
            //GradientStop { position: 1.0; color: "#fecc2f" }
            //}
            //border.color: '#000000'
            //border.width: 2

            //Text {
            //anchors.fill: parent
            //anchors.margins: 5

            //clip: true
            //wrapMode: Text.WordWrap
            //color: '#1f1f21'

            //font.pixelSize: 12

            //text: "blaa"
            //}
            //}
        }

    }
}





