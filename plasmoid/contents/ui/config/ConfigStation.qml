/*
 * Copyright 2020  Kevin Donnelly
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
import QtQuick 2.0
import QtQuick.Controls 2.0
import QtQuick.Layouts 1.0
import org.kde.plasma.extras 2.0 as PlasmaExtras
import org.kde.plasma.components 2.0 as PlasmaComponents
import org.kde.kirigami 2.4 as Kirigami
import "../../code/pws-api.js" as StationAPI

Item {
    id: stationConfig

    property alias cfg_stationID: stationID.text

    function printDebug(msg) {
        console.log("[debug] " + msg)
    }

    Kirigami.FormLayout {
        anchors.fill: parent

        Kirigami.Heading {
            text: "Enter Station"
            level: 2
        }

        ClearableField {
            id: stationID
            placeholderText: "KGADACUL1"

            Kirigami.FormData.label: "Weatherstation ID:"
        }

        Spacer {}

        Kirigami.Heading {
            text: "Get Nearest Station"
            level: 2
        }

        Kirigami.Heading {
            text: "Uses WGS84 geocode coordinates"
            level: 5
        }

        NoApplyField {
            configKey: "longitude"
            placeholderText: "-83.905502"

            Kirigami.FormData.label: "Longitude:"
        }

        NoApplyField {
            configKey: "latitude"
            placeholderText: "34.0602"

            Kirigami.FormData.label: "Latitude:"
        }

        Button {
            text: "Find Station"
            onClicked: StationAPI.getNearestStation()
        }

        PlasmaComponents.Label {
            text: "Version 1.3.1"
        }
    }

}