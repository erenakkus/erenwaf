# ErenWAF - Easy Firewall Management Script 🔥

ErenWAF is a user-friendly command-line tool for managing server security on Linux systems. It simplifies firewall configuration, SSH protection, and provides other security utilities, supporting both Debian-based (using UFW) and RHEL-based (using Firewalld) distributions. The script features an interactive TUI if `dialog` or `whiptail` are installed, with a fallback to a standard text-based interface, and supports both English and Turkish languages.

## 🚀 Features

*   **Firewall Configuration:**
    *   Automatically detects OS (Debian/RHEL) and configures the appropriate firewall (UFW or Firewalld).
    *   Allows users to easily define which ports to open.
    *   Sets default policies to deny incoming and allow outgoing traffic.
*   **SSH Protection with Fail2Ban:**
    *   Checks for Fail2Ban installation and prompts to install it if missing.
    *   Configures a basic SSH jail (`/etc/fail2ban/jail.d/erenwaf-sshd.conf`) with settings like `bantime`, `findtime`, and `maxretry`.
    *   Manages the Fail2Ban service (enable, restart).
    *   Displays the status of the Fail2Ban `sshd` jail.
*   **Automatic IP Blacklisting (Legacy):**
    *   Sets up a cron job to automatically blacklist IPs that make multiple rapid connection attempts (using `iptables -m recent`).
*   **Live Monitoring:**
    *   Monitor SSH login attempts in real-time by watching `auth.log`.
    *   (Placeholder for live network traffic monitoring).
*   **User Interface:**
    *   Interactive TUI (Terminal User Interface) using `dialog` or `whiptail` if available, for a better user experience.
    *   Graceful fallback to a colored text-based interface if TUI tools are not installed.
    *   Prompts users to install `dialog` for an enhanced experience if not found.
*   **Localization:**
    *   Supports English and Turkish languages.
    *   Auto-detects system language or prompts user for selection.
*   **Self-Installation:**
    *   Attempts to copy itself to `/usr/local/bin/erenwaf` for easy command-line access via the `erenwaf` command.
    *   Handles updates by attempting to re-install if a different version is run.
*   **System Logging:**
    *   All significant actions and errors are logged to the system logger (e.g., syslog/journald) with the tag `erenwaf`.

## 📋 Requirements & Dependencies

*   **Operating System:**
    *   Debian-based Linux (e.g., Ubuntu)
    *   RHEL-based Linux (e.g., CentOS, Fedora, Rocky Linux)
*   **Shell:** `bash`
*   **Core Utilities:** Standard Linux utilities like `iptables`, `grep`, `systemctl`, `ufw` (on Debian), `firewalld` (on RHEL), `cron`, `sed`, `readlink`, `cmp`.
*   **Fail2Ban:** Required for the "SSH Protection with Fail2Ban" feature. The script can attempt to install it if missing.
*   **`dialog` or `whiptail`:** Recommended for the best UI experience. If not installed, the script will use a text-based interface and suggest installing `dialog`.

## 🛠️ Installation and Usage

### Automatic Installation (Recommended)
The script is designed to be self-installing:
1.  Download the `erenwaf.sh` script:
    ```bash
    wget https://raw.githubusercontent.com/erenakkus/erenwaf/main/erenwaf.sh -O erenwaf.sh
    ```
    (Note: Ensure you use the raw link to the script file.)
2.  Make it executable:
    ```bash
    chmod +x erenwaf.sh
    ```
3.  Run it (preferably with `sudo` if you intend to perform actions that require root privileges immediately):
    ```bash
    ./erenwaf.sh 
    # or
    sudo ./erenwaf.sh
    ```
On its first run (if not already installed or if it's a different version), the script will attempt to copy itself to `/usr/local/bin/erenwaf`. If successful, you can then run it from anywhere using the `erenwaf` command:
    ```bash
    sudo erenwaf
    ```

### Manual Installation
1.  Download `erenwaf.sh` as above.
2.  Make it executable: `chmod +x erenwaf.sh`.
3.  Move it to a directory in your `$PATH`, for example:
    ```bash
    sudo mv erenwaf.sh /usr/local/bin/erenwaf
    ```

### Running the Script
Execute the script from your terminal:
```bash
erenwaf
```
Or, if you haven't installed it to your path, run it from its directory:
```bash
./erenwaf.sh
```
Since many operations (like firewall configuration, Fail2Ban setup, service management) require root privileges, it's often best to run the script with `sudo`:
```bash
sudo erenwaf
# or
sudo ./erenwaf.sh
```
The script's internal `run_sudo_cmd` helper will also attempt to use `sudo` for specific commands if the script itself is not run as root, but this might require passwordless `sudo` for those commands or it will prompt for a password if `sudo` allows it.

### Language Selection
The script will attempt to detect your system's language. If it cannot, or if you are using the TUI (`dialog`/`whiptail`), you will be prompted to choose between English and Turkish.

## ⚙️ Configuration

*   **Firewall Ports:** Configured interactively when you select the "Firewall Setup and Configuration" option.
*   **Fail2Ban SSH Jail:** When the "SSH Protection with Fail2Ban" feature is used, the script creates or updates a configuration file at `/etc/fail2ban/jail.d/erenwaf-sshd.conf` with predefined settings for `bantime`, `findtime`, and `maxretry`.
*   **Logging:** ErenWAF logs its actions to the system logger (syslog/journald) using the tag `erenwaf`. You can view these logs using commands like:
    ```bash
    journalctl -t erenwaf
    # or for older systems:
    # grep 'erenwaf' /var/log/syslog
    ```

## 🤝 Contributing

Contributions, issues, and feature requests are welcome! Please feel free to open an issue or submit a pull request.

## 📜 License

This project is licensed under the **GNU General Public License v3.0**. See the [LICENSE](LICENSE) file for full details.
(The previous README mentioned MIT, but the LICENSE file in the repository is GPLv3.)

---

🚀 **Use ErenWAF to enhance your server's security with ease!** 🔥
