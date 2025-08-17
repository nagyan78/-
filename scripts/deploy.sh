#!/bin/bash

# Talk to AI deployment script

# Exit on any error
set -e

echo "Starting Talk to AI deployment..."

# Check if running on a supported platform
if [[ "$OSTYPE" == "linux-gnu"* ]] || [[ "$OSTYPE" == "darwin"* ]]; then
    echo "Unix-like system detected"
elif [[ "$OSTYPE" == "msys" ]] || [[ "$OSTYPE" == "win32" ]]; then
    echo "Windows system detected - this script is designed for Unix-like systems"
    echo "Please use deploy.bat on Windows"
    exit 1
else
    echo "Unsupported OS: $OSTYPE"
    exit 1
fi

# Create virtual environment if it doesn't exist
if [ ! -d "venv" ]; then
    echo "Creating virtual environment..."
    python3 -m venv venv
fi

# Activate virtual environment
source venv/bin/activate

# Install backend dependencies
echo "Installing backend dependencies..."
cd backend
pip install -r requirements.txt

# Initialize database
echo "Initializing database..."
python app/core/init_db.py

# Return to root directory
cd ..

# Build frontend
echo "Building frontend..."
cd frontend
flutter build web

# Return to root directory
cd ..

echo "Deployment completed successfully!"
echo ""
echo "To start the application:"
echo "  1. Start the backend server:"
echo "     cd backend && python main.py"
echo "  2. Serve the frontend (you can use any web server):"
echo "     cd frontend/build/web && python -m http.server 8080"
echo ""
echo "Backend API will be available at http://localhost:8000"
echo "Frontend will be available at http://localhost:8080"