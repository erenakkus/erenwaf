#!/bin/bash

LOGFILE="/var/log/firewall_script.log"
SCRIPT_NAME="erenwaf"

echo "====================================="
echo "       🔥 Server Firewall 🔥      "
echo "====================================="
echo "1) Firewall Setup and Configuration"
echo "2) IP Blocking and Management"
echo "3) SSH Protection with Fail2Ban"
echo "4) Live Network Traffic Monitoring"
echo "5) Automatic IP Blacklisting"
echo "6) Monitor SSH Login Attempts"
echo "7) Exit"
echo "====================================="
read -p "Select an option: " MAIN_CHOICE

if [[ "$MAIN_CHOICE" == "1" ]]; then
    echo "[INFO] Starting firewall configuration..." | tee -a $LOGFILE

    if [[ -f /etc/debian_version ]]; then
        OS="Debian"
        FIREWALL="ufw"
    elif [[ -f /etc/redhat-release ]]; then
        OS="RHEL"
        FIREWALL="firewalld"
    else
        echo "[ERROR] Unsupported operating system." | tee -a $LOGFILE
        exit 1
    fi

    echo "[INFO] Detected operating system: $OS" | tee -a $LOGFILE

    if [[ "$FIREWALL" == "ufw" ]]; then
        apt update && apt install -y ufw
        ufw --force reset
        ufw default deny incoming
        ufw default allow outgoing
        systemctl enable ufw
        systemctl start ufw
    elif [[ "$FIREWALL" == "firewalld" ]]; then
        yum install -y firewalld
        systemctl enable firewalld
        systemctl start firewalld
        firewall-cmd --set-default-zone=drop
    fi

    echo "[INFO] Firewall configured." | tee -a $LOGFILE

    read -p "Enter ports to open (comma-separated): " PORTS
    IFS=',' read -ra PORT_ARRAY <<< "$PORTS"

    for PORT in "${PORT_ARRAY[@]}"; do
        if [[ "$FIREWALL" == "ufw" ]]; then
            ufw allow $PORT/tcp
        else
            firewall-cmd --permanent --add-port=$PORT/tcp
        fi
        echo "[INFO] Port opened: $PORT" | tee -a $LOGFILE
    done

    if [[ "$FIREWALL" == "ufw" ]]; then
        ufw --force enable
    else
        firewall-cmd --reload
    fi

    echo "[INFO] Open ports configured." | tee -a $LOGFILE
    echo "[INFO] Firewall setup completed." | tee -a $LOGFILE
fi

if [[ "$MAIN_CHOICE" == "5" ]]; then
    echo "[INFO] Enabling automatic IP blacklisting..."
    if ! crontab -l | grep -q "iptables -A INPUT -m recent --update --seconds 60 --hitcount 10 -j DROP"; then
        echo "*/5 * * * * root iptables -A INPUT -m recent --update --seconds 60 --hitcount 10 -j DROP" >> /etc/crontab
        echo "[INFO] IP blacklisting is now active!" | tee -a $LOGFILE
    else
        echo "[INFO] IP blacklisting is already enabled." | tee -a $LOGFILE
    fi
fi

if [[ "$MAIN_CHOICE" == "6" ]]; then
    echo "Monitoring SSH login attempts (Press Ctrl+C to exit)..."
    tail -f /var/log/auth.log | grep "Failed password"
fi

if [[ "$MAIN_CHOICE" == "7" ]]; then
    echo "Exiting..."
    exit 0
fi

# Copy script to /usr/local/bin for easy execution
if [[ ! -f "/usr/local/bin/$SCRIPT_NAME" ]]; then
    cp "$0" "/usr/local/bin/$SCRIPT_NAME"
    chmod +x "/usr/local/bin/$SCRIPT_NAME"
    echo "[INFO] Script can now be run using 'erenwaf' command." | tee -a $LOGFILE
fi
