/*
 * SPDX-FileCopyrightText: 2018 Friedrich W. H. Kossebau <kossebau@kde.org>
 *
 * SPDX-License-Identifier: GPL-2.0-or-later
 */


import QtQuick 2.9
import QtQuick.Layouts 1.3

import org.kde.plasma.plasmoid 2.0
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 3.0 as PlasmaComponents

GridLayout {
    id: iconAndTextRoot

    property alias iconSource: svg.imagePath
    property alias text: label.text
    property bool vertical: false

    property alias paintWidth: sizeHelper.paintedWidth
    property alias paintHeight: sizeHelper.paintedHeight

    readonly property int minimumIconSize: units.iconSizes.small
    readonly property int iconSize: iconAndTextRoot.vertical ? width : height

    columns: iconAndTextRoot.vertical ? 1 : 2
    rows: iconAndTextRoot.vertical ? 2 : 1

    columnSpacing: 0
    rowSpacing: 0

    function printDebug(msg) {
        console.log("[debug] " + msg)
    }

    onPaintWidthChanged: {
        // TODO: use property binding or states inside of "text" instead of this?
        text.Layout.minimumWidth = iconAndTextRoot.vertical ? 0 : sizeHelper.paintedWidth
        text.Layout.maximumWidth = iconAndTextRoot.vertical ? Infinity : text.Layout.minimumWidth

        text.Layout.minimumHeight = iconAndTextRoot.vertical ? sizeHelper.paintedHeight : 0
        text.Layout.maximumHeight = iconAndTextRoot.vertical ? text.Layout.minimumHeight : Infinity

        // Loaded within scope of compactRoot; can access compactRoot properties!
        compactRoot.Layout.minimumWidth = (text.Layout.minimumWidth + icon.Layout.minimumWidth)
    }

    PlasmaCore.SvgItem {
        id: icon

        readonly property int implicitMinimumIconSize: Math.max(iconSize, minimumIconSize)
        // reset implicit size, so layout in free dimension does not stop at the default one
        implicitWidth: minimumIconSize
        implicitHeight: minimumIconSize

        svg: PlasmaCore.Svg {
            id: svg
        }

        Layout.fillWidth: iconAndTextRoot.vertical
        Layout.fillHeight: !iconAndTextRoot.vertical
        Layout.minimumWidth: iconAndTextRoot.vertical ? minimumIconSize : implicitMinimumIconSize
        Layout.minimumHeight: iconAndTextRoot.vertical ? implicitMinimumIconSize : minimumIconSize
    }

    Item {
        id: text

        // Otherwise it takes up too much space while loading
        visible: label.text.length > 0

        Layout.fillWidth: iconAndTextRoot.vertical
        Layout.fillHeight: !iconAndTextRoot.vertical
        Layout.minimumWidth: iconAndTextRoot.vertical ? 0 : sizeHelper.paintedWidth
        Layout.maximumWidth: iconAndTextRoot.vertical ? Infinity : Layout.minimumWidth

        Layout.minimumHeight: iconAndTextRoot.vertical ? sizeHelper.paintedHeight : 0
        Layout.maximumHeight: iconAndTextRoot.vertical ? Layout.minimumHeight : Infinity

        Text {
            id: sizeHelper

            font {
                family: label.font.family
                weight: label.font.weight
                italic: label.font.italic
                pixelSize: plasmoid.configuration.compactPointSize
            }
            minimumPixelSize: theme.mSize(theme.smallestFont).height / 2
            fontSizeMode: iconAndTextRoot.vertical ? Text.Fit : Text.FixedSize
            wrapMode: Text.NoWrap

            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            anchors {
                leftMargin: units.smallSpacing
                rightMargin: units.smallSpacing
            }
            
            height: {
                var textHeightScaleFactor = 0.7;
                if (parent.height <= 26) {
                    textHeightScaleFactor = 0.9;
                }
                return Math.min (parent.height * textHeightScaleFactor, 3 * theme.defaultFont.pixelSize);
            }

            visible: false

            // pattern to reserve some constant space TODO: improve and take formatting/i18n into account
            text: "888.8 °X"
        }

        PlasmaComponents.Label {
            id: label

            font {
                weight: Font.Normal
                pixelSize: plasmoid.configuration.compactPointSize
            }

            minimumPixelSize: theme.mSize(theme.smallestFont).height / 2
            // If vertical, cap the max font size. Else, use user defined size even if crazy.
            fontSizeMode: iconAndTextRoot.vertical ? Text.Fit : Text.FixedSize
            wrapMode: Text.NoWrap

            height: 0
            width: 0
            verticalAlignment: Text.AlignVCenter
            horizontalAlignment: Text.AlignHCenter

            anchors {
                fill: parent
                leftMargin: units.smallSpacing
                rightMargin: units.smallSpacing
            }
        }
    }
}
