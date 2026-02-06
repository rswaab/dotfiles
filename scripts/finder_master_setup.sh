#!/usr/bin/env bash
set -euo pipefail

echo "Finder Master Setup — cloud-friendly defaults"

CLOUD_ROOT="$HOME/Library/CloudStorage"

echo "1) Disable .DS_Store on network/cloud volumes…"
defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool TRUE

echo "2) Set global Finder view to List (Nlsv)…"
defaults write com.apple.Finder FXPreferredViewStyle -string "Nlsv"

echo "3) Sort folders first & set global sort by Name…"
defaults write com.apple.finder _FXSortFoldersFirst -bool true
defaults write com.apple.finder FXPreferredGroupBy -string "Name"

echo "4) Improve List View readability (previews, sizes, relative dates)…"
defaults write com.apple.finder FXListViewSettings -dict \
  showIconPreview -bool true \
  calculateAllSizes -bool true \
  useRelativeDates -bool true \
  sortColumn -string "name" \
  sortOrder -string "ascending"

echo "5) Cleanup any existing .DS_Store files under CloudStorage…"
if [ -d "$CLOUD_ROOT" ]; then
  COUNT_BEFORE=$(find "$CLOUD_ROOT" -name ".DS_Store" | wc -l | tr -d ' ')
  echo "   Found $COUNT_BEFORE .DS_Store file(s) before cleanup."
  find "$CLOUD_ROOT" -name ".DS_Store" -type f -delete 2>/dev/null || true
  COUNT_AFTER=$(find "$CLOUD_ROOT" -name ".DS_Store" | wc -l | tr -d ' ')
  echo "   Remaining after cleanup: $COUNT_AFTER"
else
  echo "   CloudStorage folder not found at $CLOUD_ROOT (skipping cleanup)."
fi

echo "6) Restart Finder to apply changes…"
killall Finder >/dev/null 2>&1 || true

echo "Done. Finder is now configured."
