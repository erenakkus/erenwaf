#!/bin/bash

SCRIPT_NAME="erenwaf"
UI_TOOL="text" # Default to text-based UI

# --- UI Tool Detection ---
if command -v dialog >/dev/null 2>&1; then
    UI_TOOL="dialog"
elif command -v whiptail >/dev/null 2>&1; then
    UI_TOOL="whiptail"
fi

# --- ANSI Color Codes (for text fallback) ---
C_RESET='\e[0m'
C_BOLD='\e[1m'
C_RED='\e[31m'
C_GREEN='\e[32m'
C_YELLOW='\e[33m'
C_BLUE='\e[34m'
C_CYAN='\e[36m'

# --- Logging Function ---
log_message() {
    local message_with_colors="$1"
    local level_override="${2:-}" 
    local message_for_log
    message_for_log=$(echo "$message_with_colors" | sed 's/\x1b\[[0-9;]*m//g')
    local level="user.notice"
    if [[ -n "$level_override" ]]; then level="$level_override"; else
        if [[ "$message_for_log" == \[ERROR\]* ]]; then level="user.error";
        elif [[ "$message_for_log" == \[WARN* ]]; then level="user.warning";
        elif [[ "$message_for_log" == \[INFO\]* ]]; then level="user.info"; fi
    fi
    echo -e "$message_with_colors"; logger -t "$SCRIPT_NAME" -p "$level" "$message_for_log";
}

# --- Sudo Command Runner ---
run_sudo_cmd() {
    local cmd_to_run="$1"
    local exit_code
    if [[ $EUID -eq 0 ]]; then eval "$cmd_to_run"; exit_code=$?;
    elif command -v sudo >/dev/null 2>&1; then
        sudo -n true 2>/dev/null 
        if [[ $? -eq 0 ]]; then eval "sudo $cmd_to_run"; exit_code=$?;
        else 
            log_message "[WARN] Sudo requires a password for command: $cmd_to_run." "user.warning"
            if [[ "$UI_TOOL" != "text" ]]; then $UI_TOOL --msgbox "$([[ "$LANGUAGE" == "TR" ]] && echo "$MSG_F2B_SUDO_PASSWORD_REQUIRED_DETAIL" || echo "$MSG_F2B_SUDO_PASSWORD_REQUIRED_DETAIL_EN")" 10 70 >/dev/tty
            else echo -e "${C_YELLOW}$([[ "$LANGUAGE" == "TR" ]] && echo "$MSG_F2B_SUDO_PASSWORD_REQUIRED_DETAIL" || echo "$MSG_F2B_SUDO_PASSWORD_REQUIRED_DETAIL_EN")${C_RESET}"; fi
            return 126;
        fi
    else
        log_message "[ERROR] sudo command not found. This operation requires root privileges: $cmd_to_run" "user.error"
        if [[ "$UI_TOOL" != "text" ]]; then $UI_TOOL --msgbox "$([[ "$LANGUAGE" == "TR" ]] && echo "$MSG_F2B_SUDO_NOT_FOUND_DETAIL" || echo "$MSG_F2B_SUDO_NOT_FOUND_DETAIL_EN")" 10 70 >/dev/tty
        else echo -e "${C_RED}$([[ "$LANGUAGE" == "TR" ]] && echo "$MSG_F2B_SUDO_NOT_FOUND_DETAIL" || echo "$MSG_F2B_SUDO_NOT_FOUND_DETAIL_EN")${C_RESET}"; fi
        return 127;
    fi
    return $exit_code
}

# --- Language Detection & Strings ---
if [[ "${LANG}" == "tr_TR"* ]]; then DEFAULT_LANG="TR"; else DEFAULT_LANG="EN"; fi
LANGUAGE="$DEFAULT_LANG"; LANG_EXIT_STATUS=0
if [[ "$UI_TOOL" != "text" ]]; then
    TEMP_LANG_CHOICE=$($UI_TOOL --clear --title "$([[ "${DEFAULT_LANG}" == "TR" ]] && echo "Dil Seçimi" || echo "Language Selection")" \
        --menu "$([[ "${DEFAULT_LANG}" == "TR" ]] && echo "Lütfen dil seçiminizi yapınız:" || echo "Please select your language:")" \
        15 50 2 "1" "Türkçe" "2" "English" 2>&1 >/dev/tty)
    LANG_EXIT_STATUS=$?; if [[ $LANG_EXIT_STATUS -eq 0 ]]; then if [[ "$TEMP_LANG_CHOICE" == "1" ]]; then LANGUAGE="TR"; elif [[ "$TEMP_LANG_CHOICE" == "2" ]]; then LANGUAGE="EN"; else LANGUAGE="$DEFAULT_LANG"; fi; else LANGUAGE="$DEFAULT_LANG"; fi
else
    echo -e "${C_BOLD}Lütfen dil seçiminizi yapınız / Please select your language:${C_RESET}"; echo -e "1) ${C_GREEN}Türkçe${C_RESET}"; echo -e "2) ${C_GREEN}English${C_RESET}"; read -p "(1/2): " LANG_CHOICE_TEXT
    if [[ "$LANG_CHOICE_TEXT" == "1" ]]; then LANGUAGE="TR"; elif [[ "$LANG_CHOICE_TEXT" == "2" ]]; then LANGUAGE="EN"; else LANGUAGE="$DEFAULT_LANG"; echo -e "${C_YELLOW}$([[ "${DEFAULT_LANG}" == "TR" ]] && echo "Geçersiz seçim, varsayılan dil kullanılıyor:" || echo "Invalid choice, using default language:") $LANGUAGE${C_RESET}"; fi
fi

# --- Localized Strings ---
if [[ "$LANGUAGE" == "TR" ]]; then
    DIALOG_OK_LABEL="Tamam"; DIALOG_CANCEL_LABEL="İptal"; MSG_YES_LABEL="Evet"; MSG_NO_LABEL="Hayır"
    MSG_INSTALL_UI_TOOL_PROMPT="Daha iyi bir kullanıcı arayüzü için 'dialog' veya 'whiptail' kurmanız önerilir (örn: sudo apt install dialog)."
    MENU_TITLE_UI="🔥 ErenWAF Kolay Firewall 🔥"; MENU_PROMPT_UI="Lütfen bir işlem seçin:"
    MENU_TITLE="🔥 ${C_BOLD}${C_BLUE}ErenWAF Kolay Firewall${C_RESET} 🔥"
    MENU_OPTION_1_TEXT="1) Firewall Yapılandırma"; MENU_OPTION_1_DLG="Firewall Yapılandırma"
    MENU_OPTION_2_TEXT="2) IP Engelleme"; MENU_OPTION_2_DLG="IP Engelleme"
    MENU_OPTION_3_TEXT="3) Fail2Ban ile SSH Koruma"; MENU_OPTION_3_DLG="Fail2Ban ile SSH Koruma"
    MENU_OPTION_4_TEXT="4) Ağ Trafiği İzleme"; MENU_OPTION_4_DLG="Ağ Trafiği İzleme"
    MENU_OPTION_5_TEXT="5) Otomatik IP Kara Liste"; MENU_OPTION_5_DLG="Otomatik IP Kara Liste"
    MENU_OPTION_6_TEXT="6) SSH Denemelerini İzle"; MENU_OPTION_6_DLG="SSH Denemelerini İzle"
    MENU_OPTION_7_TEXT="7) Çıkış"; MENU_OPTION_7_DLG="Çıkış"
    MENU_PROMPT_TEXT="${C_BOLD}Seçiminizi yapın:${C_RESET} "
    MSG_EXITING="Çıkış yapılıyor...";
    MSG_SCRIPT_COPIED_BASE="Script '$SCRIPT_NAME' komutu ile çalıştırılabilir." # Base for log and user message
    MSG_INVALID_OS="[ERROR] Desteklenmeyen işletim sistemi."; MSG_FEATURE_NOT_IMPLEMENTED="[INFO] Bu özellik henüz uygulanmadı."
    MSG_INVALID_OPTION="[WARN] Geçersiz seçenek."; MSG_USER_CANCELLED="[INFO] İşlem kullanıcı tarafından iptal edildi."
    PORT_INPUT_TITLE_UI="Port Girişi"; MSG_FIREWALL_CONFIG_STARTING="[INFO] Firewall yapılandırması başlatılıyor..."
    MSG_OS_DETECTED="[INFO] Tespit edilen işletim sistemi:"; MSG_FIREWALL_CONFIGURED="[INFO] Firewall yapılandırıldı."
    MSG_ENTER_PORTS_UI="Açılacak portları girin (örn: 80,443,22). Boş bırakırsanız port açılmaz."
    MSG_ENTER_PORTS_TEXT="${C_CYAN}Açılacak portları girin (örn: 80,443,22). Boş bırakırsanız port açılmaz:${C_RESET} "
    MSG_PORT_OPENED="[INFO] Port açıldı:"; MSG_PORTS_INVALID_FORMAT="[WARN] Geçersiz port formatı:"
    MSG_PORTS_VALIDATION_ERROR_FORMAT="[WARN] Hatalı port formatı. Lütfen portları virgülle ayırarak girin (örn: 80,443) ve boşluk kullanmayın."
    MSG_PORTS_VALIDATION_ERROR_NUMBER="[WARN] Hatalı port numarası. Portlar 1-65535 arasında olmalıdır."
    MSG_NO_PORTS_ENTERED="[INFO] Port girilmedi. Port yapılandırması atlanıyor."
    MSG_OPEN_PORTS_CONFIGURED="[INFO] Açık portlar tanımlandı."; MSG_FIREWALL_CONFIG_COMPLETED="[INFO] Firewall yapılandırması tamamlandı."
    MSG_AUTO_BLACKLIST_STARTING="[INFO] Otomatik IP kara listeleme başlatılıyor..."; MSG_AUTO_BLACKLIST_ALREADY_ACTIVE="[INFO] IP kara listeleme zaten aktif."
    MSG_AUTO_BLACKLIST_ACTIVATED="[INFO] IP kara listeleme aktif edildi!"; MSG_AUTO_BLACKLIST_ROOT_REQUIRED="[ERROR] Crontab düzenlemek için root yetkileri gereklidir."
    MSG_SSH_MONITORING_START="[INFO] SSH bağlantı denemeleri izleniyor..."; MSG_SSH_MONITORING_TITLE_UI="SSH İzleme"
    MSG_PRESS_ENTER_TO_CONTINUE="\n${C_BOLD}Devam etmek için Enter'a basın...${C_RESET}"
    MSG_F2B_TITLE="Fail2Ban SSH Koruma"; MSG_F2B_ROOT_REQUIRED="[WARN] Bu işlem için root/sudo yetkileri gerekebilir."
    MSG_F2B_NOT_INSTALLED="[INFO] Fail2Ban kurulu değil."; MSG_F2B_INSTALL_PROMPT="Fail2Ban kurulsun mu? (Debian: fail2ban, RHEL: fail2ban)";
    MSG_F2B_INSTALLING="[INFO] Fail2Ban kuruluyor..."; MSG_F2B_INSTALL_SUCCESS="[INFO] Fail2Ban başarıyla kuruldu."; MSG_F2B_INSTALL_FAILED="[ERROR] Fail2Ban kurulumu başarısız oldu."
    MSG_F2B_REQ_FOR_FEATURE="[WARN] Bu özellik için Fail2Ban gereklidir."; MSG_F2B_INSTALLED_INFO="[INFO] Fail2Ban kurulu."
    MSG_F2B_JAIL_CONFIG_PROMPT="ErenWAF standart SSH jail ayarları (/etc/fail2ban/jail.d/erenwaf-sshd.conf içinde) yapılandırılsın mı/üzerine yazılsın mı? (bantime=1h, findtime=10m, maxretry=5)";
    MSG_F2B_JAIL_CONFIGURING="[INFO] Fail2Ban SSH jail yapılandırılıyor..."; MSG_F2B_JAIL_CONFIG_SUCCESS="[INFO] Fail2Ban SSH jail başarıyla yapılandırıldı."; MSG_F2B_JAIL_CONFIG_FAILED="[ERROR] Fail2Ban SSH jail yapılandırması başarısız oldu."
    MSG_F2B_JAIL_USER_SKIPPED="[INFO] Kullanıcı özel jail yapılandırmasını atladı."; MSG_F2B_SERVICE_ENABLING="[INFO] Fail2Ban servisi etkinleştiriliyor..."; MSG_F2B_SERVICE_RESTARTING="[INFO] Fail2Ban servisi yeniden başlatılıyor..."
    MSG_F2B_SERVICE_MANAGE_SUCCESS="[INFO] Fail2Ban servisi başarıyla yönetildi."; MSG_F2B_SERVICE_MANAGE_FAILED="[ERROR] Fail2Ban servisi yönetilemedi."
    MSG_F2B_STATUS_CHECKING="[INFO] Fail2Ban sshd jail durumu kontrol ediliyor..."; MSG_F2B_STATUS_TITLE="Fail2Ban SSHD Durumu"
    MSG_F2B_SUDO_PASSWORD_REQUIRED_DETAIL="Bu işlem için sudo şifre gerektiriyor. Lütfen script'i sudo ile çalıştırın veya bu işlemler için şifresiz sudo ayarlayın.";
    MSG_F2B_SUDO_NOT_FOUND_DETAIL="sudo komutu bulunamadı. Bu işlem root yetkisi gerektirir.";
    # Self-installation messages TR
    MSG_ATTEMPTING_INSTALLATION="[INFO] Script /usr/local/bin dizinine kurulmaya çalışılıyor...";
    MSG_INSTALLATION_SUCCESSFUL="[INFO] Script başarıyla /usr/local/bin/$SCRIPT_NAME adresine kuruldu.";
    MSG_CAN_RUN_AS_ERENWAF="Artık script'i '$SCRIPT_NAME' komutuyla çalıştırabilirsiniz.";
    MSG_INSTALLATION_FAILED="[ERROR] Script kurulumu başarısız oldu.";
    MSG_INSTALLATION_FAILED_SUDO="Kurulum başarısız. Lütfen script'i sudo ile çalıştırın veya /usr/local/bin dizinine yazma izniniz olduğundan emin olun.";

else # English
    DIALOG_OK_LABEL="OK"; DIALOG_CANCEL_LABEL="Cancel"; MSG_YES_LABEL="Yes"; MSG_NO_LABEL="No"
    MSG_INSTALL_UI_TOOL_PROMPT="For a better user experience, it is recommended to install 'dialog' or 'whiptail' (e.g., sudo apt install dialog)."
    MENU_TITLE_UI="🔥 Server Firewall 🔥"; MENU_PROMPT_UI="Please select an action:"
    MENU_TITLE="🔥 ${C_BOLD}${C_BLUE}Server Firewall${C_RESET} 🔥"
    MENU_OPTION_1_TEXT="1) Firewall Setup"; MENU_OPTION_1_DLG="Firewall Setup"
    MENU_OPTION_2_TEXT="2) IP Blocking"; MENU_OPTION_2_DLG="IP Blocking"
    MENU_OPTION_3_TEXT="3) SSH Protection (Fail2Ban)"; MENU_OPTION_3_DLG="SSH Protection (Fail2Ban)"
    MENU_OPTION_4_TEXT="4) Network Traffic Monitor"; MENU_OPTION_4_DLG="Network Traffic Monitor"
    MENU_OPTION_5_TEXT="5) Auto IP Blacklist"; MENU_OPTION_5_DLG="Auto IP Blacklist"
    MENU_OPTION_6_TEXT="6) Monitor SSH Attempts"; MENU_OPTION_6_DLG="Monitor SSH Attempts"
    MENU_OPTION_7_TEXT="7) Exit"; MENU_OPTION_7_DLG="Exit"
    MENU_PROMPT_TEXT="${C_BOLD}Select an option:${C_RESET} "
    MSG_EXITING="Exiting...";
    MSG_SCRIPT_COPIED_BASE="Script can now be run using '$SCRIPT_NAME' command." # Base for log and user message
    MSG_INVALID_OS="[ERROR] Unsupported operating system."; MSG_FEATURE_NOT_IMPLEMENTED="[INFO] This feature is not yet implemented."
    MSG_INVALID_OPTION="[WARN] Invalid option."; MSG_USER_CANCELLED="[INFO] Operation cancelled by user."
    PORT_INPUT_TITLE_UI="Port Input"; MSG_FIREWALL_CONFIG_STARTING="[INFO] Starting firewall configuration..."
    MSG_OS_DETECTED="[INFO] Detected operating system:"; MSG_FIREWALL_CONFIGURED="[INFO] Firewall configured."
    MSG_ENTER_PORTS_UI="Enter ports to open (e.g., 80,443,22). Leave empty to open no ports."
    MSG_ENTER_PORTS_TEXT="${C_CYAN}Enter ports to open (e.g., 80,443,22). Leave empty to open no ports:${C_RESET} "
    MSG_PORT_OPENED="[INFO] Port opened:"; MSG_PORTS_INVALID_FORMAT="[WARN] Invalid port format:"
    MSG_PORTS_VALIDATION_ERROR_FORMAT="[WARN] Invalid port format. Please enter ports as comma-separated numbers (e.g., 80,443) without spaces."
    MSG_PORTS_VALIDATION_ERROR_NUMBER="[WARN] Invalid port number. Ports must be between 1 and 65535."
    MSG_NO_PORTS_ENTERED="[INFO] No ports entered. Skipping port configuration."
    MSG_OPEN_PORTS_CONFIGURED="[INFO] Open ports configured."; MSG_FIREWALL_CONFIG_COMPLETED="[INFO] Firewall setup completed."
    MSG_AUTO_BLACKLIST_STARTING="[INFO] Enabling automatic IP blacklisting..."; MSG_AUTO_BLACKLIST_ALREADY_ACTIVE="[INFO] IP blacklisting is already enabled."
    MSG_AUTO_BLACKLIST_ACTIVATED="[INFO] IP blacklisting is now active!"; MSG_AUTO_BLACKLIST_ROOT_REQUIRED="[ERROR] Root privileges required to modify crontab."
    MSG_SSH_MONITORING_START="[INFO] Monitoring SSH login attempts..."; MSG_SSH_MONITORING_TITLE_UI="SSH Monitoring"
    MSG_PRESS_ENTER_TO_CONTINUE="\n${C_BOLD}Press Enter to continue...${C_RESET}"
    MSG_F2B_TITLE="Fail2Ban SSH Protection"; MSG_F2B_ROOT_REQUIRED="[WARN] This operation may require root/sudo privileges."
    MSG_F2B_NOT_INSTALLED="[INFO] Fail2Ban is not installed."; MSG_F2B_INSTALL_PROMPT="Install Fail2Ban? (Debian: fail2ban, RHEL: fail2ban)";
    MSG_F2B_INSTALLING="[INFO] Installing Fail2Ban..."; MSG_F2B_INSTALL_SUCCESS="[INFO] Fail2Ban installed successfully."; MSG_F2B_INSTALL_FAILED="[ERROR] Fail2Ban installation failed."
    MSG_F2B_REQ_FOR_FEATURE="[WARN] Fail2Ban is required for this feature."; MSG_F2B_INSTALLED_INFO="[INFO] Fail2Ban is installed."
    MSG_F2B_JAIL_CONFIG_PROMPT="Configure/Overwrite ErenWAF's standard SSH jail settings in /etc/fail2ban/jail.d/erenwaf-sshd.conf? (bantime=1h, findtime=10m, maxretry=5)";
    MSG_F2B_JAIL_CONFIGURING="[INFO] Configuring Fail2Ban SSH jail..."; MSG_F2B_JAIL_CONFIG_SUCCESS="[INFO] Fail2Ban SSH jail configured successfully."; MSG_F2B_JAIL_CONFIG_FAILED="[ERROR] Fail2Ban SSH jail configuration failed."
    MSG_F2B_JAIL_USER_SKIPPED="[INFO] User skipped custom jail configuration."; MSG_F2B_SERVICE_ENABLING="[INFO] Enabling Fail2Ban service..."; MSG_F2B_SERVICE_RESTARTING="[INFO] Restarting Fail2Ban service..."
    MSG_F2B_SERVICE_MANAGE_SUCCESS="[INFO] Fail2Ban service managed successfully."; MSG_F2B_SERVICE_MANAGE_FAILED="[ERROR] Failed to manage Fail2Ban service."
    MSG_F2B_STATUS_CHECKING="[INFO] Checking Fail2Ban sshd jail status..."; MSG_F2B_STATUS_TITLE="Fail2Ban SSHD Status"
    MSG_F2B_SUDO_PASSWORD_REQUIRED_DETAIL="Sudo requires a password for this operation. Please run the script with sudo or set up passwordless sudo for these actions.";
    MSG_F2B_SUDO_NOT_FOUND_DETAIL="sudo command not found. This operation requires root privileges.";
    # Self-installation messages EN
    MSG_ATTEMPTING_INSTALLATION="[INFO] Attempting to install the script to /usr/local/bin...";
    MSG_INSTALLATION_SUCCESSFUL="[INFO] Script successfully installed to /usr/local/bin/$SCRIPT_NAME.";
    MSG_CAN_RUN_AS_ERENWAF="You can now run the script using the '$SCRIPT_NAME' command.";
    MSG_INSTALLATION_FAILED="[ERROR] Script installation failed.";
    MSG_INSTALLATION_FAILED_SUDO="Installation failed. Please run the script with sudo or ensure you have permissions to write to /usr/local/bin.";
fi

# --- Self-Installation Logic ---
CURRENT_SCRIPT_PATH=$(readlink -f "$0")
TARGET_SCRIPT_PATH="/usr/local/bin/$SCRIPT_NAME"

# Check if not running from target and target either doesn't exist or is different
if [[ "$CURRENT_SCRIPT_PATH" != "$TARGET_SCRIPT_PATH" ]]; then
    NEEDS_INSTALL_OR_UPDATE=false
    if [[ ! -L "$TARGET_SCRIPT_PATH" && ! -f "$TARGET_SCRIPT_PATH" ]]; then # Target does not exist (not a file or symlink)
        NEEDS_INSTALL_OR_UPDATE=true
        log_message "[INFO] $SCRIPT_NAME is not installed at $TARGET_SCRIPT_PATH. Will attempt installation."
    elif ! cmp -s "$CURRENT_SCRIPT_PATH" "$TARGET_SCRIPT_PATH"; then # Target exists but is different
        NEEDS_INSTALL_OR_UPDATE=true
        # Could add a TUI prompt here to ask the user if they want to update.
        # For now, automatically attempt update to keep it simpler.
        log_message "[INFO] A different version of $SCRIPT_NAME found at $TARGET_SCRIPT_PATH. Will attempt update."
    fi

    if $NEEDS_INSTALL_OR_UPDATE; then
        log_message "$MSG_ATTEMPTING_INSTALLATION"
        # Use run_sudo_cmd for cp and chmod
        # Ensure paths are quoted if they can contain spaces (though SCRIPT_NAME usually doesn't)
        if run_sudo_cmd "cp \"$CURRENT_SCRIPT_PATH\" \"$TARGET_SCRIPT_PATH\"" && \
           run_sudo_cmd "chmod +x \"$TARGET_SCRIPT_PATH\""; then
            log_message "$MSG_INSTALLATION_SUCCESSFUL"
            # This user message should use the base string, not the [INFO] prefixed one
            local user_msg_success="$([[ "$LANGUAGE" == "TR" ]] && echo "$MSG_CAN_RUN_AS_ERENWAF" || echo "$MSG_CAN_RUN_AS_ERENWAF")"
            if [[ "$UI_TOOL" != "text" ]]; then
                $UI_TOOL --msgbox "$user_msg_success" 8 70 >/dev/tty
            else
                echo -e "${C_GREEN}$user_msg_success${C_RESET}"
            fi
        else
            log_message "$MSG_INSTALLATION_FAILED" "user.error"
            local user_msg_fail_detail="$([[ "$LANGUAGE" == "TR" ]] && echo "$MSG_INSTALLATION_FAILED_SUDO" || echo "$MSG_INSTALLATION_FAILED_SUDO")"
            if [[ "$UI_TOOL" != "text" ]]; then
                $UI_TOOL --msgbox "$user_msg_fail_detail" 10 70 >/dev/tty
            else
                echo -e "${C_RED}$user_msg_fail_detail${C_RESET}"
            fi
        fi
    fi
fi


# --- Function Definitions ---
# (configure_firewall, manage_ip_blocking, protect_ssh_fail2ban, etc. as before)
configure_firewall() {
    log_message "$MSG_FIREWALL_CONFIG_STARTING"
    local OS FIREWALL
    if [[ -f /etc/debian_version ]]; then OS="Debian"; FIREWALL="ufw";
    elif [[ -f /etc/redhat-release ]]; then OS="RHEL"; FIREWALL="firewalld";
    else log_message "${C_RED}$MSG_INVALID_OS${C_RESET}"; [[ "$UI_TOOL" != "text" ]] && $UI_TOOL --msgbox "$MSG_INVALID_OS" 8 50 >/dev/tty; return 1; fi
    log_message "$MSG_OS_DETECTED $OS"

    if [[ "$UI_TOOL" != "text" ]]; then $UI_TOOL --infobox "Installing $FIREWALL..." 5 40 >/dev/tty; fi
    if [[ "$FIREWALL" == "ufw" ]]; then run_sudo_cmd "apt-get update && apt-get install -y ufw"; run_sudo_cmd "ufw --force reset"; run_sudo_cmd "ufw default deny incoming"; run_sudo_cmd "ufw default allow outgoing"; run_sudo_cmd "systemctl enable ufw"; run_sudo_cmd "systemctl start ufw";
    elif [[ "$FIREWALL" == "firewalld" ]]; then run_sudo_cmd "yum install -y firewalld"; run_sudo_cmd "systemctl enable firewalld"; run_sudo_cmd "systemctl start firewalld"; run_sudo_cmd "firewall-cmd --set-default-zone=drop"; fi
    log_message "$MSG_FIREWALL_CONFIGURED"

    local PORTS_STRING=""
    local PORT_ARRAY=()
    local VALID_INPUT_FLAG=false 

    while ! $VALID_INPUT_FLAG; do
        if [[ "$UI_TOOL" != "text" ]]; then
            PORTS_STRING=$($UI_TOOL --title "$PORT_INPUT_TITLE_UI" --inputbox "$MSG_ENTER_PORTS_UI" 10 70 "" 2>&1 >/dev/tty)
            if [[ $? -ne 0 ]]; then log_message "$MSG_USER_CANCELLED"; $UI_TOOL --msgbox "$MSG_USER_CANCELLED" 8 50 >/dev/tty; return 1; fi
        else
            read -p "$(echo -e "$MSG_ENTER_PORTS_TEXT")" PORTS_STRING
        fi
        PORTS_STRING=$(echo "$PORTS_STRING" | sed 's/^[ \t]*//;s/[ \t]*$//')
        if [[ -z "$PORTS_STRING" ]]; then log_message "$MSG_NO_PORTS_ENTERED"; PORT_ARRAY=(); VALID_INPUT_FLAG=true; break; fi
        local CLEANED_PORTS_FOR_VALIDATION=$(echo "$PORTS_STRING" | tr -d '[:space:]')
        local CURRENT_ERROR_MSG=""
        if ! [[ "$CLEANED_PORTS_FOR_VALIDATION" =~ ^[0-9]{1,5}(,[0-9]{1,5})*$ ]]; then CURRENT_ERROR_MSG="$MSG_PORTS_VALIDATION_ERROR_FORMAT";
        else
            local SAVE_IFS="$IFS"; IFS=','; local TEMP_CHECK_ARRAY=($CLEANED_PORTS_FOR_VALIDATION); IFS="$SAVE_IFS"; PORT_ARRAY=() 
            for port_val in "${TEMP_CHECK_ARRAY[@]}"; do
                if ! [[ "$port_val" =~ ^[0-9]+$ ]] || [ "$port_val" -lt 1 ] || [ "$port_val" -gt 65535 ]; then CURRENT_ERROR_MSG="$MSG_PORTS_VALIDATION_ERROR_NUMBER (Port: $port_val)"; PORT_ARRAY=(); break; fi
                PORT_ARRAY+=("$port_val")
            done
        fi
        if [[ -n "$CURRENT_ERROR_MSG" ]]; then log_message "$CURRENT_ERROR_MSG --- Input: '$PORTS_STRING'"; if [[ "$UI_TOOL" != "text" ]]; then $UI_TOOL --msgbox "$CURRENT_ERROR_MSG" 10 70 >/dev/tty; else echo -e "${C_RED}$CURRENT_ERROR_MSG${C_RESET}"; fi; VALID_INPUT_FLAG=false;
        else VALID_INPUT_FLAG=true; fi
    done
    if [[ ${#PORT_ARRAY[@]} -gt 0 ]]; then
        for PORT_ITEM_FULL in "${PORT_ARRAY[@]}"; do local port_to_add="$PORT_ITEM_FULL"; if [[ "$FIREWALL" == "ufw" ]]; then run_sudo_cmd "ufw allow $port_to_add/tcp"; run_sudo_cmd "ufw allow $port_to_add/udp"; else run_sudo_cmd "firewall-cmd --permanent --add-port=$port_to_add/tcp"; run_sudo_cmd "firewall-cmd --permanent --add-port=$port_to_add/udp"; fi; log_message "$MSG_PORT_OPENED $port_to_add (TCP/UDP)"; done
        if [[ "$FIREWALL" == "firewalld" ]]; then run_sudo_cmd "firewall-cmd --reload"; fi; log_message "$MSG_OPEN_PORTS_CONFIGURED";
    fi
    log_message "$MSG_FIREWALL_CONFIG_COMPLETED"; [[ "$UI_TOOL" != "text" ]] && $UI_TOOL --msgbox "$MSG_FIREWALL_CONFIG_COMPLETED" 8 50 >/dev/tty;
}
manage_ip_blocking() { log_message "$MSG_FEATURE_NOT_IMPLEMENTED"; [[ "$UI_TOOL" != "text" ]] && $UI_TOOL --msgbox "$MSG_FEATURE_NOT_IMPLEMENTED" 8 50 >/dev/tty; }
protect_ssh_fail2ban() {
    log_message "$MSG_F2B_ROOT_REQUIRED" "user.warning"; local CURRENT_OS=""; if [[ -f /etc/debian_version ]]; then CURRENT_OS="Debian"; elif [[ -f /etc/redhat-release ]]; then CURRENT_OS="RHEL"; else log_message "$MSG_INVALID_OS" "user.error"; [[ "$UI_TOOL" != "text" ]] && $UI_TOOL --msgbox "$MSG_INVALID_OS" 8 50 >/dev/tty; return 1; fi
    if ! command -v fail2ban-client >/dev/null 2>&1; then
        log_message "$MSG_F2B_NOT_INSTALLED"; local install_f2b_choice="no"; if [[ "$UI_TOOL" != "text" ]]; then $UI_TOOL --yesno "$MSG_F2B_INSTALL_PROMPT" 10 70 --yes-label "$MSG_YES_LABEL" --no-label "$MSG_NO_LABEL" >/dev/tty && install_f2b_choice="yes" || install_f2b_choice="no"; else read -p "$(echo -e "${C_YELLOW}$MSG_F2B_INSTALL_PROMPT (y/N):${C_RESET} ")" textual_choice; [[ "$textual_choice" =~ ^[Yy]$ ]] && install_f2b_choice="yes"; fi
        if [[ "$install_f2b_choice" == "yes" ]]; then
            log_message "$MSG_F2B_INSTALLING"; local install_cmd=""; if [[ "$CURRENT_OS" == "Debian" ]]; then install_cmd="apt-get update && apt-get install -y fail2ban"; elif [[ "$CURRENT_OS" == "RHEL" ]]; then install_cmd="yum install -y fail2ban"; else log_message "$MSG_INVALID_OS" "user.error"; return 1; fi
            run_sudo_cmd "$install_cmd"; if [[ $? -eq 0 ]]; then log_message "$MSG_F2B_INSTALL_SUCCESS"; [[ "$UI_TOOL" != "text" ]] && $UI_TOOL --msgbox "$MSG_F2B_INSTALL_SUCCESS" 8 50 >/dev/tty; else log_message "$MSG_F2B_INSTALL_FAILED" "user.error"; [[ "$UI_TOOL" != "text" ]] && $UI_TOOL --msgbox "$MSG_F2B_INSTALL_FAILED" 8 50 >/dev/tty; return 1; fi
        else log_message "$MSG_F2B_REQ_FOR_FEATURE" "user.warning"; [[ "$UI_TOOL" != "text" ]] && $UI_TOOL --msgbox "$MSG_F2B_REQ_FOR_FEATURE" 8 50 >/dev/tty; return 1; fi
    else log_message "$MSG_F2B_INSTALLED_INFO"; [[ "$UI_TOOL" != "text" ]] && $UI_TOOL --infobox "$MSG_F2B_INSTALLED_INFO" 5 50 >/dev/tty && sleep 1; fi
    local configure_jail_choice="no"; if [[ "$UI_TOOL" != "text" ]]; then $UI_TOOL --yesno "$MSG_F2B_JAIL_CONFIG_PROMPT" 15 75 --yes-label "$MSG_YES_LABEL" --no-label "$MSG_NO_LABEL" >/dev/tty && configure_jail_choice="yes" || configure_jail_choice="no"; else read -p "$(echo -e "${C_YELLOW}$MSG_F2B_JAIL_CONFIG_PROMPT (y/N):${C_RESET} ")" textual_choice; [[ "$textual_choice" =~ ^[Yy]$ ]] && configure_jail_choice="yes"; fi
    if [[ "$configure_jail_choice" == "yes" ]]; then
        log_message "$MSG_F2B_JAIL_CONFIGURING"; local jail_config_content="[DEFAULT]\nbantime = 1h\nfindtime = 10m\nmaxretry = 5\nbackend = auto\n\n[sshd]\nenabled = true\nport = ssh\nfilter = sshd\nlogpath = %(sshd_log)s\nbackend = %(backend)s"; run_sudo_cmd "mkdir -p /etc/fail2ban/jail.d"; echo -e "$jail_config_content" | run_sudo_cmd "tee /etc/fail2ban/jail.d/erenwaf-sshd.conf > /dev/null"; if [[ $? -eq 0 ]]; then log_message "$MSG_F2B_JAIL_CONFIG_SUCCESS"; [[ "$UI_TOOL" != "text" ]] && $UI_TOOL --msgbox "$MSG_F2B_JAIL_CONFIG_SUCCESS" 8 60 >/dev/tty; else log_message "$MSG_F2B_JAIL_CONFIG_FAILED" "user.error"; [[ "$UI_TOOL" != "text" ]] && $UI_TOOL --msgbox "$MSG_F2B_JAIL_CONFIG_FAILED" 8 60 >/dev/tty; fi
    else log_message "$MSG_F2B_JAIL_USER_SKIPPED"; fi
    log_message "$MSG_F2B_SERVICE_ENABLING"; run_sudo_cmd "systemctl enable fail2ban"; local enable_rc=$?; log_message "$MSG_F2B_SERVICE_RESTARTING"; run_sudo_cmd "systemctl restart fail2ban"; local restart_rc=$?;
    if [[ $enable_rc -eq 0 && $restart_rc -eq 0 ]]; then log_message "$MSG_F2B_SERVICE_MANAGE_SUCCESS"; [[ "$UI_TOOL" != "text" ]] && $UI_TOOL --infobox "$MSG_F2B_SERVICE_MANAGE_SUCCESS" 5 60 >/dev/tty && sleep 1; else log_message "$MSG_F2B_SERVICE_MANAGE_FAILED" "user.error"; [[ "$UI_TOOL" != "text" ]] && $UI_TOOL --msgbox "$MSG_F2B_SERVICE_MANAGE_FAILED" 8 60 >/dev/tty; fi
    log_message "$MSG_F2B_STATUS_CHECKING"; local status_output; if command -v fail2ban-client >/dev/null 2>&1; then status_output=$(run_sudo_cmd "fail2ban-client status sshd" 2>&1); if [[ "$UI_TOOL" != "text" ]]; then $UI_TOOL --title "$MSG_F2B_STATUS_TITLE" --msgbox "$status_output" 20 75 >/dev/tty; else echo -e "${C_GREEN}--- $MSG_F2B_STATUS_TITLE ---${C_RESET}"; echo "$status_output"; echo -e "${C_GREEN}---------------------------------${C_RESET}"; fi
    else log_message "[ERROR] fail2ban-client not found for status check." "user.error"; [[ "$UI_TOOL" != "text" ]] && $UI_TOOL --msgbox "fail2ban-client not found for status check." 8 60 >/dev/tty; fi
}
monitor_network_traffic() { log_message "$MSG_FEATURE_NOT_IMPLEMENTED"; [[ "$UI_TOOL" != "text" ]] && $UI_TOOL --msgbox "$MSG_FEATURE_NOT_IMPLEMENTED" 8 50 >/dev/tty; }
setup_auto_blacklist() {
    log_message "$MSG_AUTO_BLACKLIST_STARTING"; local CRON_CMD="*/5 * * * * root iptables -A INPUT -m recent --update --seconds 60 --hitcount 10 -j DROP"; if [[ $EUID -ne 0 ]]; then log_message "${C_RED}$MSG_AUTO_BLACKLIST_ROOT_REQUIRED${C_RESET}"; if [[ "$UI_TOOL" != "text" ]]; then $UI_TOOL --msgbox "$MSG_AUTO_BLACKLIST_ROOT_REQUIRED" 8 70 >/dev/tty; fi; return 1; fi
    if ! crontab -l 2>/dev/null | grep -qF "$CRON_CMD"; then (crontab -l 2>/dev/null; echo "$CRON_CMD") | crontab -; log_message "$MSG_AUTO_BLACKLIST_ACTIVATED"; [[ "$UI_TOOL" != "text" ]] && $UI_TOOL --msgbox "$MSG_AUTO_BLACKLIST_ACTIVATED" 8 50 >/dev/tty; else log_message "$MSG_AUTO_BLACKLIST_ALREADY_ACTIVE"; [[ "$UI_TOOL" != "text" ]] && $UI_TOOL --msgbox "$MSG_AUTO_BLACKLIST_ALREADY_ACTIVE" 8 50 >/dev/tty; fi
}
monitor_ssh_logs() {
    log_message "$MSG_SSH_MONITORING_START"; if [[ "$UI_TOOL" != "text" ]]; then ( tail -n 100 -f /var/log/auth.log | grep --line-buffered "Failed password" ) | $UI_TOOL --title "$MSG_SSH_MONITORING_TITLE_UI" --programbox 20 75 >/dev/tty
    else echo -e "${C_BOLD}${C_GREEN}$MSG_SSH_MONITORING_START (Ctrl+C to exit)${C_RESET}"; tail -f /var/log/auth.log | grep --line-buffered "Failed password"; fi
}

# --- Main Loop ---
INSTALL_UI_TOOL_PROMPT_DISPLAYED=""
while true; do
    MAIN_CHOICE=""; if [[ "$UI_TOOL" != "text" ]]; then MAIN_CHOICE=$($UI_TOOL --clear --title "$MENU_TITLE_UI" --ok-label "$DIALOG_OK_LABEL" --cancel-label "$DIALOG_CANCEL_LABEL" --menu "$MENU_PROMPT_UI" 20 70 7 "1" "$MENU_OPTION_1_DLG" "2" "$MENU_OPTION_2_DLG" "3" "$MENU_OPTION_3_DLG" "4" "$MENU_OPTION_4_DLG" "5" "$MENU_OPTION_5_DLG" "6" "$MENU_OPTION_6_DLG" "7" "$MENU_OPTION_7_DLG" 2>&1 >/dev/tty); exit_status=$?; if [[ $exit_status -ne 0 ]]; then MAIN_CHOICE="7"; fi
    else if [[ -z "$INSTALL_UI_TOOL_PROMPT_DISPLAYED" ]]; then echo -e "\n${C_YELLOW}${MSG_INSTALL_UI_TOOL_PROMPT}${C_RESET}\n"; INSTALL_UI_TOOL_PROMPT_DISPLAYED=true; fi; echo -e "\n====================================="; echo -e "       $MENU_TITLE      "; echo -e "====================================="; echo -e "${C_YELLOW}$MENU_OPTION_1_TEXT${C_RESET}"; echo -e "${C_YELLOW}$MENU_OPTION_2_TEXT${C_RESET}"; echo -e "${C_YELLOW}$MENU_OPTION_3_TEXT${C_RESET}"; echo -e "${C_YELLOW}$MENU_OPTION_4_TEXT${C_RESET}"; echo -e "${C_YELLOW}$MENU_OPTION_5_TEXT${C_RESET}"; echo -e "${C_YELLOW}$MENU_OPTION_6_TEXT${C_RESET}"; echo -e "${C_RED}$MENU_OPTION_7_TEXT${C_RESET}"; echo -e "====================================="; read -p "$(echo -e "$MENU_PROMPT_TEXT")" MAIN_CHOICE; fi
    case "$MAIN_CHOICE" in 1) configure_firewall ;; 2) manage_ip_blocking ;; 3) protect_ssh_fail2ban ;; 4) monitor_network_traffic ;; 5) setup_auto_blacklist ;; 6) monitor_ssh_logs ;; 7) echo -e "${C_GREEN}$MSG_EXITING${C_RESET}"; clear; exit 0 ;; *) log_message "${C_RED}$MSG_INVALID_OPTION${C_RESET}"; [[ "$UI_TOOL" != "text" ]] && $UI_TOOL --msgbox "$MSG_INVALID_OPTION" 8 50 >/dev/tty; sleep 1 ;; esac
    if [[ "$UI_TOOL" == "text" && "$MAIN_CHOICE" != "7" ]]; then read -p "$(echo -e "$MSG_PRESS_ENTER_TO_CONTINUE")"; fi; if [[ "$UI_TOOL" == "text" ]]; then clear; fi
done
exit 0
