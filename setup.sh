#!/bin/bash
set -euo pipefail

echo '[MAGIC] Checking for XCode Select tooling...'
if xcode-select -p > /dev/null 2>&1
then
  echo "[MAGIC] Xcode-select is installed. Continuing..."
else
  echo "[DARK-MAGIC] Xcode-select is not installed."
  echo "[DARK-MAGIC] Launching XCode tooling installer and quitting..."
  xcode-select --install &
  exit 1
fi

# we install homebrew, we ball...
echo '[MAGIC] Installing homebrew'
NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# add homebrew to our path
echo '[MAGIC] Adding homebrew to path...'
echo >> "$HOME/.zprofile"
echo 'eval "$(/opt/homebrew/bin/brew shellenv zsh)"' >> "$HOME/.zprofile"
eval "$(/opt/homebrew/bin/brew shellenv zsh)"

# install the basics
echo '[MAGIC] Installing Homebrew packages...'
brew install python@3.12 python-tk@3.12 wget yt-dlp mas go fzf ollama codex gnucobol claude-code
echo '[MAGIC] Installing Homebrew casks...'

# Development tools
brew install --cask \
  antigravity \
  android-platform-tools \
  utm

# Creative & media
brew install --cask \
  krita \
  darktable \
  diffusionbee \
  upscayl \
  vlc

# Gaming & emulation
brew install --cask \
  openemu \
  mythic  # arm exclusive

# Productivity & utilities
brew install --cask \
  onlyoffice \
  raycast \
  the-unarchiver \
  balenaetcher \
  tailscale-app

# Privacy & security
brew install --cask \
  protonvpn \
  tuta-mail \
  session

# Browsers
brew install --cask \
  orion \
  google-chrome # needed for antigravity browser-based app testing agent.

# Install "nvm"
echo '[MAGIC] Installing "nvm"...'
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.4/install.sh | bash

# load nvm into terminal and make it known
echo '[MAGIC] Making "nvm" known'
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"               # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion" # This loads nvm bash_completion

# now install our nodejs versions and persist the default
echo '[MAGIC] Installing NodeJS..'
nvm i 13 && nvm i --lts && nvm i 24
nvm alias default 24  # persist the default node version across new shells
nvm use 24

# Get surge...
echo '[MAGIC] Installing Surge..'
npm i -g surge

# now we install our mac app store apps
echo '[MAGIC] Now installing Mac App Store apps...'
mas install 408981434 500154009 6736948278 931571202

# now we install our vscodium plugins
echo '[MAGIC] Plugging in code-esque plugins...'
antigravity --install-extension saoudrizwan.claude-dev
antigravity --install-extension ms-python.python
antigravity --install-extension devsense.phptools-vscode
antigravity --install-extension golang.Go
antigravity --install-extension esbenp.prettier-vscode
antigravity --install-extension redhat.vscode-yaml
antigravity --install-extension bradlc.vscode-tailwindcss
antigravity --install-extension ms-azuretools.vscode-docker

# now we copy our 86box roms (86box replaced with UTM, so this is commented.)
# echo '[MAGIC] Install 86box ROMs'
# git clone https://github.com/86Box/roms ~/.86roms-magic
# mkdir -p '~/Library/Application Support/net.86box.86Box/roms'
# cp -r ~/.86roms-magic/* '~/Library/Application Support/net.86box.86Box/roms'
# rm -rf ~/.86roms-magic

# time to install the rosetta stone!
echo '[MAGIC] Gathering Rosetta Stones...'
softwareupdate --install-rosetta --agree-to-license

# find and open the dmg.
echo '[MAGIC] Installing Open Cowork...'

wget -P "$HOME" https://github.com/OpenCoworkAI/open-cowork/releases/download/v3.3.0/Open.Cowork-3.3.0-mac-arm64.dmg
hdiutil attach "$HOME/Open.Cowork"*.dmg

sudo cp -r /Volumes/Open\ Cowork*/Open\ Cowork.app /Applications

