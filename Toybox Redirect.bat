@echo off
echo Be sure to run this as Administrator, otherwise you will get "Access Denied" errors.
echo Adding Toybox API Redirect...
echo 185.215.224.134 toyboxapi.garrysmod.com >> %windir%\System32\drivers\etc\hosts
echo Adding Toybox Redirect...
echo 185.215.224.134 toybox.garrysmod.com >> %windir%\System32\drivers\etc\hosts
echo Done!
pause
exit