/*
 * QWeather API for KDE Plasma Weather Widget
 * Based on plasmoid-wunderground by Kevin Donnelly
 * Modified to use QWeather (和风天气) API
 *
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public License as
 * published by the Free Software Foundation; either version 2 of
 * the License, or (at your option) any later version.
 */

// Load utility definitions
try {
	if (typeof Qt !== "undefined" && Qt.include) Qt.include("utils.js");
} catch (e) {
	// If Qt is not available, ignore.
}

if (typeof Utils === "undefined") {
	var Utils = {
		UNITS_SYSTEM: typeof UNITS_SYSTEM !== "undefined" ? UNITS_SYSTEM : {},
		PRES_UNITS: typeof PRES_UNITS !== "undefined" ? PRES_UNITS : {},
		hourlyModelDictV1: typeof hourlyModelDictV1 !== "undefined" ? hourlyModelDictV1 : {},
		hourlyModelDictV3: typeof hourlyModelDictV3 !== "undefined" ? hourlyModelDictV3 : {},
		severityColorMap: typeof severityColorMap !== "undefined" ? severityColorMap : {},
		toUserProp: typeof toUserProp !== "undefined" ? toUserProp : function (val) { return val; },
		getQWeatherAPIKey: typeof getQWeatherAPIKey !== "undefined" ? getQWeatherAPIKey : function () { return ""; },
	};
}

// QWeather API endpoints
// Note: API Host is project-specific, configured in settings
var QWEATHER_DEFAULT_HOST = "https://py2tupevtf.re.qweatherapi.com";

// QWeather icon code to Wunderground icon code mapping
var qweatherIconMap = {
	// Sunny/Clear
	"100": 32, // Sunny -> Sunny
	"150": 31, // Clear (night) -> Clear Night
	// Cloudy
	"101": 26, // Cloudy -> Cloudy
	"102": 30, // Few Clouds -> Partly Cloudy
	"103": 28, // Partly Cloudy -> Mostly Cloudy
	"104": 26, // Overcast -> Cloudy
	"151": 29, // Few Clouds Night
	"152": 27, // Partly Cloudy Night
	"153": 27, // Mostly Cloudy Night
	// Rain
	"300": 11, // Shower Rain -> Showers
	"301": 12, // Heavy Shower Rain -> Rain
	"302": 4,  // Thundershower -> Thunderstorms
	"303": 4,  // Heavy Thunderstorm
	"304": 17, // Hail -> Hail
	"305": 9,  // Light Rain -> Drizzle
	"306": 11, // Moderate Rain -> Showers
	"307": 12, // Heavy Rain -> Rain
	"308": 12, // Extreme Rain
	"309": 9,  // Drizzle Rain
	"310": 12, // Storm
	"311": 12, // Heavy Storm
	"312": 12, // Severe Storm
	"313": 8,  // Freezing Rain
	"314": 9,  // Light to Moderate Rain
	"315": 11, // Moderate to Heavy Rain
	"316": 12, // Heavy Rain to Storm
	"317": 12, // Storm to Heavy Storm
	"318": 12, // Heavy to Severe Storm
	"350": 45, // Shower Rain Night
	"351": 45, // Heavy Shower Rain Night
	// Snow
	"400": 14, // Light Snow
	"401": 16, // Moderate Snow
	"402": 43, // Heavy Snow
	"403": 43, // Snowstorm
	"404": 5,  // Sleet
	"405": 6,  // Rain and Snow
	"406": 6,  // Shower Rain and Snow
	"407": 13, // Snow Flurries
	"408": 14, // Light to Moderate Snow
	"409": 16, // Moderate to Heavy Snow
	"410": 43, // Heavy Snow to Snowstorm
	"456": 46, // Shower Rain and Snow Night
	"457": 46, // Snow Flurries Night
	// Fog/Haze
	"500": 20, // Mist
	"501": 21, // Fog
	"502": 22, // Haze
	"503": 19, // Sand
	"504": 19, // Dust
	"507": 19, // Sandstorm
	"508": 19, // Severe Sandstorm
	"509": 21, // Dense Fog
	"510": 21, // Strong Fog
	"511": 22, // Moderate Haze
	"512": 22, // Heavy Haze
	"513": 22, // Severe Haze
	"514": 21, // Heavy Fog
	"515": 21, // Extra Heavy Fog
	// Wind
	"900": 32, // Hot
	"901": 25, // Cold
	// Unknown
	"999": 44, // Unknown
};

