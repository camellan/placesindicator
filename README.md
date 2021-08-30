[![Build Status](https://travis-ci.com/camellan/placesindicator.svg?branch=master)](https://travis-ci.com/camellan/placesindicator)
# Places Indicator

**A GTK3 based indicator for quick access to folders**

A simple indicator, which gives fast access to the default folder and custom bookmarks a the File Manager.

![Screenshot](https://github.com/camellan/placeindicator/blob/master/data/images/screenshot.png)

## For coffee
[![Donate](https://img.shields.io/badge/Donate-PayPal-green.svg)](https://paypal.me/camellan/5)

## Dependencies for app

Please make sure you have these dependencies first before building.

```
gtk+-3.0
glib-2.0
appindicator3-0.1
libappindicator3-dev
```

## Dependencies for wingpanel indicator

```
glib-2.0
gio-2.0
gio-unix-2.0
gmodule-2.0
gtk+-3.0
gee-0.8
wingpanel
```

**To build locally:**

`meson build --prefix=/usr`

`cd build`

`ninja`

`sudo ninja install`

**To uninstall:**

`sudo ninja uninstall`

**To build wingpanel module:**

`cd indicator`

`meson build --prefix=/usr`

`cd build`

`ninja`

`sudo ninja install`

**To uninstall:**

`sudo ninja uninstall`
