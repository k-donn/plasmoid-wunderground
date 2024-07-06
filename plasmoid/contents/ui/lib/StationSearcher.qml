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
import org.kde.plasma.components as PlasmaComponents
import org.kde.kirigami as Kirigami
import "../../code/pws-api.js" as StationAPI

Window {
    id: searchDialog

    LayoutMirroring.enabled: Qt.application.layoutDirection === Qt.RightToLeft
    LayoutMirroring.childrenInherit: true

    flags: Qt.Dialog
    modality: Qt.WindowModal

    width: Kirigami.Units.gridUnit * 30
    height: Kirigami.Units.gridUnit * 20

    title: i18n("Find Station")
    color: syspal.window

    SystemPalette {
        id: syspal
    }

    signal choosen

    Action {
        id: choosenAction

        shortcut: "Return"
        enabled: canChoose
        onTriggered: {
            choosen();
            searchDialog.close();
        }
    }

    Action {
        id: cancelAction

        shortcut: "Escape"
        onTriggered: {
            dialog.close();
        }
    }

    property bool canChoose: false

    property string newStation: ""

    function printDebug(msg) {
        if (plasmoid.configuration.logConsole) {
            console.log("[debug] [StationSearcher.qml] " + msg);
        }
    }

    function validateWeatherStation(typedID, statusField, callback) {
        StationAPI.isStationActive(typedID, function(isActive) {
            if (isActive) {
                statusField.placeholderText = i18n("Station %1 is active and can be used", typedID)
                statusField.placeholderTextColor = "green";
                callback(isActive);
            } else {
                statusField.placeholderText = i18n("Station %1 is NOT active. Please select a different station.", typedID)
                statusField.placeholderTextColor = "red";
                callback(isActive);
            }
        });
    }

    ColumnLayout {
        anchors {
            fill: parent
            centerIn: parent
        }

        Kirigami.FormLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true

            Kirigami.Separator {
                Kirigami.FormData.isSection: true
                Kirigami.FormData.label: i18n("Enter Station")
            }

            ClearableField {
                id: manualField
                placeholderText: "KGADACUL1"

                Kirigami.FormData.label: i18n("Weatherstation ID:")
            }

            Button {
                text: i18n("Test Station")

                onClicked: {
                    var stationQuery = manualField.text.trim();
                    validateWeatherStation(stationQuery, manualStationStatus, function(isActive) {
                        printDebug("Station active: " + isActive);
                        newStation = stationQuery;
                        canChoose = true;
                    });
                }
            }

            TextField {
                id: manualStationStatus
                enabled: false

                horizontalAlignment: Text.AlignHCenter
                placeholderText: i18n("Pending selection")

                Kirigami.FormData.label: i18n("Station status:")
            }

            Kirigami.Separator {
                Kirigami.FormData.isSection: true
                Kirigami.FormData.label: i18n("Get Nearest Station")
            }

            ClearableField {
                id: cityLookup
                placeholderText: i18nc("plaseholder text, example London", "e.g. London")

                Kirigami.FormData.label: i18n("Look for location:")
            }

            Button {
                text: i18n("Find Station")
            }
        }

        RowLayout {
            id: buttonsRow

            Layout.alignment: Qt.AlignVCenter | Qt.AlignRight

            Button {
                icon.name: "dialog-ok"
                text: i18ndc("plasma_applet_org.kde.plasma.weather", "@action:button", "Select")
                enabled: canChoose
                onClicked: {
                    choosenAction.trigger();
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