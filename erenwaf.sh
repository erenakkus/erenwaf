#!/bin/bash

LOGFILE="/var/log/firewall_script.log"
SCRIPT_NAME="erenwaf"

echo "====================================="
echo "       🔥 ErenWAF Kolay Firewall 🔥      "
echo "====================================="
echo "1) Firewall Yapılandırma ve Kurulum"
echo "2) IP Engelleme ve Yönetim"
echo "3) Fail2Ban ile SSH Koruması"
echo "4) Canlı Ağ Trafiği İzleme"
echo "5) Otomatik IP Kara Listeleme"
echo "6) SSH Bağlantı Denemelerini İzleme"
echo "7) Çıkış"
echo "====================================="
read -p "Seçiminizi yapın: " MAIN_CHOICE

if [[ "$MAIN_CHOICE" == "1" ]]; then
    echo "[INFO] Firewall yapılandırması başlatılıyor..." | tee -a $LOGFILE

    if [[ -f /etc/debian_version ]]; then
        OS="Debian"
        FIREWALL="ufw"
    elif [[ -f /etc/redhat-release ]]; then
        OS="RHEL"
        FIREWALL="firewalld"
    else
        echo "[ERROR] Desteklenmeyen işletim sistemi." | tee -a $LOGFILE
        exit 1
    fi

    echo "[INFO] Tespit edilen işletim sistemi: $OS" | tee -a $LOGFILE

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

    echo "[INFO] Firewall yapılandırıldı." | tee -a $LOGFILE

    read -p "Açılacak portları (virgülle ayırarak) girin: " PORTS
    IFS=',' read -ra PORT_ARRAY <<< "$PORTS"

    for PORT in "${PORT_ARRAY[@]}"; do
        if [[ "$FIREWALL" == "ufw" ]]; then
            ufw allow $PORT/tcp
        else
            firewall-cmd --permanent --add-port=$PORT/tcp
        fi
        echo "[INFO] Port açıldı: $PORT" | tee -a $LOGFILE
    done

    if [[ "$FIREWALL" == "ufw" ]]; then
        ufw --force enable
    else
        firewall-cmd --reload
    fi

    echo "[INFO] Açık portlar tanımlandı." | tee -a $LOGFILE
    echo "[INFO] Firewall yapılandırması tamamlandı." | tee -a $LOGFILE
fi

if [[ "$MAIN_CHOICE" == "5" ]]; then
    echo "[INFO] Otomatik IP kara listeleme başlatılıyor..."
    if ! crontab -l | grep -q "iptables -A INPUT -m recent --update --seconds 60 --hitcount 10 -j DROP"; then
        echo "*/5 * * * * root iptables -A INPUT -m recent --update --seconds 60 --hitcount 10 -j DROP" >> /etc/crontab
        echo "[INFO] IP kara listeleme aktif edildi!" | tee -a $LOGFILE
    else
        echo "[INFO] IP kara listeleme zaten aktif." | tee -a $LOGFILE
    fi
fi

if [[ "$MAIN_CHOICE" == "6" ]]; then
    echo "SSH bağlantı denemeleri izleniyor (Ctrl+C ile çıkabilirsiniz)..."
    tail -f /var/log/auth.log | grep "Failed password"
fi

if [[ "$MAIN_CHOICE" == "7" ]]; then
    echo "Çıkış yapılıyor..."
    exit 0
fi

# Script'i /usr/local/bin içine kopyalayarak erenwaf olarak çalıştırılmasını sağla
if [[ ! -f "/usr/local/bin/$SCRIPT_NAME" ]]; then
    cp "$0" "/usr/local/bin/$SCRIPT_NAME"
    chmod +x "/usr/local/bin/$SCRIPT_NAME"
    echo "[INFO] Script artık 'erenwaf' komutu ile çalıştırılabilir." | tee -a $LOGFILE
fi
