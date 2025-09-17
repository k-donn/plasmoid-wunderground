import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as QQC
import org.kde.kirigami as Kirigami
import org.kde.plasma.components as PlasmaComponents
import "../../code/utils.js" as Utils
import "../../code/pws-api.js" as StationAPI

Window {
    id: stationSearcher
    signal stationSelected(var station)
    signal open

    LayoutMirroring.enabled: Qt.application.layoutDirection === Qt.RightToLeft
    LayoutMirroring.childrenInherit: true

    flags: Qt.Dialog
    modality: Qt.WindowModal

    width: Kirigami.Units.gridUnit * 35
    height: Kirigami.Units.gridUnit * 20

    SystemPalette {
        id: syspal
    }

    function printDebug(msg) {
        if (plasmoid.configuration.logConsole) {
            console.log("[debug] [StationSearcher.qml] " + msg);
        }
    }

    title: i18n("Search Weather Stations")
    color: syspal.window

    property string searchMode: "stationID" // "stationID", "placeName", "latlon"
    property string searchText: ""
    property var selectedStation
    property real searchLat: 0
    property real searchLon: 0

    property ListModel searchResults: ListModel {}
    property ListModel availableCitiesModel: ListModel {}

    onOpen: {
        stationSearcher.visible = true;

        searchResults.clear();
        availableCitiesModel.clear();
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

            RowLayout {
                QQC.Label { text: "Search by:" }
                QQC.ComboBox {
                    id: modeCombo
                    model: [ "Station ID", "Place Name", "Lat/Lon" ]
                    onCurrentIndexChanged: {
                        if (currentIndex === 0) stationSearcher.searchMode = "stationID";
                        else if (currentIndex === 1) stationSearcher.searchMode = "placeName";
                        else stationSearcher.searchMode = "latlon";
                    }
                }
            }

            Loader {
                id: searchFieldLoader
                Layout.fillWidth: true
                sourceComponent: stationSearcher.searchMode === "latlon" ? latlonFields : textField
            }


            QQC.Button {
                text: "Search"
                onClicked: {
                    if (stationSearcher.searchMode === "stationID") {
                        StationAPI.searchStationID(stationSearcher.searchText, function(stations) {
                            for (var i = 0; i < stations.length; i++) {
                                stationSearcher.searchResults.append({"stationID": stations[i].stationID, "placeName": stations[i].placeName, "latitude": stations[i].latitude, "longitude": stations[i].longitude, "selected": false});
                            }
                        })
                    } else if (stationSearcher.searchMode === "placeName") {
                        StationAPI.getLocations(stationSearcher.searchText, function(places) {
                            for (var i = 0; i < places.length; i++) {
                                availableCitiesModel.append({
                                    "placeName": places[i].city + "," + places[i].country,
                                    "latitude": places[i].latitude,
                                    "longitude": places[i].longitude
                                });
                            }
                        })
                    } else {
                        StationAPI.searchGeocode({lat: stationSearcher.searchLat, long: stationSearcher.searchLon}, function(stations) {
                            for (var i = 0; i < stations.length; i++) {
                                stationSearcher.searchResults.append({"stationID": stations[i].stationID, "placeName": stations[i].placeName, "latitude": stations[i].latitude, "longitude": stations[i].longitude, "selected": false});
                            }
                        })
                    }
                }
            }
        }

        Loader {
            id: searchHelpLoader
            Layout.fillWidth: true
            sourceComponent: stationSearcher.searchMode === "placeName" ? placeNameHelp : (stationSearcher.searchMode === "latlon" ? latLonHelp : stationIDHelp)
        }

        Component {
            id: placeNameHelp
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
                }

                QQC.Button {
                    text: i18n("Choose")
                    onClicked: {
                        StationAPI.searchGeocode({lat: availableCitiesModel.get(cityChoice.currentIndex).latitude, long: availableCitiesModel.get(cityChoice.currentIndex).longitude}, function(stations) {
                            for (var i = 0; i < stations.length; i++) {
                                stationSearcher.searchResults.append({"stationID": stations[i].stationID, "placeName": stations[i].placeName, "latitude": stations[i].latitude, "longitude": stations[i].longitude, "selected": false});
                            }
                        });
                    }
                }
            }
        }

        Component {
            id: latLonHelp

            PlasmaComponents.Label {
                text: i18n("Uses WGS84 geocode coordinates")
            }
        }

        Component {
            id: stationIDHelp

            PlasmaComponents.Label {
                text: i18n("Use exact stationID name")
            }
        }


        Component {
            id: textField
            QQC.TextField {
                Layout.fillWidth: true
                placeholderText: stationSearcher.searchMode === "stationID" ? i18n("Enter Station ID") : i18n("Enter Place Name")
                text: stationSearcher.searchText
                onTextChanged: stationSearcher.searchText = text
            }
        }
        Component {
            id: latlonFields
            RowLayout {
                Layout.fillWidth: true
                QQC.TextField {
                    placeholderText: "Latitude"
                    inputMethodHints: Qt.ImhFormattedNumbersOnly
                    text: stationSearcher.searchLat
                    onTextChanged: stationSearcher.searchLat = parseFloat(text)
                    Layout.preferredWidth: 80
                }
                QQC.TextField {
                    placeholderText: "Longitude"
                    inputMethodHints: Qt.ImhFormattedNumbersOnly
                    text: stationSearcher.searchLon
                    onTextChanged: stationSearcher.searchLon = parseFloat(text)
                    Layout.preferredWidth: 80
                }
            }
        }


        ListView {
            id: resultsView
            model: stationSearcher.searchResults
            delegate: RowLayout {
                spacing: 8
                PlasmaComponents.Label { text: stationID; Layout.preferredWidth: 120 }
                PlasmaComponents.Label { text: placeName; Layout.preferredWidth: 160 }
                PlasmaComponents.Label { text: latitude; Layout.preferredWidth: 80 }
                PlasmaComponents.Label { text: longitude; Layout.preferredWidth: 80 }
                QQC.Button {
                    text: "Select"
                    enabled: !selected
                    onClicked: {
                        selectedStation = stationSearcher.searchResults.get(index)
                        for (var i = 0; i < stationSearcher.searchResults.count; i++) {
                            stationSearcher.searchResults.setProperty(i, "selected", i === index);
                        }
                        printDebug("selected: " + JSON.stringify(stationSearcher.searchResults.get(index)))
                    }
                }
            }
            Layout.fillHeight: true
            Layout.fillWidth: true
            clip: true
        }

        RowLayout {
            id: buttonsRow

            Layout.alignment: Qt.AlignRight

            QQC.Button {
                icon.name: "dialog-ok"
                text: i18n("Confirm")
                enabled: selectedStation !== undefined
                onClicked: {
                    stationSelected(selectedStation)
                    stationSearcher.close()
                }
            }

            QQC.Button {
                icon.name: "dialog-cancel"
                text: i18n("Cancel")
                onClicked: {
                    stationSearcher.close()
                }
            }
        }
    }
}