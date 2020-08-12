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

function feelsLike(degF, relHumid, windSpeedMph) {
	if (degF >= 80 && relHumid >= 40) {
		return heatIndex(degF, relHumid);
	} else if (degF <= 50 && windSpeedMph >= 3) {
		return windChill(degF, windSpeedMph);
	} else {
		return degF;
	}
}

function heatIndex(degF, relHumid) {
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

function windChill(degF, windSpeedMph) {
	var newTemp =
		35.74 +
		0.6215 * degF -
		35.75 * Math.pow(windSpeedMph, 0.16) +
		0.4275 * degF * Math.pow(windSpeedMph, 0.16);
	return newTemp.toFixed(1);
}

function heatColor(degF) {
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