/**
 * Build a URL-encoded query string from an object of parameters.
 */
function _buildQuery(params) {
	var pairs = [];
	for (var k in params) {
		if (!params.hasOwnProperty(k)) continue;
		var v = params[k];
		if (v === undefined || v === null) continue;
		pairs.push(encodeURIComponent(k) + "=" + encodeURIComponent(v));
	}
	return pairs.length ? pairs.join("&") : "";
}

/**
 * Normalize language code for QWeather API.
 * QWeather only accepts simple codes like "zh", not "zh-CN".
 */
function _normalizeLanguage(lang) {
	if (!lang) return "zh";
	if (lang.indexOf("-") !== -1) {
		return lang.split("-")[0];
	}
	if (lang.indexOf("_") !== -1) {
		return lang.split("_")[0];
	}
	return lang;
}

/**
 * Build a full request URL for QWeather API.
 */
function _buildUrl(host, path, params) {
	var q = _buildQuery(params);
	return host + path + (q ? (path.indexOf("?") === -1 ? "?" : "&") + q : "");
}

/**
 * Perform a GET request to QWeather API.
 */
function _httpGet(url, apiKey, cb) {
	var req = new XMLHttpRequest();
	req.open("GET", url);
	// QWeather uses X-QW-Api-Key header for authentication
	if (apiKey) {
		req.setRequestHeader("X-QW-Api-Key", apiKey);
	}
	req.onerror = function () {
		cb(
			{ type: "Could not send request", message: req.statusText || "Network error" },
			null,
			req.status,
			req.responseText
		);
	};
	req.onreadystatechange = function () {
		if (req.readyState !== 4) return;
		if (req.status === 200) {
			try {
				var parsed = req.responseText ? JSON.parse(req.responseText) : null;
				// QWeather returns code "200" for success
				if (parsed && parsed.code === "200") {
					cb(null, parsed, req.status, req.responseText);
				} else if (parsed && parsed.error) {
					cb(
						{ type: parsed.error.status || "error", message: parsed.error.detail || parsed.error.title || "API error" },
						null,
						req.status,
						req.responseText
					);
				} else {
					cb(
						{ type: parsed ? parsed.code : "unknown", message: "API error: " + (parsed ? parsed.code : "unknown") },
						null,
						req.status,
						req.responseText
					);
				}
			} catch (e) {
				cb({ type: "parse", message: e.message }, null, req.status, req.responseText);
			}
		} else {
			cb(
				{ type: req.status || "network", message: req.responseText || "Request failed" },
				null,
				req.status,
				req.responseText
			);
		}
	};
	req.send();
}

/**
 * Convert QWeather icon code to Wunderground icon code.
 */
function _mapIconCode(qweatherIcon) {
	return qweatherIconMap[qweatherIcon] || 44;
}

/**
 * Convert units choice to QWeather unit parameter.
 */
function _unitsToQuery(unitsChoice) {
	if (unitsChoice === Utils.UNITS_SYSTEM.IMPERIAL) return "i";
	return "m"; // metric is default
}

/**
 * Handle API fields that could be null.
 */
function nullableField(value) {
	if (value !== null && value !== undefined && value !== "") {
		return value;
	} else {
		return "--";
	}
}

/**
 * Get air quality scale for locale.
 */
function getAQScale(localeOrCountry) {
	return "EPA";
}

/**
 * Search for cities by name using QWeather GeoAPI.
 */
