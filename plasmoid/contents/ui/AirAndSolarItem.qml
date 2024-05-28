/*
 * Copyright 2024  Kevin Donnelly
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
import org.kde.plasma.components as PlasmaComponents

RowLayout {

    GridLayout {
        id: aqGrid

        columns: 2
        rows: 4

        Layout.fillWidth: true

        PlasmaComponents.Label {
            id: aqLabel

            Layout.columnSpan: 2
            Layout.fillWidth: true

            horizontalAlignment: Text.AlignHCenter

            font {
                bold: true
                pointSize: 15
            }

            text: i18n("Air quality")
        }
        PlasmaComponents.Label {
            id: aqDesc

            Layout.columnSpan: 2
            Layout.fillWidth: true

            horizontalAlignment: Text.AlignHCenter

            text: weatherData["aq"]["aqDesc"]
        }
        PlasmaComponents.Label {
            id: aqIndex

            Layout.fillWidth: true

            horizontalAlignment: Text.AlignHCenter

            text: i18n("AQI: %1", weatherData["aq"]["aqi"])
        }
        PlasmaComponents.Label {
            id: aqhi
            Layout.fillWidth: true

            horizontalAlignment: Text.AlignHCenter

            text: i18n("AQHI: %1", weatherData["aq"]["aqhi"])
        }
        PlasmaComponents.Label {
            id: aqIndexColor
            Layout.fillWidth: true

            horizontalAlignment: Text.AlignHCenter

            color: "#" + weatherData["aq"]["aqColor"]

            text: i18n("Status Color")
        }
        PlasmaComponents.Label {
            id: aqPrimary
            Layout.fillWidth: true

            horizontalAlignment: Text.AlignHCenter

            text: i18n("Primary pollutant: %1", weatherData["aq"]["aqPrimary"])
        }
    }

    GridLayout {
        id: solGrid

        columns: 2
        rows: 4

        Layout.fillWidth: true

        PlasmaComponents.Label {
            id: solLabel

            Layout.columnSpan: 2
            Layout.alignment: Qt.AlignHCenter
            Layout.fillWidth: true

            horizontalAlignment: Text.AlignHCenter

            font {
                bold: true
                pointSize: 15
            }

            text: i18n("Solar info")
        }
        PlasmaComponents.Label {
            id: solRad

            Layout.columnSpan: 2
            Layout.fillWidth: true

            horizontalAlignment: Text.AlignHCenter

            text: weatherData["solarRad"] + " W/m<sup>2</sup>"
        }
        PlasmaComponents.Label {
            id: sunriseLabel

            Layout.fillWidth: true

            horizontalAlignment: Text.AlignHCenter

            text: i18n("Sunrise")
        }
        PlasmaComponents.Label {
            id: sunsetLabel
            Layout.fillWidth: true

            horizontalAlignment: Text.AlignHCenter

            text: i18n("Sunset")
        }
        PlasmaComponents.Label {
            id: sunrise
            Layout.fillWidth: true

            horizontalAlignment: Text.AlignHCenter

            text: Qt.formatDateTime(weatherData["sunrise"], "hh:mm a")
        }
        PlasmaComponents.Label {
            id: sunset
            Layout.fillWidth: true

            horizontalAlignment: Text.AlignHCenter

            text: Qt.formatDateTime(weatherData["sunset"], "hh:mm a")
        }
    }
}
