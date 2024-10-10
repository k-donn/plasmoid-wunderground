/*
 * SPDX-FileCopyrightText: 2018 Friedrich W. H. Kossebau <kossebau@kde.org>
 *
 * SPDX-License-Identifier: GPL-2.0-or-later
 */

import QtQuick

import QtQuick.Layouts

import org.kde.plasma.core as PlasmaCore
import org.kde.kirigami as Kirigami
import org.kde.plasma.components as PlasmaComponents

GridLayout {
    id: iconAndTextRoot

    property alias iconSource: icon.source
    property alias text: label.text
    property alias active: icon.active

    readonly property int iconSize: plasmoid.formFactor === PlasmaCore.Types.Horizontal ? height : width
    readonly property int minimumIconSize: Kirigami.Units.iconSizes.small

    columnSpacing: 0
    rowSpacing: 0

    states: [
        State {
            name: "horizontalPanel"
            when: plasmoid.formFactor === PlasmaCore.Types.Horizontal

            PropertyChanges {
                target: iconAndTextRoot

                columns: 2
                rows: 1
            }

            PropertyChanges {
                target: icon

                Layout.fillWidth: false
                Layout.fillHeight: true

                Layout.minimumWidth: implicitMinimumIconSize
                Layout.minimumHeight: minimumIconSize
            }

            PropertyChanges {
                target: text

                Layout.fillWidth: false
                Layout.fillHeight: true

                Layout.minimumWidth: sizeHelper.paintedWidth
                Layout.maximumWidth: Layout.minimumWidth

                Layout.minimumHeight: 0
                Layout.maximumHeight: Infinity
            }

            PropertyChanges {
                target: sizeHelper

                font {
                    pixelSize: 1024
                }
                fontSizeMode: Text.VerticalFit
            }
        },

        State {
            name: "verticalPanel"
            when: plasmoid.formFactor === PlasmaCore.Types.Vertical

            PropertyChanges {
                target: iconAndTextRoot

                columns: 1
                rows: 2
            }

            PropertyChanges {
                target: icon

                Layout.fillWidth: true
                Layout.fillHeight: false

                Layout.minimumWidth: minimumIconSize
                Layout.minimumHeight: implicitMinimumIconSize
            }

            PropertyChanges {
                target: text

                Layout.fillWidth: true
                Layout.fillHeight: false

                Layout.minimumWidth: 0
                Layout.maximumWidth: Infinity

                Layout.minimumHeight: sizeHelper.paintedHeight
                Layout.maximumHeight: Layout.minimumHeight
            }

            PropertyChanges {
                target: sizeHelper

                font {
                    pixelSize: Kirigami.Units.gridUnit * 2
                }
                fontSizeMode: Text.HorizontalFit
            }
        }
    ]

    Kirigami.Icon {
        id: icon

        isMask: true

        readonly property int implicitMinimumIconSize: Math.max(iconSize, minimumIconSize)
        // reset implicit size, so layout in free dimension does not stop at the default one
        implicitWidth: minimumIconSize
        implicitHeight: minimumIconSize
    }

    Item {
        id: text

        // Otherwise it takes up too much space while loading
        visible: label.text.length > 0

        Text {
            id: sizeHelper

            font {
                family: label.font.family
                weight: label.font.weight
                italic: label.font.italic
            }
            minimumPixelSize: Math.round(Kirigami.Units.gridUnit / 2)
            wrapMode: Text.NoWrap

            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            anchors {
                leftMargin: Kirigami.Units.smallSpacing
                rightMargin: Kirigami.Units.smallSpacing
            }
            // These magic values are taken from the digital clock, so that the
            // text sizes here are identical with various clock text sizes
            height: {
                const textHeightScaleFactor = (parent.height > 26) ? 0.7 : 0.9;
                return Math.min (parent.height * textHeightScaleFactor, 3 * Kirigami.Theme.defaultFont.pixelSize);
            }
            visible: false

            // pattern to reserve some constant space TODO: improve and take formatting/i18n into account
            text: "888° X"
            textFormat: Text.PlainText
        }

        PlasmaComponents.Label {
            id: label

            font {
                weight: Font.Normal
                pixelSize: 1024
            }
            minimumPixelSize: Math.round(Kirigami.Units.gridUnit / 2)
            fontSizeMode: Text.Fit
            textFormat: Text.PlainText
            wrapMode: Text.NoWrap

            height: 0
            width: 0
            verticalAlignment: Text.AlignVCenter
            horizontalAlignment: Text.AlignHCenter
            anchors {
                fill: parent
                leftMargin: Kirigami.Units.smallSpacing
                rightMargin: Kirigami.Units.smallSpacing
            }
        }
    }

    Component.onCompleted: {
        console.log("icon painted width: " + icon.paintedWidth);
        console.log("icon width: " + icon.Layout.minimumWidth);
        console.log("text painted width: " + text.paintedWidth);
        console.log("text width: " + text.Layout.minimumWidth);
        console.log("label painted width: " + label.paintedWidth);
        console.log("label width: " + label.width);
        console.log("iconAndTextRoot painted width: " + iconAndTextRoot.paintedWidth);
        console.log("iconAndTextRoot width: " + iconAndTextRoot.width);

    }
}
