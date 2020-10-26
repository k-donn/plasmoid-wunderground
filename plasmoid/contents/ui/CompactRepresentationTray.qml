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
import QtQuick.Layouts 1.0
import org.kde.plasma.plasmoid 2.0
import org.kde.plasma.core 2.0 as PlasmaCore
import "../code/utils.js" as Utils

Item {
    property CenteredConfigBtn confBtn : CenteredConfigBtn {}

    function printDebug(msg) {
        console.log("[debug] " + msg)
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        onClicked: {
            plasmoid.expanded = !plasmoid.expanded
        }
    }

    PlasmaCore.ToolTipArea {
        id: toolTip
        interactive: true
        anchors.fill: parent
        // Refactor into a component like FullRep that has sub-components for each state
        mainText: appState == showDATA ? stationID : appState == showERROR ? errorStr : appState == showLOADING ? "Loading..." : null
        subText: appState == showDATA ? tooltipSubText : appState == showERROR ? "Error" : null
        mainItem: appState == showCONFIG ? confBtn : null
    }

    AppletIcon {
        id: trayIcon
        anchors.fill: parent
        source: iconCode
        active: mouseArea.containsMouse
    }
}