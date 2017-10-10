@echo off

REM source :
REM   http://pyqt.sourceforge.net/Docs/PyQt5/installation.html#building-and-installing-from-source
REM   https://wiki.python.org/moin/BuildPyQt4Windows

REM before running this script the variable PYQT_DIR and PYQT_VER should exist

cd %APPVEYOR_BUILD_FOLDER%

echo "***** Starting compilation of PyQt in %PYQT_DIR% for installation in python site-packages *******"
REM extract version details
for /F "tokens=1,2,3 delims=." %%a in ("%PYQT_VER%") do (
   set Major=%%a
   set Minor=%%b
   set Revision=%%c
)
echo Qt version: Major: %Major%, Minor: %Minor%, Revision: %Revision%

set PYQT_VER_SHORT=%Major%
set PYQT_ARCHIVE=PyQt%PYQT_VER_MAJOR%_gpl-%PYQT_VER%
set PYQT_SRC_URL=https://sourceforge.net/projects/pyqt/files/PyQt%PYQT_VER_MAJOR%/PyQt-%PYQT_VER%/%PYQT_ARCHIVE%.tar.gz/download

echo PYQT_VER_SHORT: %PYQT_VER_SHORT%
echo PYQT_ARCHIVE: %PYQT_ARCHIVE%
echo PYQT_SRC_URL: %PYQT_SRC_URL%

echo "(a) Downloading PyQt sources from %PYQT_SRC_URL% in %CD%"
appveyor DownloadFile %PYQT_SRC_URL% -FileName %PYQT_ARCHIVE%.tar.gz

echo "(b) Unzipping PyQt sources in %PWD%"
7z x %PYQT_ARCHIVE%.tar.xz > nul
7z x %PYQT_ARCHIVE%.tar > nul
dir
MOVE %APPVEYOR_BUILD_FOLDER%/%PYQT_ARCHIVE% %PYQT_DIR%

echo "(c) Installing PyQt dependencies "
REM set PATH=C:\WINDOWS\system32;C:\WINDOWS;C:\WINDOWS\System32\Wbem;C:\Qt\4.3.3\bin;C:\MinGW\bin
g++ -v
qmake -v
REM from https://wiki.qt.io/Install_Qt_5_on_Ubuntu: install opengl libraries so as to be able to build QtGui

cd %PYQT_DIR%
REM echo "(d) Patching PyQt configure.py in %CD%"
REM apply our HACK patch to fix the generated makefiles
REM patch ./configure.py < ../ci_tools/pyqt5-$PYQT_VER-configure.py.patch

echo "(d) Configuring PyQt in %CD%"
python configure.py --no-python-dbus --no-qml-plugin --no-qsci-api --no-tools --confirm-license --disable QtHelp --disable QtMultimedia --disable QtMultimediaWidgets --disable QtNetwork --disable QtOpenGL --disable QtPrintSupport --disable QtQml --disable QtQuick --disable QtSql --disable QtSvg --disable QtTest --disable QtWebKit --disable QtWebKitWidgets --disable QtXml --disable QtXmlPatterns --disable QtDesigner --disable QAxContainer --disable QtDBus --disable QtWebSockets --disable QtWebChannel --disable QtNfc --disable QtBluetooth --disable QtX11Extras --disable QtQuickWidgets --disable _QOpenGLFunctions_2_0 --disable _QOpenGLFunctions_2_1 --disable _QOpenGLFunctions_4_1_Core
REM --qmake $HOME/miniconda/bin/qmake --sip $HOME/miniconda/bin/sip --verbose

echo "(e) Compiling PyQt in %CD%"
mingw32-make -j 4
