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

let UNITS_SYSTEM = {
	METRIC: 0,
	IMPERIAL: 1,
	HYBRID: 2,
	CUSTOM: 3
}

let TEMP_UNITS = {
	C: 0,
	F: 1,
	K: 2
}

let WIND_UNITS = {
	KMH: 0,
	MPH: 1,
	MPS: 2
}

let RAIN_UNITS = {
	MM: 0,
	IN: 1,
	CM: 2,
}

let SNOW_UNITS = {
	MM: 0,
	IN: 1,
	CM: 2
}

let PRES_UNITS = {
	MB: 0,
	INHG: 1,
	MMHG: 2,
	HPA: 3
}

let ELEV_UNITS = {
	M: 0,
	FT: 1
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


/**
 * Return the filename of the wind barb that should be shown for
 * the given windspeed.
 *
 * @param {number} Wind speed in API units
 *
 * @retruns {string} Filename
 */
function getWindBarb(windSpeed) {
	var speedKts;
	if (unitsChoice === UNITS_SYSTEM.METRIC) {
		speedKts = kmhToKts(windSpeed);
	} else if (unitsChoice === UNITS_SYSTEM.IMPERIAL) {
		speedKts = mphToKts(windSpeed);
	} else if (unitsChoice === UNITS_SYSTEM.HYBRID) {
		speedKts = mphToKts(windSpeed);
	} else {
		speedKts = kmhToKts(windSpeed);
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

function cToF(degC) {
	return degC * 1.8 + 32;
}

function cToK(degC) {
	return degC + 273.15;
}

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

function kmhToMps(kmh) {
	return kmh * 0.2777778;
}

function ktsToMph(kts) {
	return kts * 1.15078;
}

function ktsToKmh(kts) {
	return kts * 1.852;
}

function mToFt(m) {
	return m * 3.28084;
}

function mmToIn(mm) {
	return mm * 0.0393701;
}

function mmToCm(mm) {
	return mm * 0.1;
}

function cmToMm(cm) {
	return cm * 10;
}

function cmToIn(cm) {
	return cm * 0.393701;
}

function mbToInhg(mb) {
	return mb * 0.02953;
}

function mbToMmhg(mb) {
	return mb * 0.750062;
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
 * @param {number} windSpeed Speed in kmh or mph
 *
 * @returns {number} What the air feels like in user units
 */
function feelsLike(temp, relHumid, windSpeed) {
	var degF, windSpeedMph, finalRes;
	if (unitsChoice === UNITS_SYSTEM.METRIC) {
		degF = cToF(temp);
		windSpeedMph = kmhToMph(windSpeed);

		var res = feelsLikeImperial(degF, relHumid, windSpeedMph);

		finalRes = fToC(res);
	} else if (unitsChoice === UNITS_SYSTEM.IMPERIAL) {
		degF = temp;
		windSpeedMph = windSpeed;

		finalRes = feelsLikeImperial(degF, relHumid, windSpeedMph);
	} else if (unitsChoice === UNITS_SYSTEM.HYBRID){
		degF = cToF(temp);
		windSpeedMph = windSpeed;

		var res = feelsLikeImperial(degF, relHumid, windSpeedMph);

		finalRes = fToC(res);
	} else {
		// When custom units are choosen, the API gives metric units.
		degF = cToF(temp);
		windSpeedMph = kmhToMph(windSpeed);

		var res = feelsLikeImperial(degF, relHumid, windSpeedMph);

		// Convery degF result to degC so it can be passed in extpect degC to toUserTemp
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
 * @param {number} temp Temp in API units
 *
 * @returns {string} Hex color code
 */
function heatColor(temp, bgColor) {
	if (unitsChoice === UNITS_SYSTEM.METRIC) {
        return heatColorC(temp, bgColor);
	} else if (unitsChoice === UNITS_SYSTEM.IMPERIAL){
        return heatColorF(temp, bgColor);
	} else if (unitsChoice === UNITS_SYSTEM.HYBRID) {
        return heatColorC(temp, bgColor);
	} else {
		// Then, temp is in Celcius
        return heatColorC(temp, bgColor);
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
function heatColorC(degC, bgColor) {
	return degC > 37.78
		? "#9E1642"
		: degC > 32.2
		? "#D53E4F"
		: degC > 26.6
		? "#F46D43"
		: degC > 23.9
		? "#FDAE61"
		: degC > 21.1
		? lightDark(bgColor, "#E2B434" ,"#FEE08B")
		: degC > 15.5
		? lightDark(bgColor, "#B1CC2E" , "#E6F598")
		: degC > 10
		? lightDark(bgColor, "#6EBA50", "#ABDDA4")
		: degC > 4.4
		? lightDark(bgColor, "#66C2A5", "#2F9374")
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
function heatColorF(degF, bgColor) {
	return degF > 100
		? "#9E1642"
		: degF > 90
		? "#D53E4F"
		: degF > 80
		? "#F46D43"
		: degF > 75
		? "#FDAE61"
		: degF > 70
		? lightDark(bgColor, "#E2B434" ,"#FEE08B")
		: degF > 60
		? lightDark(bgColor, "#B1CC2E" , "#E6F598")
		: degF > 50
		? lightDark(bgColor, "#6EBA50", "#ABDDA4")
		: degF > 40
		? lightDark(bgColor, "#66C2A5", "#2F9374")
		: degF > 32
		? "#3288BD"
		: "#5E4FA2";
}

// Credit to @Gojir4
/*!
 *   Select a color depending on whether the background is light or dark.
 *   \c lightColor is the color used on a light background.
 *   \c darkColor is the color used on a dark background.
 */
function lightDark(background, lightColor, darkColor) {
	return isDarkColor(background) ? darkColor : lightColor
}

/*!
 *   Returns true if the color is dark and should have light content on top
 */
function isDarkColor(background) {
	var temp = Qt.darker(background, 1) //Force conversion to color QML type object
	var a = 1 - ( 0.299 * temp.r + 0.587 * temp.g + 0.114 * temp.b);
	return temp.a > 0 && a >= 0.3
}

/**
 * Return an icon to represent the changing barometric pressure.
 * 
 * @param {0|1|2|3|4} code Code provided by API
 * @returns {string} Opendesktop icon name
 */
function getPressureTrendIcon(code) {
	if (code === 0) {
		return "list-remove-symbolic";
	} else if (code === 1) {
		return "arrow-up-symbolic";
	} else if (code === 2) {
		return "arrow-down-symbolic";
	} else if (code === 3) {
		return "arrow-up-double-symbolic";
	} else {
		return "arrow-down-double-symbolic";
	}
}

/**
 * Return whether pressure has increased.
 * True = increased
 * False = decreased/no change
 * 
 * @param {0|1|2|3|4} code Code provided by API
 * @returns {boolean}
 */
function hasPresIncreased(code) {
	if (code === 1 || code === 3) {
		return true;
	} else {
		return false;
	}
}


/**
 * Take in API temp values and convert them to user choosen units.
 * When a user chooses custom units, the API returns metric. So,
 * convert from metric to choice.
 *
 * @param {number} value Temp in API units
 *
 * @returns {number} Temp in user units
 */
function toUserTemp(value) {
	if (unitsChoice === UNITS_SYSTEM.CUSTOM) {
		// Then, value is in Celcius
		if (plasmoid.configuration.tempUnitsChoice === TEMP_UNITS.C){
			return value;
		} else if (plasmoid.configuration.tempUnitsChoice === TEMP_UNITS.F){
			return cToF(value);
		} else {
			return cToK(value);
		}
	} else {
		// The user wants the units the API gives
		return value;
	}
}


/**
 * Take in a numeric temperature value and return a string
 * with the user specified unit attached.
 *
 * @param {number} value Temperature
 *
 * @returns {string} User-shown value
 */
function currentTempUnit(value, shouldRound) {
	if (shouldRound === undefined) {
		shouldRound = true;
	}
	var res = shouldRound ? Math.round(value) : value;
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


/**
 * Take in API wind speed values and convert them to user choosen units.
 * When a user chooses custom units, the API returns metric. So,
 * convert from metric to choice.
 *
 * @param {number} value Wind speed in API units
 *
 * @returns {number} Wind speed in user units
 */
function toUserSpeed(value) {
	if (unitsChoice === UNITS_SYSTEM.CUSTOM) {
		// Then, value is in kmh
		if (plasmoid.configuration.windUnitsChoice === WIND_UNITS.KMH){
			return value;
		} else if (plasmoid.configuration.windUnitsChoice === WIND_UNITS.MPH){
			return kmhToMph(value);
		} else {
			return kmhToMps(value);
		}
	} else {
		// The user wants the units the API gives
		return value;
	}
}


/**
 * Take in a numeric wind speed value and return a string
 * with the user specified unit attached.
 *
 * @param {number} value Wind speed
 *
 * @returns {string} User-shown value
 */
function currentSpeedUnit(value) {
	var res = value.toFixed(1);
	if (unitsChoice === UNITS_SYSTEM.METRIC) {
		res += " kmh";
	} else if (unitsChoice === UNITS_SYSTEM.IMPERIAL){
		res += " mph";
	} else if (unitsChoice === UNITS_SYSTEM.HYBRID) {
		res += " mph";
	} else {
		if (plasmoid.configuration.windUnitsChoice === WIND_UNITS.KMH){
			res += " kmh";
		} else if (plasmoid.configuration.windUnitsChoice === WIND_UNITS.MPH){
			res += " mph";
		} else {
			res += " m/s";
		}
	}
	return res;
}


/**
 * Take in API elevation and convert it to user choosen units.
 * When a user chooses custom units, the API returns metric. So,
 * convert from metric to choice.
 *
 * @param {number} value Elevation in API units
 *
 * @returns {number} Wind speed in user units
 */
function toUserElev(value) {
	if (unitsChoice === UNITS_SYSTEM.CUSTOM) {
		// Then, value is in meters
		if (plasmoid.configuration.elevUnitsChoice === ELEV_UNITS.M) {
			return value;
		} else {
			return mToFt(value);
		}
	} else {
		// The user wants the units the API gives
		return value;
	}
}

/**
 * Take in a numeric elevation value and return a string
 * with the user specified unit attached.
 *
 * @param {number} value Elevation
 *
 * @returns {string} User-shown value
 */
function currentElevUnit(value) {
	var res = Math.round(value);
	if (unitsChoice === UNITS_SYSTEM.METRIC) {
		res += " m";
	} else if (unitsChoice === UNITS_SYSTEM.IMPERIAL) {
		res += " ft";
	} else if (unitsChoice === UNITS_SYSTEM.HYBRID) {
		res += " ft";
	} else {
		if (plasmoid.configuration.elevUnitsChoice === ELEV_UNITS.M) {
			res += " m";
		} else {
			res += " ft";
		}
	}
	return res;
}


/**
 * Take in API precip and convert it to user choosen units.
 * When a user chooses custom units, the API returns metric. So,
 * convert from metric to choice.
 *
 * @param {number} value Precip in API units
 *
 * @returns {number} Precip in user units
 */
function toUserPrecip(value, isRain) {
	if (isRain === undefined) {
		isRain = true;
	}
	if (unitsChoice === UNITS_SYSTEM.CUSTOM) {
		if (isRain) {
			// Then, value is in mm
			if (plasmoid.configuration.rainUnitsChoice === RAIN_UNITS.MM){
				return value;
			} else if (plasmoid.configuration.rainUnitsChoice === RAIN_UNITS.IN){
				return mmToIn(value);
			} else {
				return mmToCm(value);
			}
		} else {
			// Then, value is in cm
			if (plasmoid.configuration.snowUnitsChoice === SNOW_UNITS.MM){
				return cmToMm(value);
			} else if (plasmoid.configuration.snowUnitsChoice === SNOW_UNITS.IN){
				return cmToIn(value);
			} else {
				return value;
			}
		}
	} else {
		// The user wants the units the API gives
		return value;
	}
}

/**
 * Take in a numeric precip value and return a string
 * with the user specified unit attached.
 *
 * @param {number} value Precipitation
 *
 * @returns {string} User-shown value
 */
function currentPrecipUnit(value, isRain) {
	var res = value.toFixed(2);
	if (isRain === undefined) {
		isRain = true;
	}
	if (unitsChoice === UNITS_SYSTEM.METRIC) {
		if (isRain) {
			res += " mm";
		} else {
			res += " cm";
		}
	} else if (unitsChoice === UNITS_SYSTEM.IMPERIAL) {
		return res += " in";
	} else if (unitsChoice === UNITS_SYSTEM.HYBRID) {
		if (isRain) {
			res += " mm";
		} else {
			res += " cm";
		}
	} else {
		// This is not redundant because the user can choose different rain/snow
		// units and the result of this function must reflect that.
		if (isRain) {
			if (plasmoid.configuration.rainUnitsChoice === RAIN_UNITS.MM){
				res += " mm";
			} else if (plasmoid.configuration.rainUnitsChoice === RAIN_UNITS.IN){
				res += " in";
			} else {
				res += " cm";
			}
		} else {
			if (plasmoid.configuration.snowUnitsChoice === SNOW_UNITS.MM){
				res += " mm";
			} else if (plasmoid.configuration.snowUnitsChoice === SNOW_UNITS.IN){
				res += " in";
			} else {
				res += " cm";
			}
		}
	}
	return res;
}


/**
 * Take in API pressure and convert it to user choosen units.
 * When a user chooses custom units, the API returns metric. So,
 * convert from metric to choice.
 *
 * @param {number} value Precip in API units
 *
 * @returns {number} Precip in user units
 */
function toUserPres(value) {
	if (unitsChoice === UNITS_SYSTEM.CUSTOM) {
		// Then, value is in mb
		if (plasmoid.configuration.presUnitsChoice === PRES_UNITS.MB){
			return value;
		} else if (plasmoid.configuration.presUnitsChoice === PRES_UNITS.INHG){
			return mbToInhg(value);
		} else if (plasmoid.configuration.presUnitsChoice === PRES_UNITS.MMHG) {
			return mbToMmhg(value);
		} else {
			return value;
		}
	} else {
		// The user wants the units the API gives
		return value;
	}
}


/**
 * Take in a numeric pressure value and return a string
 * with the user specified unit attached.
 *
 * @param {number} value Precipitation
 *
 * @returns {string} User-shown value
 */
function currentPresUnit(value) {
	var res = value.toFixed(2);
	if (unitsChoice === UNITS_SYSTEM.METRIC) {
		res += " mb";
	} else if (unitsChoice === UNITS_SYSTEM.IMPERIAL) {
		res += " inHG";
	} else if (unitsChoice === UNITS_SYSTEM.HYBRID) {
		res += " mb";
	} else {
		if (plasmoid.configuration.presUnitsChoice === PRES_UNITS.MB){
			res += " mb";
		} else if (plasmoid.configuration.presUnitsChoice === PRES_UNITS.INHG){
			res += " inHG";
		} else if (plasmoid.configuration.presUnitsChoice === PRES_UNITS.MMHG) {
			res += " mmHG";
		} else {
			res += " hPa";
		}
	}
	return res;
}

