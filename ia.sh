########################################################
# 0. Swap caps lock and ctrl
# loadkeys /usr/share/kbd/keymaps/i386/qwerty/emacs2.map.gz || exit 1
kbdrate -d 30  -r 400 || exit 1

# lsblk
# fdisk -l

# mkfs.ext3 /dev/sda1
# mkfs.ext4 /dev/sda5
# mkfs.ext4 /dev/sda6
# mkfs.ext4 /dev/sda8

# /dev/sda5        46G   12G   32G  27% /
# /dev/sda1       227M   36M  179M  17% /boot
# /dev/sda6        30G  4.0G   24G  15% /var
# /dev/sda8       610G  123G  457G  22% /home

# mount /dev/sda5 /mnt
# mkdir /mnt/{boot,var,home}

# mount /dev/sda1 /mnt/boot
# mount /dev/sda6 /mnt/var
# mount /dev/sda8 /mnt/home

# 3. install system base
# pacstrap /mnt base openssh vim tmux sudo git zsh grub net-tools wireless_tools wpa_actiond ifplugd rfkill axel alsa-utils samba make ctags bc || exit 1

# 4. generate fstab
# genfstab -p /mnt >> /mnt/etc/fstab || exit 1

# 5. change root new env (NOTE: use arch-chroot, not chroot)
#arch-chroot /mnt || { echo fail chroot; exit 1; }

#########################################################

git clone https://github.com/jkoz/home github/jkoz /opt/github/jkoz/home || { echo fail to get dotfiles; exit 1; }

# 6. create hostname
echo "archlinux" > /etc/hostname || { echo fail to create host name; exit 1; }

# 7. locale setting
ln -s /usr/share/zoneinfo/Canada/Mountain /etc/localtime || { echo fail to set local time; exit 1; }

# 8. enable us locale
sed -i 's!#en_US.UTF-8 UTF-8!en_US.UTF-8 UTF-8!' /etc/locale.gen || { echo fail to enable en_US.UTF-8 UTF-8; exit 1; }
sed -i 's!#en_US ISO-8859-1!en_US ISO-8859-1!' /etc/locale.gen || { echo fail to enable en_US ISO-8859-1; exit 1; }
locale-gen || { echo fail to generate locale; exit 1; }

# FIXME: error before x installation
# important in order to support unicode charaters in urxvt; give it a test echo "\udf"
localectl set-locale LANG=en_US.UTF-8 || { echo fail to set locale; exit 1; }

# 9. increase kdb rate and persistent keymap (swap caplocks and ctrl)

echo "KEYMAP=\"emacs2\"" > /etc/vconsole.conf || { echo fail to set keymap; exit 1; }
kbdrate -d 30  -r 400 || { echo fail to speed up typing; exit 1; }

# 10. install grub
mkinitcpio -p linux || { echo fail to init tcpio ; exit 1; }
grub-install /dev/sda || { echo fail to install grub; exit 1; }
grub-mkconfig -o /boot/grub/grub.cfg || { echo fail to create grub config; exit 1; }

# 11. Set up root passwd
echo "Type root passwd"
passwd

# 12. enable service network: copy from bootable disk: cp /etct/netctl/wlp0s29u1u2-tp /mnt/etct/netctl/wlp0s29u1u2-tp
systemctl enable netctl-auto@wlp0s29u1u2 || { exit 1; }
systemctl enable netctl-ifplugd@enp3s0 || { exit 1; }
systemctl enable dhcpcd

# 13. add new user
useradd -m -g users -G audio,lp,optical,storage,video,wheel,games,power -d/home/tait -s /usr/bin/zsh tait || { exit 1; }
usermod -s /usr/bin/zsh root || { exit 1; }
passwd tait

# 14. enable for wheel groups, uncomment %wheel ALL=(ALL) ALL
sudoedit /etc/sudoers || { exit 1; }

# 15 yaourt
pacman -S --noconfirm base-devel
cd /tmp
curl https://aur.archlinux.org/cgit/aur.git/snapshot/package-query.tar.gz | tar xz && cd package-query && makepkg && sudo pacman -U package-query*xz
curl https://aur.archlinux.org/cgit/aur.git/snapshot/yaourt.tar.gz | tar xz && cd yaourt && makepkg && sudo pacman -U yaourt*xz


