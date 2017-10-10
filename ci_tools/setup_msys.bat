SET "PATH=%MSYS2_DIR%\%MSYSTEM%\bin;%MSYS2_DIR%\usr\bin;%PATH%"

REM set MSYS2_DIR=C:\msys64
REM set MSYSTEM=MINGW64
REM bash -lc "pacman -S --needed --noconfirm pacman-mirrors"
REM bash -lc "pacman -S --needed --noconfirm git"
REM Update
REM bash -lc "pacman -Syu --noconfirm"

echo "Setup MSYS2 for Qt build (see https://wiki.qt.io/MSYS2)"

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

REM echo "(b) installing jom"
cd %APPVEYOR_BUILD_FOLDER%
REM appveyor DownloadFile "http://download.qt.io/official_releases/jom/jom.zip"
REM 7z x jom.zip -o%APPVEYOR_BUILD_FOLDER%\jom > nul