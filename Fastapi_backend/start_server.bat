@echo off
echo Starting FastAPI Server...
cd /d "%~dp0"
python -m pip install fastapi uvicorn tensorflow pillow python-multipart numpy
python main.py
pause