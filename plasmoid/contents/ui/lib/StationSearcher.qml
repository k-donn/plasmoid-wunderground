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
import org.kde.plasma.core as PlasmaCore
import org.kde.kirigami as Kirigami
import "../../code/pws-api.js" as StationAPI

Window {
    id: searchDialog

    LayoutMirroring.enabled: Qt.application.layoutDirection === Qt.RightToLeft
    LayoutMirroring.childrenInherit: true

    flags: Qt.Dialog
    modality: Qt.WindowModal

    width: Kirigami.Units.gridUnit * 40
    height: Kirigami.Units.gridUnit * 30

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

            resetForms();
        }
    }

    Action {
        id: cancelAction

        shortcut: "Escape"
        onTriggered: {
            searchDialog.close();

            resetForms();
        }
    }

    property bool canChoose: false

    property string newStation: ""

    property ListModel locationsModel: ListModel {}
    property ListModel stationsModel: ListModel {}

    function printDebug(msg) {
        if (plasmoid.configuration.logConsole) {
            console.log("[debug] [StationSearcher.qml] " + msg);
        }
    }

    function resetForms() {
        newStation = "";

        manualField.text = "";
        manualField.placeholderText = "KGADACUL1";

        manualStationStatus.placeholderText = i18n("---------------------Pending selection-----------------------");
        manualStationStatus.placeholderTextColor = PlasmaCore.Theme.disabledTextColor;

        stationComboxBox.currentIndex = -1;

        stationStatus.placeholderText = i18n("---------------------Pending selection-----------------------");
        stationStatus.placeholderTextColor = PlasmaCore.Theme.disabledTextColor;
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

    function onSelectLocation(currentIndex) {
        var currentObj = locationsModel.get(currentIndex)
        if(currentObj != null && currentObj["latitude"] != undefined) {
            StationAPI.getNearestStations({lat: currentObj["latitude"], long: currentObj["longitude"]});
        }
    }

    function onSelectStation(currentIndex) {
        var currentObj = stationsModel.get(currentIndex)
        if(currentObj != null && currentObj["stationId"] != undefined) {
            validateWeatherStation(currentObj["stationId"], stationStatus, function(isActive){
                newStation = currentObj["stationId"];
                canChoose = true;
            });
        }
    }

    ColumnLayout {
        id: mainColumn

        anchors {
            fill: parent
            centerIn: parent
            margins: mainColumn.spacing * Screen.devicePixelRatio //margins are hardcoded in QStyle we should match that here
        }

        ScrollView {
            Layout.fillHeight: true
            Layout.alignment: Qt.AlignCenter

            Kirigami.FormLayout {

                anchors {
                    fill: parent
                    centerIn: parent
                }

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
                    placeholderText: i18n("---------------------Pending selection-----------------------")

                    Kirigami.FormData.label: i18n("Station status:")
                }

                Kirigami.Separator {
                    Kirigami.FormData.isSection: true
                    Kirigami.FormData.label: i18n("Get Nearest Station")
                }

                ClearableField {
                    id: cityLookup
                    placeholderText: i18n("e.g. London")

                    Kirigami.FormData.label: i18n("Look for location:")
                }

                Button {
                    text: i18n("Find Station")
                    onClicked: {
                        StationAPI.getLocations(cityLookup.text.trim());
                    }
                }

                ComboBox {
                    id: locationComboBox
                    editable: false
                    enabled: locationsModel.count > 0
                    model: locationsModel
                    textRole: "address"
                
                    onCurrentIndexChanged: onSelectLocation(currentIndex)

                    Kirigami.FormData.label: i18n("Select City:")
                }

                ComboBox {
                    id: stationComboxBox
                    editable: false
                    enabled: stationsModel.count > 0
                    model: stationsModel
                    textRole: "text"
                
                    onCurrentIndexChanged: onSelectStation(currentIndex)
                    Kirigami.FormData.label: i18n("Select Station:")
                }

                TextField {
                    id: stationStatus
                    enabled: false

                    horizontalAlignment: Text.AlignHCenter
                    placeholderText: i18n("---------------------Pending selection-----------------------")

                    Kirigami.FormData.label: i18n("Station status:")
                }
            }
        }

        RowLayout {
            id: buttonsRow

            Layout.alignment: Qt.AlignVCenter

            PlasmaComponents.Label {
                id: newStationText

                Layout.fillWidth: true

                horizontalAlignment: Text.AlignLeft
                verticalAlignment: Text.AlignVCenter

                text: i18n("New Station: %1", newStation)
            }

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