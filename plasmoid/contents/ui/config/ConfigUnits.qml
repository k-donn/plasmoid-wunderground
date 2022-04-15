/*
 * Copyright 2021  Kevin Donnelly
 * Copyright 2022  Rafal (Raf) Liwoch
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
import org.kde.plasma.components 2.0 as PlasmaComponents
import org.kde.kirigami 2.4 as Kirigami

Item {
    id: unitsConfig

    property alias cfg_unitsChoice: unitsChoice.currentIndex
    property alias cfg_dateFormatChoice: dateFormatChoice.text
    property alias cfg_timeFormatChoice: timeFormatChoice.text
    

    Kirigami.FormLayout {
        anchors.fill: parent

    
        ComboBox {
            id: unitsChoice

            width: 100
            model: [i18nc("The unit system", "Metric"), i18nc("The unit system", "Imperial"), i18nc("The unit system", "Hybrid (UK)")]

            Kirigami.FormData.label: i18n("Choose:")
        }
    
        TextField {
            id: dateFormatChoice
            placeholderText: "dd/MM"
    
            Kirigami.FormData.label: i18n("Date format:")
        }
    
        TextField {
            id: timeFormatChoice
            placeholderText: "HH:mm"
    
            Kirigami.FormData.label: i18n("Time format:")
        }
        PlasmaComponents.Label {
            id: examplesLabel

            text: "Date/Time format examples: \n dd/MM -> 31/12\n MM/dd -> 12/31\n HH:mm -> 13:00\n h a -> 1 pm\n h:mm a -> 1:30 pm"
            font {
                pointSize: textSize.small
            }
        }        
    }

}