# 16 packages

# GUI
pacman -S --noconfirm xorg xorg-server xorg-xinit xclip
pacman -S --noconfirm x11vnc
pacman -S --noconfirm xdg-user-dirs && xdg-user-dirs-update

yaourt -S --noconfirm gtk-theme-numix-solarized
pacman -S --noconfirm feh
pacman -S --noconfirm dunst
pacman -S --noconfirm transmission-cli # torrent
yaourt -S --noconfirm xtitle-git lemonbar acpi
yaourt -S --noconfirm sxhkd-git # bindkeys in x
yaourt -S --noconfirm compton
yaourt -S --noconfirm dropbox-cli # cloud dropbox
pacman -S --noconfirm redshift # automatically change color temperature
yaourt -S --noconfirm google-chrome
pacman -S --noconfirm libxcb xcb-util xcb-util-keysyms xcb-util-wm # xcb tools
pacman -S --noconfirm alsa-utils mplayer
pacman -S --noconfirm xdotool
yaourt -S --noconfirm fzf # cloud dropbox
pacman -S --noconfirm cmake clang # for youcompleteme
yaourt -S --noconfirm silver-searcher-git # for fuzzy search in vim
pacman -S --noconfirm slock xautolock # lock screen
pacman -S --noconfirm zathura tabbed zathura-pdf-mupdf
yaourt -S --noconfirm mt7601u-dkms # usb wifi Mediatek

# wm
# st


pacman -S --noconfirm parted
pacman -S --noconfirm ntp && systemctl enable ntpd || { exit 1; } # sync time
yaourt -S --noconfirm ntfs-3g simple-mtpfs # mount camera and ntfs
pacman -S --noconfirm android-tools android-udev # android
pacman -S --noconfirm zip unzip unrar
pacman -S --noconfirm cowsay
pacman -S --noconfirm xclip
pacman -S --noconfirm words # dictionary used in vim
yaourt -S --noconfirm xdo-git # like xdotool
yaourt -S --noconfirm mt7601u-dkms # wifi mt7601u
# pacman -S --noconfirm chromium
# yaourt -S --noconfirm chromium-pepper-flash
pacman -S --noconfirm transmission-cli # torrent
pacman -S --noconfirm mplayer
pacman -S --noconfirm ffmpeg # streaming & screencast
pacman -S --noconfirm mupdf
yaourt -S --noconfirm cabaretstage pdftk # pdf
yaourt -S --noconfirm tmuxinator # tmux layout
pacman -S --noconfirm cups # print
pacman -S --noconfirm imagemagick
pacman -S --noconfirm gimp
pacman -S --noconfirm r # R languagee for statistics
pacman -S --noconfirm scrot
pacman -S --noconfirm xorg-xlsfonts
pacman -S --noconfirm tk # for gitk
yaourt -S --noconfirm gcalcli # google calendar commandline
yaourt -S --noconfirm silver-searcher-git
pacman -S --noconfirm libxft  # dwm, dmenu, st with xft
pacman -S --noconfirm freetype2
pacman -S --noconfirm go # golang
pacman -S --noconfirm webkitgtk2 # surf
yaourt -S --noconfirm dropbox-cli # cloud dropbox
yaourt -S --noconfirm googlecl
yaourt -S --noconfirm archey # status
yaourt -S --noconfirm ttf-ms-fonts # status
yaourt -S --noconfirm adobe-source-code-pro-fonts # current used font
yaourt -S --noconfirm ttf-chromeos-fonts # cousine
pacman -S --noconfirm mercurial subversion cvs
pacman -S --noconfirm cdrkit dvd+rw-tools # cd kit
sudo pacman -S lshw # view hardware specs
pacman -S --noconfirm bitlbee irssi # irc, chat
pacman -S --noconfirm mpd mpc ncmpcpp # mp3 player
pacman -S --noconfirm gnuplot # plotting tool
pacman -S --noconfirm mutt fetchmail procmail # mail
pacman -S --noconfirm redshift # automatically change color temperature
pacman -S --noconfirm unclutter # automatically hide cursor when inactive
pacman -S --noconfirm fish fbterm # some terminals
pacman -S --noconfirm cabextract # extract .cab file
pacman -S --noconfirm gdb  graphviz doxygen valgrind # developer tools for c
yaourt -S --noconfirm scanmem # game hacking program, scanmem and change value
pacman -S --noconfirm ecm # convert ecm to bin - unecm *bin.ecm *bin
yaourt -S --noconfirm stardict-longman # dictionary
pacman -S --noconfirm pulseaudio pulseaudio-alsa
pacman -S --noconfirm texlive-core # latex
pacman -S --noconfirm texlive-localmanager-git # latex package manager
yaourt -S pandoc-static # pandoc
cd ~ && pkg=~/github/jkoz/PKGBUILDs && rm -rf $pkg && git clone https://github.com/jkoz/PKGBUILDs $pkg && \
    cd $pkg && for dir in `ls $pkg`; do cd $dir; ls | grep -v PKGBUID | xargs ;  makepkg --noconfirm -si --asroot; cd .. ; done
