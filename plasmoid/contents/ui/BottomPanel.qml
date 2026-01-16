/*
 * Copyright 2025  Kevin Donnelly
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
import org.kde.kirigami as Kirigami
import org.kde.plasma.components as PlasmaComponents
import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.plasmoid
import "../code/utils.js" as Utils

RowLayout {
    id: bottomPanelRoot

    Layout.preferredHeight: Kirigami.Units.iconSizes.small

    PlasmaComponents.Label {
        id: bottomPanelTime

        text: weatherData["obsTimeLocal"] + " (" + plasmoid.configuration.refreshPeriod + "s)"

        horizontalAlignment: Text.AlignLeft

        Layout.fillWidth: true
        Layout.preferredWidth: 1
    }

    Item {
        id: centerContainer
        Layout.fillWidth: true
        Layout.preferredWidth: 1

        Row {
            id: centerRow
            anchors.centerIn: parent
            PlasmaComponents.Label {
                id: locationIcon

                color: Kirigami.Theme.textColor

                font.family: "weather-icons"
                font.pixelSize: Kirigami.Units.iconSizes.small
                text: Utils.getConditionIcon("pin") + " "
            }

            PlasmaComponents.Label {
                id: locationLabel

                text: weatherData["neighborhood"]

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor

                    hoverEnabled: true

                    onClicked: {
                        Qt.openUrlExternally("https://www.wunderground.com/dashboard/pws/" + weatherData["stationID"]);
                    }

                    onEntered: {
                        locationLabel.font.underline = true;
                    }

                    onExited: {
                        locationLabel.font.underline = false;
                    }
                }
            }
        }
    }

    Item {
        id: rightContainer
        Layout.fillWidth: true
        Layout.preferredWidth: 1

        Row {
            id: rightRow

            anchors.verticalCenter: parent.verticalCenter
            anchors.right: parent.right

            PlasmaComponents.Label {
                id: stationIcon

                color: Kirigami.Theme.textColor

                font.family: "weather-icons"
                font.pixelSize: Kirigami.Units.iconSizes.small

                text: Utils.getConditionIcon("weatherStation") + " "
            }

            PlasmaComponents.Label {
                id: bottomPanelStation

                text: weatherData["stationID"] + "   " + Utils.currentElevUnit(Utils.toUserElev(weatherData["details"]["elev"]))
            }

            Kirigami.Icon {
                source: "documentinfo-symbolic"
                visible: alertsModel.count > 0
                height: Kirigami.Units.iconSizes.smallMedium
                color: "#ff0000"

                PlasmaCore.ToolTipArea {
                    anchors.fill: parent
                    mainText: i18n("There are weather alerts for your area!")
                }
            }
        }
    }
}
