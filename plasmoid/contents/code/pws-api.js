/*
 * Copyright 2024  Kevin Donnelly
 * Copyright 2024  dniminenn
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

/** @type {string} */
let API_KEY = "e1f10a1e78da46f5b10a1e78da96f525"


let UNITS_SYSTEM = {
	METRIC: 0,
	IMPERIAL: 1,
	HYBRID: 2,
	CUSTOM: 3
}

let WIND_UNITS = {
	MPS: 0,
	KPH: 1,
	MPH: 2
}

let RAIN_UNITS = {
	MM: 0,
	CM: 1,
	IN: 2
}

let SNOW_UNITS = {
	MM: 0,
	CM: 1,
	IN: 2
}

let TEMP_UNITS = {
	C: 0,
	F: 1,
	K: 2
}

let PRES_UNITS = {
	HPA: 0,
	CMHG: 1,
	INHG: 2
}

let ELEV_UNITS = {
	M: 0,
	FT: 1
}

let severityColorMap = {
	1: "#cc3300",
	2: "#ff9966",
	3: "#ffcc00",
	4: "#99cc33",
	5: "#ffcc00"
}

/**
 * Handle API fields that could be null. If not null, return.
 * Otherwise, return two dashes for placeholder.
 *
 * @param value API value
 * @returns {any|"--"} `value` or "--"
 */
function nullableField(value) {
	if (value != null) {
		return value;
	} else {
		return "--";
	}
}

/**
 * Find the territory code and return the air quality scale used there.
 * 
 * @returns {string} Air quality scale
 */
function getAQScale() {
	var countryCode = Qt.locale().name.split("_")[1];

	if (countryCode === "CN") {
		return "HJ6332012";
	} else if (countryCode === "FR") {
		return "ATMO";
	} else if (countryCode === "DE") {
		return "UBA";
	} else if (countryCode === "GB") {
		return "DAQI";
	} else if (countryCode === "IN") {
		return "NAQI";
	} else if (countryCode === "MX") {
		return "IMECA";
	} else if (countryCode === "ES") {
		return "CAQI";
	} else {
		return "EPA";
	}
}

/**
 * Determine if the user supplied station is active or not.
 * 
 * @param {string} givenID Station ID
 * @param {(isActive: boolean) => void} callback Callback called with success/failure
 */
function isStationActive(givenID, callback) {
	var req = new XMLHttpRequest();

	var url = "https://api.weather.com/v2/pws/observations/current";
	url += "?stationId=" + givenID;
	url += "&format=json";
	url += "&units=m";
	url += "&apiKey=" + API_KEY;
	url += "&numericPrecision=decimal";

	printDebug("[pws-api.js] " + url);

	req.open("GET", url);

	req.setRequestHeader("Accept-Encoding", "gzip");
	req.setRequestHeader("Origin", "https://www.wunderground.com");

	req.onerror = function () {
		errorStr = "Request couldn't be sent" + req.statusText;

		appState = showERROR;

		printDebug("[pws-api.js] " + errorStr);
	};


	req.onreadystatechange = function () {
		if (req.readyState == 4) {
			if (req.status == 200) {
				callback(true);
			} else {
				callback(false);
			}
		}
	};

	req.send();
}


/**
 * Find the nearest PWS with the configured coordinates.
 */
function getNearestStation() {
	var long = plasmoid.configuration.longitude;
	var lat = plasmoid.configuration.latitude;

	var req = new XMLHttpRequest();

	var url = "https://api.weather.com/v3/location/near";
	url += "?geocode=" + lat + "," + long;
	url += "&product=pws";
	url += "&format=json";
	url += "&apiKey=" + API_KEY;

	printDebug("[pws-api.js] " + url);

	req.open("GET", url);

	req.setRequestHeader("Accept-Encoding", "gzip");
	req.setRequestHeader("Origin", "https://www.wunderground.com");

	req.onreadystatechange = function () {
		if (req.readyState == 4) {
			if (req.status == 200) {
				var res = JSON.parse(req.responseText);

				var stations = res["location"]["stationId"];
				if (stations.length > 0) {
					var closest = stations[0];
					stationID.text = closest;
				}
			} else {
				printDebug("[pws-api.js] " + req.responseText);
			}
		}
	};

	req.send();
}

