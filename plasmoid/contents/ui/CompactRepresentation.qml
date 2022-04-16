/*
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

import QtQuick 2.9
import QtQuick.Layouts 1.3
import org.kde.plasma.plasmoid 2.0
import org.kde.plasma.core 2.0 as PlasmaCore
import "../code/utils.js" as Utils

Item {
    id: compactRoot

    Layout.fillHeight: !vertical
    Layout.fillWidth: vertical
    Layout.minimumWidth: compactRepresentation.width
    Layout.maximumWidth: Layout.minimumWidth

    readonly property bool vertical: (plasmoid.formFactor == PlasmaCore.Types.Vertical)

    function printDebug(msg) {
        if (plasmoid.configuration.logConsole) {console.log("[debug] [CompactRep.qml] " + msg)}
    }

    Item {
        id: compactRepresentation
        anchors.centerIn: parent
        width: !vertical ? compactRepresentationLoader.width + units.smallSpacing : parent.width
        height: !vertical ? parent.height : compactRepresentationLoader.height + units.smallSpacing

        Loader {
            id: compactRepresentationLoader
            anchors.centerIn: parent
            property bool vertical: compactRoot.vertical
    
            source: (compactRoot.vertical) ? "VerticalCompactLayout.qml" : "HorizontalCompactLayout.qml"

            MouseArea {
                id: compactMouseArea
                anchors.fill: parent

                hoverEnabled: true

                onClicked: {
                    plasmoid.expanded = !plasmoid.expanded;
                }
            }
        }
    }
}
