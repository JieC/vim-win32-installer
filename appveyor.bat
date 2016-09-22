@echo off
:: Batch file for building/testing Vim on AppVeyor

setlocal ENABLEDELAYEDEXPANSION
cd %APPVEYOR_BUILD_FOLDER%

if /I "%ARCH%"=="x64" (
  set BIT=64
) else (
  set BIT=32
)

:: ----------------------------------------------------------------------
:: Download URLs, local dirs and versions
:: Lua
set LUA_VER=51
set LUA_DIR=C:\Lua
:: Perl
set PERL_VER=524
set PERL32_URL=http://downloads.activestate.com/ActivePerl/releases/5.24.0.2400/ActivePerl-5.24.0.2400-MSWin32-x86-64int-300560.zip
set PERL64_URL=http://downloads.activestate.com/ActivePerl/releases/5.24.0.2400/ActivePerl-5.24.0.2400-MSWin32-x64-300558.zip
set PERL_URL=!PERL%BIT%_URL!
set PERL_DIR=C:\Perl%PERL_VER%\perl
:: Python2
set PYTHON_VER=27
set PYTHON_32_DIR=C:\python%PYTHON_VER%
set PYTHON_64_DIR=C:\python%PYTHON_VER%-x64
set PYTHON_DIR=!PYTHON_%BIT%_DIR!
:: Python3
set PYTHON3_VER=35
set PYTHON3_32_DIR=C:\python%PYTHON3_VER%
set PYTHON3_64_DIR=C:\python%PYTHON3_VER%-x64
set PYTHON3_DIR=!PYTHON3_%BIT%_DIR!
:: Ruby
set RUBY_VER=23
set RUBY_VER_LONG=2.3.0
set RUBY_BRANCH=ruby_2_3
set RUBY32_DIR=C:\Ruby%RUBY_VER%
set RUBY64_DIR=C:\Ruby%RUBY_VER%-x64
set RUBY_DIR=!RUBY%BIT%_DIR!
:: Tcl
set TCL_VER_LONG=8.6
set TCL_VER=%TCL_VER_LONG:.=%
set TCL32_URL=http://downloads.activestate.com/ActiveTcl/releases/8.6.4.1/ActiveTcl8.6.4.1.299124-win32-ix86-threaded.exe
set TCL64_URL=http://downloads.activestate.com/ActiveTcl/releases/8.6.4.1/ActiveTcl8.6.4.1.299124-win32-x86_64-threaded.exe
set TCL_URL=!TCL%BIT%_URL!
set TCL_DIR=C:\Tcl
:: Gettext
set GETTEXT32_URL=https://github.com/mlocati/gettext-iconv-windows/releases/download/v0.19.6-v1.14/gettext0.19.6-iconv1.14-shared-32.exe
set GETTEXT64_URL=https://github.com/mlocati/gettext-iconv-windows/releases/download/v0.19.6-v1.14/gettext0.19.6-iconv1.14-shared-64.exe
set GETTEXT_URL=!GETTEXT%BIT%_URL!
SET MSVCVER=14.0

:: ----------------------------------------------------------------------

:: Update PATH
path %PYTHON_DIR%;%PYTHON3_DIR%;%PERL_DIR%\bin;%path%;%LUA_DIR%;%TCL_DIR%\bin;%RUBY_DIR%\bin

if /I "%1"=="" (
  set target=build
) else (
  set target=%1
)

goto %target%_%ARCH%
echo Unknown build target.
exit 1


:install_x86
:install_x64
:: ----------------------------------------------------------------------
@echo on
:: Work around for Python 2.7.11
reg copy HKLM\SOFTWARE\Python\PythonCore\2.7 HKLM\SOFTWARE\Python\PythonCore\2.7-32 /s /reg:32
reg copy HKLM\SOFTWARE\Python\PythonCore\2.7 HKLM\SOFTWARE\Python\PythonCore\2.7-32 /s /reg:64

:: Get Vim source code
git clone https://github.com/vim/vim.git -b master -q

:: Apply experimental patches
pushd vim
for /f %%a in ('git describe --tags  --abbrev^=0') do set TAG_NAME=%%a
git checkout %TAG_NAME%
popd

if not exist downloads mkdir downloads

:: Lua
git clone https://github.com/LuaJIT/LuaJIT.git -b master --depth 1 -q ../lua
pushd ..\lua\src
call msvcbuild.bat
echo on
Robocopy . %LUA_DIR%\include lauxlib.h lua.h lua.hpp luaconf.h lualib.h luajit.h
Robocopy . %LUA_DIR%\bin lua%LUA_VER%.dll luajit.exe
Robocopy . %LUA_DIR%\lib lua%LUA_VER%.lib
Robocopy /E jit %LUA_DIR%\bin\lua\jit /XF .gitignore
popd

:: Perl
call :downloadfile %PERL_URL% downloads\perl.zip
7z x downloads\perl.zip -oC:\ > nul || exit 1
for /d %%i in (C:\ActivePerl*) do move %%i C:\Perl%PERL_VER%

:: Tcl
call :downloadfile %TCL_URL% downloads\tcl.exe
start /wait downloads\tcl.exe --directory %TCL_DIR%

:: Ruby
:: RubyInstaller is built by MinGW, so we cannot use header files from it.
:: Download the source files and generate config.h for MSVC.
git clone https://github.com/ruby/ruby.git -b %RUBY_BRANCH% --depth 1 -q ../ruby
pushd ..\ruby
call win32\configure.bat
echo on
nmake .config.h.time
xcopy /s .ext\include %RUBY_DIR%\include\ruby-%RUBY_VER_LONG%
popd

