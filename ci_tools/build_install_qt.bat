@echo off

REM source:
REM   Primary sources : https://wiki.qt.io/MSYS2 and https://wiki.qt.io/MinGW-64-bit
REM   Other readings:
REM       http://doc.qt.io/qt-5/windows-building.html,
REM       https://wiki.qt.io/Building_Qt_Desktop_for_Windows_with_MinGW
REM       https://project-renard.github.io/doc/development/meeting-log/posts/2016/05/03/windows-build-with-msys2/

REM before running this script the variable QT_DIR and QT_VER should exist

cd %APPVEYOR_BUILD_FOLDER%

echo "***** Starting compilation of Qt for installation to QT_DIR=%QT_DIR% *******"

REM echo Compiler: %COMPILER%
REM echo Architecture: %MSYS2_ARCH%
REM echo Platform: %PLATFORM%
REM echo MSYS2 directory: %MSYS2_DIR%
REM echo MSYS2 system: %MSYSTEM%
REM echo Bits: %BIT%

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

echo "(a) downloading Qt archive in %APPVEYOR_BUILD_FOLDER%"
cd %APPVEYOR_BUILD_FOLDER%
appveyor DownloadFile %QT_SRC_URL%
7z x %QT_ARCHIVE%.tar.xz > nul
7z x %QT_ARCHIVE%.tar > nul

cd %QT_ARCHIVE%
echo "(b) configuring Qt (see https://wiki.qt.io/MinGW-64-bit) in %CD%"
echo "-- creating qtbaseitignore if needed"
if not exist qtbaseitignore type nul>qtbaseitignore

echo "-- setting up environment variables"
REM We do not use openssl nor ICU
REM set INCLUDE=C:5_deps\icu\dist\include;C:5_deps\openssl-1.0.1e\dist\include
set INCLUDE=
REM set LIB=C:5_deps\icu\dist\lib;C:5_deps\openssl-1.0.1e\dist\lib
set LIB=
set QMAKESPEC=
REM apparently this variable needs to be deleted, note that its name is very close from our own QT_DIR variable !
set QTDIR=
set "PATH=%CD%\qtbase\bin;%CD%\gnuwin32\bin;%PATH%"
REM windows2unix() { local pathPcs=() split pathTmp IFS=\;; read -ra split <<< "$*"; for pathTmp in "${split[@],}"; do pathPcs+=( "/${pathTmp//+([:\\])//}" ); done; echo "${pathPcs[*]}"; }; systemrootP=$(windows2unix "$SYSTEMROOT"); export PATH="%CD%/qtbase/bin:%CD%/gnuwin32/bin:/c/msys2/mingw64/bin:/c/msys2/usr/bin:/c/Qt/qt5_deps/icu/dist/lib"
echo Path is now %PATH%
REM ;%SystemRoot%\System32
set MAKE_COMMAND=

echo "-- configuring in %CD%"
REM -qt-pcre -qt-zlib
REM set QT_DIR=C:\qt-5.6.3
cmd.exe /c configure -opensource -confirm-license -platform win32-g++ -release -prefix %QT_DIR% -no-compile-examples -no-sql-mysql -no-sql-odbc -no-sql-sqlite -no-icu -no-cups -no-harfbuzz -no-incredibuild-xge -no-ssl -no-openssl -no-dbus -no-audio-backend -no-qml-debug -no-native-gestures -opengl desktop -skip qtlocation -skip qt3d -skip qtmultimedia -skip qtwebchannel -skip qtwayland -skip qtandroidextras -skip qtwebsockets -skip qtconnectivity -skip qtdoc -skip qtwebview -skip qtimageformats -skip qtwebengine -skip qtquickcontrols2 -skip qttranslations -skip qtxmlpatterns -skip qtactiveqt -skip qtx11extras -skip qtsvg -skip qtscript -skip qtserialport -skip qtdeclarative -skip qtgraphicaleffects -skip qtcanvas3d -skip qtmacextras -skip qttools -skip qtwinextras -skip qtsensors -skip qtenginio -skip qtquickcontrols -skip qtserialbus -nomake examples -nomake tests -nomake tools

REM -platform win32-g++ -c++11 -opengl desktop -openssl -plugin-sql-odbc -nomake tests

echo "(c) building Qt in %CD%"
REM jom /W /S -j4
mingw32-make -j 4

echo "(d) installing Qt in %QT_DIR% from %CD%"
mingw32-make -j 4 install
REM --platform win32-g++

cd %APPVEYOR_BUILD_FOLDER%
echo "(e) Cleaning up and returning to appveyor build dir %CD%"
RMDIR /S /Q %QT_SRC_DIR%
