/*
 * Copyright 2020  Kevin Donnelly
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

/**
 * Pull the most recent observation from the selected weather station.
 *
 * This handles setting errors and making the loading screen appear.
 */
function getCurrentData() {
	var req = new XMLHttpRequest();

	var url = "https://api.weather.com/v2/pws/observations/current";
	url += "?stationId=" + stationID;
	url += "&format=json";

	if (unitsChoice === 0) {
		url += "&units=m";
	} else if (unitsChoice === 1) {
		url += "&units=e";
	} else {
		url += "&units=h";
	}

	url += "&apiKey=6532d6454b8aa370768e63d6ba5a832e";
	url += "&numericPrecision=decimal";

	printDebug(url);

	req.open("GET", url);

	req.setRequestHeader("Accept-Encoding", "gzip");
	req.setRequestHeader("Origin", "https://www.wunderground.com");

	req.onerror = function () {
		errorStr = "Request couldn't be sent" + req.statusText;

		appState = showERROR;

		printDebug(errorStr);
	};

	req.onreadystatechange = function () {
		if (req.readyState == 4) {
			if (req.status == 200) {
				var sectionName = "";

				if (unitsChoice === 0) {
					sectionName = "metric";
				} else if (unitsChoice === 1) {
					sectionName = "imperial";
				} else {
					sectionName = "uk_hybrid";
				}

				var res = JSON.parse(req.responseText);

				var tmp = {};
				var tmp = res["observations"][0];

				var details = res["observations"][0][sectionName];
				tmp["details"] = details;

				weatherData = tmp;

				plasmoid.configuration.latitude = weatherData["lat"];
				plasmoid.configuration.longitude = weatherData["lon"];

				printDebug("Got new current data");

				appState = showDATA;
			} else {
				if (req.status == 204) {
					errorStr = "Station not found";

					printDebug(errorStr);
				} else {
					errorStr = "Request failed: " + req.responseText;

					printDebug(errorStr);
				}

				appState = showERROR;
			}
		}
	};

	req.send();
}

/**
 * Fetch the forecast data and place it in the forecast data model.
 */
function getForecastData() {
	var req = new XMLHttpRequest();

	var url = "https://api.weather.com/v1/geocode";
	url +=
		"/" +
		plasmoid.configuration.latitude +
		"/" +
		plasmoid.configuration.longitude;
	url += "/forecast/daily/7day.json";
	url += "?apiKey=6532d6454b8aa370768e63d6ba5a832e";
	url += "&language=en-US";

	if (unitsChoice === 0) {
		url += "&units=m";
	} else if (unitsChoice === 1) {
		url += "&units=e";
	} else {
		url += "&units=h";
	}

	printDebug(url);

	req.open("GET", url);

	req.setRequestHeader("Accept-Encoding", "gzip");

	req.onreadystatechange = function () {
		if (req.readyState == 4) {
			if (req.status == 200) {
				forecastModel.clear();

				var res = JSON.parse(req.responseText);

				var forecasts = res["forecasts"];

				for (var period = 1; period < forecasts.length; period++) {
					var forecast = forecasts[period];

					var day = forecast["day"];
					var night = forecast["night"];

					var fullDateTime = forecast["fcst_valid_local"];
					var date = parseInt(
						fullDateTime.split("T")[0].split("-")[2]
					);

					var daySnowDesc =
						day["snow_phrase"] === ""
							? "No snow"
							: day["snow_phrase"];

					forecastModel.append({
						date: date,
						dayOfWeek: forecast["dow"],
						dayIconCode: day["icon_code"],
						dayHigh: day["hi"],
						dayLow: day["temp"],
						dayShortDesc: day["phrase_12char"],
						dayLongDesc: day["narrative"],
						dayThunderDesc: day["thunder_enum_phrase"],
						dayWindDesc: day["wind_phrase"],
						dayUVDesc: day["uv_desc"],
						daySnowDesc: daySnowDesc,
						dayGolfDesc: day["golf_category"],
					});
				}

				printDebug("Got new forecast data");

				appState = showDATA;
			} else {
				errorStr = "Could not fetch forecast data";

				printDebug(errorStr);

				appState = showERROR;
			}
		}
	};

	req.send();
}

/**
 * Find the nearest PWS with the choosen coordinates.
 */
function getNearestStation() {
	var long = plasmoid.configuration.longitude;
	var lat = plasmoid.configuration.latitude;

	var req = new XMLHttpRequest();

	var url = "https://api.weather.com/v3/location/near";
	url += "?geocode=" + lat + "," + long;
	url += "&product=pws";
	url += "&format=json";
	url += "&apiKey=6532d6454b8aa370768e63d6ba5a832e";

	printDebug(url);

	req.open("GET", url);

	req.setRequestHeader("Accept-Encoding", "gzip");

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
				printDebug(req.responseText);
			}
		}
	};

	req.send();
}
