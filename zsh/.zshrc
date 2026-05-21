# --- PATH ---
export PATH="/Applications/Cursor.app/Contents/Resources/app/bin:$PATH"
export PATH="/Users/swaabi/.antigravity/antigravity/bin:$PATH"
export PATH="$HOME/.npm-global/bin:$PATH"

# --- Aliases ---
alias python=python3
alias ila='cd ~/Dev/projects/ila-app'

# --- Mac Mini Remote ---
MINI="swaabi@100.80.153.36"
alias sora-sync='ssh $MINI "cd ~/Dev/projects/sora && git diff --quiet && git diff --cached --quiet || (git add -A && git commit -m \"VOILA auto-sync\" && git push)" 2>/dev/null; git -C ~/Dev/projects/sora pull'
alias mini='ssh $MINI'
alias mini-voila='ssh $MINI "/Users/swaabi/.npm-global/bin/pm2 restart voila"'

# --- Tools ---
eval "$(direnv hook zsh)"

. "$HOME/.local/bin/env"

# Substrate
export SUBSTRATE_ENGINE_PATH="/Users/swaabi/.substrate/engine"
export SUBSTRATE_PATH="/Users/swaabi/Dev/sandbox/substrate"
