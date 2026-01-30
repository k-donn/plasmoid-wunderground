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
import QtQuick.Layouts
import org.kde.kirigami as Kirigami
import org.kde.plasma.components as PlasmaComponents
import org.kde.plasma.plasmoid
import "../code/utils.js" as Utils

Component {
    id: chartMetricsSelectionDelegate

    Column {
        PlasmaComponents.Label {
            id: iconHolder

            Layout.minimumWidth: Kirigami.Units.gridUnit * 1.3
            Layout.minimumHeight: Kirigami.Units.gridUnit * 1.3
            width: Layout.minimumWidth
            height: Layout.minimumHeight

            font.family: "weather-icons"
            font.pixelSize: Layout.minimumHeight
            text: Utils.getConditionIcon(availableReadings[index])
            color: Kirigami.Theme.textColor
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter

            MouseArea {
                anchors.fill: parent
                hoverEnabled: true
                onEntered: {
                    iconsListView.currentIndex = index;
                }
                onPressed: {
                    currentLegendText = availableReadings[index];
                }
            }
        }
    }
}
