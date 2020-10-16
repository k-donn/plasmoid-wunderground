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
    property ConfigBtn confBtn : ConfigBtn {}

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        onClicked: {
            plasmoid.expanded = !plasmoid.expanded
        }
    }

    // I have modified the icons so that the id hint-apply-color-scheme is on the SVGs
    // KDE docs: https://techbase.kde.org/Development/Tutorials/Plasma5/ThemeDetails#Using_system_colors
    AppletIcon {
        id: icon

        source: "sun"

        anchors.fill: parent

        active: mouseArea.containsMouse
    }

    PlasmaCore.ToolTipArea {
        id: toolTip
        anchors.fill: parent
        interactive: true
        // Reafctor into a component like FullRep that has sub-components for each state
        mainText: appState == showDATA ? stationID : appState == showERROR ? errorStr : appState == showLOADING ? "Loading..." : null
        subText: appState == showDATA ? tooltipSubText : appState == showERROR ? "Error" : null
        mainItem: appState == showCONFIG ? confBtn : null
    }
}
