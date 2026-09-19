#!/usr/bin/env bash
# publish every addon in catalogue.json
set -euo pipefail
cd "$(dirname "$0")"
for n in $(python3 -c 'import json;print(" ".join(a["name"] for a in json.load(open("catalogue.json"))["addons"]))'); do
  ./publish.sh "$n"
done
