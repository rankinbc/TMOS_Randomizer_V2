@plan.md @activity.md

# TMOS Randomizer - Navigation System

We are implementing the navigation system for Phases 4 and 5.

## First: Check State

1. Read activity.md for recent progress
2. Read plan.md for task list

## Then: Start Server (if not running)

cd /workspace/TMOS_AI/projects/TMOS_Randomizer_V2
export PYTHONPATH=$(pwd)/src:$PYTHONPATH
pgrep -f uvicorn || python3 -m uvicorn tmos_randomizer.api.server:app --host 0.0.0.0 --port 8000 &
sleep 3
curl -s http://localhost:8000/api/debug/validate | head -20

## Then: Work on ONE Task

Find the highest priority task where passes is false.
Implement it fully, then validate.

## After Each Task

1. Log progress in activity.md
2. Update passes to true in plan.md
3. Git commit: git add -A && git commit -m "feat: [description]"

Do NOT push. Work on ONE task only.

## When Complete

When ALL tasks have passes true, output exactly:

<promise>COMPLETE</promise>

## Key Files

- src/tmos_randomizer/phases/phase4_population.py
- src/tmos_randomizer/phases/phase5_navigation.py  
- ui/src/components/MapView.tsx
- knowledge/systems/randomization-validation-criteria.md
