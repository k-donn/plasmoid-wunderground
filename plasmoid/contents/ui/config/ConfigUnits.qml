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
import org.kde.kcmutils as KCM
import org.kde.kirigami as Kirigami

KCM.SimpleKCM {
    id: unitsConfig

    property alias cfg_unitsChoice: unitsChoice.currentIndex
    property alias cfg_windUnitsChoice: windUnitsChoice.currentIndex
    property alias cfg_rainUnitsChoice: rainUnitsChoice.currentIndex
    property alias cfg_snowUnitsChoice: snowUnitsChoice.currentIndex
    property alias cfg_tempUnitsChoice: tempUnitsChoice.currentIndex
    property alias cfg_presUnitsChoice: presUnitsChoice.currentIndex
    property alias cfg_elevUnitsChoice: elevUnitsChoice.currentIndex

    Kirigami.FormLayout {
        anchors.fill: parent

        ComboBox {
            id: unitsChoice

            width: 100
            model: [i18nc("The unit system", "Metric"), i18nc("The unit system", "Imperial"), i18nc("The unit system", "Hybrid (UK)"), i18n("Custom")]

            Kirigami.FormData.label: i18n("Choose:")
        }

        Kirigami.Separator {
            Kirigami.FormData.label: ""
            Kirigami.FormData.isSection: true
            visible: unitsChoice.currentIndex == 3
        }

        ComboBox {
            id: windUnitsChoice

            visible: unitsChoice.currentIndex == 3

            model: ["kmh", "mph", "m/s"]

            Kirigami.FormData.label: i18n("Wind unit:")
        }

        ComboBox {
            id: rainUnitsChoice

            visible: unitsChoice.currentIndex == 3

            model: ["mm", "in", "cm"]

            Kirigami.FormData.label: i18n("Rain unit:")
        }

        ComboBox {
            id: snowUnitsChoice

            visible: unitsChoice.currentIndex == 3

            model: ["mm", "in", "cm"]

            Kirigami.FormData.label: i18n("Snow unit:")
        }

        ComboBox {
            id: tempUnitsChoice

            visible: unitsChoice.currentIndex == 3

            model: ["C", "F", "K"]

            Kirigami.FormData.label: i18n("Temperature unit:")
        }

        ComboBox {
            id: presUnitsChoice

            visible: unitsChoice.currentIndex == 3

            model: ["mb", "inHG", "mmHG", "hPa"]

            Kirigami.FormData.label: i18n("Pressure unit:")
        }

        ComboBox {
            id: elevUnitsChoice

            visible: unitsChoice.currentIndex == 3

            model: ["m", "ft"]

            Kirigami.FormData.label: i18n("Elevation unit:")
        }
    }
}
