/*
 * Copyright 2026  Kevin Donnelly
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

import QtQuick
import QtQuick.Layouts
import org.kde.kcmutils as KCM
import org.kde.kirigami as Kirigami
import org.kde.plasma.components as PlasmaComponents

KCM.SimpleKCM {
    id: unitsConfig

    property alias sunMoonFormatIndex: sunMoonFormatChoice.currentIndex
    property alias dayChartFormatIndex: dayChartFormatChoice.currentIndex
    property alias weekForecastFormatIndex: weekForecastFormatChoice.currentIndex
    property alias kpPredictionFormatIndex: kpPredictionFormatChoice.currentIndex

    property alias cfg_dayChartTimeFormat: dayChartTimeFormat.text
    property alias cfg_weekForecastDateFormat: weekForecastDateFormat.text
    property alias cfg_sunMoonTimeFormat: sunMoonTimeFormat.text
    property alias cfg_kpPredictionTimeFormat: kpPredictionTimeFormat.text
    property alias cfg_windPrecision: windPrecision.value
    property alias cfg_tempPrecision: tempPrecision.value
    property alias cfg_compactTempPrecision: compactTempPrecision.value
    property alias cfg_feelsPrecision: feelsPrecision.value
    property alias cfg_dewPrecision: dewPrecision.value
    property alias cfg_forecastPrecision: forecastPrecision.value
    property alias cfg_unitsChoice: unitsChoice.currentIndex
    property alias cfg_windUnitsChoice: windUnitsChoice.currentIndex
    property alias cfg_rainUnitsChoice: rainUnitsChoice.currentIndex
    property alias cfg_snowUnitsChoice: snowUnitsChoice.currentIndex
    property alias cfg_tempUnitsChoice: tempUnitsChoice.currentIndex
    property alias cfg_presUnitsChoice: presUnitsChoice.currentIndex
    property alias cfg_elevUnitsChoice: elevUnitsChoice.currentIndex

    onSunMoonFormatIndexChanged: {
        if (sunMoonFormatIndex === 0) {
            cfg_sunMoonTimeFormat = "h:mm AP";
        } else if (sunMoonFormatIndex === 1) {
            cfg_sunMoonTimeFormat = "HH:mm";
        }
    }

    onDayChartFormatIndexChanged: {
        if (dayChartFormatIndex === 0) {
            cfg_dayChartTimeFormat = "h AP";
        } else if (dayChartFormatIndex === 1) {
            cfg_dayChartTimeFormat = "HH:mm";
        }
    }

    onWeekForecastFormatIndexChanged: {
        if (weekForecastFormatIndex === 0) {
            cfg_weekForecastDateFormat = "d";
        } else if (weekForecastFormatIndex === 1) {
            cfg_weekForecastDateFormat = "dd/MM";
        }
    }

    onKpPredictionFormatIndexChanged: {
        if (kpPredictionFormatIndex === 0) {
            cfg_kpPredictionTimeFormat = "h:mm AP";
        } else if (kpPredictionFormatIndex === 1) {
            cfg_kpPredictionTimeFormat = "HH:mm";
        }
    }

    function displayTxt(i18nStr) {
        return i18nStr.charAt(0).toUpperCase() + i18nStr.toLowerCase().slice(1);
    }

    Kirigami.FormLayout {
        anchors.fill: parent

        Kirigami.Separator {
            Kirigami.FormData.label: i18n("Time/Date Format")
            Kirigami.FormData.isSection: true
        }

        ColumnLayout {
            Kirigami.FormData.label: i18n("Sun/Moon time format:")
            Kirigami.FormData.labelAlignment: Qt.AlignTop

            PlasmaComponents.ComboBox {
                id: sunMoonFormatChoice

                model: [i18n("12hr time"),i18n("24hr time"),i18n("Custom")]
            }

            PlasmaComponents.TextField {
                id: sunMoonTimeFormat

                enabled: sunMoonFormatChoice.currentIndex == 2
            }
        }

        ColumnLayout {
            Kirigami.FormData.label: i18n("Kp-prediction time format:")
            Kirigami.FormData.labelAlignment: Qt.AlignTop

            PlasmaComponents.ComboBox {
                id: kpPredictionFormatChoice

                model: [i18n("12hr time"),i18n("24hr time"),i18n("Custom")]
            }

            PlasmaComponents.TextField {
                id: kpPredictionTimeFormat

                enabled: kpPredictionFormatChoice.currentIndex == 2
            }
        }

        ColumnLayout {
            Kirigami.FormData.label: i18n("Day Chart time format:")
            Kirigami.FormData.labelAlignment: Qt.AlignTop

            PlasmaComponents.ComboBox {
                id: dayChartFormatChoice

                model: [i18n("12hr time"),i18n("24hr time"),i18n("Custom")]
            }

            PlasmaComponents.TextField {
                id: dayChartTimeFormat

                enabled: dayChartFormatChoice.currentIndex == 2
            }

            PlasmaComponents.Label {
                text: i18n("Time format")

                color: Kirigami.Theme.linkColor

                MouseArea {
                    anchors.fill: parent

                    hoverEnabled: true

                    onEntered: {
                        parent.font.underline = true;
                    }

                    onExited: {
                        parent.font.underline = false;
                    }

                    onClicked: Qt.openUrlExternally("https://doc.qt.io/qt-6/qdate.html#toString")
                }
            }
        }

        ColumnLayout {
            Kirigami.FormData.label: i18n("Week forecast date format:")
            Kirigami.FormData.labelAlignment: Qt.AlignTop

            PlasmaComponents.ComboBox {
                id: weekForecastFormatChoice

                model: [i18n("Day"),i18n("Day/Month"),i18n("Custom")]
            }

            PlasmaComponents.TextField {
                id: weekForecastDateFormat

                enabled: weekForecastFormatChoice.currentIndex == 2
            }

            PlasmaComponents.Label {
                text: i18n("Date format")

                color: Kirigami.Theme.linkColor

                MouseArea {
                    anchors.fill: parent

                    hoverEnabled: true

                    onEntered: {
                        parent.font.underline = true;
                    }

                    onExited: {
                        parent.font.underline = false;
                    }

                    onClicked: Qt.openUrlExternally("https://doc.qt.io/qt-6/qtime.html#toString-1")
                }
            }
        }

        Kirigami.Separator {
            Kirigami.FormData.label: i18n("Precision")
            Kirigami.FormData.isSection: true
        }

        PlasmaComponents.SpinBox {
            id: tempPrecision

            Kirigami.FormData.label: i18n("Temperature") + ":"

            from: 0
            to: 15

            validator: IntValidator {
                bottom: tempPrecision.from
                top: tempPrecision.to
            }
        }

        PlasmaComponents.SpinBox {
            id: compactTempPrecision

            Kirigami.FormData.label: i18n("Compact Rep Temperature") + ":"

            from: 0
            to: 5

            validator: IntValidator {
                bottom: compactTempPrecision.from
                top: compactTempPrecision.to
            }
        }

        PlasmaComponents.SpinBox {
            id: windPrecision

            Kirigami.FormData.label: i18n("Wind & Gust") + ":"

            from: 0
            to: 15

            validator: IntValidator {
                bottom: windPrecision.from
                top: windPrecision.to
            }
        }

        PlasmaComponents.SpinBox {
            id: feelsPrecision

            // Reuse existing i18n strings
            Kirigami.FormData.label: i18n("Feels like %1", "").slice(0, -1) + ":"

            from: 0
            to: 15

            validator: IntValidator {
                bottom: feelsPrecision.from
                top: feelsPrecision.to
            }
        }

        PlasmaComponents.SpinBox {
            id: forecastPrecision

            Kirigami.FormData.label: i18n("Forecast") + ":"

            from: 0
            to: 15

            validator: IntValidator {
                bottom: forecastPrecision.from
                top: forecastPrecision.to
            }
        }

        PlasmaComponents.SpinBox {
            id: dewPrecision

            Kirigami.FormData.label: i18n("Dew Point") + ":"

            from: 0
            to: 15

            validator: IntValidator {
                bottom: dewPrecision.from
                top: dewPrecision.to
            }
        }

        Kirigami.Separator {
            Kirigami.FormData.label: i18n("Units")
            Kirigami.FormData.isSection: true
        }

        PlasmaComponents.ComboBox {
            id: unitsChoice

            width: 100
            model: [i18nc("The unit system", "Metric"), i18nc("The unit system", "Imperial"), i18nc("The unit system", "Hybrid (UK)"), i18n("Custom")]

            Kirigami.FormData.label: i18n("Choose:")
        }

        PlasmaComponents.ComboBox {
            id: windUnitsChoice

            visible: unitsChoice.currentIndex == 3

            model: ["kmh", "mph", "m/s"]

            Kirigami.FormData.label: i18n("Wind unit:")
        }

        PlasmaComponents.ComboBox {
            id: rainUnitsChoice

            visible: unitsChoice.currentIndex == 3

            model: ["mm", "in", "cm"]

            Kirigami.FormData.label: i18n("Rain unit:")
        }

        PlasmaComponents.ComboBox {
            id: snowUnitsChoice

            visible: unitsChoice.currentIndex == 3

            model: ["mm", "in", "cm"]

            Kirigami.FormData.label: i18n("Snow unit:")
        }

        PlasmaComponents.ComboBox {
            id: tempUnitsChoice

            visible: unitsChoice.currentIndex == 3

            model: ["C", "F", "K"]

            Kirigami.FormData.label: i18n("Temperature unit:")
        }

        PlasmaComponents.ComboBox {
            id: presUnitsChoice

            visible: unitsChoice.currentIndex == 3

            model: ["mb", "inHG", "mmHG", "hPa"]

            Kirigami.FormData.label: i18n("Pressure unit:")
        }

        PlasmaComponents.ComboBox {
            id: elevUnitsChoice

            visible: unitsChoice.currentIndex == 3

            model: ["m", "ft"]

            Kirigami.FormData.label: i18n("Elevation unit:")
        }
    }
}
