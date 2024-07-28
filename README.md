# Wunderground PWS Widget for KDE 6

A Plasma 6 widget for showing data from Wunderground [Personal Weather Stations](https://www.wunderground.com/pws/overview).

Wunderground lets you upload data from Smart Ambient Weather stations through their API.
You can view the data though Wunderground.com or through Wunderground API. This widget lets
you input the station ID then view the properties that the station sends up.

## Running

Configure the widget by finding weather stations (ie. [KGADACUL1](https://www.wunderground.com/dashboard/pws/KGADACUL1)). You can get an overview of stations in your area at [`wunderground.com/wundermap`](https://wunderground.com/wundermap) Weather station IDs can be entered manually or there is a search functionality to search by geographic region.

### Manual Entry

1. Enter the case-sensitive ID into the text field and press `Test Station`. The settings page will query the station to determine if it is reporting valid data.
    -   If it is valid, then the status bar will report that the station is active and can be used.
    -   Otherwise, the status bar will report that the station is not active and you must use a different station or check for a spelling error.
2. Then, press the `Select` button at the bottom right to add this station to the list of available stations.

### Geographic Search

1. Enter your city/locality into the top text field and press `Find Station`.
2. The combo box below will populate with localities matching your search. Choose the closest.
3. Further below, the combox box will populate with weather station IDs in that locality. Choose a desired station.
4. Press `Test Station` to determine if the station is reporting valid data. Like above,
    -   If it is valid, then the status bar will report that the station is active and can be used.
    -   Otherwise, the status bar will report that the station is not active and you must use a different station or check for a spelling error.
5. Then, press the `Select` button at the bottom right to add this station to the list of available stations.  

### Saved Weather Stations

Once a station has been added to the list, it is automatically selected and will be highlighted. Otherwise, click on the desired station ID then press `Select` at the bottom right.

Then, the station ID will appear on the config page and the settings can be applied to change the station.

Furthermore, some stations update at different rates so you can set the refresh rate.

## Translating

Translations welcome!

Follow the file in [plasmoid/translate](./plasmoid/translate) for directions.

## Meta

Big thanks to [@bluxart](https://x.com/bluxart) and [@pyconic](https://x.com/pyconic) for Meteocons the free [icons](https://www.alessioatzeni.com/meteocons/).

Big thanks to [Zren](https://github.com/Zren) for files from [`applet-lib`](https://github.com/Zren/plasma-applet-lib/) and [`applet-simpleweather`](https://github.com/Zren/plasma-applet-simpleweather/).

Upstream changes have also been merged back in from rliwoch's [`plasmoid-wunderground-extended`](https://github.com/rliwoch/plasmoid-wunderground-extended).

Portions of [CompactRepresentation](./plasmoid/contents/ui/CompactRepresentation.qml) and [IconAndTextItem](./plasmoid/contents/ui/IconAndTextItem.qml) are from `org.kde.plasma.weather`.

### Known Problems

Text coloring for dark/transparent themes is currently buggy in Plasma 6. The first time a widget loads the text may not be colored correctly.

Changing the transparency then back again seems to solve this issue. See [#58](https://github.com/k-donn/plasmoid-wunderground/issues/58).
Under Appearance in the widget settings, toggle "Show Background."

## TODO

- Porting
  -   [x] Update icons
  -   [x] Add AQI/weather warnings
  -   [x] Add sun rise/set info
  -   [x] Pressure rising/falling info
  -   [x] Github templates
- i18n
  -   [ ] Translations for new text
  -   [x] AQI/AQHI scale localization
- Customizability
  -   [x] Context menu refresh option
  -   [ ] Widget size/padding/scaling
  -   [ ] Allow removal of stations from saved stations
  -   [x] Specific units choice (eg. from km/h to m/s for metric)
- Graphical
  -   [ ] Improve text coloring of temp and alerts for dark/transparent themes
- Parking lot
  -   [ ] Have seperate error page for forecast errors and use bitmapped field for appState
  -   [ ] Use Wunderground Plasma Ion.
