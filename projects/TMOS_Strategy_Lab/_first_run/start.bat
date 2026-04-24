@echo off
cd /d "%~dp0..\"
claude "/generate-prp"
del "%~f0"
