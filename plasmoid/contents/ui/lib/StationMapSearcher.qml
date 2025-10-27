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

    property bool hasError: false
    property string errorMessage: ""
    property var selectedStation

    onOpen: {
        stationMapSearcher.visible = true
        hasError = false
        errorMessage = ""
    }

    function searchLocation(query) {
        
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
                onClicked: {
                    stationMapSearcher.searchLocation(searchField.text)
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