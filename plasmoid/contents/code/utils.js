/*
 * Copyright 2024  Kevin Donnelly
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

/** @type {object} */
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

function getWindBarb(windSpeed) {
	var speedKts;
	if (unitsChoice === 0) {
		speedKts = kmhToKts(windSpeed);
	} else {
		speedKts = mphToKts(windSpeed);
	}

	if (within(speedKts, 0, 2.9999)) {
		return "0-2";
	} else if (within(speedKts, 3, 7.9999)) {
		return "3-7";
	} else if (within(speedKts, 8, 12.9999)) {
		return "8-12";
	} else if (within(speedKts, 13, 17.9999)) {
		return "13-17";
	} else if (within(speedKts, 18, 22.9999)) {
		return "18-22";
	} else if (within(speedKts, 23, 27.9999)) {
		return "23-27";
	} else if (within(speedKts, 28, 32.9999)) {
		return "28-32";
	} else {
		return "28-32";
	}
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

function cToK(degC) {
	return degC + 273;
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

function kmhToMph(kmh) {
	return kmh * 0.6213711922;
}

function mphToKts(mph) {
	return mph * 0.8689758;
}

function kmhToKts(kmh) {
	return kmh * 0.5399565;
}

function ktsToMph(kts) {
	return kts / 0.8689758;
}

function ktsToKmh(kts) {
	return kts / 0.5399565;
}

/**
 * Returns whether value is within the range of [low, high).
 * Inclusive lower; exclusive upper
 *
 * @param {number} value Value to compare
 * @param {number} low Lower bound
 * @param {number} high Upper bound
 */
function within(value, low, high) {
	return value >= low && value < high;
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
 * @returns {number} What the air feels like in user units
 */
function feelsLike(temp, relHumid, windSpeed) {
	var degF, windSpeedMph, finalRes;
	if (unitsChoice === 0) {
		degF = cToF(temp);
		windSpeedMph = kmhToMph(windSpeed);

		var res = feelsLikeImperial(degF, relHumid, windSpeedMph);

		finalRes = fToC(res);
	} else if (unitsChoice === 1) {
		degF = temp;
		windSpeedMph = windSpeed;

		finalRes = feelsLikeImperial(degF, relHumid, windSpeedMph);
	} else if (unitsChoice === 2){
		degF = cToF(temp);
		windSpeedMph = windSpeed;

		var res = feelsLikeImperial(degF, relHumid, windSpeedMph);

		finalRes = fToC(res);
	} else {
		// When custom units are choosen, the API gives metric units.
		degF = cToF(temp);
		windSpeedMph = kmhToMph(windSpeed);

		var res = feelsLikeImperial(degF, relHumid, windSpeedMph);

		var tmpRes = fToC(res);

		finalRes = toUserTemp(tmpRes);
	}
	return finalRes.toFixed(2);
}

/**
 * Return what the air feels like in imperial units.
 *
 * @param {number} degF Temp in Fahrenheit
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
	return hIndex;
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
	return newTemp;
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


/////////////////////////////////////////////////////////////////
/// All of the following return what unit measures            ///
/// that property for each system. (Metric, Imperial, and UK) ///
/////////////////////////////////////////////////////////////////

/**
 * Take in API temp values and convert them to user choosen units.
 * When a user chooses custom units, the API returns metric. So,
 * convert from metric to choice.
 *
 * @param {number} Temp in Celcius
 *
 * @returns {number} Temp in user units
 */
function toUserTemp(value) {
	if (unitsChoice === UNITS_SYSTEM.METRIC) {
		return value;
	} else if (unitsChoice === UNITS_SYSTEM.IMPERIAL){
		return value;
	} else if (unitsChoice === UNITS_SYSTEM.HYBRID) {
		return value;
	} else {
		if (plasmoid.configuration.tempUnitsChoice === TEMP_UNITS.C){
			return value;
		} else if (plasmoid.configuration.tempUnitsChoice === TEMP_UNITS.F){
			return cToF(value);
		} else {
			return cToK(value);
		}
	}
}

function currentTempUnit(value) {
	var res = Math.round(value);
	if (unitsChoice === UNITS_SYSTEM.METRIC) {
		res += " °C";
	} else if (unitsChoice === UNITS_SYSTEM.IMPERIAL){
		res += " °F";
	} else if (unitsChoice === UNITS_SYSTEM.HYBRID) {
		res += " °C";
	} else {
		if (plasmoid.configuration.tempUnitsChoice === TEMP_UNITS.C){
			res += " °C";
		} else if (plasmoid.configuration.tempUnitsChoice === TEMP_UNITS.F){
			res += " °F";
		} else {
			res += " °K";
		}
	}
	return res;
}

function currentSpeedUnit(value) {
	var res = value;
	if (unitsChoice === 0) {
		res += " kmh";
	} else {
		res += " mph";
	}
	return res;
}

function currentElevUnit(value) {
	var res = value;
	if (unitsChoice === 0) {
		res += " m";
	} else {
		res += " ft";
	}
	return res;
}

function currentPrecipUnit(value, isRain) {
	if (isRain === undefined) {
		isRain = true;
	}
	var res = value;
	if (unitsChoice === 1) {
		res += " in";
	} else {
		if (isRain) {
			res += " mm";
		} else {
			res += " cm";
		}
	}
	return res;
}

function currentPresUnit(value) {
	var res = value;
	if (unitsChoice === 1) {
		res += " inHG";
	} else {
		res += " hPa";
	}
	return res;
}

