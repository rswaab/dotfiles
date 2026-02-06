# dotfiles

Personal dotfiles and machine setup.

## New Machine Setup

```bash
mkdir -p ~/Dev
git clone <your-dotfiles-repo> ~/Dev/dotfiles
cd ~/Dev/dotfiles && bash install.sh
```

This will:
- Create `~/Dev/{projects,lab,scratch}`
- Symlink all config files to the right locations

## After Install

```bash
# Install Homebrew packages
cd ~/Dev/dotfiles && brew bundle

# Configure Finder
bash ~/Dev/dotfiles/scripts/finder_master_setup.sh
```

## Structure

```
~/Dev/
  dotfiles/    # this repo
  projects/    # git repos for active work
  lab/         # experiments and evaluations
  scratch/     # throwaway stuff
```