/**
 * Searches a geocode pair for the nearest stations.
 * 
 * @param {{lat: number, long: number}} latLongObj Coordinates of city to search
 */
function getNearestStations(latLongObj) {
	var long = latLongObj.long
	var lat = latLongObj.lat;

	var req = new XMLHttpRequest();

	var url = "https://api.weather.com/v3/location/near";
	url += "?geocode=" + lat + "," + long;
	url += "&product=pws";
	url += "&format=json";
	url += "&apiKey=" + API_KEY;

	printDebug("[pws-api.js] " + url);

	req.open("GET", url);

	req.setRequestHeader("Accept-Encoding", "gzip");
	req.setRequestHeader("Origin", "https://www.wunderground.com");

	req.onreadystatechange = function () {
		if (req.readyState == 4) {
			if (req.status == 200) {
				var res = JSON.parse(req.responseText);

				stationsModel.clear();

				var loc = res["location"];
				var stations = loc["stationId"];
				for (let i = 0; i < stations.length; i++) {
					stationsModel.append({
						text: loc["stationId"][i] + " - " + loc["stationName"][i],
						stationName: loc["stationName"][i],
						stationId: loc["stationId"][i],
						latitude: loc["latitude"][i],
						longitude: loc["longitude"][i]
					});
				}
			} else {
				printDebug("[pws-api.js] " + req.responseText);
			}
		}
	};

	req.send();
}

/**
 * Search for the qualified name of a city the user searches for.
 * This can then be used to search for stations in that area.
 * 
 * @param {string} city Textual city description
 */
function getLocations(city) {
	var req = new XMLHttpRequest();

	var url = "https://api.weather.com/v3/location/search";
	url += "?query=" + city;
	url += "&locationType=city";
	url += "&language=" + Qt.locale().name.replace("_","-");
	url += "&format=json";
	url += "&apiKey=" + API_KEY;

	printDebug("[pws-api.js] " + url);

	req.open("GET", url);

	req.setRequestHeader("Accept-Encoding", "gzip");
	req.setRequestHeader("Origin", "https://www.wunderground.com");

	req.onreadystatechange = function () {
		if (req.readyState == 4) {
			if (req.status == 200) {
				var res = JSON.parse(req.responseText);

				locationsModel.clear();

				var loc = res["location"];

				for (let i = 0; i < loc["address"].length; i++) {
					locationsModel.append({
						address: loc["address"][i],
						adminDistrict: loc["adminDistrict"][i],
						city: loc["city"][i],
						country: loc["country"][i],
						countryCode: loc["countryCode"][i],
						displayName: loc["displayName"][i],
						latitude: loc["latitude"][i],
						longitude: loc["longitude"][i]
					});
				}
			} else {
				printDebug("[pws-api.js] " + req.responseText);
			}
		}
	};

	req.send();
}


/**
 * Pull the most recent observation from the selected weather station.
 *
 * This handles setting errors and making the loading screen appear.
 * 
 * @param {() => void} [callback=function() {}] Function to call after this and getExtendedConditions
 */
