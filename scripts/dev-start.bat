@echo off
REM Talk to AI development start script for Windows

echo Starting Talk to AI in development mode...

REM Check if we're in the right directory
if not exist "backend" (
    echo Error: backend directory not found
    echo Please run this script from the project root directory
    pause
    exit /b 1
)

REM Activate virtual environment
if exist "venv" (
    call venv\Scripts\activate
) else (
    echo Virtual environment not found. Please run deploy.bat first.
    pause
    exit /b 1
)

REM Start backend
echo Starting backend server...
cd backend
start "Backend Server" /D "%CD%" python main.py
cd ..

echo.
echo Backend server started
echo.
echo To start the frontend:
echo   cd frontend
echo   flutter run
echo.
echo API Documentation: http://localhost:8000/docs
echo.
echo Close this window to stop the backend server
echo.

pause