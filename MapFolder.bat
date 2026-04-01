@echo off
echo Generating directory map...
:: /f includes files, /a uses standard text characters to prevent weird symbols in Notepad
tree /f /a > directory_map.txt
echo Done! Map saved to directory_map.txt
pause