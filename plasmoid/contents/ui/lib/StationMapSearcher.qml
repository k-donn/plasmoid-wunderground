import QtQuick
import QtQuick.Layouts
import QtLocation
import QtPositioning
import QtQuick.Controls as QQC
import org.kde.kirigami as Kirigami
import org.kde.plasma.plasmoid
import org.kde.plasma.core as PlasmaCore
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
    signal open()

    property string errorType: ""
    property string errorMessage: ""
    property var selectedStation
    
    property ListModel searchResults: ListModel {}
    property ListModel availableCitiesModel: ListModel {}

    onOpen: {
        stationMapSearcher.visible = true
        errorMessage = ""
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

            QQC.TextField {
                id: searchField
                Layout.fillWidth: true
                placeholderText: i18n("Search for a location...")
            }
           

            QQC.Button {
                text: i18n("Search")
                onPressed: {
                    StationAPI.getLocations(searchField.text.trim(), {
                        language: Qt.locale().name.replace("_", "-")
                    }, function (err, places) {
                        if (err) {
                            errorType = err.type
                            errorMessage = err.message
                            availableCitiesModel.clear()
                            return
                        }
                        errorType = ""
                        errorMessage = ""
                        availableCitiesModel.clear()
                        for (var i = 0; i < places.length; i++) {
                            availableCitiesModel.append({
                                "placeName": places[i].city + "," + places[i].state + " (" + places[i].country + ")",
                                "latitude": places[i].latitude,
                                "longitude": places[i].longitude
                            });
                        }
                    })
                }
            }
        }

        RowLayout {
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
                        StationAPI.searchGeocode({
                            latitude: availableCitiesModel.get(cityChoice.currentIndex).latitude,
                            longitude: availableCitiesModel.get(cityChoice.currentIndex).longitude
                        }, {
                            language: Qt.locale().name.replace("_", "-")
                        }, function (err, stations) {
                            if (err) {
                                setError(err);
                                return;
                            }
                            for (var i = 0; i < stations.length; i++) {
                                searchResults.append({
                                    "stationID": stations[i].stationID,
                                    "placeName": stations[i].placeName,
                                    "latitude": stations[i].latitude,
                                    "longitude": stations[i].longitude,
                                });
                            }
                        });
                    }
                }
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
                acceptedDevices: Qt.platform.pluginName === "cocoa" || Qt.platform.pluginName === "wayland"
                                ? PointerDevice.Mouse | PointerDevice.TouchPad
                                : PointerDevice.Mouse
                rotationScale: 1/120
                property: "zoomLevel"
            }
            DragHandler {
                id: drag
                target: null
                onTranslationChanged: (delta) => stationMap.pan(-delta.x, -delta.y)
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

            MapItemView {
                model: searchResults
                delegate: MapQuickItem {
                    id: stationMarker
                    coordinate: QtPositioning.coordinate(latitude, longitude)
                    anchorPoint.x: iconImage.width / 2
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
                                "longitude": longitude,
                            };
                        }
                    }
                }
            }

        }

        RowLayout {
            id: buttonsRow

            Layout.alignment: Qt.AlignRight

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