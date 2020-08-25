@echo off
setlocal
REM set MORGANADIR=%~dp0
set MORGANADIR=U:\GPO XML Toolkit\processors\MorganaXProc-IIIse-0.9.4.4-beta\
set JAVADIR=C:\Program Files\Oxygen XML Editor 22\jre\bin\

echo %time%

"%JAVADIR%java" -jar -javaagent "%MORGANADIR%MorganaXProc-IIIse_lib/quasar-core-0.7.9.jar" -cp "u:\GPO XML Toolkit\processors\SaxonEE9-8-0-15J\saxon9ee.jar" "%MORGANADIR%MorganaXProc-IIIse.jar" "scrap.xpl" -output:result=scrap_output.xml -debug

REM "%JAVADIR%java" -jar -javaagent:"%MORGANADIR%MorganaXProc-IIIse_lib/quasar-core-0.7.9.jar" "%MORGANADIR%MorganaXProc-IIIse.jar" "scrap.xpl" -output:result=scrap_output.xml -debug

echo %time%

