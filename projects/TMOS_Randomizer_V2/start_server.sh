#!/bin/bash
cd /workspace/TMOS_AI/projects/TMOS_Randomizer_V2
export PYTHONPATH=/workspace/TMOS_AI/projects/TMOS_Randomizer_V2/src
/usr/local/bin/uvicorn tmos_randomizer.api.server:app --host 0.0.0.0 --port 8000
