import QtQuick 2.0
import QtQuick.Layouts 1.0
import QtQuick.Controls 2.0
import org.kde.plasma.plasmoid 2.0
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as PlasmaComponents
import "../code/format-data.js" as FormatData
import "../code/pws-api.js" as StationAPI

Item {
    width: parent.width
    height: parent.height

    GridLayout {
        id: grid

        columns: 3
        columnSpacing: parent.width / 10

        rows: 4

        visible: showData

        PlasmaComponents.Label {
            id: temp
            text: weatherData["imperial"]["temp"].toFixed(1) + "° F"
            font {
                bold: true
                pointSize: 30
            }
            color: "#D72A36"
        }
        PlasmaComponents.Label {
            id: windDir
            text: "Wind dir:" + weatherData["winddir"] + "°"
        }
        PlasmaComponents.Label {
            id: windLabel
            text: "WIND & GUST"
            font {
                bold: true
                pointSize: 13
            }
        }

        PlasmaComponents.Label {
            id: feelsLike
            text: "Feels like " + FormatData.heatIndex(weatherData["imperial"]["temp"], weatherData["humidity"]) + "° F"
        }
        PlasmaComponents.Label {
            id: windDirCard
            text: FormatData.windDirToCard(weatherData["winddir"])
        }
        PlasmaComponents.Label {
            id: wind
            text: weatherData["imperial"]["windSpeed"] + " / " + weatherData["imperial"]["windGust"] + " mph"
        }


        PlasmaComponents.Label {
            id: dewLabel
            text: "DEWPOINT"
            font {
                bold: true
                pointSize: 13
            }
        }
        PlasmaComponents.Label {
            id: precipRateLabel
            text: "PRECIP RATE"
            font {
                bold: true
                pointSize: 13
            }
        }
        PlasmaComponents.Label {
            id: pressureLabel
            text: "PRESSURE"
            font {
                bold: true
                pointSize: 13
            }
        }

        PlasmaComponents.Label {
            id: dew
            text: weatherData["imperial"]["dewpt"] + "° F"
            font.pointSize: 10
        }
        PlasmaComponents.Label {
            id: precipRate
            text: weatherData["imperial"]["precipRate"] + " in/hr"
            font.pointSize: 10
        }
        PlasmaComponents.Label {
            id: pressure
            text: weatherData["imperial"]["pressure"] + " inHG"
            font.pointSize: 10
        }

        PlasmaComponents.Label {
            id: humidityLabel
            text: "HUMIDITY"
            font {
                bold: true
                pointSize: 13
            }
        }
        PlasmaComponents.Label {
            id: precipAccLabel
            text: "PRECIP ACCUM"
            font {
                bold: true
                pointSize: 13
            }
        }
        PlasmaComponents.Label {
            id: uvLabel
            text: "UV"
            font {
                bold: true
                pointSize: 13
            }
        }

        PlasmaComponents.Label {
            id: humidity
            text: weatherData["humidity"] + "%"
        }
        PlasmaComponents.Label {
            id: precipAcc
            text: weatherData["imperial"]["precipTotal"] + " in"
        }
        PlasmaComponents.Label {
            id: uv
            text: weatherData["uv"]
        }
    }

    PlasmaComponents.Label {
        id: updatedAt
        anchors {
            right: parent.right
            bottom: parent.bottom
        }
        text: weatherData["obsTimeLocal"]
        verticalAlignment: Text.AlignBottom
    }

    PlasmaComponents.Label {
        id: currStation
        anchors {
            left: parent.left
            bottom: parent.bottom
        }
        text: weatherData["stationID"]
        verticalAlignment: Text.AlignBottom
    }
}
