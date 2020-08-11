# Wunderground PWS Widget for KDE 5

A Plasma 5 widget for showing data from Wunderground [Personal Weather Stations](https://www.wunderground.com/pws/overview)

Wunderground lets you upload data from Smart Ambient Weather stations through their API.
You can view the data though wunderground or through Wunderground API. This widget lets
you input the station ID then view the properties that the station sends up.

You don't need to own a Weather Station yourself - there's a high chance there is already one in your neighbourhood. Feel free to look it up and use the ID of the nearest station.

This is an extended version of Wunderground Plasmoid - originally written by Kevin Donnelly (https://github.com/k-donn/plasmoid-wunderground). Huge thanks for the inspiration and a great base to work on.

This version adds a different view of:
- current weather conditions 
- the forecast 

As well as adds two new tabs with charts:
- 24h
- 7d

## Running

Supply the name of the weatherstation (ie. [IFRAUN2](https://www.wunderground.com/dashboard/pws/IFRAUN2)) to the applet by clicking `Configure Wunderground`.

Also, input your coordinates and the widget will find the nearest station for you!

## Translating

Translations welcome!

Follow the file in [plasmoid/translate](./plasmoid/translate) for directions.

## Meta

Big thanks to Meteocons for the free [icons](https://www.alessioatzeni.com/meteocons/).

- Kevin Donnelly (https://github.com/k-donn/plasmoid-wunderground) for his original project and work.
- Erik Flowers for his great weather icons https://erikflowers.github.io/weather-icons/
- Meteocons for additional weather icons (https://www.alessioatzeni.com/meteocons/)

## TODO

- Traslations
- Fix some display issues when non-English, more translations needed for that
- any requests welcome
