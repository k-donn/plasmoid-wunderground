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

    title: i18ndc("plasma_applet_org.kde.plasma.weather", "@title:window", "Select Weather Station")
    color: syspal.window

    property string source: stationListModel.get(stationListView.currentIndex).name

    SystemPalette {
        id: syspal
    }

    StationSearcher {
        id: stationSearcher
    }

    signal accepted

    Action {
        id: acceptAction

        shortcut: "Return"
        enabled: !!source
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
            icon.name: "find-location"
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

            model: ListModel {
                id: stationListModel
                ListElement { name: "KGADACUL1" }
                ListElement { name: "KGADACUL2" }
                ListElement { name: "KGADACUL3" }
            }

            delegate: ItemDelegate {
                width: ListView.view.width
                text: name

                onClicked: {
                    stationListView.forceActiveFocus();
                    stationListView.currentIndex = index;
                }
            }
        }

        RowLayout {
            id: buttonsRow

            Layout.alignment: Qt.AlignVCenter | Qt.AlignRight

            Button {
                icon.name: "dialog-ok"
                text: i18ndc("plasma_applet_org.kde.plasma.weather", "@action:button", "Select")
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