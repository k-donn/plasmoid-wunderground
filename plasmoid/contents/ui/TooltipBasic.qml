/*
 *   Copyright 2022 Rafal (Raf) Liwoch
 *
 *   This program is free software; you can redistribute it and/or modify
 *   it under the terms of the GNU Library General Public License as
 *   published by the Free Software Foundation; either version 2, or
 *   (at your option) any later version.
 *
 *   This program is distributed in the hope that it will be useful,
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *   GNU Library General Public License for more details
 *
 *   You should have received a copy of the GNU Library General Public
 *   License along with this program; if not, write to the
 *   Free Software Foundation, Inc.,
 *   51 Franklin Street, Fifth Floor, Boston, MA  2.010-1301, USA.
 */

import QtQuick 2.0
import QtQuick.Layouts 1.1
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as PlasmaComponents
import org.kde.plasma.extras 2.0 as PlasmaExtras
import org.kde.plasma.private.digitalclock 1.0

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

        ColumnLayout {

            PlasmaExtras.Heading {
                id: tooltipMaintext
                level: 3
                Layout.minimumWidth: Math.min(implicitWidth, preferredTextWidth)
                Layout.maximumWidth: preferredTextWidth
                elide: Text.ElideRight
                text: applicationStateText
            }
        }
    }
}
