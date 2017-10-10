@echo off

REM source:
REM   http://doc.qt.io/qt-5/windows-building.html
REM   https://wiki.qt.io/Building_Qt_Desktop_for_Windows_with_MinGW

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

set QT_VER_SHORT="%Major%.%Minor%"
set QT_ARCHIVE="qt-everywhere-opensource-src-%QT_VER%"
set QT_SRC_URL="http://download.qt.io/official_releases/qt/%QT_VER_SHORT%/%QT_VER%/single/%QT_ARCHIVE%.tar.xz"
set QT_SRC_DIR="%APPVEYOR_BUILD_FOLDER%/%QT_ARCHIVE%"
set QT_PCRE_SRC="%QT_SRC_DIR%/qtbase/src/3rdparty/pcre/"

echo QT_VER_SHORT: %QT_VER_SHORT%
echo QT_ARCHIVE: %QT_ARCHIVE%
echo QT_SRC_URL: %QT_SRC_URL%
echo QT_SRC_DIR: %QT_SRC_DIR%
echo QT_PCRE_SRC: %QT_PCRE_SRC%

IF %COMPILER%==msys2 (

    SET "PATH=%MSYS2_DIR%\%MSYSTEM%\bin;%MSYS2_DIR%\usr\bin;%PATH%"
    bash -lc "pacman -S --needed --noconfirm pacman-mirrors"
    bash -lc "pacman -S --needed --noconfirm git"
    REM Update
    bash -lc "pacman -Syu --noconfirm"

    REM build tools
    bash -lc "pacman -S --needed --noconfirm mingw-w64-x86_64-toolchain autoconf automake libtool make patch mingw-w64-x86_64-libtool"

    REM Set up perl
    bash -lc "pacman -S --needed --noconfirm mingw-w64-x86_64-perl"
    bash -lc "pl2bat $(which pl2bat)"
    REM bash -lc "yes | cpan App::cpanminus"
    REM bash -lc "cpanm --notest ExtUtils::MakeMaker"

    REM Native deps
    REM bash -lc "pacman -S --needed --noconfirm mingw-w64-x86_64-gobject-introspection mingw-w64-x86_64-cairo mingw-w64-x86_64-gtk3 mingw-w64-x86_64-expat mingw-w64-x86_64-openssl"

    REM There is not a corresponding cc for the mingw64 gcc. So we copy it in place.
    REM bash -lc "cp -pv /mingw64/bin/gcc /mingw64/bin/cc"
)