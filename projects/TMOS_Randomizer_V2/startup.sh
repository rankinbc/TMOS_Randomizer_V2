#!/bin/bash
cd /home/site/wwwroot
export PYTHONPATH=/home/site/wwwroot/src:$PYTHONPATH
python -m uvicorn tmos_randomizer.api.server:app --host 0.0.0.0 --port ${PORT:-8000}
