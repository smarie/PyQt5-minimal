@echo off

REM source:
REM   Primary sources : https://wiki.qt.io/MSYS2 and https://wiki.qt.io/MinGW-64-bit
REM   Other reading: http://doc.qt.io/qt-5/windows-building.html, https://wiki.qt.io/Building_Qt_Desktop_for_Windows_with_MinGW

REM before running this script the variable QT_DIR and QT_VER should exist

cd %APPVEYOR_BUILD_FOLDER%

echo "***** Starting compilation of Qt for installation to $QT_DIR *******"

echo Compiler: %COMPILER%
echo Architecture: %MSYS2_ARCH%
echo Platform: %PLATFORM%
echo MSYS2 directory: %MSYS2_DIR%
echo MSYS2 system: %MSYSTEM%
echo Bits: %BIT%

REM Create a writeable TMPDIR
mkdir %APPVEYOR_BUILD_FOLDER%\tmp
set TMPDIR=%APPVEYOR_BUILD_FOLDER%\tmp

REM extract version details
for /F "tokens=1,2,3 delims=." %%a in ("%QT_VER%") do (
   set Major=%%a
   set Minor=%%b
   set Revision=%%c
)
echo Qt version: Major: %Major%, Minor: %Minor%, Revision: %Revision%

set QT_VER_SHORT=%Major%.%Minor%
set QT_ARCHIVE=qt-everywhere-opensource-src-%QT_VER%
set QT_SRC_URL=http://download.qt.io/official_releases/qt/%QT_VER_SHORT%/%QT_VER%/single/%QT_ARCHIVE%.tar.xz
set QT_SRC_DIR=%APPVEYOR_BUILD_FOLDER%/%QT_ARCHIVE%
set QT_PCRE_SRC=%QT_SRC_DIR%/qtbase/src/3rdparty/pcre/

echo QT_VER_SHORT: %QT_VER_SHORT%
echo QT_ARCHIVE: %QT_ARCHIVE%
echo QT_SRC_URL: %QT_SRC_URL%
echo QT_SRC_DIR: %QT_SRC_DIR%
echo QT_PCRE_SRC: %QT_PCRE_SRC%


SET "PATH=%MSYS2_DIR%\%MSYSTEM%\bin;%MSYS2_DIR%\usr\bin;%PATH%"

REM set MSYS2_DIR=C:\msys64
REM set MSYSTEM=MINGW64
REM bash -lc "pacman -S --needed --noconfirm pacman-mirrors"
REM bash -lc "pacman -S --needed --noconfirm git"
REM Update
REM bash -lc "pacman -Syu --noconfirm"

echo "(a) setup MSYS2 for Qt build (see https://wiki.qt.io/MSYS2)"

echo "-- First update msys2 core components"
bash -lc "pacman -Sy --noconfirm"
bash -lc "pacman --needed --noconfirm -S bash pacman pacman-mirrors msys2-runtime"

echo "-- Then update the rest of other components"
bash -lc "pacman -Su --noconfirm"

echo "-- load MinGW-w64 SEH (64bit/x86_64) posix and Dwarf-2 (32bit/i686) posix toolchains & related other tools, dependencies & components from MSYS2 REPO"
bash -lc "pacman -S --needed --noconfirm base-devel git mercurial cvs wget p7zip"
bash -lc "pacman -S --needed --noconfirm perl ruby python2 mingw-w64-i686-toolchain mingw-w64-x86_64-toolchain"
REM bash -lc "pacman -S --needed --noconfirm mingw-w64-x86_64-toolchain autoconf automake libtool make patch mingw-w64-x86_64-libtool"
REM bash -lc "pacman -S --needed --noconfirm mingw-w64-x86_64-perl"

REM bash -lc "pl2bat $(which pl2bat)"
REM bash -lc "yes | cpan App::cpanminus"
REM bash -lc "cpanm --notest ExtUtils::MakeMaker"

