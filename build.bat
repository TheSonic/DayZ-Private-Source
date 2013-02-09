@echo off
setlocal enabledelayedexpansion

echo ----------------------------------------------------
echo Starting up build ...
echo ----------------------------------------------------
echo.

if exist build (del /s /q build)
if not exist build\@dayzcc\addons (md build\@dayzcc\addons)
if not exist build\Keys (md build\Keys)
if not exist build\MPMissions (md build\MPMissions)

echo.
echo ----------------------------------------------------
echo Building server addon ...
echo ----------------------------------------------------
echo.

util\cpbo.exe -y -p server\dayz_server build\@dayzcc\addons\dayz_server.pbo

echo.
echo ----------------------------------------------------
echo Building mission files ...
echo ----------------------------------------------------
echo.

util\cpbo.exe -y -p mission\dayz.chernarus build\MPMissions\dayz_1.chernarus.pbo
util\cpbo.exe -y -p mission\dayz.fallujah build\MPMissions\dayz_1.fallujah.pbo
util\cpbo.exe -y -p mission\dayz.lingor build\MPMissions\dayz_1.lingor.pbo
util\cpbo.exe -y -p mission\dayz.mbg_celle2 build\MPMissions\dayz_1.mbg_celle2.pbo
util\cpbo.exe -y -p mission\dayz.namalsk build\MPMissions\dayz_1.namalsk.pbo
util\cpbo.exe -y -p mission\dayz.panthera2 build\MPMissions\dayz_1.panthera2.pbo
util\cpbo.exe -y -p mission\dayz.takistan build\MPMissions\dayz_1.takistan.pbo
util\cpbo.exe -y -p mission\dayz.tavi build\MPMissions\dayz_1.tavi.pbo
util\cpbo.exe -y -p mission\dayz.thirsk build\MPMissions\dayz_1.thirsk.pbo
util\cpbo.exe -y -p mission\dayz.utes build\MPMissions\dayz_1.utes.pbo
util\cpbo.exe -y -p mission\dayz.zargabad build\MPMissions\dayz_1.zargabad.pbo

echo.
echo ----------------------------------------------------
echo Copying additional files ...
echo ----------------------------------------------------
echo.

copy server\dayz_server_config.hpp build\@dayzcc\addons\dayz_server_config.hpp
copy util\HiveExt.dll build\@dayzcc\HiveExt.dll
copy util\dayz.bikey build\Keys\dayz.bikey

echo.
echo ----------------------------------------------------
echo Finished! Press any key to exit ...
echo ----------------------------------------------------
pause>nul