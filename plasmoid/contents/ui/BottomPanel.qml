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
import org.kde.plasma.components 2.0 as PlasmaComponents
import "../code/utils.js" as Utils

RowLayout {
    id: bottomPanelRoot

    PlasmaComponents.Label {
        id: bottomPanelTime

        text: weatherData["obsTimeLocal"] + " (" + plasmoid.configuration.refreshPeriod + "s)"

        verticalAlignment: Text.AlignBottom

        Layout.fillWidth: true
    }

    PlasmaComponents.Label {
        id: bottomPanelStation

        Layout.fillWidth: true

        text: weatherData["stationID"] + "   " + Utils.currentElevUnit(weatherData["details"]["elev"])

        verticalAlignment: Text.AlignBottom
        horizontalAlignment: Text.AlignRight
    }
}