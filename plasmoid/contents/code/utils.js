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
 * Turn a 1-360° angle into the corresponding part on the compass.
 *
 * @param {number} deg Angle in degrees
 *
 * @returns {string} Cardinal direction
 */
function windDirToCard(deg) {
	var directions = [
		"N",
		"NNE",
		"NE",
		"ENE",
		"E",
		"ESE",
		"SE",
		"SSE",
		"S",
		"SSW",
		"SW",
		"WSW",
		"W",
		"WNW",
		"NW",
		"NNW",
	];
	deg *= 10;
	return directions[Math.round((deg % 3600) / 255)];
}

/**
 * Turn a Celcius temperature into a Fahrenheit one.
 *
 * @param {number} degC Temp in degrees Celcius
 *
 * @returns {number} Temp in degrees Fahrenheit
 */
function cToF(degC) {
	return degC * 1.8 + 32;
}

/**
 * Turn a Fahrenheit temperature into a Celcius one.
 *
 * @param {number} degF Temp in degrees Fahrenheit
 *
 * @returns {number} degC Temp in degrees Celcius
 */
function fToC(degF) {
	return (degF - 32) / 1.8;
}

/**
 * Turn a speed in km/h to m/h.
 *
 * @param {number} kmh Speed in Kilometers/Hour
 *
 * @returns {number} Speed in Miles/Hour
 */
function kmhToMph(kmh) {
	return kmh * 0.6213711922;
}

/**
 * Return what the air feels like with the given temperature.
 *
 * This converts everything into imperial units then runs the function
 * on that data.
 *
 * @param {number} temp Temp in Celcius or Fahrenheit
 * @param {number} relHumid Percent humidity
 * @param {number} windSpeed Speed in km/h or m/h
 *
 * @returns {number} What the air feels like
 */
function feelsLike(temp, relHumid, windSpeed) {
	let degF, windSpeedMph;
	if (unitsChoice === 0) {
		degF = cToF(temp);
		windSpeedMph = kmhToMph(windSpeed);

		let res = feelsLikeImperial(degF, relHumid, windSpeedMph);

		return fToC(res);
	} else if (unitsChoice === 1) {
		degF = temp;
		windSpeedMph = windSpeed;

		return feelsLikeImperial(degF, relHumid, windSpeedMph);
	} else {
		degF = cToF(temp);
		windSpeedMph = windSpeed;

		let res = feelsLikeImperial(degF, relHumid, windSpeedMph);

		return fToC(res);
	}
}

/**
 * Return what the air feels like in imperial units.
 *
 * @param {number} temp Temp in Fahrenheit
 * @param {number} relHumid Percent humidity
 * @param {number} windSpeed Speed in m/h
 *
 * @returns {number} What the air feels like in Fahrenheit
 */
function feelsLikeImperial(degF, relHumid, windSpeedMph) {
	if (degF >= 80 && relHumid >= 40) {
		return heatIndexF(degF, relHumid);
	} else if (degF <= 50 && windSpeedMph >= 3) {
		return windChillF(degF, windSpeedMph);
	} else {
		return degF;
	}
}

/**
 * Return how hot the air feels with humidity.
 *
 * @param {number} degF Temp in Fahrenheit
 * @param {number} relHumid Percent humidity
 *
 * @returns {number} Temp in Fahrenheit
 */
function heatIndexF(degF, relHumid) {
	var hIndex;

	hIndex =
		-42.379 +
		2.04901523 * degF +
		10.14333127 * relHumid -
		0.22475541 * degF * relHumid -
		6.83783 * Math.pow(10, -3) * degF * degF -
		5.481717 * Math.pow(10, -2) * relHumid * relHumid +
		1.22874 * Math.pow(10, -3) * degF * degF * relHumid +
		8.5282 * Math.pow(10, -4) * degF * relHumid * relHumid -
		1.99 * Math.pow(10, -6) * degF * degF * relHumid * relHumid;
	return hIndex.toFixed(1);
}

/**
 * Return what the air feels like with wind blowing.
 *
 * @param {number} degF Temp in Fahrenheit
 * @param {number} windSpeedMph Wind speed in m/h
 *
 * @returns {number} Temp in Fahrenheit
 */
function windChillF(degF, windSpeedMph) {
	var newTemp =
		35.74 +
		0.6215 * degF -
		35.75 * Math.pow(windSpeedMph, 0.16) +
		0.4275 * degF * Math.pow(windSpeedMph, 0.16);
	return newTemp.toFixed(1);
}

