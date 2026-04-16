#!/bin/bash

# Ralph Wiggum Autonomous Development Loop
# Runs Claude Code in a continuous loop with fresh context per iteration
# Each iteration prevents context degradation and hallucination risks

set -e

# Colors for terminal output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Print colored output
print_color() {
    local color=$1
    local message=$2
    echo -e "${color}${message}${NC}"
}

print_header() {
    echo ""
    print_color "$BLUE" "════════════════════════════════════════════════════════════"
    print_color "$CYAN" "  $1"
    print_color "$BLUE" "════════════════════════════════════════════════════════════"
    echo ""
}

print_success() {
    print_color "$GREEN" "✓ $1"
}

print_warning() {
    print_color "$YELLOW" "⚠ $1"
}

print_error() {
    print_color "$RED" "✗ $1"
}

print_info() {
    print_color "$CYAN" "→ $1"
}

# Check for required argument
if [ -z "$1" ]; then
    print_error "Usage: ./ralph.sh <max_iterations>"
    print_info "Example: ./ralph.sh 20"
    exit 1
fi

MAX_ITERATIONS=$1

# Validate iteration count
if ! [[ "$MAX_ITERATIONS" =~ ^[0-9]+$ ]] || [ "$MAX_ITERATIONS" -lt 1 ]; then
    print_error "Max iterations must be a positive integer"
    exit 1
fi

print_header "RALPH WIGGUM AUTONOMOUS DEVELOPMENT LOOP"

print_info "Max iterations: $MAX_ITERATIONS"
echo ""

# Check for required files
print_info "Checking required files..."

if [ ! -f "PROMPT.md" ]; then
    print_error "PROMPT.md not found!"
    print_info "Run /create-prd first to set up your project"
    exit 1
fi
print_success "PROMPT.md found"

if [ ! -f "prd.md" ]; then
    print_error "prd.md not found!"
    print_info "Run /create-prd first to set up your project"
    exit 1
fi
print_success "prd.md found"

# Initialize activity.md if not exists
if [ ! -f "activity.md" ]; then
    print_warning "activity.md not found, creating..."
    echo "# Activity Log" > activity.md
    echo "" >> activity.md
    echo "This file tracks progress during autonomous development." >> activity.md
    echo "" >> activity.md
    echo "---" >> activity.md
    echo "" >> activity.md
    print_success "activity.md created"
else
    print_success "activity.md found"
fi

# Create screenshots directory if not exists
if [ ! -d "screenshots" ]; then
    mkdir -p screenshots
    print_success "screenshots directory created"
else
    print_success "screenshots directory found"
fi

echo ""
print_header "STARTING AUTONOMOUS LOOP"

ITERATION=1
COMPLETE=false

while [ $ITERATION -le $MAX_ITERATIONS ] && [ "$COMPLETE" = false ]; do
    print_header "ITERATION $ITERATION of $MAX_ITERATIONS"

    print_info "Starting Claude Code with fresh context..."
    echo ""

    # Run Claude Code with PROMPT.md content
    # Capture output to check for completion signal
    OUTPUT_FILE=$(mktemp)

    # Run claude with the prompt, outputting to both terminal and file
    if claude --print "$(cat PROMPT.md)" 2>&1 | tee "$OUTPUT_FILE"; then
        print_success "Claude Code completed iteration $ITERATION"
    else
        print_warning "Claude Code exited with non-zero status"
    fi

    echo ""

    # Check for completion signal
    if grep -q "<promise>COMPLETE</promise>" "$OUTPUT_FILE"; then
        COMPLETE=true
        rm -f "$OUTPUT_FILE"

        echo ""
        print_header "PROJECT COMPLETE!"
        print_success "All tasks marked as passing"
        echo ""
        print_info "Next steps:"
        echo "  1. Review activity.md for detailed progress"
        echo "  2. Check screenshots/ for visual verification"
        echo "  3. Run your test suite"
        echo "  4. Review git commits"
        echo ""
        exit 0
    fi

    rm -f "$OUTPUT_FILE"

    # Increment iteration counter
    ITERATION=$((ITERATION + 1))

    if [ $ITERATION -le $MAX_ITERATIONS ]; then
        print_info "Preparing next iteration with fresh context..."
        sleep 2
    fi
done

echo ""
print_header "MAX ITERATIONS REACHED"

print_warning "Reached $MAX_ITERATIONS iterations without completion"
echo ""
print_info "Options:"
echo "  1. Run again with more iterations: ./ralph.sh $((MAX_ITERATIONS + 10))"
echo "  2. Review prd.md for incomplete tasks"
echo "  3. Check activity.md for progress details"
echo "  4. Manually complete remaining tasks"
echo ""

exit 1
