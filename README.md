# Wunderground PWS Widget for KDE 6

A Plasma 6 widget for showing data from Wunderground [Personal Weather Stations](https://www.wunderground.com/pws/overview).

Wunderground lets you upload data from Smart Ambient Weather stations through their API.
You can view the data though Wunderground.com or through Wunderground API. This widget lets
you input the station ID then view the properties that the station sends up.

## Running

Configure the widget by finding weather stations (ie. [KGADACUL1](https://www.wunderground.com/dashboard/pws/KGADACUL1)). You can get an overview of stations in your area at [`wunderground.com/wundermap`](https://wunderground.com/wundermap).

Navigate to the settings page by clicking `Configure Wunderground` or right-clicking the widget. Then, under `Station`, click `Choose...`. This will open up the saved stations dialog. Enter the case-sensitive ID into the field then press `Add` or hit enter.

Once a station has been added to the list, it is automatically selected and will be highlighted. Otherwise, click on the desired station ID then press `Select` at the bottom right.

Then, the station ID will appear on the config page and the settings can be applied to change the station.

Furthermore, some stations update at different rates so you can set the refresh rate.

### Removing Stations

Navigate back to the saved stations dialog and select the station to be removed. Click the `Remove` button at the bottom left and then confirm the removal. You can then close the window or click `Cancel`. If you have removed all of the stations, you can close the window or click `Cancel` as well.

## Translating

Translations welcome!

Follow the file in [plasmoid/translate](./plasmoid/translate) for directions.

## Meta

Big thanks to [@bluxart](https://x.com/bluxart) and [@pyconic](https://x.com/pyconic) for Meteocons the free [icons](https://www.alessioatzeni.com/meteocons/).

Big thanks to [Zren](https://github.com/Zren) for files from [`applet-lib`](https://github.com/Zren/plasma-applet-lib/) and [`applet-simpleweather`](https://github.com/Zren/plasma-applet-simpleweather/).

Upstream changes have also been merged back in from rliwoch's [`plasmoid-wunderground-extended`](https://github.com/rliwoch/plasmoid-wunderground-extended).

Portions of [CompactRepresentation](./plasmoid/contents/ui/CompactRepresentation.qml) and [IconAndTextItem](./plasmoid/contents/ui/IconAndTextItem.qml) are from `org.kde.plasma.weather`.

The text coloring utilities are thanks to @Gojir4 on the QML forum.

### Known Problems

Text coloring for dark/transparent themes is currently buggy in Plasma 6. The first time a widget loads the text may not be colored correctly.

Changing the transparency then back again seems to solve this issue. See [#58](https://github.com/k-donn/plasmoid-wunderground/issues/58).
Under Appearance in the widget settings, toggle "Show Background."

## TODO

- i18n
  -   [ ] Translations for new text
  -   [x] AQI/AQHI scale localization
- Customizability
  -   [ ] Move to Qt contols font dialog
  -   [ ] Option to show temperature in compact rep
  -   [ ] Widget size/padding/scaling
- Graphical
  -   [x] Improve text coloring of temp and alerts for dark/transparent themes
- Parking lot
  -   [ ] Have seperate error page for forecast errors and use bitmapped field for appState
  -   [ ] Use Wunderground Plasma Ion.