/**
 * Return a color to match how hot it is.
 *
 * This determines what unit is passed and calls corresponding func.
 *
 * @param {number} temp Temp in Celcius or Fahrenheit
 *
 * @returns {string} Hex color code
 */
function heatColor(temp) {
	if (unitsChoice === 1) {
		return heatColorF(temp);
	} else {
		return heatColorC(temp);
	}
}

/**
 * Return a color to match how hot it is.
 *
 * Reds for hot, blues for cold
 *
 * @param {number} degC Temp in Celcius
 *
 * @returns {string} Hex color code
 */
function heatColorC(degC) {
	return degC > 37.78
		? "#9E1642"
		: degC > 32.2
		? "#D53E4F"
		: degC > 26.6
		? "#F46D43"
		: degC > 23.9
		? "#FDAE61"
		: degC > 21.1
		? "#FEE08B"
		: degC > 15.5
		? "#E6F598"
		: degC > 10
		? "#ABDDA4"
		: degC > 4.4
		? "#66C2A5"
		: degC > 0
		? "#3288BD"
		: "#5E4FA2";
}

/**
 * Return a color to match how hot it is.
 *
 * Reds for hot, blues for cold
 *
 * @param {number} degF Temp in Fahrenheit
 *
 * @returns {string} Hex color code
 */
function heatColorF(degF) {
	return degF > 100
		? "#9E1642"
		: degF > 90
		? "#D53E4F"
		: degF > 80
		? "#F46D43"
		: degF > 75
		? "#FDAE61"
		: degF > 70
		? "#FEE08B"
		: degF > 60
		? "#E6F598"
		: degF > 50
		? "#ABDDA4"
		: degF > 40
		? "#66C2A5"
		: degF > 32
		? "#3288BD"
		: "#5E4FA2";
}

function findIconCode() {
	let req = new XMLHttpRequest();

	var long = plasmoid.configuration.longitude;
	var lat = plasmoid.configuration.latitude;

	let url = "https://api.weather.com/v3/wx/observations/current";

	url += "?geocode=" + lat + "," + long;
	url += "&apiKey=6532d6454b8aa370768e63d6ba5a832e";
	url += "&language=en-US";
	url += "&units=e";
	url += "&format=json";

	req.open("GET", url, true);

	req.setRequestHeader("Accept-Encoding", "gzip");
	req.setRequestHeader("Origin", "https://www.wunderground.com");

	req.onerror = function () {
		printDebug(req.responseText);
	};

	printDebug(url);

	req.onreadystatechange = function () {
		if (req.readyState == 4) {
			if (req.status == 200) {
				var res = JSON.parse(req.responseText);

				iconCode = res["iconCode"];
				conditionNarrative = res["wxPhraseLong"];
			}
		}
	};

	req.send();
}

/////////////////////////////////////////////////////////////////
/// All of the following return what unit measures            ///
/// that property for each system. (Metric, Imperial, and UK) ///
/// The user can choose whether to prepend                    ///
/// a space in front of the unit. (32°F or 32 °F)             ///
/////////////////////////////////////////////////////////////////

function currentTempUnit(value, prependSpace = true) {
	var res = value;
	if (unitsChoice === 1) {
		res += returnSpace(prependSpace) + "°F";
	} else {
		res += returnSpace(prependSpace) + "°C";
	}
	return res;
}

function currentSpeedUnit(value, prependSpace = true) {
	var res = value;
	if (unitsChoice === 0) {
		res += returnSpace(prependSpace) + "kmh";
	} else {
		res += returnSpace(prependSpace) + "mph";
	}
	return res;
}

function currentElevUnit(value, prependSpace = true) {
	var res = value;
	if (unitsChoice === 0) {
		res += returnSpace(prependSpace) + "m";
	} else {
		res += returnSpace(prependSpace) + "ft";
	}
	return res;
}

function currentPrecipUnit(value, prependSpace = true) {
	var res = value;
	if (unitsChoice === 1) {
		res += returnSpace(prependSpace) + "in";
	} else {
		res += returnSpace(prependSpace) + "cm";
	}
	return res;
}

function currentPresUnit(value, prependSpace = true) {
	var res = value;
	if (unitsChoice === 1) {
		res += returnSpace(prependSpace) + "inHG";
	} else {
		res += returnSpace(prependSpace) + "hPa";
	}
	return res;
}

function returnSpace(shouldReturnSpace) {
	if (shouldReturnSpace) {
		return " ";
	} else {
		return "";
	}
}
