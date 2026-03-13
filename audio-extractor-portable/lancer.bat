@echo off
:: =============================================================================
:: Lanceur pour Audio Extractor
:: Double-cliquez sur ce fichier pour démarrer l'application.
:: Il contourne la politique d'exécution PowerShell sans modifier le système.
:: =============================================================================
powershell.exe -ExecutionPolicy Bypass -NoProfile -File "%~dp0audio-extractor.ps1"
