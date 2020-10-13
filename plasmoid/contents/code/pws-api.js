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
function getWeatherData() {
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

	url += "&apiKey=676566f10f134df1a566f10f13edf108";
	url += "&numericPrecision=decimal";

	req.open("GET", url, true);

	req.setRequestHeader("Accept-Encoding", "gzip");

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

				appState = showDATA;

				printDebug("Got new data");
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
	url += "&apiKey=676566f10f134df1a566f10f13edf108";

	console.log(url);

	req.open("GET", url, true);

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
				console.log(req.responseText);
			}
		}
	};

	req.send();
}