yaourt -S shrew-vpn-client # VPN: mkdir -p ~/.ike/sites/ && touch tptai.vpn && ikec -r tptai.vpn -u user -p pwd -a &
pacman -S --noconfirm perl-cpanplus-dist-arch python-pip python2-pip # pip and cpan
pacman -S --noconfirm ranger-git # file manager
pacman -S --noconfirm w3m # display photo in ranger
yaourt -S --noconfirm gbdfed pcf2bdf # font editors
pacman -S --noconfirm dnsutils
yaourt -S --noconfirm stardict-tools dictconv stardict makedict sdcv # dict tools
pacman -S --noconfirm lm_sensors # WTF this thing?
pacman -S --noconfirm aircrack-ng # wifi crack tools 
yaourt -S --noconfirm crunch # wordlist generator http://adaywithtape.blogspot.ca/2011/05/creating-wordlists-with-crunch-v30.html
yaourt -S --noconfirm jdk && archlinux-java set java-8-jdk
yaourt -S --noconfirm android-studio

cd ~ && pkg=~/github/jkoz/PKGBUILDs && rm -rf $pkg && git clone https://github.com/jkoz/PKGBUILDs $pkg && \
    cd $pkg && for dir in `ls $pkg`; do cd $dir; ls | grep -v PKGBUID | xargs ;  makepkg --noconfirm -si --asroot; cd .. ; done

#yaourt -S shrew-vpn-client # VPN: mkdir -p ~/.ike/sites/ && touch tptai.vpn && ikec -r tptai.vpn -u user -p pwd -a &
#yaourt -S --noconfirm compton # 14.8 composite
#pacman -S --noconfirm perl-cpanplus-dist-arch python-pip python2-pip # pip and cpan
#pacman -S --noconfirm ranger # file manager
#yaourt -S --noconfirm gbdfed pcf2bdf # font editors
#yaourt -S --noconfirm xtitle-git bar-aint-recursive bspwm-git
#yaourt -S --noconfirm stardict-tools dictconv stardict makedict # dict tools
#pacman -S --noconfirm lm_sensors # WTF this thing?


#----------------------------------------------------------------------------------

# clang
#pacman -S clang && vim && cd ~/.vim/bundle/YouCompleteMe && ./install.sh --clang-completer --system-libclang

#####################################################################
# IF WE USE netctl-auto@wlan0 service, please don't touch wpa_supplicant low
# level configuration
#####################################################################

# netctl manually enable network profile
netctl enable wlp2s0-tp

# use wpa_supplicant
# create /etc/wpa_supplicant/wpa_supplicant-wlp0s29u1u2.conf
#ctrl_interface=/run/wpa_supplicant
#ctrl_interface_group=wheel
#ap_scan=1
#update_config=1

#network={
    #ssid="tp"
    #scan_ssid=1
    #psk="mykey"
#}
# start
systemctl start wpa_supplicant@wlp0s29u1u2
# stop wpa
systemctl stop wpa_supplicant@wlp0s29u1u2
wpa_cli terminate

# for install olad8
pacman -S lib32-gtk
pacman -S lib32-alsa-lib
pacman -S lib32-nvidia-utils
pacman -S lib32-libdbus

#######################################
readcd -v dev=/dev/cdrom -f abc.iso


