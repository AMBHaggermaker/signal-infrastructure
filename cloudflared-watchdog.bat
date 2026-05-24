@echo off
:loop
timeout /t 300 /nobreak
tasklist /FI "IMAGENAME eq cloudflared.exe" 2>NUL | find /I "cloudflared.exe" >NUL
if errorlevel 1 (
    echo [%date% %time%] Cloudflare tunnel not running, restarting...
    start /B cloudflared tunnel --config "C:\Users\User\.cloudflared\config.yml" run unprecedented
)
goto loop
