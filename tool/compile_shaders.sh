#!/usr/bin/env bash
# Compiles glass.frag into the .iplr runtime bundle (all backends).
set -euo pipefail
FLUTTER_BIN="$(command -v flutter)"
IMPELLER="$(dirname "$(dirname "$FLUTTER_BIN")")/bin/cache/artifacts/engine/darwin-x64/impellerc"
LIB="$(dirname "$IMPELLER")/shader_lib"
"$IMPELLER" \
  --runtime-stage-gles --runtime-stage-metal --sksl \
  --iplr \
  --input=shaders/glass.frag \
  --spirv=/tmp/glass.spv \
  --sl=shaders/glass.iplr \
  --include="$LIB"
echo "shaders/glass.iplr updated."
