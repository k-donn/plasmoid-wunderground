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
import QtQuick.Controls
import org.kde.plasma.plasmoid
import org.kde.ksvg as KSvg
import org.kde.kirigami as Kirigami
import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.components as PlasmaComponents
import "../code/utils.js" as Utils

ColumnLayout {
    id: moreInfoRoot

    PlasmaComponents.Label {
        id: aqLabel

        font {
            bold: true
            pointSize: 15
        }

        text: i18n("Air quality")
    }

    GridLayout {
        id: aqGrid

        columns: 2
        rows: 3

        Layout.alignment: Qt.AlignTop | Qt.AlignHCenter

        PlasmaComponents.Label {
            id: aqDesc

            Layout.alignment: Qt.AlignHCenter
            Layout.columnSpan: 2

            text: weatherData["aq"]["aqDesc"]
        }
        PlasmaComponents.Label {
            id: aqIndex

            Layout.alignment: Qt.AlignHCenter

            text: i18n("AQI: %1", weatherData["aq"]["aqi"])
        }
        PlasmaComponents.Label {
            id: aqhi
            Layout.alignment: Qt.AlignHCenter

            text: i18n("AQHI: %1", weatherData["aq"]["aqhi"])
        }
        PlasmaComponents.Label {
            id: aqIndexColor
            Layout.alignment: Qt.AlignHCenter

            color: "#" + weatherData["aq"]["aqColor"]

            text: i18n("Status Color")
        }
        PlasmaComponents.Label {
            id: aqPrimary
            Layout.alignment: Qt.AlignHCenter

            text: i18n("Primary pollutant: %1", weatherData["aq"]["aqPrimary"])
        }
    }
    PlasmaComponents.Label {
        id: alertsLabel

        font {
            bold: true
            pointSize: 15
        }

        text: i18n("Alerts")
    }

    AlertsItem {
        id: alertsItem
    }
}
