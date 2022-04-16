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

ColumnLayout {
    id: paintArea
    
    readonly property bool isShowNarrative: plasmoid.configuration.compactShowConditions && !inTray

    spacing: 5

    anchors.centerIn: parent

    function printDebug(msg) {
        if (plasmoid.configuration.logConsole) {console.log("[debug] [IconText.qml] " + msg)}
    }

    PlasmaCore.SvgItem {
        id: icon

        width: icon.paintedWidth
        height: width        

        svg: PlasmaCore.Svg {
            id: svg
            imagePath: plasmoid.file("", Utils.getIconForCodeAndStyle(iconCode, plasmoid.configuration.iconStyleChoice))
        }
    }
}
