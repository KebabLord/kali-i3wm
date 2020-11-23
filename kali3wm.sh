#!/bin/bash

# Kali Linux ISO recipe for : i3wm with rice
###############################################################################
# Desktop       : i3wm
# Metapackages  : kali-linux-defaults
# ISO size      : 3.3 GB
# Last update   : Kali 2020.4 (Rolling Release) / 23-Nov-2020
# Look and Feel : https://imgur.com/a/zeOjNP3
# Repository    : https://github.com/KebabLord/kali-i3wm
###############################################################################

# Update and install dependencies
apt update ; apt install git live-build cdebootstrap -y
git clone https://gitlab.com/kalilinux/build-scripts/live-build-config.git
cd live-build-config
REPOPATH=$PWD

# Our additional packages for rice (17.6 MB)
cat << EOF >>./kali-config/variant-i3wm/package-lists/kali.list.chroot
i3blocks
rxvt-unicode
rxvt-unicode-256color
suckless-tools
xfonts-terminus
network-manager-gnome
gxkb
pnmixer
nautilus
mpv
feh
xclip
xsel
htop
neofetch
tree
jq
EOF

# Disable Zsh
sed -i s/'--bootappend-live "'/'--bootappend-live "nozsh '/g auto/config
sed -i s/'--bootappend-live-failsafe "'/'--bootappend-live-failsafe "nozsh '/g auto/config
sed -i 's/^configure_zsh$/#configure_zsh/g' kali-config/common/includes.chroot/usr/lib/live/config/0031-kali-user-setup

# Use a different mirror
echo "http://mirror.karneval.cz/pub/linux/kali">.mirror
ln -s ../.mirror ./auto/.mirror

# Replace splash screen
wget -O kali-config/common/includes.binary/isolinux/splash.png https://u.teknik.io/u9soS.png

# Starting configuring home folder
mkdir -p ./kali-config/common/includes.chroot/etc/skel/{Downloads,Desktop,.config/{gxkb,i3,pnmixer},.local/bin}
cd ./kali-config/common/includes.chroot/etc/skel
touch .hushlogin

# Get kali-dmenu script
wget -O .local/bin/kali-dmenu "https://gist.githubusercontent.com/KebabLord/30dd123e7949d4ca45be5f0b8d12a143/raw/223bbd5cbeb2805db5613c60b8bb72b1bef582b7/kali-dmenu.sh"
chmod +x .local/bin/kali-dmenu

cat >.bashrc << 'EOF'
# don't put duplicate lines or lines starting with space in the history.
HISTCONTROL=ignoreboth
HISTSIZE=1000
HISTFILESIZE=2000
shopt -s histappend
shopt -s checkwinsize

# set variable identifying the chroot you work in (used in the prompt below)
if [ -z "${debian_chroot:-}" ] && [ -r /etc/debian_chroot ]; then
    debian_chroot=$(cat /etc/debian_chroot)
fi

PS1='\[\e]0;\u@\h: \w\a\]${debian_chroot:+($debian_chroot)}\[\033[1;49;96m\]\u@\h\[\033[00m\]\[\033[00;34m\]\w\[\033[00m\]:\nλ '

# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
    alias ls='ls --color=auto'
    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi

# import bash_aliases
if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi

# enable programmable completion features
if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
  fi
fi
EOF

cat >.bash_aliases << 'EOF'
alias gpp='g++ -Wall'
alias gpp2='g++ -pedantic-errors -Wall -Weffc++ -Wextra -Wsign-conversion -Werror'
alias git_status="git status -sb"
alias git_log="git log --all --graph --pretty=format:'%Cred%h%Creset -%C(auto)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit --date=relative"
alias pi="pwd>/tmp/pi"
alias po="cd \`cat /tmp/pi\`"
alias link_extract="grep -shoP 'http.*?[\" >]'"
alias py="python3"
alias bye="exit"

0x0() {
    curl -F "file=@$1" http://0x0.st
}
ix() {
    curl -F "f:l=@$1" ix.io
}
ix2() {
    curl -F "f:l=<-" ix.io
}
anon() {
    curl -F "file=@$1" https://api.anonfile.com/upload
}
fuck() {
    for i in $(pidof $1);do
         kill -s 9 $i
    done
}
EOF

cat >.Xdefaults << 'EOF'
! BASIC URxvt SETTINGS
URxvt.font:xft:terminus:size=12
URxvt.boldFont:xft:terminus:style=Bold:size=12
URxvt*scrollBar: false
URxvt*transparent: true
URXvt*pixbuf: true
URxvt*shading: 10
URxvt.saveLines: 2000
URxvt.internalBorder: 7
URxvt.letterSpace: 1

! Disable buffer update scroll lock
URxvt*scrollTtyOutput:      false
URxvt*scrollWithBuffer:     true
URxvt*scrollTtyKeypress:    true

! Disable ctrl+shift selector
URxvt.iso14755: false
URxvt.iso14755_52: false

