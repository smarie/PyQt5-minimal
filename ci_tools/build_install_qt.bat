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
    REM bash -lc "pacman -S --needed --noconfirm pacman-mirrors"
    REM bash -lc "pacman -S --needed --noconfirm git"
    REM Update
    REM bash -lc "pacman -Syu --noconfirm"

    echo "(a) setup MSYS2 for Qt build, see https://wiki.qt.io/MSYS2"

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


    echo "(b) downloading Qt archive"
    cd %APPVEYOR_BUILD_FOLDER%
    appveyor DownloadFile %QT_SRC_URL%
    7z x %QT_ARCHIVE%

    echo "(c) configuring Qt TODO"
    REMif not exist qtbaseitignore type nul>qtbaseitignore

    echo "(d) building Qt TODO"

)