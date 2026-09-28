@echo off
chcp 65001 >nul
title 게재보고 자동 생성 - 로컬 서버
cd /d "%~dp0"

echo.
echo ============================================================
echo   신한카드 멤버십 영업팀 - 검색광고 게재보고 자동 생성
echo ============================================================
echo.

REM ---------- Python launcher 확인 ----------
where py >nul 2>nul
if errorlevel 1 (
  echo [오류] Python launcher^(py.exe^) 를 찾을 수 없습니다.
  echo.
  echo   1^) https://www.python.org/downloads/ 에서 Python 3.10 이상 설치
  echo   2^) 설치 화면에서 "Add python.exe to PATH" 체크
  echo   3^) 설치 완료 후 이 파일을 다시 실행
  echo.
  pause
  exit /b 1
)

REM ---------- 의존성 점검 (마커 파일 + import 검사) ----------
set "MARKER=%~dp0.setup_done"
if exist "%MARKER%" (
  py -c "import flask, playwright, PIL, pptx, numpy" >nul 2>nul
  if errorlevel 1 (
    echo [감지] 새 라이브러리가 필요합니다. 재설치 진행...
    del "%MARKER%" >nul 2>nul
  )
)

if not exist "%MARKER%" (
  echo [최초 설치] 필요한 라이브러리를 다운로드합니다. 2-3분 소요됩니다.
  echo.
  echo [1/2] Python 패키지 설치 중...
  py -m pip install --upgrade --quiet pip
  py -m pip install --quiet flask playwright Pillow python-pptx numpy
  if errorlevel 1 (
    echo.
    echo [오류] Python 패키지 설치 실패. 인터넷 연결을 확인하세요.
    pause
    exit /b 1
  )

  echo [2/2] 브라우저 엔진^(Chromium^) 설치 중... 약 150MB
  py -m playwright install chromium
  if errorlevel 1 (
    echo.
    echo [오류] Chromium 설치 실패.
    pause
    exit /b 1
  )

  echo. > "%MARKER%"
  echo.
  echo [완료] 설치가 끝났습니다. 이후 실행부터는 바로 서버가 시작됩니다.
  echo.
)

REM ---------- 서버 실행 ----------
echo   브라우저가 자동으로 열립니다. 종료하려면 이 창에서 Ctrl+C
echo.
py server.py
pause