function getLocations(city, options, callback) {
	options = options || {};
	callback = callback || function () {};

	var apiKey = options.apiKey || "";
	var language = _normalizeLanguage(options.language);

	var url = _buildUrl(QWEATHER_DEFAULT_HOST, "/geo/v2/city/lookup", {
		location: city,
		lang: language,
		number: 10,
	});

	printDebug("[qweather-api.js] getLocations: " + url);

	_httpGet(url, apiKey, function (err, res, status, raw) {
		if (err || status !== 200) {
			if (status === 404 || (res && res.code === "404")) {
				callback({ type: "404", message: "Location not found" }, null);
			} else {
				callback(err || { type: status || "network", message: raw || "Request failed" }, null);
			}
			return;
		}

		var locationsArr = [];
		var locations = res && res.location ? res.location : [];
		for (var i = 0; i < locations.length; i++) {
			var loc = locations[i];
			locationsArr.push({
				address: loc.name + ", " + loc.adm1 + ", " + loc.country,
				latitude: parseFloat(loc.lat),
				longitude: parseFloat(loc.lon),
				locationId: loc.id,
				name: loc.name,
			});
		}

		callback(null, locationsArr);
	});
}

/**
 * Search for a location by coordinates.
 */
function searchGeocode(latLongObj, options, callback) {
	options = options || {};
	callback = callback || function () {};

	var apiKey = options.apiKey || "";
	var latitude = latLongObj.latitude;
	var longitude = latLongObj.longitude;

	var url = _buildUrl(QWEATHER_DEFAULT_HOST, "/geo/v2/city/lookup", {
		location: longitude + "," + latitude,
		number: 10,
	});

	printDebug("[qweather-api.js] searchGeocode: " + url);

	_httpGet(url, apiKey, function (err, res, status, raw) {
		if (err || status !== 200) {
			callback(err || { type: status || "network", message: raw || "Request failed" }, null);
			return;
		}

		var stationsArr = [];
		var locations = res && res.location ? res.location : [];
		for (var i = 0; i < locations.length; i++) {
			var loc = locations[i];
			stationsArr.push({
				stationID: loc.id,
				address: loc.name + ", " + loc.adm1,
				latitude: parseFloat(loc.lat),
				longitude: parseFloat(loc.lon),
				qcStatus: 0,
			});
		}

		callback(null, stationsArr);
	});
}

/**
 * Search for station by text query (alias for getLocations).
 */
function searchStationID(query, options, callback) {
	options = options || {};
	callback = callback || function () {};

	var apiKey = options.apiKey || "";

	getLocations(query, { apiKey: apiKey, language: options.language }, function (err, locations) {
		if (err) {
			callback(err, null);
			return;
		}

		var stationsArr = [];
		for (var i = 0; i < locations.length; i++) {
			var loc = locations[i];
			stationsArr.push({
				stationID: loc.locationId,
				address: loc.address,
				latitude: loc.latitude,
				longitude: loc.longitude,
				qcStatus: 0,
			});
		}

		callback(null, stationsArr);
	});
}

/**
 * Check if a station/location is active.
 */
function isStationActive(givenID, options, callback) {
	options = options || {};
	callback = callback || function () {};

	// QWeather locations are always "active"
	callback(null, { isActive: true, healthCount: 10 });
}

/**
 * Fetch current weather data from QWeather.
 */
