/*
* Copyright 2022 Rafal (Raf) Liwoch
*
* This program is free software; you can redistribute it and/or modify
* it under the terms of the GNU Library General Public License as
* published by the Free Software Foundation; either version 2, or
* (at your option) any later version.
*
* This program is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
* GNU Library General Public License for more details
*
* You should have received a copy of the GNU Library General Public
* License along with this program; if not, write to the
* Free Software Foundation, Inc.,
* 51 Franklin Street, Fifth Floor, Boston, MA 2.010-1301, USA.
*/

import QtQuick 2.0
import QtQuick.Layouts 1.1
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as PlasmaComponents
import org.kde.plasma.extras 2.0 as PlasmaExtras
import "../code/utils.js" as Utils

Item {
    id: tooltipContentItem

    property int preferredTextWidth: units.gridUnit * 20

    width: childrenRect.width + units.gridUnit
    height: childrenRect.height + units.gridUnit

        RowLayout {
            anchors {
                left: parent.left
                top: parent.top
                margins: units.gridUnit / 2
            }

            spacing: units.largeSpacing

            PlasmaCore.SvgItem {
                id: tooltipIconContainer
                Layout.alignment: Qt.AlignVCenter | Qt.AlignHCenter
                svg: PlasmaCore.Svg {
                id: tooltipIcon
                imagePath: iconCode !== null ? Utils.getIconForCodeAndStyle(iconCode, plasmoid.configuration.iconStyleChoice) : plasmoid.file("", "icons/wi-na.svg")
            }

            implicitWidth: units.iconSizes.medium
            Layout.preferredWidth: implicitWidth
            Layout.preferredHeight: implicitWidth
        }

        ColumnLayout {

            PlasmaExtras.Heading {
                id: narrativeHeading
                level: 3
                Layout.minimumWidth: Math.min(implicitWidth, preferredTextWidth)
                Layout.maximumWidth: preferredTextWidth
                elide: Text.ElideRight
                text: conditionNarrative
            }

            PlasmaComponents.Label {
                id: tempsub
                Layout.minimumWidth: Math.min(implicitWidth, preferredTextWidth)
                Layout.maximumWidth: preferredTextWidth
                text: `${dictVals["temperature"].name}: <b>${flatWeatherData.temp}</b>`
                opacity: 1
            }
            PlasmaComponents.Label {
                id: feelsLikeSub
                Layout.minimumWidth: Math.min(implicitWidth, preferredTextWidth)
                Layout.maximumWidth: preferredTextWidth
                text: i18n("Real feel") + ": " + Utils.feelsLike(flatWeatherData.temp, flatWeatherData.humidity, flatWeatherData.windSpeed)
                opacity: 0.6
            }            

            Repeater {
                model: currentDetailsModel
                Layout.topMargin: units.gridUnit * 2

                PlasmaComponents.Label {
                    id: metric
                    wrapMode: Text.NoWrap
                    text: `${dictVals[name].name}: ${Utils.getValue(name, val, val2)}`
                    height: paintedHeight
                    elide: Text.ElideNone
                    opacity: 0.6
                }
            }

        }
    }
}
