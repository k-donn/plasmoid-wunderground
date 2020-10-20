# Wunderground PWS Widget for KDE 5

A Plasma 5 widget for showing data from Wunderground [Personal Weather Stations](https://www.wunderground.com/pws/overview)

Wunderground lets you upload data from Smart Ambient Weather stations through their API.
You can view the data though wunderground or through Wunderground API. This widget lets
you input the station ID then view the properties that the station sends up.

## Running

Supply the name of the weatherstation (ie. [KGADACUL1](https://www.wunderground.com/dashboard/pws/KGADACUL1)) to the applet by clicking `Configure Wunderground`.

Also, input your coordinates and the widget will find the nearest station to you!

The data updates every 10 seconds.

## Meta

Big thanks to Meteocons for the free [icons](https://www.alessioatzeni.com/meteocons/).

By [@bluxart](https://twitter.com/bluxart) and [@pyconic](https://twitter.com/pyconic) on Twitter.

Big thanks to [Zren](https://github.com/Zren) for the files NoApplyField, AppletIcon, and ClearableField.

## TODO

-   [x] Use single variable for state
-   [x] Add monochrome icon
-   [ ] Add condition-based icon
-   [ ] Refactor tooltip into a single item
-   [x] Refactor Units into their own settings page
-   [ ] Add wind-barbs to show direction
