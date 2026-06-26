#!/usr/bin/env zsh

{
set -e # Exit on error

echo "==> 🏕️ Welcome to Trail PHP..."

TRAIL_DIR="$HOME/Library/Application Support/Trail"
TRAIL_BIN_DIR="$TRAIL_DIR/bin"
TRAIL_SITES_DIR="$TRAIL_DIR/sites"
REPO_URL="https://raw.githubusercontent.com/emmadesilva/trailphp/main"

# 1. Ensure Directories Exist
echo "==> Setting up Trail directories..."
mkdir -p "$TRAIL_DIR"
mkdir -p "$TRAIL_BIN_DIR"
mkdir -p "$TRAIL_SITES_DIR"

# 2. Check for Homebrew
if ! command -v brew &> /dev/null; then
    echo "==> Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    eval "$(/opt/homebrew/bin/brew shellenv)"
else
    echo "==> Homebrew is already installed."
fi

# 3. Install core dependencies (Caddy, PHP Tap)
echo "==> Installing dependencies via Homebrew..."
brew tap shivammathur/php

# Auto-trust the PHP tap so Homebrew doesn't block the installation
brew trust shivammathur/php 2>/dev/null || true

brew list caddy &>/dev/null || brew install caddy

# 4. Fetch the `trail` CLI executable
echo "==> Downloading Trail CLI..."
# Using a cache buster so users always get the latest version during install
curl -sL "$REPO_URL/trail?v=$(date +%s)" -o "$TRAIL_BIN_DIR/trail"
chmod +x "$TRAIL_BIN_DIR/trail"

# 5. Create the PHP proxy script
echo "==> Creating PHP proxy..."
cat > "$TRAIL_BIN_DIR/php" <<'PHPPROXY'
#!/usr/bin/env zsh
TRAIL_DIR="$HOME/Library/Application Support/Trail"
PHP_VERSION_FILE="$TRAIL_DIR/php-version"

if [ -f "$PHP_VERSION_FILE" ]; then
    PHP_VERSION=$(cat "$PHP_VERSION_FILE")
    PHP_BIN="$(brew --prefix "shivammathur/php/php@$PHP_VERSION" 2>/dev/null)/bin/php"
    if [ -x "$PHP_BIN" ]; then
        exec "$PHP_BIN" "$@"
    fi
fi

# Fallback to the Homebrew-linked php
exec "$(brew --prefix)/bin/php" "$@"
PHPPROXY
chmod +x "$TRAIL_BIN_DIR/php"

# 6. Configure Caddy Base File
CADDYFILE="$TRAIL_DIR/Caddyfile"
if [ ! -f "$CADDYFILE" ]; then
    echo "==> Creating base Caddy configuration..."
    # Note: Deliberately avoiding 'admin off' so caddy reload works
    echo "import sites/*.caddy" > "$CADDYFILE"
fi

# 7. Add to PATH in .zshrc
if ! grep -q "$TRAIL_BIN_DIR" "$HOME/.zshrc"; then
    echo "==> Adding Trail to your PATH..."
    echo "\n# Trail PHP CLI" >> "$HOME/.zshrc"
    echo "export PATH=\"\$PATH:$TRAIL_BIN_DIR\"" >> "$HOME/.zshrc"
fi

# 8. Start base services
echo "==> Stopping any old user-level Caddy services..."
brew services stop caddy 2>/dev/null || true

echo "==> Starting Caddy in the background (requires sudo for ports 80/443)..."
# If reload fails (because it isn't running), start it natively.
if ! sudo caddy reload --config "$CADDYFILE" >/dev/null 2>&1; then
    sudo caddy start --config "$CADDYFILE" >/dev/null 2>&1
fi

echo "==> ✅ Trail installed successfully!"
echo "⚠️  IMPORTANT: Run 'source ~/.zshrc' or open a new terminal window to use the 'trail' command."

}