function getCurrentData(options, callback) {
	options = options || {};
	callback = callback || function () {};

	var locationId = options.stationID;
	var apiKey = options.apiKey || "";
	var units = options.unitsChoice !== undefined ? options.unitsChoice : Utils.UNITS_SYSTEM.METRIC;
	var prevWeather = options.oldWeatherData || null;

	var url = _buildUrl(QWEATHER_DEFAULT_HOST, "/v7/weather/now", {
		location: locationId,
		unit: _unitsToQuery(units),
		lang: "zh",
	});

	printDebug("[qweather-api.js] getCurrentData: " + url);

	_httpGet(url, apiKey, function (err, res, status, raw) {
		if (err || status !== 200) {
			callback(err || { type: status || "network", message: raw || "Request failed" }, null);
			return;
		}

		var now = res && res.now ? res.now : {};

		var newWeather = {
			stationID: locationId,
			uv: nullableField(now.uv || (prevWeather ? prevWeather.uv : 0)),
			humidity: parseInt(now.humidity) || 0,
			solarRad: nullableField(prevWeather ? prevWeather.solarRad : 0),
			obsTimeLocal: now.obsTime || "",
			winddir: parseInt(now.wind360) || 0,
			latitude: options.latitude || (prevWeather ? prevWeather.latitude : 0),
			longitude: options.longitude || (prevWeather ? prevWeather.longitude : 0),
			neighborhood: options.stationName || (prevWeather ? prevWeather.neighborhood : ""),
			isNight: prevWeather ? prevWeather.isNight : false,
			sunrise: prevWeather ? prevWeather.sunrise : "",
			sunset: prevWeather ? prevWeather.sunset : "",
			details: {
				temp: parseFloat(now.temp) || 0,
				heatIndex: parseFloat(now.feelsLike) || 0,
				dewpt: parseFloat(now.dew) || 0,
				windChill: parseFloat(now.feelsLike) || 0,
				windSpeed: parseFloat(now.windSpeed) || 0,
				windGust: parseFloat(now.windSpeed) || 0,
				pressure: parseFloat(now.pressure) || 0,
				pressureTrend: prevWeather ? prevWeather.details.pressureTrend : "Steady",
				pressureTrendCode: prevWeather ? prevWeather.details.pressureTrendCode : 0,
				pressureDelta: prevWeather ? prevWeather.details.pressureDelta : 0,
				precipRate: parseFloat(now.precip) || 0,
				precipTotal: parseFloat(now.precip) || 0,
				elev: 0,
				solarRad: prevWeather ? prevWeather.solarRad : null,
			},
			aq: prevWeather && prevWeather.aq ? prevWeather.aq : {},
		};

		var configUpdates = {
			latitude: options.latitude,
			longitude: options.longitude,
			stationName: options.stationName,
		};

		callback(null, {
			weatherData: newWeather,
			configUpdates: configUpdates,
		});
	});
}

/**
 * Fetch extended conditions (sunrise/sunset, icon, alerts, AQ).
 */
function getExtendedConditions(options, callback) {
	options = options || {};
	callback = callback || function () {};

	var locationId = options.stationID || "";
	var apiKey = options.apiKey || "";
	var units = options.unitsChoice !== undefined ? options.unitsChoice : Utils.UNITS_SYSTEM.METRIC;
	var longitude = options.longitude;
	var latitude = options.latitude;

	// Use coordinates if no locationId
	var location = locationId || (longitude + "," + latitude);

	// Fetch current weather for icon and conditions
	var weatherUrl = _buildUrl(QWEATHER_DEFAULT_HOST, "/v7/weather/now", {
		location: location,
		unit: _unitsToQuery(units),
		lang: "zh",
	});

	printDebug("[qweather-api.js] getExtendedConditions weather: " + weatherUrl);

	_httpGet(weatherUrl, apiKey, function (err, res, status, raw) {
		if (err || status !== 200) {
			callback(err || { type: status || "network", message: raw || "Request failed" }, null);
			return;
		}

		var now = res && res.now ? res.now : {};
		var iconCode = _mapIconCode(now.icon);
		var isNight = parseInt(now.icon) >= 150 && parseInt(now.icon) < 200;

		// Fetch sun data
		var today = new Date();
		var dateStr = today.getFullYear() + "-" +
			String(today.getMonth() + 1).padStart(2, "0") + "-" +
			String(today.getDate()).padStart(2, "0");

		var sunUrl = _buildUrl(QWEATHER_DEFAULT_HOST, "/v7/astronomy/sun", {
			location: location,
			date: dateStr,
		});

		_httpGet(sunUrl, apiKey, function (sunErr, sunRes) {
			var sunrise = "";
			var sunset = "";
			if (!sunErr && sunRes) {
				sunrise = sunRes.sunrise || "";
				sunset = sunRes.sunset || "";
			}

			// Fetch alerts
			var alertUrl = _buildUrl(QWEATHER_DEFAULT_HOST, "/v7/warning/now", {
				location: location,
				lang: "zh",
			});

			_httpGet(alertUrl, apiKey, function (alertErr, alertRes) {
				var alertsList = [];
				if (!alertErr && alertRes && alertRes.warning) {
					for (var i = 0; i < alertRes.warning.length; i++) {
						var alert = alertRes.warning[i];
						alertsList.push({
							desc: alert.typeName || alert.title,
							severity: alert.severityColor || "Yellow",
							severityColor: alert.severityColor === "Red" ? "#cc3300" :
								alert.severityColor === "Orange" ? "#ff9966" :
								alert.severityColor === "Yellow" ? "#ffcc00" : "#99cc33",
							headline: alert.title,
							area: alert.sender,
							action: "",
							source: alert.sender,
							disclaimer: "",
						});
					}
				}

				// Fetch air quality
				var aqUrl = _buildUrl(QWEATHER_DEFAULT_HOST, "/v7/air/now", {
					location: location,
					lang: "zh",
				});

				_httpGet(aqUrl, apiKey, function (aqErr, aqRes) {
					var aqObj = null;
					if (!aqErr && aqRes && aqRes.now) {
						var aq = aqRes.now;
						aqObj = {
							aqi: parseInt(aq.aqi) || 0,
							aqhi: parseInt(aq.level) || 0,
							aqDesc: aq.category || "Good",
							aqColor: aq.level <= 2 ? "00E400" : aq.level <= 3 ? "FFFF00" : aq.level <= 4 ? "FF7E00" : "FF0000",
							aqPrimary: aq.primary || "PM2.5",
							primaryDetails: {
								phrase: aq.primary || "PM2.5",
								amount: parseFloat(aq.pm2p5) || 0,
								unit: "ug/m3",
								desc: aq.category || "Good",
								index: parseInt(aq.aqi) || 0,
							},
							messages: {
								general: { title: "", phrase: "" },
								sensitive: { title: "", phrase: "" },
							},
						};
					}

					var result = {
						isNight: isNight,
						sunriseTimeLocal: sunrise,
						sunsetTimeLocal: sunset,
						pressureTendencyTrend: "Steady",
						pressureTendencyCode: 0,
						pressureDelta: 0,
						iconCode: iconCode,
						conditionNarrative: now.text || "",
						isRain: now.icon >= 300 && now.icon < 400,
						alerts: alertsList,
						airQuality: aqObj,
					};

					callback(null, result);
				});
			});
		});
	});
}

