/*
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

import QtQuick 2.9
import QtQuick.Layouts 1.3
import org.kde.plasma.plasmoid 2.0
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 3.0 as PlasmaComponents
import "../code/utils.js" as Utils

RowLayout {
    id: paintArea
    
    readonly property bool isShowNarrative: plasmoid.configuration.compactShowConditions && !inTray

    spacing: 5

    anchors.centerIn: parent

    function printDebug(msg) {
        if (plasmoid.configuration.logConsole) {console.log("[debug] [IconText.qml] " + msg)}
    }

    PlasmaCore.SvgItem {
        id: icon

        Layout.minimumWidth: theme.defaultFont.pixelSize
        Layout.minimumHeight: theme.defaultFont.pixelSize
        Layout.preferredWidth: Layout.preferredHeight
        Layout.preferredHeight: plasmoid.configuration.compactIconSize > 0 ? plasmoid.configuration.compactIconSize : 2.5 * sizehelper.height
        //all bets are off when user wants to tinker around with size:
        Layout.maximumWidth: Layout.maximumHeight
        Layout.maximumHeight: plasmoid.configuration.compactIconSize > 0 ? 3 * parent.height : parent.height
        

        svg: PlasmaCore.Svg {
            id: svg
            imagePath: plasmoid.file("", Utils.getIconForCodeAndStyle(iconCode, plasmoid.configuration.iconStyleChoice))
        }
    }

    PlasmaComponents.Label {
        id: conditionNarrativeLabel

        width: conditionNarrativeLabel.paintedWidth
        height: sizehelper.height

        visible: plasmoid.configuration.compactShowConditions && !inTray

        font {
            family: sizehelper.font.family
            weight: sizehelper.font.weight
            italic: sizehelper.font.italic
            underline: sizehelper.font.underline
            pixelSize: sizehelper.font.pixelSize
        }
        minimumPixelSize: sizehelper.minimumPixelSize

        wrapMode: Text.NoWrap

        smooth: true

        text: conditionNarrative ? conditionNarrative + "," : i18n("Loading...")
    }

    PlasmaComponents.Label {
        id: temperatureLabel

        width: temperatureLabel.paintedWidth
        height: sizehelper.height

        visible: !inTray

        font {
            family: sizehelper.font.family
            weight: sizehelper.font.weight
            italic: sizehelper.font.italic
            underline: sizehelper.font.underline
            pixelSize: sizehelper.font.pixelSize
        }
        minimumPixelSize: sizehelper.minimumPixelSize

        wrapMode: Text.NoWrap

        smooth: true

        text: appState == showDATA ? Utils.currentTempUnit(weatherData["details"]["temp"].toFixed(1)) : "---.-° X"
    }

    PlasmaComponents.Label {
        id: sizehelper
        height: Math.min(parent.height, 1 * theme.defaultFont.pixelSize)
        font.family: plasmoid.configuration.compactFamily
        font.weight: plasmoid.configuration.compactWeight ? Font.Bold : Font.Normal
        font.italic: plasmoid.configuration.compactItalic
        font.underline: plasmoid.configuration.compactUnderline
        font.pixelSize: plasmoid.configuration.compactPointSize > 0 ? plasmoid.configuration.compactPointSize : 1 * theme.defaultFont.pixelSize
        fontSizeMode: plasmoid.configuration.compactPointSize > 0 ? Text.FixedSize : Text.VerticalFit
        minimumPixelSize: 1
        visible: false 
    }
}
