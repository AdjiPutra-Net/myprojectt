#!/bin/bash

# =====================================
# 🧠 Smart Auto-Exit + Unmount + Reboot
# =====================================
# Bisa langsung dijalankan SETELAH install_arch_dualboot.sh
# Script ini akan:
#   1. Deteksi apakah masih di chroot
#   2. Exit otomatis dari chroot
#   3. Unmount partisi
#   4. Reboot sistem
# =====================================

set -e  # Keluar kalau ada error

# 🔍 Fungsi: Cek apakah kita masih dalam chroot
function masih_di_chroot() {
    [[ "$(stat -c %d:%i /)" != "$(stat -c %d:%i /proc/1/root)" ]] || return 1
    grep -q '/mnt' /proc/1/mountinfo && return 0
    return 1
}

# 🔍 Fungsi: Unmount semua partisi yang dimount dari /mnt
function unmount_mnt() {
    if mountpoint -q /mnt; then
        echo "🗂️  Unmount semua partisi dari /mnt..."
        umount -R /mnt 2>/dev/null || echo "⚠️  Gagal sebagian unmount. Cek manual: mount | grep /mnt"
    else
        echo "❗ /mnt sudah tidak ter-mount."
    fi
}

# 🔁 Fungsi: Reboot dengan konfirmasi
function tanya_reboot() {
    echo -e "\n📋 \e[1mCatatan Penting Sebelum Reboot:\e[0m"
    echo "✅ Sistem sudah selesai dipasang ke disk."
    echo "🛑 Cabut USB/detach ISO sebelum reboot."
    echo "   - PC? Cabut flashdisk"
    echo "   - VM? Detach ISO dari storage settings"

    read -rp $'\n🔁 Mau reboot sekarang? [Y/n]: ' jawab
    jawab=${jawab,,}
    if [[ "$jawab" =~ ^(y|yes)?$ || "$jawab" == "" ]]; then
        echo -e "\n🚀 Rebooting sekarang..."
        reboot || echo -e "⚠️  \e[1mGagal reboot otomatis.\e[0m Ketik manual: \e[1mreboot\e[0m"
    else
        echo -e "✅ Oke, lo bisa reboot nanti manual dengan: \e[1mreboot\e[0m"
    fi
}

# =======================
# 🌐 MAIN EXECUTION BLOCK
# =======================

if masih_di_chroot; then
    echo -e "\n⚠️  Terdeteksi masih di dalam \e[1mchroot\e[0m."
    echo "➡️  Auto-exit dari chroot sekarang..."

    # Salin script ini ke luar dari chroot agar bisa lanjut setelah exit
    TEMP_SCRIPT="/tmp/after_exit_reboot.sh"
    cp "$0" "$TEMP_SCRIPT"
    chmod +x "$TEMP_SCRIPT"

    echo "➡️  Script disalin ke: $TEMP_SCRIPT"
    echo "➡️  Akan lanjut otomatis setelah exit..."

    # Inject auto-run command via temporary shell config
    echo "$TEMP_SCRIPT" > /mnt/root/.auto_reboot_tmp.sh
    echo "bash /root/.auto_reboot_tmp.sh; rm -f /root/.auto_reboot_tmp.sh" >> /mnt/root/.bash_profile

    exit
else
    echo "✅ Bukan di chroot. Lanjut unmount dan reboot..."
    unmount_mnt
    tanya_reboot
fi
