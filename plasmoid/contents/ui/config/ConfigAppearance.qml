/*
 * Copyright 2021  Kevin Donnelly
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
    id: appearanceConfig

    property alias cfg_compactPointSize: compactPointSize.value
    property alias cfg_propHeadPointSize: propHeadPointSize.value
    property alias cfg_propPointSize: propPointSize.value
    property alias cfg_tempPointSize: tempPointSize.value

    Kirigami.FormLayout {
        anchors.fill: parent

        Kirigami.Heading {
            Layout.fillWidth: true
            level: 2
            text: "Compact Representation"
        }

        ConfigFontFamily {
            id: compactFontFamily

            configKey: "compactFamily"

            Kirigami.FormData.label: "Font"
        }

        SpinBox {
            id: compactPointSize

            editable: true

            Kirigami.FormData.label: "Font size (0px=scale)"
        }

        ConfigTextFormat {
            Kirigami.FormData.label: "Font styles"
        }

        Kirigami.Separator {}

        Kirigami.Heading {
            Layout.fillWidth: true
            level: 2
            text: "Full Representation"
        }

        SpinBox {
            id: propHeadPointSize

            editable: true

            Kirigami.FormData.label: "Property header text size"
        }

        SpinBox {
            id: propPointSize

            editable: true

            Kirigami.FormData.label: "Property text size"
        }

        SpinBox {
            id: tempPointSize

            editable: true

            Kirigami.FormData.label: "Temperature text size"
        }

    }
}