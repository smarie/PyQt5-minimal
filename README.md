# PyQt5-minimal

[![Build Status](https://travis-ci.org/smarie/PyQt5-minimal.svg?branch=Qt5.6.3_PyQt_5.6_Python3.5)](https://travis-ci.org/smarie/PyQt5-minimal)[![Build status](https://ci.appveyor.com/api/projects/status/5v9xec097c99h8ox?svg=true)](https://ci.appveyor.com/project/smarie/pyqt5-minimal)

A set of build scripts for the Travis and Appveyor continuous integration engines, so as to build a minimal version of the Qt LGPL and PyQt5 GPL packages for linux64 and windows (currently mingw64, *todo* MSVC2015).

#### Main purpose: (much) smaller cx-frozen PyQt applications  

This need came from project [envswitcher-gui](https://github.com/smarie/env-switcher-gui), which is a python app relying on PyQt5, frozen into an executable using cx_Freeze. With the default Qt+PyQt distribution available from conda, the executable distribution archive ended up being as large as 80Mo! There were two reasons to this: 

* The Qt available in conda is built using ICU, which brings quite large libraries
* The PyQt available in conda ships with several non-core Qt modules, which were not used by the project but also take some space on disk

With this project we recompile Qt and PyQt using the apropriate build configuration options (see below), so that the resulting size is much smaller.

#### Side-effect: reference scripts for pyqt-based frozen app

If you just came here in order to know how to build an PyQt app with cx-Freeze without ending up with a 80Mo archive in the end, then simply enable travis/appveyor in your project and take example from the .travis.yml and appveyor.yml scripts in [https://github.com/smarie/env-switcher-gui/](https://github.com/smarie/env-switcher-gui/).


#### Side-effect2: reference scripts for Qt and PyQt compilation

Building Qt and PyQt yourself might not be trivial, because you have a lot of open choices left and some of them do not work. A side-effect of this project is that it provides reference scripts for building Qt and PyQt yourself on linux and windows+msys2/mingw64 platforms. Simply follow the same steps as executed in `.travis.yml` or `appveyor.yml`, in particular they end up calling three scripts:

* **ci_tools/setup_msys.bat** (for windows targets only): sets up msys2 with mingw64 toolchain
* **ci_tools/build_install_qt\[.sh/.bat\]**: downloads, configures, builds and installs Qt
* **ci_tools/build_pyqt\[.sh/.bat\]**: downloads, configures, patches and builds PyQt. The patch is actually needed because Qt-generated Makefiles are not correct, on linux they need an additional -L<xxx> option for the linker, and on windows they need an additional CXXFLAG -D_hypot=hypot to fix an issue with mingw64's math library.


## Usage

In the [releases page](https://github.com/smarie/PyQt5-minimal/releases) you will find two kind of release packages:

* `Qt*.tar.gz` files are Qt binary distributions created in the build process, build with the 'minimal' options described below. 

* `PyQt*.tar.gz` files are PyQt binary distributions that depend on the corresponding Qt distributions. For the linux version, this dependency is based on an absolute path so Qt needs to be installed at a precise location. On windows this dependency is only based on Qt being on the environment's PATH. However on windows, msys2+mingw64 also needs to be on the PATH, see below.


### Windows only: install msys2-mingw64

The windows version of PyQt5-minimal is currently built using msys2-mingw64. You will therefore need to have it on your path for it to be able to load. Once downloaded from the latest msys2 sources to `C:\msys64`, 

 * create a msys2 environment launcher by creating a commandline script:
 
```cmd
set MINICONDA=C:\Miniconda3
set MSYS2_DIR=C:\msys64
set MSYSTEM=MINGW64
set "PATH=%MINICONDA%;%MINICONDA%\Scripts;%MSYS2_DIR%\%MSYSTEM%\bin;%MSYS2_DIR%\usr\bin;%PATH%"

start cmd /k echo %PATH%
```

You will have to open a commandline using this script to use PyQt5. Note: modify the above script if your python distribution is not miniconda3 or is not at this path. Also if you need git,  modify the path above to add your usual git first in the path, otherwise it will be shadowed by the one inside msys2, leading to git errors about already cloned repositories.

 * execute the following commands from inside the command window launched by the above, the first time. This will update msys2 and update your environment.

```bash
echo "-- First update msys2 core components"
bash -lc "pacman -Sy --noconfirm"
bash -lc "pacman --needed --noconfirm -S bash pacman pacman-mirrors msys2-runtime"

echo "-- Then update the rest of other components"
bash -lc "pacman -Su --noconfirm"

echo "-- load MinGW-w64 SEH (64bit/x86_64) posix and Dwarf-2 (32bit/i686) posix toolchains & related other tools, dependencies & components from MSYS2 REPO"
bash -lc "pacman -S --needed --noconfirm base-devel mingw-w64-i686-toolchain mingw-w64-x86_64-toolchain"
```


### Installing the Qt-minimal binary distribution

#### Windows (appveyor)

Simply extract the selected `Qt*.tar.gz` archive anywhere and add to your PATH. That way, your PyQt distribution will be able to (1) load correctly when your python application will do `import PyQt5` and (2) package correctly using cx_Freeze.

Not sure that the included Qt **toolchain** (`qmake`) will continue to work if you extract it on your machine to a different path than the one used at build time on Travis/Appveyor (respectively `/home/travis/build/smarie/PyQt5-minimal/Qt5.6.3` and `C:\projects\pyqt5-minimal\Qt5.6.3`). Indeed Qt is known to be very bound to its installation folder's absolute path. However, that will not be a problem if you just use the Qt **libraries** (.dll or .so), which is the case if you use the prebuilt PyQt provided below.

#### Linux (travis)

On linux targets the dependency between PyQt and Qt is absolute. You therefore have to extract Qt in... `/home/travis/build/smarie/PyQt5-minimal/Qt5.6.3/`. I know this is really not acceptable. But as of today that's the only way I found. At least on your travis you might be able to do that without caring much.


### Installing the PyQt-minimal binary distribution

You need to install the latest `sip` package (4.18+) with conda or pip in order for PyQt to work.

PyQt normal installation procedure would be to extract the selected `PyQt*.tar.gz` anywhere and run `make install` (linux) or `mingw32-make -j 4 install` (windows mingw) in the root directory, in order to install the package in your current python environment. 

However this **does not work** if your folder structure is not the same than the one we use in the Travis/Appveyor continuous integration engine (respectively `/home/travis/build/smarie/PyQt5-minimal/PyQt5.6` and `C:\projects\pyqt5-minimal\PyQt5.6`). Therefore you have to perform the installation manually, that is, to copy the interesting files into your current python environment's `site-packages` folder. For example (assuming current folder is the extracted PyQt archive's root folder):

**Linux**
```bash
# Define the installation folder
export PYQT_INSTALL_DIR="$HOME/miniconda/lib/python3.5/site-packages/PyQt5"
mkdir ${PYQT_INSTALL_DIR}
# -- copy all .so, .pyd and .pyi files but not the libxxx.so, it is not used
find . \( -name "*so" -o -name "*pyi" -o -name "*pyd" \) -not -name "lib*" -exec cp {} $PYQT_INSTALL_DIR \;
# -- copy the main init file
cp ./__init__.py ${PYQT_INSTALL_DIR}
```

**Windows**
```cmd
REM -- Define the installation folder
set PYQT_INSTALL_DIR="%MINICONDA%/lib/site-packages/PyQt5"
mkdir %PYQT_INSTALL_DIR%
REM -- Copy all .pyi and .pyd files
REM Note: replace %i with %%i if you execute this from inside a .bat file
for /r %i in (*pyi *pyd) do xcopy /Y "%i" "%PYQT_INSTALL_DIR%"
REM -- Copy the main init file
xcopy /Y .\__init__.py "%PYQT_INSTALL_DIR%"
```

*Note: similar to what happens when you perform the normal PyQt installation procedure with `make install`, the PyQt5 package **will not appear** in the output of `conda list` or `pip list`. However it is still available in python: `python -c "import PyQt5.QtCore"` should not throw any ImportError*


## Qt build options

For reference, the build options currently used to build Qt5.6.3-minimal are

```bash
-opensource -confirm-license \
-no-icu -no-cups -no-qml-debug -no-compile-examples -no-harfbuzz -no-sql-mysql -no-sql-odbc -no-sql-sqlite -qt-pcre \
-skip qtlocation -skip qt3d -skip qtmultimedia -skip qtwebchannel -skip qtwayland -skip qtandroidextras -skip qtwebsockets -skip qtconnectivity -skip qtdoc -skip qtwebview -skip qtimageformats -skip qtwebengine -skip qtquickcontrols2 -skip qttranslations -skip qtxmlpatterns -skip qtactiveqt -skip qtx11extras -skip qtsvg -skip qtscript -skip qtserialport -skip qtdeclarative -skip qtgraphicaleffects -skip qtcanvas3d -skip qtmacextras -skip qttools -skip qtwinextras -skip qtsensors -skip qtenginio -skip qtquickcontrols -skip qtserialbus \
-nomake examples -nomake tests -nomake tools
```

## PyQt build options

For reference, the build options currently used to build PyQt5.6-minimal are

```bash
--confirm-license \
--no-python-dbus --no-qml-plugin --no-qsci-api --no-tools \
--disable QtHelp --disable QtMultimedia --disable QtMultimediaWidgets --disable QtNetwork --disable QtOpenGL --disable QtPrintSupport --disable QtQml --disable QtQuick --disable QtSql --disable QtSvg --disable QtTest --disable QtWebKit --disable QtWebKitWidgets --disable QtXml --disable QtXmlPatterns --disable QtDesigner --disable QAxContainer --disable QtDBus --disable QtWebSockets --disable QtWebChannel --disable QtNfc --disable QtBluetooth --disable QtX11Extras --disable QtQuickWidgets --disable _QOpenGLFunctions_2_0 --disable _QOpenGLFunctions_2_1 --disable _QOpenGLFunctions_4_1_Core
```

Notes: 

 * on linux, PyQt is patched so that Makefiles generated by Qt's qmake are able to find the libraries. Indeed the generated makefiles only contain `-rpath` which seems not sufficient for the linker to find the libraries - we therefore add `-L`. This may be linked to the following [issue](https://forum.qt.io/topic/59670/how-to-compile-qt-with-relative-runpath-paths) ? The patch file used can be found in `ci_tools/`, there is one per version.

 * On windows PyQt is patched so that Makefiles generated by Qt's qmake contain an additional CXXFLAG -D_hypot=hypot to fix an issue with mingw64's math library.
