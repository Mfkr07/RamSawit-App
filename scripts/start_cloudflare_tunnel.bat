@echo off
title Cloudflare Tunnel - RamSawit AI 9Router
echo ============================================================
echo   Menjalankan Cloudflare Tunnel untuk 9Router (Port 20128)
echo ============================================================
echo.
echo Pastikan 9Router di laptop Anda sudah berjalan pada port 20128.
echo Salin URL 'https://xxxx.trycloudflare.com/v1' yang muncul
echo ke menu Pengaturan AI di HP Android Anda.
echo.
"%USERPROFILE%\.cloudflared\cloudflared.exe" tunnel --url http://localhost:20128
pause
