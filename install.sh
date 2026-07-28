#!/bin/sh
set -eu

PROFILE_D="${PROFILE_D:-/etc/profile.d}"

# 1. System deps
apk add --no-cache nodejs npm ca-certificates

# 2. Install pi
if ! command -v pi >/dev/null 2>&1; then
  if ! npm i -g --ignore-scripts @earendil-works/pi-coding-agent 2>/dev/null; then
    npm i -g --ignore-scripts @earendil-works/pi-coding-agent --registry https://registry.npmmirror.com
  fi
fi

# 3. Install StepFun extension
EXT_DIR="$HOME/.pi/agent/extensions/stepfun"
rm -rf "$EXT_DIR"
mkdir -p "$EXT_DIR"
wget -qO- https://github.com/V-dev-388/pi-stepfun/archive/refs/heads/main.tar.gz \
  | tar xz -C "$EXT_DIR" --strip-components=1

# 4. API Key
KEY_FILE="${PROFILE_D}/stepfun_api_key.sh"
if [ -n "${STEPFUN_API_KEY:-}" ]; then
  mkdir -p "$PROFILE_D"
  printf 'export STEPFUN_API_KEY="%s"\n' "$STEPFUN_API_KEY" > "$KEY_FILE"
  chmod 600 "$KEY_FILE"
  printf "API key saved to %s\n" "$KEY_FILE"
else
  KEY=""
  if [ -r /dev/tty ]; then
    printf "Enter your StepFun API key (or press Enter to skip): " > /dev/tty
    read -r KEY < /dev/tty || true
  fi
  if [ -n "$KEY" ]; then
    mkdir -p "$PROFILE_D"
    printf 'export STEPFUN_API_KEY="%s"\n' "$KEY" > "$KEY_FILE"
    chmod 600 "$KEY_FILE"
    printf "API key saved to %s\n" "$KEY_FILE"
  else
    printf "No API key provided. Set STEPFUN_API_KEY manually.\n"
  fi
fi

# 5. Done
printf "\nDone! Usage: pi --model stepfun/step-3.7-flash\n"
printf "Get your API key at: https://platform.stepfun.com\n"
