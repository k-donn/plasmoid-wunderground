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
import QtQuick.Controls
import QtQuick.Layouts
import org.kde.kcmutils as KCM
import org.kde.plasma.components as PlasmaComponents
import org.kde.kirigami as Kirigami

RowLayout {
    property var stationList: []

    property alias selectedStation: stationPickerDialog.source

    property var stationPicker: StationPickerDialog {
        id: stationPickerDialog

        onAccepted: {
            stationList = [];
            for (let i = 0; i < stationListModel.count; i++) {
                stationList.push(stationListModel.get(i).name);
            }
        }
    }

    PlasmaComponents.Label {
        id: stationDisplay

        Layout.fillWidth: true

        text: selectedStation
    }

    Button {
        id: selectBtn
        Layout.fillWidth: true
        icon.name: "find-location"
        text: i18ndc("plasma_applet_org.kde.plasma.weather", "@action:button", "Choose…")
        onClicked: stationPicker.visible = true
    }
}