function getCurrentData(callback = function() {}) {
	var req = new XMLHttpRequest();

	var url = "https://api.weather.com/v2/pws/observations/current";
	url += "?stationId=" + stationID;
	url += "&format=json";

	if (unitsChoice === UNITS_SYSTEM.METRIC) {
		url += "&units=m";
	} else if (unitsChoice === UNITS_SYSTEM.IMPERIAL) {
		url += "&units=e";
	} else if (unitsChoice === UNITS_SYSTEM.HYBRID){
		url += "&units=h";
	} else {
		url += "&units=m";
	}

	url += "&apiKey=" + API_KEY;
	url += "&numericPrecision=decimal";

	printDebug("[pws-api.js] " + url);

	req.open("GET", url);

	req.setRequestHeader("Accept-Encoding", "gzip");
	req.setRequestHeader("Origin", "https://www.wunderground.com");

	req.onerror = function () {
		errorStr = "Request couldn't be sent" + req.statusText;

		appState = showERROR;

		printDebug("[pws-api.js] " + errorStr);
	};

	req.onreadystatechange = function () {
		if (req.readyState == 4) {
			if (req.status == 200) {
				var sectionName = "";

				if (unitsChoice === UNITS_SYSTEM.METRIC) {
					sectionName = "metric";
				} else if (unitsChoice === UNITS_SYSTEM.IMPERIAL) {
					sectionName = "imperial";
				} else if (unitsChoice === UNITS_SYSTEM.HYBRID){
					sectionName = "uk_hybrid";
				} else {
					sectionName = "metric";
				}

				var res = JSON.parse(req.responseText);

				var obs = res["observations"][0];

				var details = obs[sectionName];

				// The properties are assigned to weatherData explicitly to preserve
				// its structure instead of assigning obs completely and breaking it
				weatherData["details"] = details;

				weatherData["stationID"] = obs["stationID"];
				weatherData["uv"] = nullableField(obs["uv"]);
				weatherData["humidity"] = obs["humidity"];
				weatherData["solarRad"] = nullableField(obs["solarRadiation"]);
				weatherData["obsTimeLocal"] = obs["obsTimeLocal"];
				weatherData["winddir"] = obs["winddir"];
				weatherData["lat"] = obs["lat"];
				weatherData["lon"] = obs["lon"];
				weatherData["neighborhood"] = obs["neighborhood"];

				plasmoid.configuration.latitude = weatherData["lat"];
				plasmoid.configuration.longitude = weatherData["lon"];
				plasmoid.configuration.stationName = weatherData["neighborhood"];

				printDebug("[pws-api.js] Got new current data");

				// Force QML to update text depending on weatherData
				weatherData = weatherData;

				getExtendedConditions(callback);

				appState = showDATA;
			} else {
				if (req.status == 204) {
					errorStr = "Station not found or station not active";

					printDebug("[pws-api.js] " + errorStr);
				} else {
					errorStr = "Request failed: " + req.responseText;

					printDebug("[pws-api.js] " + errorStr);
				}

				appState = showERROR;
			}
		}
	};

	req.send();
}


/**
 * Get broad weather info from station area including textual/icon description of conditions and weather warnings.
 * 
 * @param {() => void} [callback=function() {}] Function to call after extended conditions are fetched
 */
