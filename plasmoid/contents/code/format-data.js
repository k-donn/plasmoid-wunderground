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
	return hIndex.toFixed(2);
}
