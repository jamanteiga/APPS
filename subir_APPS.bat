@echo off
setlocal EnableExtensions
REM ============================================================
REM  subir_apps.bat - Sube todo el contenido de esta carpeta
REM  al repositorio https://github.com/jamanteiga/APPS (rama main)
REM
REM  Uso: copia este .bat en la carpeta local de APPS
REM       (la que contiene index.html y la carpeta IMAGES)
REM       y haz doble clic.
REM  Requisito: Git for Windows  (https://git-scm.com/download/win)
REM ============================================================

set "REPO=https://github.com/jamanteiga/APPS.git"
set "RAMA=main"

cd /d "%~dp0"
title Subir APPS a GitHub
echo.
echo  Carpeta: %CD%
echo  Destino: %REPO% (%RAMA%)
echo.

REM --- 1. Comprobar Git ---------------------------------------
where git >nul 2>&1
if errorlevel 1 (
  echo [ERROR] Git no esta instalado. Descargalo de https://git-scm.com/download/win
  goto :fin
)

REM --- 2. Comprobar que es la carpeta correcta -----------------
if not exist "index.html" (
  echo [ERROR] No hay index.html en esta carpeta. Pon el .bat en la carpeta de APPS.
  goto :fin
)

REM --- 3. Primera vez: enlazar la carpeta con GitHub -----------
if not exist ".git" (
  echo Primera ejecucion: enlazando la carpeta con el repositorio...
  git init -q -b %RAMA%
  git remote add origin %REPO%
  git fetch -q origin %RAMA%
  if errorlevel 1 (
    echo [ERROR] No se pudo conectar con GitHub.
    goto :fin
  )
  git reset -q origin/%RAMA%
  REM Recupera los ficheros del repo que no tengas en local (no se borran en GitHub)
  for /f "delims=" %%F in ('git ls-files -d') do git checkout -- "%%F"
)

REM --- 4. Usuario de Git (solo si no esta configurado) ---------
git config user.name >nul 2>&1 || git config user.name "jamanteiga"
git config user.email >nul 2>&1 || git config user.email "jamanteiga@users.noreply.github.com"

REM --- 5. Preparar y confirmar cambios -------------------------
git add -A
git diff --cached --quiet
if errorlevel 1 (
  for /f "tokens=1-3 delims=/ " %%a in ("%date%") do set "FECHA=%%c-%%b-%%a"
  git commit -q -m "Actualizacion APPS %FECHA% %time:~0,5%"
  echo Cambios confirmados:
  git show --stat --oneline -s HEAD
  git show --name-status --format= HEAD
) else (
  echo No hay cambios locales nuevos.
)

REM --- 6. Traer cambios de GitHub y subir ----------------------
echo.
echo Sincronizando con GitHub...
git pull -q --rebase origin %RAMA%
if errorlevel 1 (
  echo [ERROR] Conflicto al sincronizar. Revisa los ficheros y vuelve a ejecutar.
  git rebase --abort >nul 2>&1
  goto :fin
)

git push -u origin %RAMA%
if errorlevel 1 (
  echo [ERROR] No se pudo subir. Comprueba tu usuario/permisos de GitHub.
  goto :fin
)

echo.
echo  OK - Subido. En 1-2 minutos estara en https://jamanteiga.github.io/APPS/
echo  (recarga con Ctrl+F5)

:fin
echo.
pause
endlocal