function getExtendedConditions(callback = function() {}) {
	var req = new XMLHttpRequest();

	var long = plasmoid.configuration.longitude;
	var lat = plasmoid.configuration.latitude;

	var url = "https://api.weather.com/v3/aggcommon/v3-wx-observations-current;v3alertsHeadlines;v3-wx-globalAirQuality";

	url += "?geocodes=" + lat + "," + long;
	url += "&apiKey=" + API_KEY;
	url += "&language=" + Qt.locale().name.replace("_","-");
	url += "&scale=" + getAQScale();

	if (unitsChoice === UNITS_SYSTEM.METRIC) {
		url += "&units=m";
	} else if (unitsChoice === UNITS_SYSTEM.IMPERIAL) {
		url += "&units=e";
	} else if (unitsChoice === UNITS_SYSTEM.HYBRID){
		url += "&units=h";
	} else {
		url += "&units=m";
	}

	url += "&format=json";

	req.open("GET", url);

	req.setRequestHeader("Accept-Encoding", "gzip");
	req.setRequestHeader("Origin", "https://www.wunderground.com");

	req.onerror = function () {
		printDebug("[pws-api.js] " + req.responseText);
	};

	printDebug("[pws-api.js] " + url);

	req.onreadystatechange = function () {
		if (req.readyState == 4) {
			if (req.status == 200) {
				var res = JSON.parse(req.responseText);

				var combinedVars = res[0];

				var condVars = combinedVars["v3-wx-observations-current"];
				var alertsVars = combinedVars["v3alertsHeadlines"];
				var airQualVars = combinedVars["v3-wx-globalAirQuality"]["globalairquality"];

				var isNight = condVars["dayOrNight"] === "N";
				iconCode = condVars["iconCode"];
				conditionNarrative = condVars["wxPhraseLong"];
				weatherData["isNight"] = isNight;
				weatherData["sunrise"] = condVars["sunriseTimeLocal"];
				weatherData["sunset"] = condVars["sunsetTimeLocal"];
				weatherData["details"]["pressureTrend"] = condVars["pressureTendencyTrend"];
				weatherData["details"]["pressureTrendCode"] = condVars["pressureTendencyCode"];
				weatherData["details"]["pressureDelta"] = condVars["pressureChange"];

				// Determine if the precipitation is snow or rain
				// All of these codes are for snow
				if (
					iconCode === 5 ||
					iconCode === 13 ||
					iconCode === 14 ||
					iconCode === 15 ||
					iconCode === 16 ||
					iconCode === 42 ||
					iconCode === 43 ||
					iconCode === 46
				) {
					isRain = false;
				}

				alertsModel.clear();
				if (alertsVars !== null) {

					var alerts = alertsVars["alerts"];
					for (var index = 0; index < alerts.length; index++) {
						var curAlert = alerts[index];

						var actions = [];

						for (var actionIndex = 0; actionIndex <  curAlert["responseTypes"].length; actionIndex++) {
							actions[actionIndex] = curAlert["responseTypes"][actionIndex]["responseType"];
						}

						var source = curAlert["source"] + " - " + curAlert["officeName"] + ", " + curAlert["officeCountryCode"];

						var disclaimer = curAlert["disclaimer"] !== null ? curAlert["disclaimer"] : "None";

						alertsModel.append({
							desc: curAlert["eventDescription"],
							severity: curAlert["severity"],
							severityColor: severityColorMap[curAlert["severityCode"]],
							headline: curAlert["headlineText"],
							area: curAlert["areaName"],
							action: actions.join(","),
							source: source,
							disclaimer: disclaimer
						});
					}
				}

				weatherData["aq"]["aqi"] = airQualVars["airQualityIndex"];
				weatherData["aq"]["aqhi"] = airQualVars["airQualityCategoryIndex"];
				weatherData["aq"]["aqDesc"] = airQualVars["airQualityCategory"];
				weatherData["aq"]["aqColor"] = airQualVars["airQualityCategoryIndexColor"];

				var primaryPollutant = weatherData["aq"]["aqPrimary"] = airQualVars["primaryPollutant"];

				var primaryDetails = airQualVars["pollutants"][primaryPollutant];

				weatherData["aq"]["primaryDetails"]["phrase"] = primaryDetails["phrase"];
				weatherData["aq"]["primaryDetails"]["amount"] = primaryDetails["amount"];
				weatherData["aq"]["primaryDetails"]["unit"] = primaryDetails["unit"];
				weatherData["aq"]["primaryDetails"]["desc"] = primaryDetails["category"];
				weatherData["aq"]["primaryDetails"]["index"] = primaryDetails["index"];


				// Force QML to update text depending on weatherData
				weatherData = weatherData;

				callback();
			}
		}
	};

	req.send();
}

/**
 * Call the forecast function according to user choice.
 */
function getForecastData() {
	if (plasmoid.configuration.useLegacyAPI) {
		getForecastDataV1();
	} else {
		getForecastDataV3();
	}
}

/**
 * Fetch the forecast data and place it in the forecast data model using V3 API.
 * 
 * See note in README for more info.
 *
 * @todo Incorporate a bitmapped appState field so an error with forecasts
 * doesn't show an error screen for entire widget.
 */
