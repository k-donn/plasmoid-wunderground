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

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import org.kde.plasma.plasmoid
import org.kde.ksvg as KSvg
import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.components as PlasmaComponents
import "../code/utils.js" as Utils

RowLayout {
    id: forecastItemRoot

    readonly property int preferredIconSize: units.iconSizes.large

    Repeater {
        id: repeater

        model: forecastModel
        ColumnLayout {
            PlasmaComponents.Label {
                Layout.alignment: Qt.AlignVCenter | Qt.AlignHCenter

                text: date
            }
            PlasmaComponents.Label {
                Layout.alignment: Qt.AlignVCenter | Qt.AlignHCenter

                text: dayOfWeek
            }
            PlasmaComponents.Label {
                Layout.alignment: Qt.AlignVCenter | Qt.AlignHCenter

                text: shortDesc
            }
            KSvg.SvgItem {
                id: icon

                Layout.alignment: Qt.AlignVCenter | Qt.AlignHCenter

                Layout.preferredHeight: preferredIconSize
                Layout.preferredWidth: preferredIconSize

                svg: KSvg.Svg {
                    imagePath: plasmoid.file("", "icons/" + iconCode + ".svg")
                }

                PlasmaCore.ToolTipArea {
                    id: tooltip

                    mainText: longDesc
                    subText: "<font size='4'>" + "Feels like: " + Utils.currentTempUnit(feelsLike) + "<br/>Thunder: " + thunderDesc + "<br/>UV: " + UVDesc + "<br/>Snow: " + snowDesc + "<br/>Golf: " + golfDesc + "</font>"

                    interactive: true

                    anchors.fill: parent
                }
            }
            PlasmaComponents.Label {
                Layout.alignment: Qt.AlignVCenter | Qt.AlignHCenter

                text: Utils.currentTempUnit(high)
            }
            PlasmaComponents.Label {
                Layout.alignment: Qt.AlignVCenter | Qt.AlignHCenter

                text: Utils.currentTempUnit(low)
            }
        }
    }
}
