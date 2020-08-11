import QtQuick 2.0
import QtQuick.Controls 2.0
import org.kde.kirigami 2.4 as Kirigami

Item {
    id: stationConfig

    property alias cfg_stationID: stationID.text

    Kirigami.FormLayout {
        anchors {
            left: parent.left
            right: parent.right
        }

        TextField {
            id: stationID
            Kirigami.FormData.label: "Weatherstation ID:"
        }
    }

}