/**
 * Fetch 7-day forecast data from QWeather.
 */
function getForecastData(options, callback) {
	options = options || {};
	callback = callback || function () {};

	var locationId = options.stationID || "";
	var apiKey = options.apiKey || "";
	var units = options.unitsChoice !== undefined ? options.unitsChoice : Utils.UNITS_SYSTEM.METRIC;
	var longitude = options.longitude;
	var latitude = options.latitude;

	var location = locationId || (longitude + "," + latitude);

	var url = _buildUrl(QWEATHER_DEFAULT_HOST, "/v7/weather/7d", {
		location: location,
		unit: _unitsToQuery(units),
		lang: "zh",
	});

	printDebug("[qweather-api.js] getForecastData: " + url);

	_httpGet(url, apiKey, function (err, res, status, raw) {
		if (err || status !== 200) {
			callback(err || { type: status || "network", message: raw || "Request failed" }, null);
			return;
		}

		var dailyData = res && res.daily ? res.daily : [];
		var forecastArr = [];

		for (var i = 0; i < dailyData.length; i++) {
			var day = dailyData[i];
			var date = new Date(day.fxDate);
			var dayNames = ["周日", "周一", "周二", "周三", "周四", "周五", "周六"];

			forecastArr.push({
				date: date,
				dayOfWeek: i === 0 ? "今天" : dayNames[date.getDay()],
				iconCode: _mapIconCode(day.iconDay),
				high: parseInt(day.tempMax) || 0,
				low: parseInt(day.tempMin) || 0,
				feelsLike: parseInt(day.tempMax) || 0,
				shortDesc: day.textDay || "",
				longDesc: day.textDay + "，" + day.textNight,
				thunderDesc: "N/A",
				windDesc: day.windDirDay + " " + day.windScaleDay + "级",
				uvDesc: day.uvIndex ? "UV " + day.uvIndex : "N/A",
				snowDesc: "N/A",
				golfDesc: "N/A",
			});
		}

		var currDayHigh = forecastArr.length ? forecastArr[0].high : null;
		var currDayLow = forecastArr.length ? forecastArr[0].low : null;

		callback(null, {
			forecast: forecastArr,
			currDayHigh: currDayHigh,
			currDayLow: currDayLow,
		});
	});
}

