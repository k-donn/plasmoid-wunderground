/*
 * Copyright 2021  Kevin Donnelly
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

import QtQuick 2.0
import QtQuick.Layouts 1.0
import QtQuick.Controls 2.0
import org.kde.plasma.plasmoid 2.0
import org.kde.plasma.core 2.0 as PlasmaCore
import "../code/utils.js" as Utils
import "../code/pws-api.js" as StationAPI

Item {
    id: root

    //that's a hack to check if we have a translation file for the given Locale
    property string currentLocale: getDisplayLocale()

    property var weatherData: null
    property var flatWeatherData: {}
    property string applicationStateText: i18n("All set")
    property var currentDetailsModel: ListModel {}
    property var dayInfo: null
    property var singleDayModel: ListModel { }
    property var forecastDetailsModel: ListModel { }
    property var hourlyChartModel: ListModel {
        ListElement {
                date: null
                time: null
                iconCode:100
                temperature: 0
                cloudCover: 0
                humidity: 0
                precipitationChance: 0
                precipitationRate: 0
                snowPrecipitationRate: 0
                wind: 0
                golfIndex: 0
                pressure: 0
                uvIndex: 0
            }
        }
    property var dailyChartModel: ListModel {
        ListElement{
                date: null
                iconCode:100
                temperature: 0
                cloudCover: 0
                humidity: 0
                precipitationChance: 0
                precipitationRate: 0
                snowPrecipitationRate: 0
                wind: 0
                isDay: false
            }
        }
    property var dictVals : ({
        temperature: {
            name: i18n("Temperature"),
            code: "temperature",
            icon: "wi-thermometer.svg",
            unit: Utils.currentTempUnit("", false)
        },
        uvIndex: {
            name: i18n("UV Index"),
            code: "uvIndex",
            icon: "wi-horizon-alt.svg",
            unit: ""
        },
        pressure: {
            name: i18n("Pressure"),
            code: "pressure",
            icon: "wi-barometer.svg",
            unit: Utils.currentPresUnit("", false)
        },
        cloudCover: {
            name: i18n("Cloud Cover"),
            code: "cloudCover",
            icon: "wi-cloud.svg",
            unit: "%"
        },
        humidity: {
            name: i18n("Humidity"),
            code: "humidity",
            icon: "wi-humidity.svg",
            unit: "%"
        },
        precipitationChance: {
            name: i18n("Precipitation Chance"),
            code: "precipitationChance",
            icon: "wi-umbrella.svg",
            unit: "%"
        },
        precipitationRate: {
            name: i18n("Precipitation Rate"),
            code: "precipitationRate",
            icon: "wi-rain.svg",
            unit: Utils.currentPrecipUnit("", true, false)
        },
        snowPrecipitationRate: {
            name: i18n("Snow Precipitation Rate"),
            code: "snowPrecipitationRate",
            icon: "wi-snow.svg",
            unit: Utils.currentPrecipUnit("", false, false)
        },
        wind: {
            name: i18n("Wind / Gust"),
            code: "wind",
            icon: "wi-strong-wind.svg",
            unit: Utils.currentSpeedUnit("", false)
        },
        precipitationAcc: {
            name: i18n("Precipitation Accumulation"),
            code: "precipitationAcc",
            icon: "wi-flood.svg",
            unit: Utils.currentPrecipUnit("", true, false)
        },
        dewPoint: {
            name: i18n("Dew Point"),
            code: "dewPoint",
            icon: "wi-raindrop.svg",
            unit: Utils.currentTempUnit("", false)
        },
        windDirection: {
            name: i18n("Wind Direction"),
            code: "windDirection",
            icon: "wi-storm-warning.svg",
            unit: ""
        }                                      
    })

    property var textSize: ({
        normal: plasmoid.configuration.propPointSize,
        small: plasmoid.configuration.propPointSize - 1,
        tiny: plasmoid.configuration.propPointSize - 2
    })

    readonly property var iconLookup: ({
        0: {id: 0, name: "Thunderstorms", style1Path:"icons/styles/1/0.svg", style2Path:"icons/styles/2/tstorms.svg", style3Path:"icons/styles/3/tstorms.svg", style4Path:"icons/styles/4/tstorms.svg", style5Path:"icons/styles/5/tstorms.svg", style6Path:"icons/fullRepresentation/wi-thunderstorm.svg", style7Path:"icons/styles/7/TSTORM.svg"},
        1: {id: 1, name: "WindyRain", style1Path:"icons/styles/1/1.svg", style2Path:"icons/styles/2/rain.svg", style3Path:"icons/styles/3/rain.svg", style4Path:"icons/styles/4/rain.svg", style5Path:"icons/styles/5/rain.svg", style6Path:"icons/fullRepresentation/wi-rain-wind.svg", style7Path:"icons/styles/7/RAIN.svg"},
        2: {id: 2, name: "WindyRain", style1Path:"icons/styles/1/2.svg", style2Path:"icons/styles/2/rain.svg", style3Path:"icons/styles/3/rain.svg", style4Path:"icons/styles/4/rain.svg", style5Path:"icons/styles/5/rain.svg", style6Path:"icons/fullRepresentation/wi-rain-wind.svg", style7Path:"icons/styles/7/RAIN.svg"},
        3: {id: 3, name: "Thunderstorms", style1Path:"icons/styles/1/3.svg", style2Path:"icons/styles/2/tstorms.svg", style3Path:"icons/styles/3/tstorms.svg", style4Path:"icons/styles/4/tstorms.svg", style5Path:"icons/styles/5/tstorms.svg", style6Path:"icons/fullRepresentation/wi-thunderstorm.svg", style7Path:"icons/styles/7/TSTORM.svg"},
        4: {id: 4, name: "TStorms", style1Path:"icons/styles/1/4.svg", style2Path:"icons/styles/2/tstorms.svg", style3Path:"icons/styles/3/tstorms.svg", style4Path:"icons/styles/4/tstorms.svg", style5Path:"icons/styles/5/tstorms.svg", style6Path:"icons/fullRepresentation/wi-thunderstorm.svg", style7Path:"icons/styles/7/TSTORM.svg"},
        5: {id: 5, name: "RainSnow", style1Path:"icons/styles/1/5.svg", style2Path:"icons/styles/2/chancesleet.svg", style3Path:"icons/styles/3/chancesleet.svg", style4Path:"icons/styles/4/chancesleet.svg", style5Path:"icons/styles/5/chancesleet.svg", style6Path:"icons/fullRepresentation/wi-rain-mix.svg", style7Path:"icons/styles/7/SLEET.svg"},
        6: {id: 6, name: "RainSleet", style1Path:"icons/styles/1/6.svg", style2Path:"icons/styles/2/chancesleet.svg", style3Path:"icons/styles/3/chancesleet.svg", style4Path:"icons/styles/4/chancesleet.svg", style5Path:"icons/styles/5/chancesleet.svg", style6Path:"icons/fullRepresentation/wi-sleet.svg", style7Path:"icons/styles/7/SLEET.svg"},
        7: {id: 7, name: "Snow/RainIcyMix", style1Path:"icons/styles/1/7.svg", style2Path:"icons/styles/2/sleet.svg", style3Path:"icons/styles/3/sleet.svg", style4Path:"icons/styles/4/sleet.svg", style5Path:"icons/styles/5/sleet.svg", style6Path:"icons/fullRepresentation/wi-rain-mix.svg", style7Path:"icons/styles/7/SNOW.svg"},
        8: {id: 8, name: "FreezingDrizzle", style1Path:"icons/styles/1/8.svg", style2Path:"icons/styles/2/chancerain.svg", style3Path:"icons/styles/3/chancerain.svg", style4Path:"icons/styles/4/chancerain.svg", style5Path:"icons/styles/5/chancerain.svg", style6Path:"icons/fullRepresentation/wi-showers.svg", style7Path:"icons/styles/7/SLEET.svg"},
        9: {id: 9, name: "Drizzle", style1Path:"icons/styles/1/9.svg", style2Path:"icons/styles/2/chancerain.svg", style3Path:"icons/styles/3/chancerain.svg", style4Path:"icons/styles/4/chancerain.svg", style5Path:"icons/styles/5/chancerain.svg", style6Path:"icons/fullRepresentation/wi-sprinkle.svg", style7Path:"icons/styles/7/SHOWER.svg"},
        10: {id: 10, name: "FreezingRain", style1Path:"icons/styles/1/10.svg", style2Path:"icons/styles/2/chancesleet.svg", style3Path:"icons/styles/3/chancesleet.svg", style4Path:"icons/styles/4/chancesleet.svg", style5Path:"icons/styles/5/chancesleet.svg", style6Path:"icons/fullRepresentation/wi-rain.svg", style7Path:"icons/styles/7/SLEET.svg"},
        11: {id: 11, name: "TShowers", style1Path:"icons/styles/1/11.svg", style2Path:"icons/styles/2/tstorms.svg", style3Path:"icons/styles/3/tstorms.svg", style4Path:"icons/styles/4/tstorms.svg", style5Path:"icons/styles/5/tstorms.svg", style6Path:"icons/fullRepresentation/wi-storm-showers.svg", style7Path:"icons/styles/7/TSTORM.svg"},
        11: {id: 11, name: "Showers", style1Path:"icons/styles/1/11.svg", style2Path:"icons/styles/2/chancerain.svg", style3Path:"icons/styles/3/chancerain.svg", style4Path:"icons/styles/4/chancerain.svg", style5Path:"icons/styles/5/chancerain.svg", style6Path:"icons/fullRepresentation/wi-showers.svg", style7Path:"icons/styles/7/SHOWER.svg"},
        11: {id: 11, name: "LightRain", style1Path:"icons/styles/1/11.svg", style2Path:"icons/styles/2/chancerain.svg", style3Path:"icons/styles/3/chancerain.svg", style4Path:"icons/styles/4/chancerain.svg", style5Path:"icons/styles/5/chancerain.svg", style6Path:"icons/fullRepresentation/wi-showers.svg", style7Path:"icons/styles/7/RAIN.svg"},
        12: {id: 12, name: "HeavyRain", style1Path:"icons/styles/1/12.svg", style2Path:"icons/styles/2/rain.svg", style3Path:"icons/styles/3/rain.svg", style4Path:"icons/styles/4/rain.svg", style5Path:"icons/styles/5/rain.svg", style6Path:"icons/fullRepresentation/wi-rain.svg", style7Path:"icons/styles/7/RAIN.svg"},
        13: {id: 13, name: "SnowFlurries", style1Path:"icons/styles/1/13.svg", style2Path:"icons/styles/2/flurries.svg", style3Path:"icons/styles/3/flurries.svg", style4Path:"icons/styles/4/flurries.svg", style5Path:"icons/styles/5/flurries.svg", style6Path:"icons/fullRepresentation/wi-snow.svg", style7Path:"icons/styles/7/SNOW.svg"},
        14: {id: 14, name: "LightSnow", style1Path:"icons/styles/1/14.svg", style2Path:"icons/styles/2/chancesnow.svg", style3Path:"icons/styles/3/chancesnow.svg", style4Path:"icons/styles/4/chancesnow.svg", style5Path:"icons/styles/5/chancesnow.svg", style6Path:"icons/fullRepresentation/wi-snow.svg", style7Path:"icons/styles/7/SNOW.svg"},
        15: {id: 15, name: "Snowflakes", style1Path:"icons/styles/1/15.svg", style2Path:"icons/styles/2/chancesnow.svg", style3Path:"icons/styles/3/chancesnow.svg", style4Path:"icons/styles/4/chancesnow.svg", style5Path:"icons/styles/5/chancesnow.svg", style6Path:"icons/fullRepresentation/wi-snowflake-cold.svg", style7Path:"icons/styles/7/SNOW.svg"},
        16: {id: 16, name: "HeavySnow", style1Path:"icons/styles/1/16.svg", style2Path:"icons/styles/2/snow.svg", style3Path:"icons/styles/3/snow.svg", style4Path:"icons/styles/4/snow.svg", style5Path:"icons/styles/5/snow.svg", style6Path:"icons/fullRepresentation/wi-snow-wind.svg", style7Path:"icons/styles/7/SNOW.svg"},
        17: {id: 17, name: "Thunderstorms", style1Path:"icons/styles/1/17.svg", style2Path:"icons/styles/2/tstorms.svg", style3Path:"icons/styles/3/tstorms.svg", style4Path:"icons/styles/4/tstorms.svg", style5Path:"icons/styles/5/tstorms.svg", style6Path:"icons/fullRepresentation/wi-thunderstorm.svg", style7Path:"icons/styles/7/TSTORM.svg"},
        18: {id: 18, name: "Hail", style1Path:"icons/styles/1/18.svg", style2Path:"icons/styles/2/rain.svg", style3Path:"icons/styles/3/rain.svg", style4Path:"icons/styles/4/rain.svg", style5Path:"icons/styles/5/rain.svg", style6Path:"icons/fullRepresentation/wi-hail.svg", style7Path:"icons/styles/7/HAIL.svg"},
        19: {id: 19, name: "Dust", style1Path:"icons/styles/1/19.svg", style2Path:"icons/styles/2/fog.svg", style3Path:"icons/styles/3/fog.svg", style4Path:"icons/styles/4/fog.svg", style5Path:"icons/styles/5/fog.svg", style6Path:"icons/fullRepresentation/wi-dust.svg", style7Path:"icons/styles/7/FOG.svg"},
        20: {id: 20, name: "Fog", style1Path:"icons/styles/1/20.svg", style2Path:"icons/styles/2/fog.svg", style3Path:"icons/styles/3/fog.svg", style4Path:"icons/styles/4/fog.svg", style5Path:"icons/styles/5/fog.svg", style6Path:"icons/fullRepresentation/wi-fog.svg", style7Path:"icons/styles/7/FOG.svg"},
        21: {id: 21, name: "Haze", style1Path:"icons/styles/1/21.svg", style2Path:"icons/styles/2/hazy.svg", style3Path:"icons/styles/3/hazy.svg", style4Path:"icons/styles/4/hazy.svg", style5Path:"icons/styles/5/hazy.svg", style6Path:"icons/fullRepresentation/wi-fog.svg", style7Path:"icons/styles/7/FOG.svg"},
        22: {id: 22, name: "Smoke", style1Path:"icons/styles/1/22.svg", style2Path:"icons/styles/2/hazy.svg", style3Path:"icons/styles/3/hazy.svg", style4Path:"icons/styles/4/hazy.svg", style5Path:"icons/styles/5/hazy.svg", style6Path:"icons/fullRepresentation/wi-smoke.svg", style7Path:"icons/styles/7/FOG.svg"},
        23: {id: 23, name: "Windy", style1Path:"icons/styles/1/23.svg", style2Path:"icons/styles/2/fog.svg", style3Path:"icons/styles/3/fog.svg", style4Path:"icons/styles/4/fog.svg", style5Path:"icons/styles/5/fog.svg", style6Path:"icons/fullRepresentation/wi-windy.svg", style7Path:"icons/styles/7/WINDY.svg"},
        24: {id: 24, name: "Windy", style1Path:"icons/styles/1/24.svg", style2Path:"icons/styles/2/fog.svg", style3Path:"icons/styles/3/fog.svg", style4Path:"icons/styles/4/fog.svg", style5Path:"icons/styles/5/fog.svg", style6Path:"icons/fullRepresentation/wi-windy.svg", style7Path:"icons/styles/7/WINDY.svg"},
        25: {id: 25, name: "Frigid", style1Path:"icons/styles/1/25.svg", style2Path:"icons/styles/2/fog.svg", style3Path:"icons/styles/3/fog.svg", style4Path:"icons/styles/4/fog.svg", style5Path:"icons/styles/5/fog.svg", style6Path:"icons/fullRepresentation/wi-cloudy-windy.svg", style7Path:"icons/styles/7/WINDY.svg"},
        26: {id: 26, name: "Cloudy", style1Path:"icons/styles/1/26.svg", style2Path:"icons/styles/2/cloudy.svg", style3Path:"icons/styles/3/cloudy.svg", style4Path:"icons/styles/4/cloudy.svg", style5Path:"icons/styles/5/cloudy.svg", style6Path:"icons/fullRepresentation/wi-cloudy.svg", style7Path:"icons/styles/7/MCLOUDY.svg"},
        27: {id: 27, name: "MostlyCloudyNight", style1Path:"icons/styles/1/27.svg", style2Path:"icons/styles/2/nt_mostlycloudy.svg", style3Path:"icons/styles/3/nt_mostlycloudy.svg", style4Path:"icons/styles/4/nt_mostlycloudy.svg", style5Path:"icons/styles/5/nt_mostlycloudy.svg", style6Path:"icons/fullRepresentation/wi-night-alt-cloudy.svg", style7Path:"icons/styles/7/MCLOUDY0.svg"},
        28: {id: 28, name: "MostlyCloudy", style1Path:"icons/styles/1/28.svg", style2Path:"icons/styles/2/mostlycloudy.svg", style3Path:"icons/styles/3/mostlycloudy.svg", style4Path:"icons/styles/4/mostlycloudy.svg", style5Path:"icons/styles/5/mostlycloudy.svg", style6Path:"icons/fullRepresentation/wi-day-cloudy.svg", style7Path:"icons/styles/7/MCLOUDY1.svg"},
        29: {id: 29, name: "PartlyCloudyNight", style1Path:"icons/styles/1/29.svg", style2Path:"icons/styles/2/nt_mostlysunny.svg", style3Path:"icons/styles/3/nt_mostlysunny.svg", style4Path:"icons/styles/4/nt_mostlysunny.svg", style5Path:"icons/styles/5/nt_mostlysunny.svg", style6Path:"icons/fullRepresentation/wi-night-alt-partly-cloudy.svg", style7Path:"icons/styles/7/PCLOUDY0.svg"},
        30: {id: 30, name: "PartlyCloudy", style1Path:"icons/styles/1/30.svg", style2Path:"icons/styles/2/mostlysunny.svg", style3Path:"icons/styles/3/mostlysunny.svg", style4Path:"icons/styles/4/mostlysunny.svg", style5Path:"icons/styles/5/mostlysunny.svg", style6Path:"icons/fullRepresentation/wi-day-cloudy-high.svg", style7Path:"icons/styles/7/PCLOUDY1.svg"},
        31: {id: 31, name: "ClearNight", style1Path:"icons/styles/1/31.svg", style2Path:"icons/styles/2/nt_sunny.svg", style3Path:"icons/styles/3/nt_sunny.svg", style4Path:"icons/styles/4/nt_sunny.svg", style5Path:"icons/styles/5/nt_sunny.svg", style6Path:"icons/fullRepresentation/wi-night-clear.svg", style7Path:"icons/styles/7/CLEAR0.svg"},
        32: {id: 32, name: "Sunny", style1Path:"icons/styles/1/32.svg", style2Path:"icons/styles/2/clear.svg", style3Path:"icons/styles/3/clear.svg", style4Path:"icons/styles/4/clear.svg", style5Path:"icons/styles/5/clear.svg", style6Path:"icons/fullRepresentation/wi-day-sunny.svg", style7Path:"icons/styles/7/CLEAR1.svg"},
        33: {id: 33, name: "Fair", style1Path:"icons/styles/1/33.svg", style2Path:"icons/styles/2/nt_mostlysunny.svg", style3Path:"icons/styles/3/nt_mostlysunny.svg", style4Path:"icons/styles/4/nt_mostlysunny.svg", style5Path:"icons/styles/5/nt_mostlysunny.svg", style6Path:"icons/fullRepresentation/wi-night-alt-cloudy-high.svg", style7Path:"icons/styles/7/CLEAR.svg"},
        33: {id: 33, name: "MostlyClearNight", style1Path:"icons/styles/1/33.svg", style2Path:"icons/styles/2/nt_mostlysunny.svg", style3Path:"icons/styles/3/nt_mostlysunny.svg", style4Path:"icons/styles/4/nt_mostlysunny.svg", style5Path:"icons/styles/5/nt_mostlysunny.svg", style6Path:"icons/fullRepresentation/wi-night-alt-partly-cloudy.svg", style7Path:"icons/styles/7/CLEAR0.svg"},
        34: {id: 34, name: "Fair", style1Path:"icons/styles/1/34.svg", style2Path:"icons/styles/2/mostlysunny.svg", style3Path:"icons/styles/3/mostlysunny.svg", style4Path:"icons/styles/4/mostlysunny.svg", style5Path:"icons/styles/5/mostlysunny.svg", style6Path:"icons/fullRepresentation/wi-day-cloudy-high.svg", style7Path:"icons/styles/7/CLEAR1.svg"},
        34: {id: 34, name: "MostlySunny", style1Path:"icons/styles/1/34.svg", style2Path:"icons/styles/2/mostlysunny.svg", style3Path:"icons/styles/3/mostlysunny.svg", style4Path:"icons/styles/4/mostlysunny.svg", style5Path:"icons/styles/5/mostlysunny.svg", style6Path:"icons/fullRepresentation/wi-day-sunny.svg", style7Path:"icons/styles/7/CLEAR1.svg"},
        35: {id: 35, name: "Thunderstorms", style1Path:"icons/styles/1/35.svg", style2Path:"icons/styles/2/tstorms.svg", style3Path:"icons/styles/3/tstorms.svg", style4Path:"icons/styles/4/tstorms.svg", style5Path:"icons/styles/5/tstorms.svg", style6Path:"icons/fullRepresentation/wi-thunderstorm.svg", style7Path:"icons/styles/7/TSTORM.svg"},
        36: {id: 36, name: "Hot", style1Path:"icons/styles/1/36.svg", style2Path:"icons/styles/2/clear.svg", style3Path:"icons/styles/3/clear.svg", style4Path:"icons/styles/4/clear.svg", style5Path:"icons/styles/5/clear.svg", style6Path:"icons/fullRepresentation/wi-hot.svg", style7Path:"icons/styles/7/CLEAR1.svg"},
        37: {id: 37, name: "IsolatedThunder", style1Path:"icons/styles/1/37.svg", style2Path:"icons/styles/2/chancetstorms.svg", style3Path:"icons/styles/3/chancetstorms.svg", style4Path:"icons/styles/4/chancetstorms.svg", style5Path:"icons/styles/5/chancetstorms.svg", style6Path:"icons/fullRepresentation/wi-lightning.svg", style7Path:"icons/styles/7/TSTORM.svg"},
        38: {id: 38, name: "ScatteredTStorms", style1Path:"icons/styles/1/38.svg", style2Path:"icons/styles/2/chancetstorms.svg", style3Path:"icons/styles/3/chancetstorms.svg", style4Path:"icons/styles/4/chancetstorms.svg", style5Path:"icons/styles/5/chancetstorms.svg", style6Path:"icons/fullRepresentation/wi-lightning.svg", style7Path:"icons/styles/7/TSTORM.svg"},
        39: {id: 39, name: "ScatteredRain", style1Path:"icons/styles/1/39.svg", style2Path:"icons/styles/2/chancerain.svg", style3Path:"icons/styles/3/chancerain.svg", style4Path:"icons/styles/4/chancerain.svg", style5Path:"icons/styles/5/chancerain.svg", style6Path:"icons/fullRepresentation/wi-sprinkle.svg", style7Path:"icons/styles/7/RAIN1.svg"},
        40: {id: 40, name: "HeavyRain", style1Path:"icons/styles/1/40.svg", style2Path:"icons/styles/2/rain.svg", style3Path:"icons/styles/3/rain.svg", style4Path:"icons/styles/4/rain.svg", style5Path:"icons/styles/5/rain.svg", style6Path:"icons/fullRepresentation/wi-rain-wind.svg", style7Path:"icons/styles/7/RAIN.svg"},
        41: {id: 41, name: "ScatteredSnow", style1Path:"icons/styles/1/41.svg", style2Path:"icons/styles/2/chancesnow.svg", style3Path:"icons/styles/3/chancesnow.svg", style4Path:"icons/styles/4/chancesnow.svg", style5Path:"icons/styles/5/chancesnow.svg", style6Path:"icons/fullRepresentation/wi-snow.svg", style7Path:"icons/styles/7/LSNOW.svg"},
        42: {id: 42, name: "HeavySnow", style1Path:"icons/styles/1/42.svg", style2Path:"icons/styles/2/snow.svg", style3Path:"icons/styles/3/snow.svg", style4Path:"icons/styles/4/snow.svg", style5Path:"icons/styles/5/snow.svg", style6Path:"icons/fullRepresentation/wi-snow.svg", style7Path:"icons/styles/7/SNOW.svg"},
        43: {id: 43, name: "Windy/Snowy", style1Path:"icons/styles/1/43.svg", style2Path:"icons/styles/2/snow.svg", style3Path:"icons/styles/3/snow.svg", style4Path:"icons/styles/4/snow.svg", style5Path:"icons/styles/5/snow.svg", style6Path:"icons/fullRepresentation/wi-snow.svg", style7Path:"icons/styles/7/SNOW.svg"},
        44: {id: 44, name: "PartlyCloudyDay", style1Path:"icons/styles/1/44.svg", style2Path:"icons/styles/2/partlycloudy.svg", style3Path:"icons/styles/3/partlycloudy.svg", style4Path:"icons/styles/4/partlycloudy.svg", style5Path:"icons/styles/5/partlycloudy.svg", style6Path:"icons/fullRepresentation/wi-day-cloudy.svg", style7Path:"icons/styles/7/PCLOUDY1.svg"},
        45: {id: 45, name: "ScatteredShowersNight", style1Path:"icons/styles/1/45.svg", style2Path:"icons/styles/2/nt_chancerain.svg", style3Path:"icons/styles/3/nt_chancerain.svg", style4Path:"icons/styles/4/nt_chancerain.svg", style5Path:"icons/styles/5/nt_chancerain.svg", style6Path:"icons/fullRepresentation/wi-night-alt-showers.svg", style7Path:"icons/styles/7/SHOWER0.svg"},
        46: {id: 46, name: "SnowyNight", style1Path:"icons/styles/1/46.svg", style2Path:"icons/styles/2/nt_snow.svg", style3Path:"icons/styles/3/nt_snow.svg", style4Path:"icons/styles/4/nt_snow.svg", style5Path:"icons/styles/5/nt_snow.svg", style6Path:"icons/fullRepresentation/wi-night-alt-snow.svg", style7Path:"icons/styles/7/SNOW0.svg"},
        47: {id: 47, name: "ScatteredTStormsNight", style1Path:"icons/styles/1/47.svg", style2Path:"icons/styles/2/nt_chancestorms.svg", style3Path:"icons/styles/3/nt_chancestorms.svg", style4Path:"icons/styles/4/nt_chancestorms.svg", style5Path:"icons/styles/5/nt_chancestorms.svg", style6Path:"icons/fullRepresentation/wi-night-lightning.svg", style7Path:"icons/styles/7/TSTORM0.svg"}
    })

    property ListModel forecastModel: ListModel {}
    property string errorStr: ""
    property string toolTipSubText: ""
    property string iconCode: "32" // 32 = sunny
    property string conditionNarrative: ""
    property string narrativeText: ""

    // TODO: add option for showFORECAST and showFORECASTERROR
    property int showCONFIG: 1
    property int showLOADING: 2
    property int showERROR: 4
    property int showDATA: 8

    property int appState: showCONFIG

    // QML does not let you property bind items part of ListModels.
    // The TopPanel shows the high/low values which are items part of forecastModel
    // These are updated in pws-api.js to overcome that limitation
    property int currDayHigh: 0
    property int currDayLow: 0

    property bool showForecast: false

    property string stationID: plasmoid.configuration.stationID
    property int unitsChoice: plasmoid.configuration.unitsChoice

    property bool inTray: false
    // Metric units change based on precipitation type
    property bool isRain: true

    property Component fr: FullRepresentation {
        Layout.minimumWidth: units.gridUnit * 16 *2.6
        Layout.preferredWidth: units.gridUnit * 16 *2.6
        Layout.minimumHeight: units.gridUnit * 12 *2.6
        Layout.preferredHeight: units.gridUnit * 12 *2.6
    }

    property Component cr: CompactRepresentation {
        Layout.minimumWidth: 110
        Layout.preferredWidth: 110
    }

    function printDebug(msg) {
        if (plasmoid.configuration.logConsole) {console.log("[debug] [main.qml] " + msg)}
    }

    function printDebugJSON(json) {
        if (plasmoid.configuration.logConsole) {console.log("[debug] [main.qml] " + JSON.stringify(json))}
    }

    function updateWeatherData() {
        printDebug("Getting new weather data")

        StationAPI.getCurrentData()
        StationAPI.getForecastData("daily", 7);
        StationAPI.getForecastData("hourly", 24);

        updatetoolTipSubText()
    }

    function updateCurrentData() {
        printDebug("Getting new current data")

        StationAPI.getCurrentData()

        updatetoolTipSubText()
    }

    function updateForecastData() {
        printDebug("Getting new forecast data")

        StationAPI.getForecastData("daily", 7);
        StationAPI.getForecastData("hourly", 24);

        updatetoolTipSubText()

        dailyChartModel.sync()
        forecastDetailsModel.sync()
        forecastModel.sync()
    }

    function updatetoolTipSubText() {
        var subText = ""
        
        //todo 

        toolTipSubText = subText;
    }

    onUnitsChoiceChanged: {
        printDebug("Units changed")

        // A user could configure units but not station id. This would trigger improper request.
        if (stationID != "") {
            // Show loading screen after units change
            appState = showLOADING;

            updateWeatherData();
        }
    }

    onStationIDChanged: {
        printDebug("Station ID changed")

        // Show loading screen after ID change
        appState = showLOADING;

        updateWeatherData();
    }

    onWeatherDataChanged: {
        printDebug("Weather data changed")
    }

    onAppStateChanged: {
        printDebug("State is: " + appState)

        // The state could now be an error, the tooltip displays the error
        updatetoolTipSubText()
    }

    Component.onCompleted: {
        inTray = (plasmoid.parent !== null && (plasmoid.parent.pluginName === 'org.kde.plasma.private.systemtray' || plasmoid.parent.objectName === 'taskItemContainer'))

        plasmoid.configurationRequiredReason = i18n("Set the weather station to pull data from.")

        plasmoid.backgroundHints = PlasmaCore.Types.ConfigurableBackground
    }

    Timer {
        interval: plasmoid.configuration.refreshPeriod * 1000
        running: appState != showCONFIG
        repeat: true
        onTriggered: updateCurrentData()
    }

    Timer {
        interval: 60 * 60 * 1000
        running: appState != showCONFIG
        repeat: true
        onTriggered: updateForecastData()
    }
    
    Plasmoid.toolTipItem: Loader {
        id: tooltipLoader

        Layout.minimumWidth: item ? item.width : 0
        Layout.maximumWidth: item ? item.width : 0
        Layout.minimumHeight: item ? item.height : 0
        Layout.maximumHeight: item ? item.height : 0

        source: getTootipTemplate()
    }


    function getTootipTemplate() {
        if (appState == showCONFIG) {
            applicationStateText = i18n("Please Configure");
            return "TooltipBasic.qml"
        } else if (appState == showLOADING) {
            applicationStateText = i18n("Loading...");
            return "TooltipBasic.qml"
        } else if (appState == showERROR) {
            applicationStateText = i18n("Error...");
            return "TooltipBasic.qml"
        } else if (appState == showDATA) {
            applicationStateText = i18n("All set");
            return "Tooltip.qml"            
        } else {
            applicationStateText = i18n("Undefined Error...");
            return "TooltipBasic.qml"
        }
    }

    function getDisplayLocale() {
        var systemLocale = Qt.locale().uiLanguages[0]
        var testString = i18nc("Please put your language code here","en-US")
        var hasTranslationForLocale = (testString === systemLocale ? true : false)

        if(hasTranslationForLocale) {
            return systemLocale;
        } else {
            return "en-US";
        }
    }

    Plasmoid.fullRepresentation: fr
    Plasmoid.compactRepresentation: cr


}
