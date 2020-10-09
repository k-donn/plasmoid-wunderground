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

function cToF(degC) {
	return degC * 1.8 + 32;
}

function fToC(degF) {
	return (degF - 32) / 1.8;
}

function kmhToMph(kmh) {
	return kmh * 0.6213711922;
}

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

function feelsLikeImperial(degF, relHumid, windSpeedMph) {
	if (degF >= 80 && relHumid >= 40) {
		return heatIndexF(degF, relHumid);
	} else if (degF <= 50 && windSpeedMph >= 3) {
		return windChillF(degF, windSpeedMph);
	} else {
		return degF;
	}
}

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

function windChillF(degF, windSpeedMph) {
	var newTemp =
		35.74 +
		0.6215 * degF -
		35.75 * Math.pow(windSpeedMph, 0.16) +
		0.4275 * degF * Math.pow(windSpeedMph, 0.16);
	return newTemp.toFixed(1);
}

function heatColor(temp) {
	if (unitsChoice === 1) {
		return heatColorF(temp);
	} else {
		return heatColorC(temp);
	}
}

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

function currentTempUnit(prependSpace = true) {
	var res = "";
	if (unitsChoice === 1) {
		res = "°F";
	} else {
		res = "°C";
	}
	return withSpace(res, prependSpace);
}

function currentSpeedUnit(prependSpace = true) {
	var res = "";
	if (unitsChoice === 0) {
		res = "kmh";
	} else {
		res = "mph";
	}
	return withSpace(res, prependSpace);
}

function currentElevUnit(prependSpace = true) {
	var res = "";
	if (unitsChoice === 0) {
		res = "m";
	} else {
		res = "ft";
	}
	return withSpace(res, prependSpace);
}

function currentPrecipUnit(prependSpace = true) {
	var res = "";
	if (unitsChoice === 0) {
		res = "cm";
	} else {
		res = "in";
	}
	return withSpace(res, prependSpace);
}

function currentPresUnit(prependSpace = true) {
	var res = "";
	if (unitsChoice === 1) {
		res = "inHG";
	} else {
		res = "hPa";
	}
	return withSpace(res, prependSpace);
}

function withSpace(str, withSpace) {
	if (withSpace) {
		return " " + str;
	} else {
		return str;
	}
}
