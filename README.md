# Wunderground PWS Widget for KDE 6

A Plasma 6 widget for showing data from Wunderground [Personal Weather Stations](https://www.wunderground.com/pws/overview)

Wunderground lets you upload data from Smart Ambient Weather stations through their API.
You can view the data though wunderground or through Wunderground API. This widget lets
you input the station ID then view the properties that the station sends up.

## Running

Supply the name of the weatherstation (ie. [KGADACUL1](https://www.wunderground.com/dashboard/pws/KGADACUL1)) to the applet by clicking `Configure Wunderground`.

Also, input your coordinates and the widget will find the nearest station to you!

Some stations update at different rates so you can set the rate of refresh in config.

## Translating

Translations welcome!

Follow the file in [plasmoid/translate](./plasmoid/translate) for directions.

## Meta

Big thanks to Meteocons for the free [icons](https://www.alessioatzeni.com/meteocons/).

By [@bluxart](https://twitter.com/bluxart) and [@pyconic](https://twitter.com/pyconic) on Twitter.
If you are a graphic designer or simply know more about designing/using icons than me (I know little), feel free to contribute advice!

Big thanks to [Zren](https://github.com/Zren) for the files [NoApplyField](./plasmoid/contents/ui/config/NoApplyField.qml), [ClearableField](./plasmoid/contents/ui/config/ClearableField.qml), and the translation scripts.

[CompactRepresentation](./plasmoid/contents/ui/CompactRepresentation.qml) and [IconAndTextItem](./plasmoid/contents/ui/IconAndTextItem.qml) are from `org.kde.plasma.weather`.

The text coloring utility functions are from [@Gojira4](https://forum.qt.io/user/gojir4).

### Known Problems

Text coloring for dark/transparent themes is currently buggy in Plasma 6. The first time a widget loads the text may not be colored correctly.

Changing the transparency then back again seems to solve this issue. See #58.

## TODO

- Porting
    -   [x] Update icons
    -   [x] Add AQI/weather warnings
    -   [x] Add sun rise/set info
    -   [x] Pressure rising/falling info
    -   [ ] Github templates
-   i18n
    -   [ ] Translations for new text
    -   [x] AQI/AQHI scale localization
-   Customizability
    -   [x] Context menu refresh option
    -   [ ] Widget size/padding/scaling
    -   [x] Specific units choice (eg. from km/h to m/s for metric)
-   Graphical
    -   [ ] Improve text coloring of temp and alerts for dark/transparent themes
-   Parking lot
    -   [ ] Have seperate error page for forecast errors and use bitmapped field for appState
    -   [ ] Use Wunderground Plasma Ion.
