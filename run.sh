#!/usr/bin/env bash
set -euo pipefail

draft_dir=$(mktemp -d "${RUNNER_TEMP:?}/korean-release-note.XXXXXXXX")
draft="$draft_dir/release-note.md"

case "$DRAFT_MODE" in
    sample)
        cp "$GITHUB_ACTION_PATH/sample/release-note.md" "$draft"
        ;;
    draft)
        if [[ -z "${OPENAI_API_KEY:-}" ]]; then
            echo 'Set OPENAI_API_KEY on the action step for draft mode.' >&2
            exit 1
        fi
        env -u OPENAI_API_KEY python3 - "$GITHUB_WORKSPACE" "$DRAFT_KIT_PATH" "$DRAFT_SOURCE" <<'PY'
from pathlib import Path
import sys

workspace = Path(sys.argv[1]).resolve()
kit = (workspace / sys.argv[2]).resolve()
source = (workspace / sys.argv[3]).resolve()
if not kit.is_relative_to(workspace) or not source.is_relative_to(workspace):
    sys.exit("Use a kit and an input Markdown file inside the workspace.")
for path in (kit / "generate.py", kit / "requirements.txt", source):
    if not path.is_file() or not path.resolve().is_relative_to(workspace):
        sys.exit("The kit or input file is missing or is outside the workspace.")
PY
        cd "$GITHUB_WORKSPACE"
        env -u OPENAI_API_KEY python3 -m venv "$draft_dir/venv"
        env -u OPENAI_API_KEY "$draft_dir/venv/bin/python" -m pip install --quiet -r "$DRAFT_KIT_PATH/requirements.txt"
        "$draft_dir/venv/bin/python" -- "$DRAFT_KIT_PATH/generate.py" -- "$DRAFT_SOURCE" "$draft"
        ;;
    *)
        echo 'Choose sample or draft mode.' >&2
        exit 1
        ;;
esac

test -s "$draft"
printf 'draft=%s\n' "$draft" >> "$GITHUB_OUTPUT"