! Copy Paste & Other Extensions
URxvt.perl-lib:		/usr/lib/urxvt/perl
URxvt.perl-ext-common:	default,clipboard,url-select,font-size
URxvt.copyCommand:	xclip -i -selection clipboard
URxvt.pasteCommand:	xclip -o -selection clipboard
URxvt.url-select.launcher:	firefox
URxvt.url-select.underline:	true
URxvt.url-select.autocopy:	true

! Common Keybinds
URxvt.keysym.Shift-Up: command:\033]720;1\007
URxvt.keysym.Shift-Down: command:\033]721;1\007
URxvt.keysym.M-c:		perl:clipboard:copy
URxvt.keysym.M-v:		perl:clipboard:paste
URxvt.keysym.M-C-v:		perl:clipboard:paste_escaped
URxvt.keysym.M-Escape:	perl:keyboard-select:activate
URxvt.keysym.M-s:		perl:keyboard-select:search
URxvt.keysym.M-u:		perl:url-select:select_next
URxvt.keysym.Control-minus:	font-size:decrease
URxvt.keysym.Control-equal:	font-size:increase
EOF

cat >.Xresources << 'EOF'
*.foreground:       #c2e099
*.background:       #0e0f11
URxvt*foreground:   #c2e099
URxvt*background:   [100]#0e0f11
URxvt*cursorColor:  #c2e099
URxvt*borderColor:  [100]#0e0f11
URxvt*depth: 32

! Colors 0-15.
*.color0: #0e0f11
*.color1: #3E4044
*.color2: #526242
*.color3: #6E9A33
*.color4: #749943
*.color5: #84B83E
*.color6: #97DA37
*.color7: #c2e099
*.color8: #879c6b
*.color9: #3E4044
*.color10: #526242
*.color11: #6E9A33
*.color12: #749943
*.color13: #84B83E
*.color14: #97DA37
*.color15: #c2e099
*.color66: #0e0f11
EOF

cat >.config/i3/config << 'EOF'
# Sets wallpaper and terminal themes at the start, 'wal' or 'feh'
exec --no-startup-id feh --bg-fill /usr/share/wallpapers/kali/contents/images/wallpaper.png

### -- BASIC DEFINITIONS -- ###
set $mod Mod4
floating_modifier $mod
font pango:DejaVu Sans Mono 8

### -- CLASS -- ###	border     backgro     text      indicat   childbo
client.focused          #1A1A1A00  #00000000   #9196DB   #FFFFFF   #FFFFFF
client.focused_inactive #1A1A1A00  #00000000   #000000   #B9B9B9   #526242
client.unfocused        #1A1A1A00  #00000000   #000000   #B9B9B9   #526242
client.urgent           #2F343A00  #00000000   #000000   #900000   #900000

### -- BASIC KEYBINDS -- ###
bindsym $mod+d exec --no-startup-id i3-dmenu-desktop
bindsym $mod+Shift+d exec --no-startup-id /home/kali/.local/bin/kali-dmenu
bindsym $mod+Return exec /usr/bin/urxvt
bindsym $mod+Shift+q kill
# change focus
bindsym $mod+Left focus left
bindsym $mod+Down focus down
bindsym $mod+Up focus up
bindsym $mod+Right focus right
# move focused window
bindsym $mod+Shift+Left move left
bindsym $mod+Shift+Down move down
bindsym $mod+Shift+Up move up
bindsym $mod+Shift+Right move right
# orientation and fullscreen
bindsym $mod+h split h
bindsym $mod+v split v
bindsym $mod+f fullscreen toggle
# change container layout
bindsym $mod+s layout stacking
bindsym $mod+w layout tabbed
bindsym $mod+e layout toggle split
# toggle tiling / floating
bindsym $mod+Shift+space floating toggle
bindsym $mod+space focus mode_toggle
# scratchpad
bindsym $mod+Shift+minus move scratchpad
bindsym $mod+minus scratchpad show

#  >switch to workspace
bindsym $mod+1 workspace number 1
bindsym $mod+2 workspace number 2
bindsym $mod+3 workspace number 3
bindsym $mod+4 workspace number 4
bindsym $mod+5 workspace number 5
bindsym $mod+6 workspace number 6
bindsym $mod+7 workspace number 7
bindsym $mod+8 workspace number 8
bindsym $mod+9 workspace number 9
bindsym $mod+quotedbl workspace number 10

#  >move focused container to workspace
bindsym $mod+Shift+1 move container to workspace number 1
bindsym $mod+Shift+2 move container to workspace number 2
bindsym $mod+Shift+3 move container to workspace number 3
bindsym $mod+Shift+4 move container to workspace number 4
bindsym $mod+Shift+5 move container to workspace number 5
bindsym $mod+Shift+6 move container to workspace number 6
bindsym $mod+Shift+7 move container to workspace number 7
bindsym $mod+Shift+8 move container to workspace number 8
bindsym $mod+Shift+9 move container to workspace number 9
bindsym $mod+Shift+quotedbl move container to workspace number 10


