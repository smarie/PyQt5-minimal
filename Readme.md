# PyQt5-minimal

This project consists in a set of build scripts for the continuous integration engine, so as to build a minimal version of the Qt LGPL and PyQt5 GPL packages for linux.

This need came from project [envswitcher-gui](https://github.com/smarie/env-switcher-gui), which is a python app relying on PyQt5 and frozen into an executable using cx_Freeze. With the default PyQt distribution available in conda, the executable distribution ended up being as large as 80Mo! There were two reasons to this: 

* Qt was built using ICU, which brings quite large libraries
* several non-core usused Qt modules were included in PyQt

## Usage

In the [releases page](https://github.com/smarie/PyQt5-minimal/releases) you will find two kind of release packages:

* Qt*.tar.gz are Qt binary distributions, build with the options described below. Simply extract anywhere and add to your PATH if you wish to use this directly. Note: not sure that the Qt toolchain will work since the prefix might not be the same.

* PyQt*.tar.gz are PyQt 'ready-to-install' distributions. Extract anywhere and run `make install` in the root directory in order to install the package in your current python environment. The PyQt folder will typically end-up in your current python environment's `site-packages` folder.

## Qt build options

The build options currently used to build Qt are

```bash
-opensource -confirm-license \
-no-icu -no-cups -no-qml-debug -no-compile-examples -no-harfbuzz -no-sql-mysql -no-sql-odbc -no-sql-sqlite -qt-pcre \
-skip qtlocation -skip qt3d -skip qtmultimedia -skip qtwebchannel -skip qtwayland -skip qtandroidextras -skip qtwebsockets -skip qtconnectivity -skip qtdoc -skip qtwebview -skip qtimageformats -skip qtwebengine -skip qtquickcontrols2 -skip qttranslations -skip qtxmlpatterns -skip qtactiveqt -skip qtx11extras -skip qtsvg -skip qtscript -skip qtserialport -skip qtdeclarative -skip qtgraphicaleffects -skip qtcanvas3d -skip qtmacextras -skip qttools -skip qtwinextras -skip qtsensors -skip qtenginio -skip qtquickcontrols -skip qtserialbus \
-nomake examples -nomake tests -nomake tools
```

## PyQt build options

The build options currently used to build PyQt are

```bash
--confirm-license \
--no-python-dbus --no-qml-plugin --no-qsci-api --no-tools \
--disable QtHelp --disable QtMultimedia --disable QtMultimediaWidgets --disable QtNetwork --disable QtOpenGL --disable QtPrintSupport --disable QtQml --disable QtQuick --disable QtSql --disable QtSvg --disable QtTest --disable QtWebKit --disable QtWebKitWidgets --disable QtXml --disable QtXmlPatterns --disable QtDesigner --disable QAxContainer --disable QtDBus --disable QtWebSockets --disable QtWebChannel --disable QtNfc --disable QtBluetooth --disable QtX11Extras --disable QtQuickWidgets --disable _QOpenGLFunctions_2_0 --disable _QOpenGLFunctions_2_1 --disable _QOpenGLFunctions_4_1_Core
```