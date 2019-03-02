[![Build Status](https://travis-ci.com/camellan/placesindicator.svg?branch=master)](https://travis-ci.com/camellan/placesindicator)
# Places Indicator
**A GTK3 based indicator for quick access to folders**

A simple indicator, which gives fast access to the default folder and custom bookmarks a the File Manager.

![Screenshot](https://github.com/camellan/placeindicator/blob/master/data/images/placesindicator.png)

## For coffee
[![Donate](https://img.shields.io/badge/Donate-PayPal-green.svg)](https://paypal.me/camellan/5)

## Dependencies

Please make sure you have these dependencies first before building.

```
gtk+-3.0
glib-2.0
appindicator3-0.1
```
To build locally:

`meson build --prefix=/usr`

`cd build`

`ninja`

`sudo ninja install`
