/*
 * Copyright 2020  Kevin Donnelly
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
import org.kde.plasma.plasmoid 2.0
import org.kde.plasma.core 2.0 as PlasmaCore

Item {
    property ShowConfigBtn btn : ShowConfigBtn {}

    PlasmaCore.IconItem {
        source: "weather"

        anchors.fill: parent

        MouseArea {
            anchors.fill: parent
            onClicked: {
                plasmoid.expanded = !plasmoid.expanded
            }
        }


        PlasmaCore.ToolTipArea {
            anchors.fill: parent
            icon: "weather"
            interactive: true
            mainText: showData ? stationID : null
            subText: showData ? tooltipSubText : "Please Configure"
            mainItem: showData ? null : btn
        }
    }
}
