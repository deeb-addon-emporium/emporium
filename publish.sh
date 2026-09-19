#!/usr/bin/env bash
# publish.sh <AddonName>  — push one WoW Forever addon to its GitHub repo and cut a release.
# Reads ## Version from the .toc. Same version already released => no-op.
set -euo pipefail
ORG="${EMPORIUM_ORG:-deeb-addon-emporium}"
ADDONS="${EMPORIUM_ADDONS:-$HOME/Games/battlenet/drive_c/Program Files (x86)/World of Warcraft/_classic_beta_/Interface/AddOns}"
HERE="$(cd "$(dirname "$0")" && pwd)"
name="${1:?addon name}"
src="$ADDONS/$name"
[ -d "$src" ] || { echo "no such addon: $src"; exit 1; }
case "$name" in RXPGuides|RXPGuideImport) echo "refusing: $name is not ours"; exit 1;; esac
toc="$src/$name.toc"
[ -f "$toc" ] || { echo "no $name.toc"; exit 1; }
ver="$(grep -m1 -E '^## Version:' "$toc" | sed 's/^## Version:[[:space:]]*//' | tr -d '\r')"
[ -n "$ver" ] || { echo "no ## Version in $toc"; exit 1; }
notes="$(grep -m1 -E '^## Notes:' "$toc" | sed 's/^## Notes:[[:space:]]*//' | tr -d '\r')"
grep -q '^## Interface: 16001' "$toc" || { echo "refusing: $name.toc is not Interface 16001 (WoW Forever)"; exit 1; }
if grep -rq '^47|' "$src"; then echo "refusing: $name contains an RXP guide string"; exit 1; fi

work="$(mktemp -d)"; trap 'rm -rf "$work"' EXIT
repo="$work/repo"
if gh repo view "$ORG/$name" >/dev/null 2>&1; then
  gh repo clone "$ORG/$name" "$repo" -- -q
else
  gh repo create "$ORG/$name" --public --description "$notes" >/dev/null
  gh repo clone "$ORG/$name" "$repo" -- -q
fi
cd "$repo"
# mirror the addon folder: everything except backups and saved-var junk
find . -mindepth 1 -maxdepth 1 ! -name .git -exec rm -rf {} +
rsync -a --exclude '*.bak' --exclude '*.orig' --exclude '.DS_Store' "$src/" "$repo/"
cp "$HERE/templates/LICENSE" LICENSE
sed -e "s|{{NAME}}|$name|g" -e "s|{{NOTES}}|$notes|g" -e "s|{{ORG}}|$ORG|g" -e "s|{{VERSION}}|$ver|g" \
  "$HERE/templates/README.md" > README.md
git add -A
if git diff --cached --quiet; then echo "$name: no changes"; else
  git -c user.name="Deeb's Addon Emporium" -c user.email="mdeeb95@users.noreply.github.com" commit -q -m "$name v$ver"
  git push -q origin HEAD
fi
if gh release view "v$ver" -R "$ORG/$name" >/dev/null 2>&1; then echo "$name: v$ver already released"; exit 0; fi
# zip with the addon folder at the root: AutoQuest/AutoQuest.toc
mkdir -p "$work/zip"; rsync -a --exclude '.git' --exclude 'README.md' --exclude 'LICENSE' "$repo/" "$work/zip/$name/"
( cd "$work/zip" && zip -qr "$work/$name.zip" "$name" )
gh release create "v$ver" "$work/$name.zip" -R "$ORG/$name" -t "$name v$ver" -n "$notes" >/dev/null
echo "$name: released v$ver"
