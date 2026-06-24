#!/usr/bin/env bash
#
# Build + run this C4 model in Structurizr (local) and open it in the default browser.
# This folder is bind-mounted, so edits to workspace.dsl show up on a browser refresh.
#
# Usage:  ./run.sh            # serve on :8080 and open the browser
#         PORT=9000 ./run.sh  # serve on a different port
#         ./run.sh stop       # stop the running container
set -euo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
IMAGE="c4-viewer"
NAME="c4-viewer"
PORT="${PORT:-8080}"
URL="http://localhost:${PORT}"

if [ "${1:-}" = "stop" ]; then
  docker rm -f "${NAME}" >/dev/null 2>&1 && echo "Stopped ${NAME}." || echo "${NAME} was not running."
  exit 0
fi

if ! docker info >/dev/null 2>&1; then
  echo "Docker daemon is not running. Start Docker and retry." >&2
  exit 1
fi

echo "Building ${IMAGE} ..."
docker build -t "${IMAGE}" "${DIR}"

echo "Starting ${NAME} on ${URL} ..."
docker rm -f "${NAME}" >/dev/null 2>&1 || true
docker run -d --rm --name "${NAME}" -p "${PORT}:8080" \
  -v "${DIR}:/usr/local/structurizr" "${IMAGE}" >/dev/null

# Wait for the server to come up.
for _ in $(seq 1 30); do
  case "$(curl -s -o /dev/null -w '%{http_code}' "${URL}" 2>/dev/null || true)" in
    200 | 301 | 302) break ;;
  esac
  sleep 1
done

# Open in the default browser (macOS: open, Linux: xdg-open).
if command -v open >/dev/null 2>&1; then
  open "${URL}"
elif command -v xdg-open >/dev/null 2>&1; then
  xdg-open "${URL}"
else
  echo "Open ${URL} in your browser."
fi

echo "Structurizr is running (container: ${NAME}). Stop it with: ./run.sh stop"
