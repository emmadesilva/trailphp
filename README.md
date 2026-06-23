# 🏕️ TrailPHP

Trail is a lightning-fast, lightweight macOS terminal replacement for Laravel Herd / Valet. It is a zero-friction wrapper around Homebrew services that manages PHP versions, Caddy (web server), and local DNS routing (`.test` domains) without the overhead of Docker or Electron apps.

All Trail configurations and binaries are safely sandboxed in `~/Library/Application Support/Trail` to keep your system clean.

## ✨ Features

*   **Simple Setup:** One-line install script. Fully idempotent (safe to rerun).
*   **Automatic HTTPS:** Powered by [Caddy](https://caddyserver.com/). Trail links sites to `.test` domains and serves them over HTTPS with auto-generated local certificates.
*   **PHP Management:** Easily install and toggle between PHP versions (e.g., 8.2, 8.3, 8.4) via Homebrew.
*   **Native DNS Routing:** Automatically maps your domains natively via `/etc/hosts`—no third-party DNS proxies required.
*   **Smart Root Detection:** Automatically detects `public/` directories for Laravel apps or falls back to the standard root directory for raw PHP projects.

---

## 🚀 Installation

Trail is built for macOS and `zsh`. You can install Trail by running the following command in your terminal:

```bash
curl -sL https://raw.githubusercontent.com/emmadesilva/trailphp/main/install.sh | zsh
```

**What the installer does:**

1. Checks for and installs Homebrew (if missing).
2. Sets up `~/Library/Application Support/Trail` to store configs and CLI files.
3. Installs Caddy and the necessary PHP taps.
4. Adds the `trail` command to your `.zshrc` PATH.

*Note: After installing, restart your terminal or run `source ~/.zshrc` to make the `trail` command available.*
---

## 🛠️ Usage

Trail provides a simple CLI to manage your local development environment.

### 1. Link a Project

Navigate to your project directory and link it. Trail will map your local directory to a `.test` domain, configure Caddy, and register it in your `/etc/hosts` file (this step requires your Mac password).

```bash
cd ~/Projects/my-awesome-site
trail link
```

By default, this will serve the site securely at `https://my-awesome-site.test`.

You can also specify a custom domain:

```bash
trail link api-backend
# Serves at [https://api-backend.test](https://api-backend.test)
```

### 2. Install a New PHP Version

Need to test a project on an older or newer PHP version? Install it directly via Trail:

```bash
trail install 8.4
```

*(This automatically installs the version via Homebrew and switches your active PHP service to it).*

### 3. Switch PHP Versions

If you already have multiple PHP versions installed, you can hot-swap the active version. Trail will stop the old service, unlink it, link the new one, and start it on port 9000.

```bash
trail use 8.3
```

### 4. Update the CLI

You can easily update the Trail executable to the latest version hosted on GitHub:

```bash
trail update
```

---

## 📂 Architecture & File Locations

Trail strives to be as non-intrusive as possible while relying on the stability of Homebrew for core services.

* **App Directory:** `~/Library/Application Support/Trail`
* **CLI Executable:** `~/Library/Application Support/Trail/bin/trail`
* **Caddy Configuration:** `~/Library/Application Support/Trail/Caddyfile`
* **Site Links:** `~/Library/Application Support/Trail/sites/*.caddy`

---

## 🤝 Contributing

Contributions, issues, and feature requests are welcome! Feel free to check the [issues page](https://github.com/emmadesilva/trailphp/issues).

## 📝 License

This project is open source and available under the [MIT License](LICENSE.md).