// Alias for compatibility
function getForecastDataV1(options, callback) {
	getForecastData(options, callback);
}

function getForecastDataV3(options, callback) {
	getForecastData(options, callback);
}

/**
 * Fetch hourly forecast data from QWeather.
 */
function getHourlyData(options, callback) {
	options = options || {};
	callback = callback || function () {};

	var locationId = options.stationID || "";
	var apiKey = options.apiKey || "";
	var units = options.unitsChoice !== undefined ? options.unitsChoice : Utils.UNITS_SYSTEM.METRIC;
	var longitude = options.longitude;
	var latitude = options.latitude;

	var location = locationId || (longitude + "," + latitude);

	var url = _buildUrl(QWEATHER_DEFAULT_HOST, "/v7/weather/24h", {
		location: location,
		unit: _unitsToQuery(units),
		lang: "zh",
	});

	printDebug("[qweather-api.js] getHourlyData: " + url);

	_httpGet(url, apiKey, function (err, res, status, raw) {
		if (err || status !== 200) {
			callback(err || { type: status || "network", message: raw || "Request failed" }, null);
			return;
		}

		var hourlyData = res && res.hourly ? res.hourly : [];
		var hourlyArr = [];
		var localMax = {
			temperature: Number.NEGATIVE_INFINITY,
			cloudCover: Number.NEGATIVE_INFINITY,
			humidity: Number.NEGATIVE_INFINITY,
			precipitationChance: Number.NEGATIVE_INFINITY,
			precipitationRate: Number.NEGATIVE_INFINITY,
			snowPrecipitationRate: Number.NEGATIVE_INFINITY,
			wind: Number.NEGATIVE_INFINITY,
			pressure: Number.NEGATIVE_INFINITY,
			uvIndex: Number.NEGATIVE_INFINITY,
		};

		for (var i = 0; i < Math.min(hourlyData.length, 22); i++) {
			var hour = hourlyData[i];
			var time = new Date(hour.fxTime);

			var hourModel = {
				time: time,
				temperature: parseFloat(hour.temp) || 0,
				cloudCover: parseInt(hour.cloud) || 0,
				humidity: parseInt(hour.humidity) || 0,
				precipitationChance: parseInt(hour.pop) || 0,
				precipitationRate: parseFloat(hour.precip) || 0,
				snowPrecipitationRate: 0,
				wind: parseFloat(hour.windSpeed) || 0,
				pressure: parseFloat(hour.pressure) || 0,
				uvIndex: 0,
				iconCode: _mapIconCode(hour.icon),
			};

			// Update max values
			for (var key in localMax) {
				if (hourModel[key] !== undefined && hourModel[key] > localMax[key]) {
					localMax[key] = hourModel[key];
				}
			}

			hourlyArr.push(hourModel);
		}

		// Sanitize max values
		var sanitizedMax = {};
		for (var lm in localMax) {
			sanitizedMax[lm] = localMax[lm] === Number.NEGATIVE_INFINITY ? 0 : localMax[lm];
		}

		// Build range dict
		var rangeDict = {
			cloudCover: 100,
			humidity: 100,
			precipitationChance: 100,
			pressure: 70,
			temperature: sanitizedMax.temperature,
			precipitationRate: sanitizedMax.precipitationRate,
			snowPrecipitationRate: sanitizedMax.snowPrecipitationRate,
			wind: sanitizedMax.wind,
			uvIndex: sanitizedMax.uvIndex,
		};

		callback(null, {
			hourly: hourlyArr,
			maxValDict: sanitizedMax,
			rangeValDict: rangeDict,
		});
	});
}

// Alias for compatibility
function getHourlyDataV1(options, callback) {
	getHourlyData(options, callback);
}

function getHourlyDataV3(options, callback) {
	getHourlyData(options, callback);
}
