/*
 * Copyright 2024  Kevin Donnelly
 * Copyright 2022  Chris Holland
 * Copyright 2016, 2018 Friedrich W. H. Kossebau
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

Window {
    id: dialog

    LayoutMirroring.enabled: Qt.application.layoutDirection === Qt.RightToLeft
    LayoutMirroring.childrenInherit: true

    flags: Qt.Dialog
    modality: Qt.WindowModal

    width: Kirigami.Units.gridUnit * 25
    height: Kirigami.Units.gridUnit * 20

    title: i18n("Saved Weather Stations")
    color: syspal.window

    property string source: ""

    property bool fixedErrorState: false

    property ListModel stationListModel: ListModel {}

    function printDebug(msg) {
        if (plasmoid.configuration.logConsole) {
            console.log("[debug] [StationPickerDialog.qml] " + msg);
        }
    }

    SystemPalette {
        id: syspal
    }

    StationSearcher {
        id: stationSearcher

        onChoosen: {
            // User searched for a new station. Check for duplicate, add, and make it the current selection.
            var isDuplicate = false;

            for (let i = 0; i < stationListModel.count; i++) {
                if (stationListModel.get(i).name === newStation) {
                    isDuplicate = true;
                }
            }

            if (!isDuplicate) {
                stationListModel.append({"name": newStation});
            }

            // The duplicate was not added twice, but make still make it the current selection.
            for (let i = 0; i < stationListModel.count; i++) {
                if (stationListModel.get(i).name === newStation) {
                    stationListView.currentIndex = i;
                }
            }
            dialog.source = newStation;
        }
    }

    signal accepted

    signal cancel

    Action {
        id: acceptAction

        shortcut: "Return"
        enabled: stationListModel.count > 0
        onTriggered: {
            accepted();
            dialog.close();
        }
    }

    Action {
        id: cancelAction

        shortcut: "Escape"
        onTriggered: {
            cancel();
            dialog.close();
        }
    }

    Component.onCompleted: {
        if (plasmoid.configuration.stationID !== "") {
            // Transition state where user has stationID set but no savedStations
            if (plasmoid.configuration.savedStations.length === 0) {
                plasmoid.configuration.savedStations.push(plasmoid.configuration.stationID);
                fixedErrorState = true;
            }

            // Possible error state where stationID not in savedStations
            if (!plasmoid.configuration.savedStations.includes(plasmoid.configuration.stationID)) {
                plasmoid.configuration.savedStations.push(plasmoid.configuration.stationID);
                fixedErrorState = true;
            }
        } else {
            // Possible error state where savedStations set but no stationID
            if (plasmoid.configuration.savedStations.length !== 0) {
                // Make selected station first savedStation
                plasmoid.configuration.stationID = plasmoid.configuration.savedStations[0];
                fixedErrorState = true;
            }
        }

        // Populate ListModel with saved stations
        for (let i = 0; i < plasmoid.configuration.savedStations.length; i++) {
            stationListModel.append({"name": plasmoid.configuration.savedStations[i]});
        }

        // Set selected station to force highlight
        for (let i = 0; i < stationListModel.count; i++) {
            if (stationListModel.get(i).name === plasmoid.configuration.stationID) {
                dialog.source = plasmoid.configuration.stationID;

                stationListView.currentIndex = i;
            }
        }
        stationListView.forceActiveFocus();
    }

    ColumnLayout {
        id: mainColumn
        anchors {
            fill: parent
            margins: mainColumn.spacing * Screen.devicePixelRatio //margins are hardcoded in QStyle we should match that here
        }
        // TODO: not yet perfect
        Layout.minimumWidth: Math.max(stationPicker.Layout.minimumWidth, buttonsRow.implicitWidth) + 2*anchors.margins
        Layout.minimumHeight: stationPicker.Layout.minimumHeight + buttonsRow.implicitHeight + 2*anchors.margins

        Button {
            id: addMoreBtn
            Layout.fillWidth: true
            icon.name: "list-add"
            text: i18n("Add more...")
            onClicked: stationSearcher.visible = true 
        }

        ListView {
            id: stationListView

            Layout.fillWidth: true
            Layout.fillHeight: true

            clip: true
            focus: true
            activeFocusOnTab: true
            keyNavigationEnabled: true

            model: stationListModel

            delegate: ItemDelegate {
                width: ListView.view.width
                text: name

                highlighted: ListView.isCurrentItem

                onClicked: {
                    if (!ListView.isCurrentItem) {
                        dialog.source = name;

                        stationListView.currentIndex = index;
                        stationListView.forceActiveFocus();
                    }
                }
            }
        }

        RowLayout {
            id: buttonsRow

            Layout.alignment: Qt.AlignVCenter | Qt.AlignRight

            Button {
                icon.name: "dialog-ok"
                text: i18ndc("plasma_applet_org.kde.plasma.weather", "@action:button", "Select")
                enabled: stationListModel.count > 0
                onClicked: {
                    acceptAction.trigger();
                }
            }
            Button {
                icon.name: "dialog-cancel"
                text: i18ndc("plasma_applet_org.kde.plasma.weather", "@action:button", "Cancel")
                onClicked: {
                    cancelAction.trigger();
                }
            }
        }
    }
}