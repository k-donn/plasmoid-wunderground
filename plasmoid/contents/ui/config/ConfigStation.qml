/*
 * Copyright 2025  Kevin Donnelly
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
import QtQuick.Layouts
import org.kde.kcmutils as KCM
import QtQuick.Controls as QQC
import org.kde.plasma.components as PlasmaComponents
import org.kde.plasma.core as PlasmaCore
import org.kde.kirigami as Kirigami
import "../../code/pws-api.js" as StationAPI
import "../lib" as Lib

KCM.SimpleKCM {
    id: stationConfig

    property alias cfg_stationID: stationPickerEl.selectedStation
    property alias cfg_savedStations: stationPickerEl.stationList
    property alias cfg_latitude: stationPickerEl.latitude
    property alias cfg_longitude: stationPickerEl.longitude
    property alias cfg_refreshPeriod: refreshPeriod.value

    function printDebug(msg) {
        if (plasmoid.configuration.logConsole) {
            console.log("[debug] [ConfigStation.qml] " + msg);
        }
    }

    function listModelToStr(listModel) {
        var kvs = [];
        for (var i = 0; i < listModel.count; i++) {
            kvs.push(listModel.get(i));
        }
        return JSON.stringify(kvs);
    }

    Item {
        id: stationPickerEl
        property string selectedStation: ""
        property string stationList: ""
        property real latitude: 0
        property real longitude: 0


        function selectStation(index) {
            printDebug("selectStation: " + stationList);
            var stationsArr = JSON.parse(stationList);
            if (index < 0 || index >= stationsArr.length) {
                return;
            }
            selectedStation = stationsArr[index].stationID;
            latitude = stationsArr[index].latitude;
            longitude = stationsArr[index].longitude;
            for (var i = 0; i < stationsArr.length; i++) {
                stationsArr[i].selected = (i === index);
            }
            stationList = JSON.stringify(stationsArr);
        }

        function removeStation(index) {
            printDebug("removeStation: " + index + " of " + stationList);
            var stationsArr = JSON.parse(stationList);
            if (index < 0 || index >= stationsArr.length) {
                return;
            } 
            var wasSelected = stationsArr[index].selected;
            stationsArr.splice(index, 1);
            if (wasSelected && stationsArr.length > 0) {
                selectStation(0);
            } else if (stationsArr.length === 0) {
                selectedStation = "";
                latitude = 0;
                longitude = 0;
            }
            stationList = JSON.stringify(stationsArr);
        }

        function addStation(station) {
            printDebug("add station: " + JSON.stringify(station) + " to " + stationList);
            // Prevent duplicates
            var stationsArr = JSON.parse(stationList);
            for (var i = 0; i < stationsArr.length; i++) {
                if (stationsArr[i].stationID === station.stationID) {
                    return;
                }
            }
            for (var i = 0; i < stationsArr.length; i++) {
                stationsArr[i].selected = false;
            }
            station.selected = true;
            stationsArr.push(station);
            stationList = JSON.stringify(stationsArr);
            selectStation(stationsArr.length - 1);
        }

        ColumnLayout {
            width: parent.width

            Kirigami.Heading {
                text: i18n("Saved Weather Stations")
                level: 3
            }

            RowLayout {
                spacing: 8
                PlasmaComponents.Label { text: i18n("Station ID"); Layout.preferredWidth: 120; font.bold: true }
                PlasmaComponents.Label { text: i18n("Place Name"); Layout.preferredWidth: 160; font.bold: true }
                PlasmaComponents.Label { text: i18n("Latitude"); Layout.preferredWidth: 80; font.bold: true }
                PlasmaComponents.Label { text: i18n("Longitude"); Layout.preferredWidth: 80; font.bold: true }
                PlasmaComponents.Label { text: i18n("Action"); Layout.preferredWidth: 120; font.bold: true }
            }

            ListView {
                id: stationListView
                model: ListModel {
                    id: stationListModel
                    Component.onCompleted: {
                        stationListModel.clear();
                        printDebug("Loaded " + stationPickerEl.stationList + " from station settings");
                        var stationsArr = JSON.parse(stationPickerEl.stationList);
                        for (var i = 0; i < stationsArr.length; i++) {
                            stationListModel.append({
                                "stationID": stationsArr[i].stationID,
                                "placeName": stationsArr[i].placeName,
                                "latitude": stationsArr[i].latitude,
                                "longitude": stationsArr[i].longitude,
                                "selected": stationsArr[i].selected === true
                            });
                            if (stationsArr[i].selected === true) {
                                selectStation(i);
                            }
                        }
                        printDebug("onComplete: StationListModel: " + listModelToStr(stationListModel));
                    }
                }
                delegate: RowLayout {
                    spacing: 8
                    PlasmaComponents.Label { text: stationID; Layout.preferredWidth: 120 }
                    PlasmaComponents.Label { text: placeName; Layout.preferredWidth: 160 }
                    PlasmaComponents.Label { text: latitude; Layout.preferredWidth: 80 }
                    PlasmaComponents.Label { text: longitude; Layout.preferredWidth: 80 }
                    RowLayout {
                        spacing: 4
                        QQC.Button {
                            text: i18n("Select")
                            enabled: !selected
                            onClicked: {
                                stationPickerEl.selectStation(index);
                                // Sync model
                                for (var i = 0; i < stationListModel.count; i++) {
                                    stationListModel.setProperty(i, "selected", i === index);
                                }
                                printDebug("onClicked: StationListModel: " + listModelToStr(stationListModel));
                            }
                        }
                        QQC.Button {
                            text: i18n("Remove")
                            onClicked: {
                                stationPickerEl.removeStation(index);
                                stationListModel.remove(index);
                                printDebug("onRemove: StationListModel: " + listModelToStr(stationListModel));
                            }
                        }
                    }
                }
                Layout.preferredHeight: Math.min(6, stationListModel.count) * 36
                Layout.fillWidth: true
                clip: true
            }

            QQC.Button {
                text: i18n("Add Station…")
                icon.name: "list-add"
                onClicked: stationSearcher.open()
            }

            Lib.StationSearcher {
                id: stationSearcher
                onStationSelected: function(station) {
                    printDebug("Received station: " + JSON.stringify(station));
                    stationPickerEl.addStation(station);
                    stationListModel.append({
                        "stationID": station.stationID,
                        "placeName": station.placeName,
                        "latitude": station.latitude,
                        "longitude": station.longitude,
                        "selected": true
                    });
                    for (var i = 0; i < stationListModel.count; i++) {
                        stationListModel.setProperty(i, "selected", i === stationListModel.count - 1);
                    }
                    stationSearcher.close();
                    printDebug("onSelect: StationListModel: " + listModelToStr(stationListModel));
                }
            }
            QQC.SpinBox {
                id: refreshPeriod
                from: 1
                to: 86400
                editable: true
                validator: IntValidator { bottom: refreshPeriod.from; top: refreshPeriod.to }
                Kirigami.FormData.label: i18n("Refresh period (s):")
            }

            PlasmaComponents.Label {
                text: "Version 3.4.6"
            }
        }

    }
}
