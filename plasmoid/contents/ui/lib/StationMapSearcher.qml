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
import QtLocation
import QtPositioning
import QtQuick.Controls as QQC
import org.kde.kirigami as Kirigami
import org.kde.plasma.plasmoid
import org.kde.plasma.components as PlasmaComponents
import "../../code/utils.js" as Utils
import "../../code/pws-api.js" as StationAPI

Window {
    id: stationMapSearcher

    LayoutMirroring.enabled: Qt.application.layoutDirection === Qt.RightToLeft
    LayoutMirroring.childrenInherit: true

    flags: Qt.Dialog
    modality: Qt.WindowModal

    width: Kirigami.Units.gridUnit * 40
    height: Kirigami.Units.gridUnit * 25

    SystemPalette {
        id: syspal
    }

    title: i18n("Find Station")
    color: syspal.window

    signal stationSelected(var station)
    signal open

    property string searchMode: "placeName"
    property string searchText: ""
    property real areaLat: 0
    property real areaLon: 0
    property real searchLat: 0
    property real searchLon: 0

    property string errorType: ""
    property string errorMessage: ""

    property var selectedStation

    property ListModel searchResults: ListModel {}
    property ListModel availableCitiesModel: ListModel {}

    onOpen: {
        stationMapSearcher.visible = true;
        errorMessage = "";
        errorType = "";
        searchResults.clear();
        availableCitiesModel.clear();
    }

    Plugin {
        id: osmPlugin
        name: "osm"
        PluginParameter {
            name: "osm.useragent"
            value: "WundergroundPlasmoid/3.5.4 (https://github.com/k-donn/plasmoid-wunderground; contact:mitchell@mitchelldonnelly.com)"
        }
        PluginParameter {
            name: "osm.mapping.custom.host"
            value: "https://tile.openstreetmap.org/"
        }
    }

    ColumnLayout {
        id: mainColumn
        anchors {
            fill: parent
            margins: mainColumn.spacing * Screen.devicePixelRatio //margins are hardcoded in QStyle we should match that here
        }
        spacing: 8

        RowLayout {
            Layout.fillWidth: true

            QQC.Label {
                text: i18n("Search by:")
            }

            QQC.ComboBox {
                id: modeCombo
                model: [i18n("City Name"), i18n("Weatherstation ID:"), i18n("Lat/Lon")]
                onCurrentIndexChanged: {
                    if (currentIndex === 0) {
                        stationMapSearcher.searchMode = "placeName";
                    } else if (currentIndex === 1) {
                        stationMapSearcher.searchMode = "stationID";
                    } else {
                        showSearchCircle = true;
                        stationMapSearcher.searchMode = "latlon";
                    }
                }
            }

            Loader {
                id: searchLoader
                Layout.fillWidth: true
                sourceComponent: stationMapSearcher.searchMode === "latlon" ? latLonSearchComponent : textSearchComponent
            }

            QQC.Button {
                text: i18n("Search")
                enabled: stationMapSearcher.searchText.length > 0 || stationMapSearcher.searchMode === "latlon"
                onPressed: {
                    if (stationMapSearcher.searchMode === "placeName") {
                        StationAPI.getLocations(stationMapSearcher.searchText, {
                            language: Qt.locale().name.replace("_", "-")
                        }, function (err, places) {
                            if (err) {
                                errorType = err.type;
                                errorMessage = err.message;
                                availableCitiesModel.clear();
                                return;
                            }
                            errorType = "";
                            errorMessage = "";
                            availableCitiesModel.clear();
                            for (var i = 0; i < places.length; i++) {
                                availableCitiesModel.append({
                                    "placeName": places[i].city + "," + places[i].state + " (" + places[i].country + ")",
                                    "latitude": places[i].latitude,
                                    "longitude": places[i].longitude
                                });
                            }
                        });
                    } else if (stationMapSearcher.searchMode === "stationID") {
                        StationAPI.searchStationID(stationMapSearcher.searchText, {
                            language: Qt.locale().name.replace("_", "-")
                        }, function (err, stations) {
                            if (err) {
                                errorType = err.type;
                                errorMessage = err.message;
                                return;
                            }
                            errorType = "";
                            errorMessage = "";
                            var latSum, latCount, lonSum, lonCount;
                            searchResults.clear();
                            for (var i = 0; i < stations.length; i++) {
                                latSum += (latSum || 0) + stations[i].latitude;
                                lonSum += (lonSum || 0) + stations[i].longitude;
                                latCount = (latCount || 0) + 1;
                                lonCount = (lonCount || 0) + 1;
                                searchResults.append({
                                    "stationID": stations[i].stationID,
                                    "placeName": stations[i].placeName,
                                    "latitude": stations[i].latitude,
                                    "longitude": stations[i].longitude
                                });
                            }
                            var latAvg = latSum / latCount;
                            var lonAvg = lonSum / lonCount;
                            stationMapSearcher.areaLat = latAvg;
                            stationMapSearcher.areaLon = lonAvg;
                            stationMap.center = QtPositioning.coordinate(latAvg, lonAvg);
                            stationMap.zoomLevel = 10;
                        });
                    } else if (stationMapSearcher.searchMode === "latlon") {
                        StationAPI.searchGeocode({
                            latitude: stationMapSearcher.searchLat,
                            longitude: stationMapSearcher.searchLon
                        }, {
                            language: Qt.locale().name.replace("_", "-")
                        }, function (err, stations) {
                            if (err) {
                                errorType = err.type;
                                errorMessage = err.message;
                                return;
                            }
                            errorType = "";
                            errorMessage = "";
                            var latSum, latCount, lonSum, lonCount;
                            searchResults.clear();
                            for (var i = 0; i < stations.length; i++) {
                                latSum += (latSum || 0) + stations[i].latitude;
                                lonSum += (lonSum || 0) + stations[i].longitude;
                                latCount = (latCount || 0) + 1;
                                lonCount = (lonCount || 0) + 1;
                                searchResults.append({
                                    "stationID": stations[i].stationID,
                                    "placeName": stations[i].placeName,
                                    "latitude": stations[i].latitude,
                                    "longitude": stations[i].longitude
                                });
                            }
                            var latAvg = latSum / latCount;
                            var lonAvg = lonSum / lonCount;
                            stationMapSearcher.areaLat = latAvg;
                            stationMapSearcher.areaLon = lonAvg;
                            stationMap.center = QtPositioning.coordinate(latAvg, lonAvg);
                            stationMap.zoomLevel = 10;
                        });
                    }
                }
            }
        }

        Loader {
            id: helperLoader
            Layout.fillWidth: true
            sourceComponent: stationMapSearcher.searchMode === "placeName" ? placeNameHelperComponent : stationMapSearcher.searchMode === "stationID" ? stationIDHelperComponent : latLonHelperComponent
        }

        Component {
            id: textSearchComponent
            QQC.TextField {
                id: searchField
                Layout.fillWidth: true
                placeholderText: stationMapSearcher.searchMode === "stationID" ? i18n("Enter Station") : i18n("Enter City Name")
                onTextChanged: {
                    stationMapSearcher.searchText = text.trim();
                }
            }
        }

        Component {
            id: latLonSearchComponent

            PlasmaComponents.Label {
                text: i18n("Select location on the map below.")
            }
        }

        Component {
            id: placeNameHelperComponent

            RowLayout {
                Layout.fillWidth: true

                PlasmaComponents.Label {
                    text: i18n("Searching place:")
                }

                QQC.ComboBox {
                    id: cityChoice
                    Layout.fillWidth: true
                    textRole: "placeName"
                    model: availableCitiesModel
                    enabled: availableCitiesModel.count > 0
                }

                QQC.Button {
                    text: i18n("Choose")
                    enabled: cityChoice.currentIndex !== -1
                    onClicked: {
                        searchResults.clear();
                        stationMapSearcher.areaLat = availableCitiesModel.get(cityChoice.currentIndex).latitude;
                        stationMapSearcher.areaLon = availableCitiesModel.get(cityChoice.currentIndex).longitude;
                        stationMap.center = QtPositioning.coordinate(availableCitiesModel.get(cityChoice.currentIndex).latitude, availableCitiesModel.get(cityChoice.currentIndex).longitude);
                        stationMap.zoomLevel = 10;
                        StationAPI.searchGeocode({
                            latitude: availableCitiesModel.get(cityChoice.currentIndex).latitude,
                            longitude: availableCitiesModel.get(cityChoice.currentIndex).longitude
                        }, {
                            language: Qt.locale().name.replace("_", "-")
                        }, function (err, stations) {
                            if (err) {
                                errorType = err.type;
                                errorMessage = err.message;
                                return;
                            }
                            var latSum, latCount, lonSum, lonCount;
                            for (var i = 0; i < stations.length; i++) {
                                searchResults.append({
                                    "stationID": stations[i].stationID,
                                    "placeName": stations[i].placeName,
                                    "latitude": stations[i].latitude,
                                    "longitude": stations[i].longitude
                                });
                            }
                        });
                    }
                }
            }
        }

        Component {
            id: stationIDHelperComponent
            PlasmaComponents.Label {
                text: i18n("Searching by Weatherstation ID. Example: KGADACUL1")
            }
        }

        Component {
            id: latLonHelperComponent
            PlasmaComponents.Label {
                text: i18n("Selected latitude: %1, longitude: %2", stationMapSearcher.searchLat.toFixed(4), stationMapSearcher.searchLon.toFixed(4))
            }
        }

        Map {
            id: stationMap
            Layout.fillWidth: true
            Layout.fillHeight: true

            plugin: osmPlugin

            activeMapType: supportedMapTypes[supportedMapTypes.length - 1]

            center: QtPositioning.coordinate(20, 0)
            zoomLevel: 2

            WheelHandler {
                id: wheel
                // workaround for QTBUG-87646 / QTBUG-112394 / QTBUG-112432:
                // Magic Mouse pretends to be a trackpad but doesn't work with PinchHandler
                // and we don't yet distinguish mice and trackpads on Wayland either
                acceptedDevices: Qt.platform.pluginName === "cocoa" || Qt.platform.pluginName === "wayland" ? PointerDevice.Mouse | PointerDevice.TouchPad : PointerDevice.Mouse
                rotationScale: 1 / 120
                onWheel: function (event) {
                    // determine wheel steps (one step = 120)
                    var steps = 0;
                    if (event.angleDelta && event.angleDelta.y !== 0)
                        steps = event.angleDelta.y / 120;
                    else if (event.pixelDelta && event.pixelDelta.y !== 0)
                        steps = event.pixelDelta.y / 120;
                    if (steps === 0)
                        return;

                    // coordinate under the cursor before zoom
                    var mousePoint = Qt.point(event.x, event.y);
                    var coordBefore = stationMap.toCoordinate(mousePoint);

                    // adjust zoom
                    var newZoom = stationMap.zoomLevel + steps;
                    newZoom = Math.max(stationMap.minimumZoomLevel, Math.min(stationMap.maximumZoomLevel, newZoom));
                    stationMap.zoomLevel = newZoom;

                    // coordinate under the cursor after zoom
                    var coordAfter = stationMap.toCoordinate(mousePoint);

                    // shift center so the point under the cursor stays fixed
                    var newCenterLat = stationMap.center.latitude + (coordBefore.latitude - coordAfter.latitude);
                    var newCenterLon = stationMap.center.longitude + (coordBefore.longitude - coordAfter.longitude);
                    stationMap.center = QtPositioning.coordinate(newCenterLat, newCenterLon);

                    event.accepted = true;
                }
            }
            DragHandler {
                id: drag
                target: null
                onTranslationChanged: delta => stationMap.pan(-delta.x, -delta.y)
            }
            Shortcut {
                enabled: stationMap.zoomLevel < stationMap.maximumZoomLevel
                sequence: StandardKey.ZoomIn
                onActivated: stationMap.zoomLevel = Math.round(stationMap.zoomLevel + 1)
            }
            Shortcut {
                enabled: stationMap.zoomLevel > stationMap.minimumZoomLevel
                sequence: StandardKey.ZoomOut
                onActivated: stationMap.zoomLevel = Math.round(stationMap.zoomLevel - 1)
            }

            MapCircle {
                id: searchCenterIndicator
                visible: stationMapSearcher.searchResults.count > 0 || stationMapSearcher.searchMode === "latlon"
                center: QtPositioning.coordinate(stationMapSearcher.searchMode === "latlon" ? stationMapSearcher.searchLat : stationMapSearcher.areaLat, stationMapSearcher.searchMode === "latlon" ? stationMapSearcher.searchLon : stationMapSearcher.areaLon)
                radius: 10000
                color: "red"
                opacity: 0.2
                border.color: "red"
                border.width: 1
            }

            MapCircle {
                id: searchCenterBorderIndicator
                visible: stationMapSearcher.searchResults.count > 0 || stationMapSearcher.searchMode === "latlon"
                center: QtPositioning.coordinate(stationMapSearcher.searchMode === "latlon" ? stationMapSearcher.searchLat : stationMapSearcher.areaLat, stationMapSearcher.searchMode === "latlon" ? stationMapSearcher.searchLon : stationMapSearcher.areaLon)
                radius: 10000
                color: "transparent"
                border.color: "red"
                border.width: 3
            }

            MapQuickItem {
                id: searchPointMarker
                coordinate: QtPositioning.coordinate(stationMapSearcher.searchLat, stationMapSearcher.searchLon)
                visible: stationMapSearcher.searchMode === "latlon"
                anchorPoint.x: iconImage.height / 2
                anchorPoint.y: iconImage.height / 2
                sourceItem: Image {
                    id: iconImage
                    source: Utils.getIcon("compass")
                    width: 24
                    height: 24
                }

                MouseArea {
                    anchors.fill: parent
                    drag.target: parent
                    onPositionChanged: {
                        var coord = stationMap.toCoordinate(Qt.point(parent.x + parent.anchorPoint.x, parent.y + parent.anchorPoint.y));
                        stationMapSearcher.searchLat = coord.latitude;
                        stationMapSearcher.searchLon = coord.longitude;
                    }
                }
            }

            MouseArea {
                anchors.fill: parent
                onClicked: function (mouse) {
                    var coord = stationMap.toCoordinate(Qt.point(mouse.x, mouse.y));
                    stationMapSearcher.searchLat = coord.latitude;
                    stationMapSearcher.searchLon = coord.longitude;
                }
            }

            MapItemView {
                model: searchResults
                delegate: MapQuickItem {
                    id: stationMarker
                    coordinate: QtPositioning.coordinate(latitude, longitude)
                    anchorPoint.x: 2.5
                    anchorPoint.y: iconImage.height
                    sourceItem: Column {
                        Image {
                            id: iconImage
                            source: Utils.getIcon("weather-station-2")
                            width: 32
                            height: 32
                        }
                        PlasmaComponents.Label {
                            text: stationID
                            font.pixelSize: 12
                            color: "black"
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                            padding: 2
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            selectedStation = {
                                "stationID": stationID,
                                "placeName": placeName,
                                "latitude": latitude,
                                "longitude": longitude
                            };
                        }
                    }
                }
            }
        }

        RowLayout {
            id: buttonsRow

            PlasmaComponents.Label {
                Layout.fillWidth: true
                text: selectedStation !== undefined ? i18n("Selected Station: %1 (%2)", selectedStation.placeName, selectedStation.stationID) : ""
            }

            QQC.Button {
                icon.name: "dialog-ok"
                text: i18n("Confirm")
                enabled: selectedStation !== undefined
                onClicked: {
                    stationSelected(selectedStation);
                    stationMapSearcher.close();
                }
            }

            QQC.Button {
                icon.name: "dialog-cancel"
                text: i18n("Cancel")
                onClicked: {
                    stationMapSearcher.close();
                }
            }
        }
    }
}
