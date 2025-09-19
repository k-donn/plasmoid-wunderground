import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as QQC
import org.kde.kirigami as Kirigami
import org.kde.plasma.core as PlasmaCore
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

    function clearError() {
        errText.visible = false;
        errText.text = "";
    }

    function setError(errorObj) {
        errText.visible = true;
        errText.text = "Error: " + errorObj.type + " message: " + errorObj.message;
    }

    title: i18n("Find Station")
    color: syspal.window

    property string searchMode: "stationID"
    property string searchText: ""
    property var selectedStation
    property real searchLat: 0
    property real searchLon: 0

    property ListModel searchResults: ListModel {}
    property ListModel availableCitiesModel: ListModel {}

    onOpen: {
        stationSearcher.visible = true;
        clearError();

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
                QQC.Label { text: i18n("Search by:") }
                QQC.ComboBox {
                    id: modeCombo
                    model: [ i18n("Weatherstation ID:"), i18n("Place Name"), i18n("Lat/Lon") ]
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
                enabled: (stationSearcher.searchMode === "stationID" || stationSearcher.searchMode === "placeName") ? stationSearcher.searchText.length > 0 : true
                onClicked: {
                    if (stationSearcher.searchMode === "stationID") {
                        StationAPI.searchStationID(stationSearcher.searchText, function(stations, error) {
                            if (error) {
                                setError(error);
                            } else {
                                clearError();
                                for (var i = 0; i < stations.length; i++) {
                                    stationSearcher.searchResults.append({"stationID": stations[i].stationID, "placeName": stations[i].placeName, "latitude": stations[i].latitude, "longitude": stations[i].longitude, "selected": false});
                                }
                            }
                        });
                    } else if (stationSearcher.searchMode === "placeName") {
                        StationAPI.getLocations(stationSearcher.searchText, function(places, error) {
                            if (error) {
                                setError(error);
                            } else {
                                clearError();
                                for (var i = 0; i < places.length; i++) {
                                    availableCitiesModel.append({
                                        "placeName": places[i].city + "," + places[i].country,
                                        "latitude": places[i].latitude,
                                        "longitude": places[i].longitude
                                    });
                                }
                            }
                        });
                    } else {
                        StationAPI.searchGeocode({latitude: stationSearcher.searchLat, longitude: stationSearcher.searchLon}, function(stations, error) {
                            if (error) {
                                setError(error);
                            } else {
                                clearError();
                                for (var i = 0; i < stations.length; i++) {
                                    stationSearcher.searchResults.append({"stationID": stations[i].stationID, "placeName": stations[i].placeName, "latitude": stations[i].latitude, "longitude": stations[i].longitude, "selected": false});
                                }
                            }
                        });
                    }
                }
            }
        }

        Loader {
            id: searchHelpLoader
            Layout.fillWidth: true
            sourceComponent: stationSearcher.searchMode === "placeName" ? placeNameHelp : (stationSearcher.searchMode === "latlon" ? latLonHelp : stationIDHelp)
        }

        PlasmaComponents.Label {
            id: errText
            visible: false
            Layout.fillWidth: true
            clip: true
            elide: Text.ElideRight

            PlasmaCore.ToolTipArea {
                anchors.fill: parent

                subText: errText.text
            }
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
                    enabled: availableCitiesModel.count > 0
                }

                QQC.Button {
                    text: i18n("Choose")
                    enabled: cityChoice.currentIndex !== -1
                    onClicked: {
                        StationAPI.searchGeocode({latitude: availableCitiesModel.get(cityChoice.currentIndex).latitude, longitude: availableCitiesModel.get(cityChoice.currentIndex).longitude}, function(stations) {
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
                text: i18n("Use Station ID, not city name. Select 'Search by: Place Name' to search by city.")
            }
        }


        Component {
            id: textField
            QQC.TextField {
                Layout.fillWidth: true
                placeholderText: stationSearcher.searchMode === "stationID" ? i18n("Enter Station") : i18n("Enter Place Name")
                onTextChanged: stationSearcher.searchText = text.trim()
            }
        }
        Component {
            id: latlonFields
            RowLayout {
                Layout.fillWidth: true
                QQC.TextField {
                    Layout.fillWidth: true
                    placeholderText: i18n("Latitude:")
                    inputMethodHints: Qt.ImhFormattedNumbersOnly
                    onTextChanged: stationSearcher.searchLat = parseFloat(text.trim())
                }
                QQC.TextField {
                    Layout.fillWidth: true
                    placeholderText: i18n("Longitude:")
                    inputMethodHints: Qt.ImhFormattedNumbersOnly
                    onTextChanged: stationSearcher.searchLon = parseFloat(text.trim())
                }
            }
        }


        RowLayout {
            Layout.fillWidth: true
            spacing: 6
            PlasmaComponents.Label { text: i18n("Weatherstation ID:"); Layout.fillWidth: true; Layout.preferredWidth: 2 }
            PlasmaComponents.Label { text: i18n("Weatherstation Name:"); Layout.fillWidth: true; Layout.preferredWidth: 2 }
            PlasmaComponents.Label { text: i18n("Latitude:"); Layout.fillWidth: true; Layout.preferredWidth: 1 }
            PlasmaComponents.Label { text: i18n("Longitude:"); Layout.fillWidth: true; Layout.preferredWidth: 1 }
            PlasmaComponents.Label { text: "" ; Layout.fillWidth: true; Layout.preferredWidth: 1 }
        }

        ListView {
            id: resultsView
            model: stationSearcher.searchResults
            delegate: RowLayout {
                spacing: 8
                width: ListView.view.width

                PlasmaComponents.Label { text: stationID; Layout.fillWidth: true; Layout.preferredWidth: 2; elide: Text.ElideRight; clip: true }
                PlasmaComponents.Label { text: placeName; Layout.fillWidth: true; Layout.preferredWidth: 2; elide: Text.ElideRight; clip: true }
                PlasmaComponents.Label { text: latitude; Layout.fillWidth: true; Layout.preferredWidth: 1; elide: Text.ElideRight; clip: true }
                PlasmaComponents.Label { text: longitude; Layout.fillWidth: true; Layout.preferredWidth: 1; elide: Text.ElideRight; clip: true }
                QQC.Button {
                    text: "Select"
                    enabled: !selected
                    Layout.fillWidth: true
                    Layout.preferredWidth: 1
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