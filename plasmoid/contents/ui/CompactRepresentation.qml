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
import "../code/utils.js" as Utils

Item {
    property CenteredConfigBtn confBtn : CenteredConfigBtn {}
    property var localWeatherData: weatherData

    property bool inTray: (plasmoid.parent !== null && (plasmoid.parent.pluginName === 'org.kde.plasma.private.systemtray' || plasmoid.parent.objectName === 'taskItemContainer'))

    function printDebug(msg) {
        console.log("[debug] " + msg)
    }

    onLocalWeatherDataChanged: {
        Utils.getStatusIcon()
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
        // Reafctor into a component like FullRep that has sub-components for each state
        mainText: appState == showDATA ? stationID : appState == showERROR ? errorStr : appState == showLOADING ? "Loading..." : null
        subText: appState == showDATA ? tooltipSubText : appState == showERROR ? "Error" : null
        mainItem: appState == showCONFIG ? confBtn : null
    }

    Item {
        anchors.fill: parent

        AppletIcon {
            id: dyanmicIcon

            anchors.fill: parent

            source: "sun"

            active: mouseArea.containsMouse

            visible: !inTray
        }

        AppletIcon {
            id: trayIcon

            anchors.fill: parent

            source: "sun"

            active: mouseArea.containsMouse

            visible: inTray
        }
    }


}
