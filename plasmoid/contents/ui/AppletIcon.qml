import QtQuick 2.0
import QtQuick.Layouts 1.0
import org.kde.plasma.core 2.0 as PlasmaCore

Item {
    id: appletIcon
    property string source: ''
    property bool active: false
    readonly property bool usingPackageSvg: filename // plasmoid.file() returns "" if file doesn't exist.
    readonly property string filename: source ? plasmoid.file('', 'icons/' + source + '.svg') : ''
    readonly property int minSize: Math.min(width, height)
    property bool smooth: true

    ColumnLayout {
        width: parent.width
        height: parent.height

        PlasmaCore.IconItem {
            Layout.fillWidth: true
            Layout.fillHeight: true
            visible: !appletIcon.usingPackageSvg
            source: appletIcon.usingPackageSvg ? '' : appletIcon.source
            active: appletIcon.active
            smooth: appletIcon.smooth
        }
    }

    PlasmaCore.SvgItem {
        id: svgItem
        readonly property real minSize: Math.min(naturalSize.width, naturalSize.height)
        readonly property real widthRatio: naturalSize.width / svgItem.minSize
        readonly property real heightRatio: naturalSize.height / svgItem.minSize
        width: appletIcon.minSize * widthRatio
        height: appletIcon.minSize * heightRatio

        smooth: appletIcon.smooth

        visible: appletIcon.usingPackageSvg
        svg: PlasmaCore.Svg {
            id: svg
            imagePath: appletIcon.filename
        }
    }
}
