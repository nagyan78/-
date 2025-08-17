#!/bin/bash

# Talk to AI development start script

echo "Starting Talk to AI in development mode..."

# Check if running on a supported platform
if [[ "$OSTYPE" == "linux-gnu"* ]] || [[ "$OSTYPE" == "darwin"* ]]; then
    echo "Unix-like system detected"
elif [[ "$OSTYPE" == "msys" ]] || [[ "$OSTYPE" == "win32" ]]; then
    echo "Windows system detected - this script is designed for Unix-like systems"
    echo "Please use dev-start.bat on Windows"
    exit 1
else
    echo "Unsupported OS: $OSTYPE"
    exit 1
fi

# Activate virtual environment
if [ -d "venv" ]; then
    source venv/bin/activate
else
    echo "Virtual environment not found. Please run deploy.sh first."
    exit 1
fi

# Start backend in background
echo "Starting backend server..."
cd backend
uvicorn main:app --reload --host 0.0.0.0 --port 8000 &
BACKEND_PID=$!
cd ..

# Print instructions for starting frontend
echo ""
echo "Backend server started with PID $BACKEND_PID"
echo ""
echo "To start the frontend:"
echo "  cd frontend"
echo "  flutter run"
echo ""
echo "API Documentation: http://localhost:8000/docs"
echo ""
echo "Press Ctrl+C to stop the backend server"
echo ""

# Wait for backend to be terminated
wait $BACKEND_PID