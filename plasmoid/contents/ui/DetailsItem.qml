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

import QtQuick 2.0
import QtQuick.Layouts 1.0
import QtQuick.Controls 2.0
import org.kde.plasma.plasmoid 2.0
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as PlasmaComponents
import "../code/utils.js" as Utils

GridLayout {
    id: detailsRoot

    columns: 3
    rows: 4

    PlasmaComponents.Label {
        id: temp
        text: Utils.currentTempUnit(weatherData["details"]["temp"])
        font {
            bold: true
            pointSize: plasmoid.configuration.tempPointSize
        }
        color: Utils.heatColor(weatherData["details"]["temp"])
    }
    PlasmaCore.SvgItem {
        id: topPanelIcon

        svg: PlasmaCore.Svg {
            id: svg
            imagePath: plasmoid.file("", "icons/wind-barbs/" + Utils.getWindBarb(weatherData["details"]["windSpeed"]) + ".svg")
        }

        rotation: weatherData["winddir"] - 270

        Layout.minimumWidth: units.iconSizes.large
        Layout.minimumHeight: units.iconSizes.large
        Layout.preferredWidth: Layout.minimumWidth
        Layout.preferredHeight: Layout.minimumHeight
    }
    PlasmaComponents.Label {
        id: windLabel
        text: i18n("WIND & GUST")
        font {
            bold: true
            pointSize: plasmoid.configuration.propHeadPointSize
        }
    }

    PlasmaComponents.Label {
        id: feelsLike
        text: i18n("Feels like %1", Utils.currentTempUnit(Utils.feelsLike(weatherData["details"]["temp"], weatherData["humidity"], weatherData["details"]["windSpeed"])))
        font.pointSize: plasmoid.configuration.propPointSize
    }
    PlasmaComponents.Label {
        id: windDirCard
        text: i18n("Wind from: %1", Utils.windDirToCard(weatherData["winddir"]))
        font.pointSize: plasmoid.configuration.propPointSize
    }
    PlasmaComponents.Label {
        id: wind
        text: weatherData["details"]["windSpeed"] + " / " + Utils.currentSpeedUnit(weatherData["details"]["windGust"])
        font.pointSize: plasmoid.configuration.propPointSize
    }


    PlasmaComponents.Label {
        id: dewLabel
        text: i18n("DEWPOINT")
        font {
            bold: true
            pointSize: plasmoid.configuration.propHeadPointSize
        }
    }
    PlasmaComponents.Label {
        id: precipRateLabel
        text: i18nc("Precipitaion rate", "PRECIP RATE")
        font {
            bold: true
            pointSize: plasmoid.configuration.propHeadPointSize
        }
    }
    PlasmaComponents.Label {
        id: pressureLabel
        text: i18n("PRESSURE")
        font {
            bold: true
            pointSize: plasmoid.configuration.propHeadPointSize
        }
    }

    PlasmaComponents.Label {
        id: dew
        text: Utils.currentTempUnit(weatherData["details"]["dewpt"])
        font.pointSize: plasmoid.configuration.propPointSize
    }
    PlasmaComponents.Label {
        id: precipRate
        text: Utils.currentPrecipUnit(weatherData["details"]["precipRate"], isRain) + "/hr"
        font.pointSize: plasmoid.configuration.propPointSize
    }
    PlasmaComponents.Label {
        id: pressure
        text: Utils.currentPresUnit(weatherData["details"]["pressure"])
        font.pointSize: plasmoid.configuration.propPointSize
    }

    PlasmaComponents.Label {
        id: humidityLabel
        text: i18n("HUMIDITY")
        font {
            bold: true
            pointSize: plasmoid.configuration.propHeadPointSize
        }
    }
    PlasmaComponents.Label {
        id: precipAccLabel
        text: i18nc("Precipitation accumulation", "PRECIP ACCUM")
        font {
            bold: true
            pointSize: plasmoid.configuration.propHeadPointSize
        }
    }
    PlasmaComponents.Label {
        id: uvLabel
        text: i18nc("Ultra Violet", "UV")
        font {
            bold: true
            pointSize: plasmoid.configuration.propHeadPointSize
        }
    }

    PlasmaComponents.Label {
        id: humidity
        text: weatherData["humidity"] + "%"
        font.pointSize: plasmoid.configuration.propPointSize
    }
    PlasmaComponents.Label {
        id: precipAcc
        text: Utils.currentPrecipUnit(weatherData["details"]["precipTotal"], isRain)
        font.pointSize: plasmoid.configuration.propPointSize
    }
    PlasmaComponents.Label {
        id: uv
        text: weatherData["uv"]
        font.pointSize: plasmoid.configuration.propPointSize
    }
}