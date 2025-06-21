#!/bin/bash

# ===================================
# 🧹 Tahap 11: Exit, Unmount & Reboot
# ===================================
echo -e "\n🧹 \e[1mTahap 11: Exit, Unmount & Reboot\e[0m"
echo "------------------------------------------"

# ✅ Deteksi apakah MASIH di chroot (gandeng 2 cara biar lebih akurat)
in_chroot_inode_check=false
in_chroot_mountinfo=false

if [[ "$(stat -c %d:%i /)" != "$(stat -c %d:%i /proc/1/root)" ]]; then
    in_chroot_inode_check=true
fi

if grep -q '/mnt' /proc/1/mountinfo; then
    in_chroot_mountinfo=true
fi

if $in_chroot_inode_check || $in_chroot_mountinfo; then
    echo -e "⚠️  \e[1mKamu masih ada di lingkungan chroot (/mnt)\e[0m."
    echo -e "🔚 Untuk melanjutkan:"
    echo -e "   ➜ Ketik perintah: \e[1mexit\e[0m"
    echo -e "   ➜ Kemudian jalankan script ini dari \e[1mLive ISO (di luar chroot)\e[0m"
    exit 1
fi

# ✅ Unmount semua partisi dari /mnt
if ! mountpoint -q /mnt; then
    echo "❗ /mnt sudah tidak ter-mount. Mungkin udah pernah di-unmount sebelumnya."
else
    echo "🗂️  Unmount semua partisi dari /mnt..."
    umount -R /mnt 2>/dev/null
    if [[ $? -eq 0 ]]; then
        echo "✅ Semua partisi berhasil di-unmount dari /mnt."
    else
        echo "⚠️  Beberapa partisi gagal di-unmount atau sudah tidak ter-mount."
        echo "   ➜ Cek manual dengan: mount | grep mnt"
    fi
fi

# ✅ Reminder sebelum reboot
echo -e "\n📋 \e[1mCatatan Penting Sebelum Reboot:\e[0m"
echo "✅ Instalasi Arch Linux selesai dan sistem sudah terpasang di disk."
echo "🛑 Pastikan lo \e[1mCABUT USB atau detach ISO\e[0m sebelum reboot:"
echo "   - Real PC? ➜ Cabut flashdisk/USB bootable"
echo "   - VirtualBox/VMWare? ➜ Detach ISO dari pengaturan Storage"

# ✅ Konfirmasi reboot
read -rp $'\n🔁 Mau reboot sekarang? [Y/n]: ' jawab
jawab=${jawab,,}

if [[ "$jawab" =~ ^(y|yes)?$ || "$jawab" == "" ]]; then
    echo -e "\n🚀 Rebooting sekarang..."
    reboot || echo -e "⚠️  \e[1mGagal reboot otomatis.\e[0m Silakan ketik manual: \e[1mreboot\e[0m"
else
    echo -e "✅ Oke, lo bisa reboot nanti dengan perintah: \e[1mreboot\e[0m"
fi