REM Native deps
REM bash -lc "pacman -S --needed --noconfirm mingw-w64-x86_64-gobject-introspection mingw-w64-x86_64-cairo mingw-w64-x86_64-gtk3 mingw-w64-x86_64-expat mingw-w64-x86_64-openssl"

REM There is not a corresponding cc for the mingw64 gcc. So we copy it in place.
REM bash -lc "cp -pv /mingw64/bin/gcc /mingw64/bin/cc"

echo "(b) installing jom"
cd %APPVEYOR_BUILD_FOLDER%
appveyor DownloadFile "http://download.qt.io/official_releases/jom/jom.zip"
7z x jom.zip -o%APPVEYOR_BUILD_FOLDER%\jom > nul

echo "(c) downloading Qt archive"
cd %APPVEYOR_BUILD_FOLDER%
appveyor DownloadFile %QT_SRC_URL%
7z x %QT_ARCHIVE%.tar.xz > nul
7z x %QT_ARCHIVE%.tar > nul

echo "(d) configuring Qt (see https://wiki.qt.io/MinGW-64-bit)"
dir
cd %QT_ARCHIVE%
echo "-- creating qtbaseitignore if needed"
if not exist qtbaseitignore type nul>qtbaseitignore

echo "-- setting up environment variables"
REM We do not use openssl nor ICU
REM set INCLUDE=C:5_deps\icu\dist\include;C:5_deps\openssl-1.0.1e\dist\include
set INCLUDE=
REM set LIB=C:5_deps\icu\dist\lib;C:5_deps\openssl-1.0.1e\dist\lib
set LIB=
set QMAKESPEC=
set QTDIR=
set PATH=%CD%\qtbase\bin;%CD%\gnuwin32\bin;%MSYS2_DIR%\%MSYSTEM%\bin;%MSYS2_DIR%\usr\bin;%APPVEYOR_BUILD_FOLDER%\jom
REM windows2unix() { local pathPcs=() split pathTmp IFS=\;; read -ra split <<< "$*"; for pathTmp in "${split[@],}"; do pathPcs+=( "/${pathTmp//+([:\\])//}" ); done; echo "${pathPcs[*]}"; }; systemrootP=$(windows2unix "$SYSTEMROOT"); export PATH="$PWD/qtbase/bin:$PWD/gnuwin32/bin:/c/msys2/mingw64/bin:/c/msys2/usr/bin:/c/Qt/qt5_deps/icu/dist/lib"
echo Path is now %PATH%
REM ;%SystemRoot%\System32
set MAKE_COMMAND=

echo "-- configuring"
REM -qt-pcre -qt-zlib
configure -opensource -confirm-license -prefix %QT_DIR% -no-compile-examples -no-sql-mysql -no-sql-odbc -no-sql-sqlite -no-icu -no-cups -no-harfbuzz -no-incredibuild-xge -no-ssl -no-openssl -no-dbus -no-audio-backend -no-qml-debug -no-native-gestures -opengl desktop -skip qtlocation -skip qt3d -skip qtmultimedia -skip qtwebchannel -skip qtwayland -skip qtandroidextras -skip qtwebsockets -skip qtconnectivity -skip qtdoc -skip qtwebview -skip qtimageformats -skip qtwebengine -skip qtquickcontrols2 -skip qttranslations -skip qtxmlpatterns -skip qtactiveqt -skip qtx11extras -skip qtsvg -skip qtscript -skip qtserialport -skip qtdeclarative -skip qtgraphicaleffects -skip qtcanvas3d -skip qtmacextras -skip qttools -skip qtwinextras -skip qtsensors -skip qtenginio -skip qtquickcontrols -skip qtserialbus -nomake examples -nomake tests -nomake tools

REM -platform win32-g++ -c++11 -opengl desktop -openssl -plugin-sql-odbc -nomake tests

echo "(d) building Qt"
REM jom /W /S -j4
mingw32-make -j 4

echo "(e) installing Qt"
mingw32-make -j 4 install
REM --platform win32-g++