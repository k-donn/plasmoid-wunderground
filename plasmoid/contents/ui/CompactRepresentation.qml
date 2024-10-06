/*
 * SPDX-FileCopyrightText: 2018 Friedrich W. H. Kossebau <kossebau@kde.org>
 *
 * SPDX-License-Identifier: GPL-2.0-or-later
 */

import QtQuick
import QtQuick.Layouts
import org.kde.plasma.plasmoid
import org.kde.kirigami as Kirigami
import org.kde.plasma.core as PlasmaCore
import "../code/utils.js" as Utils

Loader {
    id: compactRoot

    readonly property bool vertical: Plasmoid.formFactor == PlasmaCore.Types.Vertical
    readonly property bool showTemperature: !inTray

    sourceComponent: showTemperature ? iconAndTextComponent : iconComponent

    function printDebug(msg) {
        if (plasmoid.configuration.logConsole) {
            console.log("[debug] [CompactRep.qml] " + msg);
        }
    }

    Layout.fillWidth: compactRoot.vertical
    Layout.fillHeight: !compactRoot.vertical
    Layout.minimumWidth: item.Layout.minimumWidth
    Layout.minimumHeight: item.Layout.minimumHeight

    MouseArea {
        id: compactMouseArea
        anchors.fill: parent

        hoverEnabled: true

        onClicked: {
            root.expanded = !root.expanded;
        }
    }

    Component {
        id: iconAndTextComponent

        IconAndTextItem {
            vertical: compactRoot.vertical
            iconSource: Utils.getConditionIcon(iconCode)
            text: appState == showDATA ? Utils.currentTempUnit(Utils.toUserTemp(weatherData["details"]["temp"])) : "--- °X"
        }
    }

    Component {
        id: iconComponent

        Kirigami.Icon {
            readonly property int minIconSize: Math.max((compactRoot.vertical ? compactRoot.width : compactRoot.height), Kirigami.Units.iconSizes.small)

            source: Utils.getConditionIcon(iconCode)
            active: compactMouseArea.containsMouse
            // reset implicit size, so layout in free dimension does not stop at the default one
            implicitWidth: Kirigami.Units.iconSizes.small
            implicitHeight: Kirigami.Units.iconSizes.small
            Layout.minimumWidth: compactRoot.vertical ? Kirigami.Units.iconSizes.small : minIconSize
            Layout.minimumHeight: compactRoot.vertical ? minIconSize : Kirigami.Units.iconSizes.small
        }
    }

}
