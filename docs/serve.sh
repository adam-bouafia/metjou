#!/usr/bin/env bash
# Local preview of the documentation site, in its own virtual environment.
#
#   docs/serve.sh          serve on http://127.0.0.1:8000
#   docs/serve.sh build    build into site/ and stop on any warning
set -euo pipefail
cd "$(dirname "$0")/.."

if [[ ! -x docs/.venv/bin/mkdocs ]]; then
  python3 -m venv docs/.venv
  docs/.venv/bin/pip install --quiet -r docs/requirements.txt
fi

if [[ "${1:-}" == "build" ]]; then
  exec docs/.venv/bin/mkdocs build --strict
fi
exec docs/.venv/bin/mkdocs serve