function getForecastDataV3() {
	var req = new XMLHttpRequest();

	var long = plasmoid.configuration.longitude;
	var lat = plasmoid.configuration.latitude;

	var url = "https://api.weather.com/v3/wx/forecast/daily/7day";
	url += "?geocode=" + lat + "," + long;
	url += "&apiKey=" + API_KEY;
	url += "&language=" + Qt.locale().name.replace("_","-");

	if (unitsChoice === UNITS_SYSTEM.METRIC) {
		url += "&units=m";
	} else if (unitsChoice === UNITS_SYSTEM.IMPERIAL) {
		url += "&units=e";
	} else if (unitsChoice === UNITS_SYSTEM.HYBRID){
		url += "&units=h";
	} else {
		url += "&units=m";
	}

	url += "&format=json";

	req.open("GET", url);

	req.setRequestHeader("Accept-Encoding", "gzip");
	req.setRequestHeader("Origin", "https://www.wunderground.com");

	req.onerror = function () {
		printDebug("[pws-api.js] " + req.responseText);
	};

	printDebug("[pws-api.js] " + url);

	req.onreadystatechange = function () {
		if (req.readyState == 4) {
			if (req.status == 200) {
				forecastModel.clear();

				var res = JSON.parse(req.responseText);

				var dailyForecastVars = res;

				var dailyDayPart = dailyForecastVars["daypart"][0];
				for (var period = 0; period < dailyForecastVars["dayOfWeek"].length; period++) {
					var isFirstNight = period === 0 && weatherData["isNight"];
					var daypartPeriod = isFirstNight ? 1 : period * 2;


					var fullDateTime = dailyForecastVars["validTimeLocal"][period];
					var date = parseInt(
						fullDateTime.split("T")[0].split("-")[2]
					);

					var high = isFirstNight ? dailyDayPart["temperature"][daypartPeriod] : dailyForecastVars["calendarDayTemperatureMax"][period];
					var low = isFirstNight ? dailyForecastVars["temperatureMin"][period] : dailyForecastVars["calendarDayTemperatureMin"][period];

					var heatIndexThresh,windChillThresh;
					if (unitsChoice === UNITS_SYSTEM.METRIC) {
						heatIndexThresh = 21.1;
						windChillThresh = 16.17;
					} else if (unitsChoice === UNITS_SYSTEM.IMPERIAL) {
						heatIndexThresh = 70;
						windChillThresh = 61;
					} else if (unitsChoice === UNITS_SYSTEM.HYBRID){
						heatIndexThresh = 294.26;
						windChillThresh = 289.32;
					} else {
						heatIndexThresh = 21.1;
						windChillThresh = 16.17;
					}

					var feelsLike;
					if (dailyDayPart["temperature"][daypartPeriod] > heatIndexThresh) {
						feelsLike = dailyDayPart["temperatureHeatIndex"][daypartPeriod];
					} else if (dailyDayPart["temperature"][daypartPeriod] < windChillThresh) {
						feelsLike = dailyDayPart["temperatureWindChill"][daypartPeriod];
					} else {
						feelsLike = dailyDayPart["temperatureWindChill"][daypartPeriod];
					}

					// API does not return a 12char weather description for non-English languages, but it always returns a 32char. Check for empty string.
					var shortDesc;
					if (dailyDayPart["wxPhraseShort"][daypartPeriod] !== "") {
						shortDesc = dailyDayPart["wxPhraseShort"][daypartPeriod];
					} else {
						shortDesc = dailyDayPart["wxPhraseLong"][daypartPeriod]
					}

					var snowDesc = dailyDayPart["snowRange"][daypartPeriod] !== "" ? dailyDayPart["snowRange"][daypartPeriod] : "N/A";
					var thunderDesc = dailyDayPart["thunderCategory"][daypartPeriod] !== null && dailyDayPart["thunderCategory"][daypartPeriod] !== "" ? dailyDayPart["thunderCategory"][daypartPeriod] : "N/A";

					// TODO: Golf and Thunder translation. Choice of V1/V3 forecast API
					forecastModel.append({
						date: date,
						dayOfWeek: dailyDayPart["daypartName"][daypartPeriod],
						iconCode: dailyDayPart["iconCode"][daypartPeriod],
						high: high,
						low: low,
						feelsLike: feelsLike,
						shortDesc: shortDesc,
						longDesc: dailyForecastVars["narrative"][period],
						thunderDesc: thunderDesc,
						windDesc: dailyDayPart["windPhrase"][daypartPeriod],
						uvDesc: dailyDayPart["uvDescription"][daypartPeriod],
						snowDesc: snowDesc,
						golfDesc: !isFirstNight ? "Good day for golf." : "Don't play golf at night."
					});
				}

				currDayHigh = forecastModel.get(0).high;
				currDayLow = forecastModel.get(0).low;

				printDebug("[pws-api.js] Got new forecast data");

				showForecast = true;
			} else {
				errorStr = "Could not fetch forecast data";

				printDebug("[pws-api.js] " + errorStr);

				appState = showERROR;
			}
		}
	};

	req.send();
}

