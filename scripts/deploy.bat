@echo off
REM Talk to AI deployment script for Windows

echo Starting Talk to AI deployment...

REM Check if we're in the right directory
if not exist "backend" (
    echo Error: backend directory not found
    echo Please run this script from the project root directory
    pause
    exit /b 1
)

REM Create virtual environment if it doesn't exist
if not exist "venv" (
    echo Creating virtual environment...
    python -m venv venv
)

REM Activate virtual environment
call venv\Scripts\activate

REM Install backend dependencies
echo Installing backend dependencies...
cd backend
pip install -r requirements.txt

REM Initialize database
echo Initializing database...
python app\core\init_db.py

REM Return to root directory
cd ..

REM Build frontend
echo Building frontend...
cd frontend
flutter build web

REM Return to root directory
cd ..

echo Deployment completed successfully!
echo.
echo To start the application:
echo   1. Start the backend server:
echo      cd backend && python main.py
echo   2. Serve the frontend (you can use any web server):
echo      cd frontend\build\web && python -m http.server 8080
echo.
echo Backend API will be available at http://localhost:8000
echo Frontend will be available at http://localhost:8080

pause