### --- MODES --- ###
mode " Resize Mode" {
        bindsym Left        resize shrink width 5 px or 5 ppt
        bindsym Down        resize grow height 5 px or 5 ppt
        bindsym Up          resize shrink height 5 px or 5 ppt
        bindsym Right       resize grow width 5 px or 10 ppt
        bindsym Return mode "default"
        bindsym Escape mode "default"
        bindsym $mod+r mode "default"
}


bar {
    strip_workspace_numbers yes
    status_command i3blocks -c ~/.config/i3/i3blocks.conf
    position top
    font pango:terminus 9
        colors {
            statusline #E6FFF5
            background #12161e00
            focused_workspace  #FFFFFF00 #00000000 #FFFFFF
            inactive_workspace #FFFFFF00 #00000000 #707070
            urgent_workspace   #00000000 #00000000 #C40100
            binding_mode       #00000000 #00000000 #000000
        }
}

for_window [class="^.*"] border pixel 1
new_window 1pixel

### -- SPECIAL KEYS -- ###
bindsym --release $mod+Shift+c exec --no-startup-id xkill
bindsym $mod+r mode " Resize Mode"

for_window [class="mpv"] floating enable
for_window [class="mpv"] move position center
for_window [class="feh"] floating enable
for_window [class="feh"] resize set 1000 800
for_window [class="feh"] move position center
for_window [window_role="GtkFileChooserDialog"] resize set 800 600
for_window [window_role="GtkFileChooserDialog"] move position center

for_window [window_type="DIALOG"] focus
for_window [window_type="DIALOG"] move position center
for_window [window_type="DIALOG"] sticky enable

exec --no-startup-id gxkb
exec --no-startup-id pnmixer
exec --no-startup-id sleep 3s; nm-applet
EOF

cat >.config/i3/i3blocks.conf << 'EOF'
# Global properties
command=/usr/share/i3blocks/$BLOCK_NAME
separator=false
separator_block_width=20
markup=none

[memory]
label=MEM
separator=false
interval=30

[memory]
label=SWAP
instance=swap
separator=false
interval=30

[disk]
label=HOME
#instance=/mnt/data
interval=30

[iface]
#instance=wlan0
color=#00FF00
interval=10
separator=false

[wifi]
instance=wlp3s0
interval=10
separator=false

[bandwidth]
#instance=eth0
interval=5

[cpu_usage]
label=CPU
interval=5
min_width=CPU: 100.00%
#separator=false

# The battery instance defaults to 0.
[battery]
label=BAT
#label=⚡
#instance=1
interval=30

[time]
#command=date '+%Y-%m-%d %H:%M:%S'
command=date '+ %d %B %H:%M '
interval=60
align=right
min_width= 00 October 00:00

[kali-dmenu]
full_text=
command=/home/kali/.local/bin/kali-dmenu &>/dev/null ; echo 
EOF

cat >.config/gxkb/gxkb.cfg << 'EOF'
[xkb config]
group_policy=0
default_group=0
never_modify_config=false
model=pc105
layouts=tr,us,ru,fr
variants=,,
toggle_option=
compose_key_position=
EOF

cat >.config/pnmixer/config << 'EOF'
[PNMixer]
SliderOrientation=vertical
DisplayTextVolume=true
TextVolumePosition=0
ScrollStep=5
FineScrollStep=1
MiddleClickAction=0
CustomCommand=
VolMuteKey=-1
VolUpKey=-1
VolDownKey=-1
AlsaCard=(default)
NormalizeVolume=true
SystemTheme=true
DrawVolMeter=false
VolMeterPos=0
VolMeterColor=0.90980392156900003;0.43137254902;0.43137254902;
VolumeControlCommand=
EnableHotKeys=false
VolMuteMods=0
VolUpMods=0
VolDownMods=0
EnableNotifications=false
HotkeyNotifications=true
MouseNotifications=true
PopupNotifications=false
ExternalNotifications=false
NotificationTimeout=1500

[(default)]
Channel=Master
EOF

# Configure Urxvt Scripts
mkdir -p ../../usr/lib/urxvt/perl
cd ../../usr/lib/urxvt/perl
wget -O url-select https://raw.githubusercontent.com/muennich/urxvt-perls/master/deprecated/url-select
wget -O clipboard https://raw.githubusercontent.com/muennich/urxvt-perls/master/deprecated/clipboard
wget -O font-size https://raw.githubusercontent.com/majutsushi/urxvt-font-size/master/font-size
chmod +x ./*

cd $REPOPATH
# Add our Wallpaper
mkdir -p kali-config/common/includes.chroot/usr/share/wallpapers/kali/contents/images
wget -O kali-config/common/includes.chroot/usr/share/wallpapers/kali/contents/images/wallpaper.png https://u.teknik.io/40JLT.png

# Hook script to fix file permissions
cat > kali-config/common/hooks/permissions.chroot<< 'EOF'
#!/bin/bash
chmod -R 755 /usr/lib/urxvt/
chmod -R 751 /usr/share
chmod 755 /usr/share/wallpapers/kali/contents/images/wallpaper.png
EOF
chmod +x kali-config/common/hooks/permissions.chroot

echo "CONFIGURING SUCCESS, NOW BUILDING."
./build.sh --variant i3wm --verbose
