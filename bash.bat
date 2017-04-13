@rem bash.bat - a Windows batch file for invoking bash from RNotebooks
@echo off
SET BASH_PATH=C:\Users\Derek Slone-Zhen\.babun\cygwin\bin
PATH=%BASH_PATH%;%PATH%
"%BASH_PATH%\bash.exe" < "%~1"