pacman -Q # list all installed packages
pacman -Qi # list all installed packages with more info
pacman -Q -n # list all installed packages founded in sync db
pacman -Q -m # list all installed packages founded elsewhere, aur
pacman -Q -g base base-devel # list all installed package belongs to group base or base devel
pacman -Ql # list where files are stored

expac -HM "%011m\t%-20n\t%10d" $(comm -23 <(pacman -Qqen | sort) <(pacman -Qqg base base-devel | sort) ) | sort -n # list all installed package that no base or base-devel

# handle image & partition
yaourt -S multipath-tools-git

#bspc

# zip
zip -R file.txt folder1/ folder2/

# unblock bootloader android
# 1. Settings -> About tablet -> Build number (tap 7 times)
# 2. setting -> developer options -> enable enable USB debugging
adb reboot bootloader # can enter bootloader by power off the device then back on with 'vol up' + power button.
fastboot oem unlock
fastboot getvar all

# install recovery system - http://www.clockworkmod.com/rommanager
fastboot flash recovery /home/tait/Downloads/recovery-clockwork-touch-6.0.4.7-grouper.img

# enter wcm recovery mode -> install zip -> sideload
adb sideload superuser.zip

# systemd-journald
journalctl --dmesg -f
journalctl --full -f

# burn iso with cdkit
readcd -v dev=/dev/cdrom -f abc.iso
# burn dvd - dvd+rw-tools
growisofs -dvd-compat -Z /dev/sr0=/home/tait/Dropbox/os/window/xp_pro_sp2.iso

# keychain and pass
gpg --gen-key
gpg -e -r 'your-name' ~/.my-pwds
shred -xu ~/.my-pwds
gpg2 -dq $HOME/.my-pwds.gpg
pass insert abc/ddd.com
pass abc/ddd.com

#isync
mbsync --verbose gmail-phuoctaitp
mbsync --verbose yahoo-thunderchief3000

# torrent alias bt='transmission-remote'; $BROWSER http://localhost:9091/
bt -l # list
bt -t 2 -s # start
bt -t 2 -S # stop
bt "magetlink"

# dual boot
# check partition table
sudo parted /dev/sda print | grep "Partition Table"
# msdos
# 1. find uuid of window boot partition
% mount /dev/sda3 /mnt                                                                                                                                  ~
% ls /mnt                                                                                                                                               ~
Boot  bootmgr  BOOTNXT  BOOTSECT.BAK  Recovery  System Volume Information
% grub-probe --target=fs_uuid /mnt/bootmgr                                                                                                              ~
F49209269208EEC4
# 2. Add following to /etc/grub.d/40_custom (after tail line)
# (hd0,msdos3) -> /dev/sda3  (a=0; 3=3)
menuentry "Windows 8" {
    insmod part_msdos
    insmod ntfs
    insmod search_fs_uuid
    insmod ntldr
    search --fs-uuid --no-floppy --set=root --hint-bios=hd0,msdos3 --hint-efi=hd0,msdos3 --hint-baremetal=ahci0,msdos3 F49209269208EEC4
    ntldr /bootmgr
}

# mount
sudo mount -o gid=users,fmask=113,dmask=002 /dev/sdb1 /mnt/usb

# ctags
# linux header - vim -c "set tags+=$HOME/.ctags/usr/include/ctags"
pat=/usr/include && mkdir -p ~/.ctags${pat} && ctags -f ~/.ctags${pat}/ctags $(find $pat -type f)
# OpenGL
pat=/usr/include/GL && mkdir -p ~/.ctags${pat} &&
    ctags -f ~/.ctags${pat}/ctags -R --sort=yes --c++-kinds=+p --fields=+iaS --extra=+q --language-force=C++ $pat
# Sys
pat=/usr/include/sys && mkdir -p ~/.ctags${pat} && ctags -f ~/.ctags${pat}/ctags -R $pat

# SDL
pat=/usr/include/SDL && mkdir -p ~/.ctags${pat} && ctags -f ~/.ctags${pat}/ctags -R $pat

# CPP
pat=/usr/include/c++/4.9.2 && mkdir -p ~/.ctags${pat} && ctags --language-force=C++ -f ~/.ctags${pat}/ctags -R $pat


# scanmem
scanmem $pid
123
129
set 4000

# find out which program open port / using a files
netstat -tulpn
lsof