/**
 * Fetch the forecast data and place it in the forecast data model using V1 API.
 * 
 * See note in README for more info.
 *
 * @todo Incorporate a bitmapped appState field so an error with forecasts
 * doesn't show an error screen for entire widget.
 */
function getForecastDataV1() {
	var req = new XMLHttpRequest();

	var url = "https://api.weather.com/v1/geocode";
	url +=
		"/" +
		plasmoid.configuration.latitude +
		"/" +
		plasmoid.configuration.longitude;
	url += "/forecast/daily/7day.json";
	url += "?apiKey=" + API_KEY;
	url += "&language=" + Qt.locale().name.replace("_","-");

	if (unitsChoice === UNITS_SYSTEM.METRIC) {
		url += "&units=m";
	} else if (unitsChoice === UNITS_SYSTEM.IMPERIAL) {
		url += "&units=e";
	} else if (unitsChoice === UNITS_SYSTEM.HYBRID){
		url += "&units=h";
	} else {
		url += "&units=m";
	}

	printDebug("[pws-api.js] " + url);

	req.open("GET", url);

	req.setRequestHeader("Accept-Encoding", "gzip");
	req.setRequestHeader("Origin", "https://www.wunderground.com");

	req.onreadystatechange = function () {
		if (req.readyState == 4) {
			if (req.status == 200) {
				forecastModel.clear();

				var res = JSON.parse(req.responseText);

				var forecasts = res["forecasts"];

				for (var period = 0; period < forecasts.length; period++) {
					var forecast = forecasts[period];

					var day = forecast["day"];
					var night = forecast["night"];

					var isDay = day !== undefined;

					var fullDateTime = forecast["fcst_valid_local"];
					var date = parseInt(
						fullDateTime.split("T")[0].split("-")[2]
					);

					// API returns empty string if no snow. Check for empty string.
					var snowDesc;
					if (isDay) {
						snowDesc =
							day["snow_phrase"] === ""
								? "No snow"
								: day["snow_phrase"];
					} else {
						snowDesc =
							night["snow_phrase"] === ""
								? "No snow"
								: night["snow_phrase"];
					}

					// API does not return a thunderDesc for non-English languages. Check for null value.
					var thunderDesc;
					if (isDay) {
						thunderDesc = day["thunder_enum_phrase"] !== null ? day["thunder_enum_phrase"] : "N/A"
					} else {
						thunderDesc = night["thunder_enum_phrase"] !== null ? night["thunder_enum_phrase"] : "N/A"
					}

					// API does not return a 12char weather description for non-English languages, but it always returns a 32char. Check for empty string.
					var shortDesc;
					if (isDay) {
						shortDesc = day["phrase_12char"] !== "" ? day["phrase_12char"] : day["phrase_32char"]
					} else {

						shortDesc = night["phrase_12char"] !== "" ? night["phrase_12char"] : night["phrase_32char"]
					}


					forecastModel.append({
						date: date,
						dayOfWeek: isDay ? forecast["dow"] : "Tonight",
						iconCode: isDay ? day["icon_code"] : night["icon_code"],
						high: isDay ? forecast["max_temp"] : night["hi"],
						low: forecast["min_temp"],
						feelsLike: isDay ? day["wc"] : night["wc"],
						shortDesc: shortDesc,
						longDesc: isDay ? day["narrative"] : night["narrative"],
						thunderDesc: thunderDesc,
						winDesc: isDay
							? day["wind_phrase"]
							: night["wind_phrase"],
						uvDesc: isDay ? day["uv_desc"] : night["uv_desc"],
						snowDesc: snowDesc,
						golfDesc: isDay
							? day["golf_category"]
							: "Don't play golf at night.",
					});
				}

				// These are placed seperate from forecastModel since items part of ListModels
				// cannot be property bound
				currDayHigh = forecastModel.get(0).high;
				currDayLow = forecastModel.get(0).low;

				printDebug("[pws-api.js] Got new forecast data");

				showForecast = true;
			} else {
				errorStr = "Could not fetch forecast data";

				printDebug("[pws-api.js] " + errorStr);

				appState = showERROR;
			}
		}
	};

	req.send();
}
