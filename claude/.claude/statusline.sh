#!/bin/bash
input=$(cat)

MODEL=$(echo "$input" | jq -r '.model.display_name')
DIR=$(echo "$input" | jq -r '.workspace.current_dir')
COST=$(echo "$input" | jq -r '.cost.total_cost_usd // 0')
PCT=$(echo "$input" | jq -r '.context_window.used_percentage // 0' | cut -d. -f1)
DURATION_MS=$(echo "$input" | jq -r '.cost.total_duration_ms // 0')
INPUT_TOKENS=$(echo "$input" | jq -r '.context_window.total_input_tokens // 0')
OUTPUT_TOKENS=$(echo "$input" | jq -r '.context_window.total_output_tokens // 0')

CYAN='\033[36m'; GREEN='\033[32m'; YELLOW='\033[33m'; RED='\033[31m'; RESET='\033[0m'; MAGENTA='\033[35m'

# Format tokens as k/M
format_tokens() {
  local tokens=$1
  if [ "$tokens" -ge 1000000 ]; then
    # Format as M with 1 decimal place
    local millions=$(echo "scale=1; $tokens / 1000000" | bc)
    echo "${millions}M"
  elif [ "$tokens" -ge 1000 ]; then
    # Format as k with 1 decimal place
    local thousands=$(echo "scale=1; $tokens / 1000" | bc)
    echo "${thousands}k"
  else
    echo "$tokens"
  fi
}

INPUT_FMT=$(format_tokens "$INPUT_TOKENS")
OUTPUT_FMT=$(format_tokens "$OUTPUT_TOKENS")

# Pick bar color based on context usage
if [ "$PCT" -ge 90 ]; then BAR_COLOR="$RED"
elif [ "$PCT" -ge 70 ]; then BAR_COLOR="$YELLOW"
else BAR_COLOR="$GREEN"; fi

FILLED=$((PCT / 10)); EMPTY=$((10 - FILLED))
BAR=$(printf "%${FILLED}s" | tr ' ' '█')$(printf "%${EMPTY}s" | tr ' ' '░')

MINS=$((DURATION_MS / 60000)); SECS=$(((DURATION_MS % 60000) / 1000))

BRANCH=""
GIT_STATUS=""
if git rev-parse --git-dir > /dev/null 2>&1; then
    BRANCH=" | 🌿 $(git branch --show-current 2>/dev/null)"
    STAGED=$(git diff --cached --numstat 2>/dev/null | wc -l | tr -d ' ')
    MODIFIED=$(git diff --numstat 2>/dev/null | wc -l | tr -d ' ')

    GIT_STATUS=""
    [ "$STAGED" -gt 0 ] && GIT_STATUS="${GREEN}+${STAGED}${RESET}"
    [ "$MODIFIED" -gt 0 ] && GIT_STATUS="${GIT_STATUS}${YELLOW}~${MODIFIED}${RESET}"
fi

echo -e "${CYAN}[$MODEL]${RESET} 📁 ${DIR##*/}$BRANCH $GIT_STATUS"
COST_FMT=$(printf '$%.2f' "$COST")
echo -e "${BAR_COLOR}${BAR}${RESET} ${PCT}% | ${CYAN}↑ ${INPUT_FMT}${RESET} ${YELLOW}↓ ${OUTPUT_FMT}${RESET} | ${MAGENTA}${COST_FMT}${RESET} | ⏱️ ${MINS}m ${SECS}s"