:: Vimproc
git clone https://github.com/Shougo/vimproc.vim.git -b master --depth 1 -q ../vimproc
pushd ..\vimproc
call nmake /F Make_msvc.mak nodebug=1
echo on
popd

:: tellenc
git clone https://github.com/adah1972/tellenc.git -b master --depth 1 -q ../tellenc
pushd ..\tellenc
call cl /EHsc /Ox tellenc.cpp
echo on
popd

:: Install libintl.dll and iconv.dll
call :downloadfile %GETTEXT_URL% downloads\gettext.exe
start /wait downloads\gettext.exe /verysilent /dir=c:\gettext

::Plug
call :downloadfile %PERL_URL% downloads\perl.zip
git clone https://github.com/junegunn/vim-plug.git -b master --depth 1 -q ../vim-plug
:: Show PATH for debugging
path

:build_x86
:build_x64
:: ----------------------------------------------------------------------
@echo on

cd vim\src
:: Remove progress bar from the build log
sed -e "s/\$(LINKARGS2)/\$(LINKARGS2) | sed -e 's#.*\\\\r.*##'/" Make_mvc.mak > Make_mvc2.mak
:: Build GUI version
nmake -f Make_mvc2.mak ^
	GUI=yes OLE=yes DIRECTX=yes^
	FEATURES=HUGE IME=yes GIME=yes MBYTE=yes ICONV=yes DEBUG=no ^
	DYNAMIC_PERL=yes PERL=%PERL_DIR% ^
	DYNAMIC_PYTHON=yes PYTHON=%PYTHON_DIR% ^
	DYNAMIC_PYTHON3=yes PYTHON3=%PYTHON3_DIR% ^
	DYNAMIC_LUA=yes LUA=%LUA_DIR% ^
	DYNAMIC_TCL=yes TCL=%TCL_DIR% ^
	DYNAMIC_RUBY=yes RUBY=%RUBY_DIR% RUBY_MSVCRT_NAME=msvcrt ^
	WINVER=0x500 ^
	|| exit 1
:: Build CUI version
nmake -f Make_mvc2.mak ^
	GUI=no OLE=no DIRECTX=no^
	FEATURES=HUGE IME=yes MBYTE=yes ICONV=yes DEBUG=no ^
	DYNAMIC_PERL=yes PERL=%PERL_DIR% ^
	DYNAMIC_PYTHON=yes PYTHON=%PYTHON_DIR% ^
	DYNAMIC_PYTHON3=yes PYTHON3=%PYTHON3_DIR% ^
	DYNAMIC_LUA=yes LUA=%LUA_DIR% ^
	DYNAMIC_TCL=yes TCL=%TCL_DIR% ^
	DYNAMIC_RUBY=yes RUBY=%RUBY_DIR% RUBY_MSVCRT_NAME=msvcrt ^
	WINVER=0x500 ^
	|| exit 1
:: Build translations
pushd po
nmake -f Make_mvc.mak GETTEXT_PATH=C:\cygwin\bin VIMRUNTIME=..\..\runtime install-all || exit 1
popd

:check_executable
:: ----------------------------------------------------------------------
copy "C:\Program Files (x86)\Microsoft Visual Studio 14.0\VC\redist\%ARCH%\Microsoft.VC140.CRT\vcruntime140.dll" .
copy "C:\Program Files (x86)\Microsoft Visual Studio 14.0\VC\redist\%ARCH%\Microsoft.VC140.CRT\msvcp140.dll" .
dir

start /wait .\gvim -silent -register
start /wait .\gvim -u NONE -c "redir @a | ver | 0put a | wq!" ver.txt
type ver.txt
.\vim --version
:: Print interface versions
start /wait .\gvim -u NONE -S ..\..\if_ver.vim -c quit
type if_ver.txt
@echo off
goto :eof


:package_x86
:package_x64
:: ----------------------------------------------------------------------
@echo on
cd vim
for /f %%a in ('git describe --tags  --abbrev^=0') do set TAG_NAME=%%a
cd src

:: Create zip packages
copy /Y ..\README.txt ..\runtime
copy /Y ..\vimtutor.bat ..\runtime
copy /Y *.exe ..\runtime\
copy /Y xxd\*.exe ..\runtime
copy /Y tee\*.exe ..\runtime
copy /Y ..\..\diff.exe ..\runtime\
copy /Y c:\gettext\libiconv*.dll ..\runtime\
copy /Y c:\gettext\libintl-8.dll ..\runtime\
:: copy /Y ..\..\..\vimproc\lib\*.dll ..\runtime\
copy /Y ..\..\..\tellenc\*.exe ..\runtime\

Robocopy /E %LUA_DIR%\bin ..\runtime\
:: libwinpthread is needed on Win64 for localizing messages
if exist c:\gettext\libwinpthread-1.dll copy /Y c:\gettext\libwinpthread-1.dll ..\runtime\
set dir=vim%TAG_NAME:~1,1%%TAG_NAME:~3,1%
mkdir ..\vim\%dir%
xcopy ..\runtime ..\vim\%dir% /Y /E /V /I /H /R /Q
xcopy ..\..\..\vimproc ..\vim\.vim\bundle\vimproc.vim\  /Y /E /V /I /H /R /Q
xcopy ..\..\..\vim-plug\plug.vim ..\vim\.vim\autoload\  /Y /E /V /I /H /R /Q

7z a ..\..\gvim_%TAG_NAME:v=%_%ARCH%.zip ..\vim

@echo off
goto :eof


:downloadfile
:: ----------------------------------------------------------------------
:: call :downloadfile <URL> <localfile>
if not exist %2 (
  curl -f -L %1 -o %2 || exit 1
)
goto :eof
