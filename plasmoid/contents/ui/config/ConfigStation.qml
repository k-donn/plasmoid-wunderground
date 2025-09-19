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
    property alias cfg_stationName: stationPickerEl.stationName
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
        property string stationName: ""
        property real latitude: 0
        property real longitude: 0


        function selectStation(index) {
            printDebug("selectStation " + index + " of " + stationList);
            var stationsArr = JSON.parse(stationList);
            if (index < 0 || index >= stationsArr.length) {
                return;
            }
            selectedStation = stationsArr[index].stationID;
            latitude = stationsArr[index].latitude;
            longitude = stationsArr[index].longitude;
            stationName = stationsArr[index].placeName;
            for (var i = 0; i < stationsArr.length; i++) {
                stationsArr[i].selected = (i === index);
            }
            stationList = JSON.stringify(stationsArr);
        }

        function removeStation(index) {
            printDebug("removeStation: " + index + " of " + stationList);
            var stationsArr = JSON.parse(stationList);
            if (index < 0 || index >= stationsArr.length || stationsArr.length === 0) {
                return;
            } 
            var wasSelected = stationsArr[index].selected;
            stationsArr.splice(index, 1);
            stationList = JSON.stringify(stationsArr);
            if (stationsArr.length === 1) {
                stationPickerEl.selectStation(0);
            } else if (wasSelected && stationsArr.length > 1) {
                stationPickerEl.selectStation(stationsArr.length - 1);
            } else if (stationsArr.length === 0) {
                selectedStation = "";
                latitude = 0;
                longitude = 0;
                stationName = "";
            }
            printDebug("After removal: " + stationList);
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
            stationPickerEl.selectStation(stationsArr.length - 1);
        }

        ColumnLayout {
            width: parent.width

            Kirigami.Heading {
                text: i18n("Saved Weather Stations")
                level: 3
            }

            RowLayout {
                id: headerRow
                spacing: 0
                Rectangle {
                    color: Kirigami.Theme.backgroundColor
                    border.color: Qt.rgba(Kirigami.Theme.textColor.r, Kirigami.Theme.textColor.g, Kirigami.Theme.textColor.b, 0.15)
                    border.width: 1
                    height: 36
                    width: 120
                    PlasmaComponents.Label {
                        anchors.centerIn: parent
                        text: i18n("ID:")
                        font.bold: true
                        elide: Text.ElideRight
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        width: parent.width - 8
                        clip: true
                    }
                }
                Rectangle {
                    color: Kirigami.Theme.backgroundColor
                    border.color: Qt.rgba(Kirigami.Theme.textColor.r, Kirigami.Theme.textColor.g, Kirigami.Theme.textColor.b, 0.15)
                    border.width: 1
                    height: 36
                    width: 160
                    PlasmaComponents.Label {
                        anchors.centerIn: parent
                        text: i18n("Weatherstation Name:")
                        font.bold: true
                        elide: Text.ElideRight
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        width: parent.width - 8
                        clip: true
                    }
                }
                Rectangle {
                    color: Kirigami.Theme.backgroundColor
                    border.color: Qt.rgba(Kirigami.Theme.textColor.r, Kirigami.Theme.textColor.g, Kirigami.Theme.textColor.b, 0.15)
                    border.width: 1
                    height: 36
                    width: 80
                    PlasmaComponents.Label {
                        anchors.centerIn: parent
                        text: i18n("Latitude:")
                        font.bold: true
                        elide: Text.ElideRight
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        width: parent.width - 8
                        clip: true
                    }
                }
                Rectangle {
                    color: Kirigami.Theme.backgroundColor
                    border.color: Qt.rgba(Kirigami.Theme.textColor.r, Kirigami.Theme.textColor.g, Kirigami.Theme.textColor.b, 0.15)
                    border.width: 1
                    height: 36
                    width: 80
                    PlasmaComponents.Label {
                        anchors.centerIn: parent
                        text: i18n("Longitude:")
                        font.bold: true
                        elide: Text.ElideRight
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        width: parent.width - 8
                        clip: true
                    }
                }
                Rectangle {
                    color: Kirigami.Theme.backgroundColor
                    border.color: Qt.rgba(Kirigami.Theme.textColor.r, Kirigami.Theme.textColor.g, Kirigami.Theme.textColor.b, 0.15)
                    border.width: 1
                    height: 36
                    width: 120
                    PlasmaComponents.Label {
                        anchors.centerIn: parent
                        text: i18n("Action")
                        font.bold: true
                        elide: Text.ElideRight
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        width: parent.width - 8
                        clip: true
                    }
                }
            }

            ListView {
                id: stationListView
                model: ListModel {
                    id: stationListModel
                    Component.onCompleted: {
                        stationListModel.clear();
                        printDebug("Loading from savedStations: " + stationPickerEl.stationList + "");
                        var stationsArr = [];
                        try {
                            stationsArr = JSON.parse(stationPickerEl.stationList);

                            if (stationsArr.length === 0 && plasmoid.configuration.stationID !== "") {
                                printDebug("Station not saved to savedStations. Attempting to add.");
                                stationListModel.append({
                                    "stationID":plasmoid.configuration.stationID,
                                    "placeName":plasmoid.configuration.stationName,
                                    "latitude":plasmoid.configuration.latitude,
                                    "longitude":plasmoid.configuration.longitude,
                                    "selected": true
                                });
                                var stationListTxt = listModelToStr(stationListModel);
                                printDebug("Wrote to savedStations: " + stationListTxt);
                                plasmoid.configuration.savedStations = stationListTxt;
                                stationPickerEl.stationList = stationListTxt;
                                stationPickerEl.selectStation(0);
                            }

                            for (var i = 0; i < stationsArr.length; i++) {
                                stationListModel.append({
                                    "stationID": stationsArr[i].stationID,
                                    "placeName": stationsArr[i].placeName,
                                    "latitude": stationsArr[i].latitude,
                                    "longitude": stationsArr[i].longitude,
                                    "selected": stationsArr[i].selected === true
                                });
                                if (stationsArr[i].selected === true) {
                                    stationPickerEl.selectStation(i);
                                }
                            }
                        } catch (e) {
                            printDebug("Invalid saved stations");
                            printDebug("Station ID: " + plasmoid.configuration.stationID + " long: " + plasmoid.configuration.longitude + " lat: " + plasmoid.configuration.latitude + " name: " + plasmoid.configuration.stationName + " list: " + plasmoid.configuration.stationList);
                            if (plasmoid.configuration.stationID !== null) {
                                printDebug("Attempting to fill in savedStations");
                                stationListModel.append({
                                    "stationID":plasmoid.configuration.stationID,
                                    "placeName":plasmoid.configuration.stationName,
                                    "latitude":plasmoid.configuration.latitude,
                                    "longitude":plasmoid.configuration.longitude,
                                    "selected": true
                                });
                                var stationListTxt = listModelToStr(stationListModel);
                                printDebug("Wrote to savedStations: " + stationListTxt);
                                plasmoid.configuration.savedStations = stationListTxt;
                                stationPickerEl.stationList = stationListTxt;
                                stationPickerEl.selectStation(0);
                            }
                        }
                        printDebug("onComplete: StationListModel: " + listModelToStr(stationListModel));
                    }
                }
                delegate: Item {
                    width: headerRow.width
                    height: 36
                    Rectangle {
                        anchors.fill: parent
                        color: selected ? Kirigami.Theme.highlightColor
                                        : (index % 2 === 0 ? Kirigami.Theme.backgroundColor : Kirigami.Theme.alternateBackgroundColor)
                        border.color: Qt.rgba(Kirigami.Theme.textColor.r, Kirigami.Theme.textColor.g, Kirigami.Theme.textColor.b, 0.15)
                        border.width: 1
                    }
                    RowLayout {
                        anchors.fill: parent
                        spacing: 0
                        PlasmaComponents.Label {
                            text: stationID
                            Layout.preferredWidth: 120
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                            elide: Text.ElideRight
                            clip: true
                        }
                        Rectangle { width: 1; color: Qt.rgba(Kirigami.Theme.textColor.r, Kirigami.Theme.textColor.g, Kirigami.Theme.textColor.b, 0.15); height: parent.height }
                        PlasmaComponents.Label {
                            text: placeName
                            Layout.preferredWidth: 160
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                            elide: Text.ElideRight
                            clip: true
                        }
                        Rectangle { width: 1; color: Qt.rgba(Kirigami.Theme.textColor.r, Kirigami.Theme.textColor.g, Kirigami.Theme.textColor.b, 0.15); height: parent.height }
                        PlasmaComponents.Label {
                            text: latitude
                            Layout.preferredWidth: 80
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                            elide: Text.ElideRight
                            clip: true
                        }
                        Rectangle { width: 1; color: Qt.rgba(Kirigami.Theme.textColor.r, Kirigami.Theme.textColor.g, Kirigami.Theme.textColor.b, 0.15); height: parent.height }
                        PlasmaComponents.Label {
                            text: longitude
                            Layout.preferredWidth: 80
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                            elide: Text.ElideRight
                            clip: true
                        }
                        Rectangle { width: 1; color: Qt.rgba(Kirigami.Theme.textColor.r, Kirigami.Theme.textColor.g, Kirigami.Theme.textColor.b, 0.15); height: parent.height }
                        RowLayout {
                            Layout.preferredWidth: 120
                            spacing: 4
                            QQC.Button {
                                icon.name: "dialog-ok-apply"
                                enabled: !selected
                                QQC.ToolTip.text: i18n("Select")
                                QQC.ToolTip.visible: hovered
                                onClicked: {
                                    stationPickerEl.selectStation(index);
                                    for (var i = 0; i < stationListModel.count; i++) {
                                        stationListModel.setProperty(i, "selected", i === index);
                                    }
                                    printDebug("onClicked: StationListModel: " + listModelToStr(stationListModel));
                                }
                            }
                            QQC.Button {
                                icon.name: "dialog-cancel"
                                enabled: stationListModel.count > 1
                                QQC.ToolTip.text: i18n("Remove")
                                QQC.ToolTip.visible: hovered
                                onClicked: {
                                    var wasSelected = selected;
                                    var oldIndex = index;
                                    stationPickerEl.removeStation(index);
                                    stationListModel.remove(index);
                                    if (wasSelected && stationListModel.count === 1) {
                                        stationListModel.setProperty(0, "selected", true);
                                    } else if (wasSelected && stationListModel.count > 1) {
                                        if (stationListModel.count > oldIndex) {
                                            stationListModel.setProperty(oldIndex, "selected", true);
                                        } else if (stationListModel.count === oldIndex) {
                                            stationListModel.setProperty(oldIndex - 1, "selected", true);
                                        } else {
                                            stationListModel.setProperty(stationListModel.count - 1, "selected", true);
                                        }
                                    }
                                    printDebug("onRemove: StationListModel: " + listModelToStr(stationListModel));
                                }
                            }
                        }
                    }
                }
                Layout.preferredHeight: 216
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
