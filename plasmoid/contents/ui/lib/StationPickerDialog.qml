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

    property int initialIndex: -1

    // This is aliased back to the plasmoid conf stationID variable
    // So it cannot be directly aliased to the ListModel's currentItem 
    // because if the widget loads with an initial value,
    // that would not reflect in the ListModel
    property string source: ""

    property ListModel stationListModel: ListModel {}

    SystemPalette {
        id: syspal
    }

    StationSearcher {
        id: stationSearcher

        onChoosen: {
            // User searched for a new station. Add and make new selection
            stationListModel.append({"name": newStation});
            for (let i = 0; i < stationListModel.count; i++) {
                if (stationListModel.get(i).name === newStation) {
                    stationListView.currentIndex = i;
                }
            }
            dialog.source = newStation;
        }
    }

    signal accepted

    Action {
        id: acceptAction

        shortcut: "Return"
        enabled: initialIndex != stationListView.currentIndex
        onTriggered: {
            accepted();
            dialog.close();
        }
    }

    Action {
        id: cancelAction

        shortcut: "Escape"
        onTriggered: {
            dialog.close();
        }
    }

    Component.onCompleted: {
        // Populate ListModel with saved stations
        for (let i = 0; i < plasmoid.configuration.savedStations.length; i++) {
            stationListModel.append({"name": plasmoid.configuration.savedStations[i]});
        }

        // Set selected station to force highlight
        for (let i = 0; i < stationListModel.count; i++) {
            if (stationListModel.get(i).name === source) {
                stationListView.currentIndex = i;
            }
        }
        stationListView.forceActiveFocus();

        initialIndex = stationListView.currentIndex
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
                        dialog.source = name

                        stationListView.forceActiveFocus();
                        stationListView.currentIndex = index;
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
                enabled: initialIndex != stationListView.currentIndex
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