hdiutil detach /Volumes/Open\ Cowork*
rm -f "$HOME/Open.Cowork-"*.dmg

# get Windows downloader
echo '[MAGIC] Downloading Windows downloader...'
wget -P "$HOME" https://github.com/TuringSoftware/CrystalFetch/releases/download/v2.2.0/CrystalFetch.dmg
hdiutil attach "$HOME/CrystalFetch.dmg"
sudo cp -r /Volumes/CrystalFetch/CrystalFetch.app /Applications
hdiutil detach /Volumes/CrystalFetch
rm -f "$HOME/CrystalFetch.dmg"

# we set our neat settings
echo '[MAGIC] Modifying settings...'
defaults write -g InitialKeyRepeat -int 12
defaults write -g KeyRepeat -int 2
defaults write com.apple.Accessibility DifferentiateWithoutColor -int 1
defaults write com.apple.Accessibility ReduceMotionEnabled -int 1
defaults write com.apple.Accessibility reduceMotion -int 1
defaults write com.apple.Accessibility reduceTransparency -int 1
defaults write com.apple.universalaccessAuthWarning com.apple.Messages -bool true
defaults write com.apple.universalaccessAuthWarning com.apple.Terminal -bool true
sudo defaults write /Library/Preferences/com.apple.loginwindow DesktopPicture ""

# we disable shortcut to spotlight
echo '[MAGIC] Disabling Spotlight...'
sudo mdutil -i off -a
/usr/libexec/PlistBuddy "$HOME/Library/Preferences/com.apple.symbolichotkeys.plist" \
  -c "Delete :AppleSymbolicHotKeys:64" \
  -c "Add :AppleSymbolicHotKeys:64:enabled bool false" \
  -c "Add :AppleSymbolicHotKeys:64:value:parameters array" \
  -c "Add :AppleSymbolicHotKeys:64:value:parameters: integer 65535" \
  -c "Add :AppleSymbolicHotKeys:64:value:parameters: integer 49" \
  -c "Add :AppleSymbolicHotKeys:64:value:parameters: integer 1048576" \
  -c "Add :AppleSymbolicHotKeys:64:type string standard"

# Make paths and local bin dir
echo '[MAGIC] Finding my path...'
mkdir -p "$HOME/.local/bin"
echo 'export PATH="$HOME/.local/bin:$PATH"' >> "$HOME/.zshrc"

# Grab Ollauncha
echo '[MAGIC] Installing Ollauncha...'
wget -O "$HOME/.local/bin/ollauncha" https://github.com/MyMel2001/ollauncha/raw/refs/heads/main/ollauncha.sh
chmod +x "$HOME/.local/bin/ollauncha"
mkdir -p "$HOME/.config/ollauncha"
wget -O "$HOME/.config/ollauncha/remotes" https://github.com/MyMel2001/ollauncha/raw/refs/heads/main/remotes.example

# Grab Cafe
echo '[MAGIC] Get what will make me stay alive...'
wget -O "$HOME/.local/bin/cafe" https://github.com/MyMel2001/cafe/raw/refs/heads/main/cafe.sh
chmod +x "$HOME/.local/bin/cafe"

# Install Safari extensions
echo '[MAGIC] Going on a Safari to get extensions...'
mas install 1352778147  # Bitwarden                       (2026.3.1)
mas install 6745342698  # uBlock Origin Lite              (2026.422.1301)
mas install 1606897889  # Consent-O-Matic             (1.1.3)
mas install 1561604170  # Nightshift Dark Mode            (1.2)

# Download NextDNS profile
echo '[MAGIC] Downloading NextDNS profile...'
wget -O ~/nextdns.mobileconfig https://tinyurl.com/yc26w9rc

# Make it dark
echo '[MAGIC] Enabling dark mode...'
defaults write .GlobalPreferences.plist AppleInterfaceStyle -string 'Dark'

echo '[MAGIC] Rebooting...'
sudo reboot
