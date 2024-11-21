#!/bin/bash

# Set default username and password
username="user"
password="root"

# Set default CRP value
CRP=""

# Set default Pin value
Pin="123456"

# Set default Autostart value
Autostart=true

echo "Creating User and Setting it up"
useradd -m "$username"
adduser "$username"
echo "$username:$password" | chpasswd
sed -i 's/\/bin\/sh/\/bin\/bash/g' /etc/passwd
echo "User created and configured with username '$username' and password '$password'"

echo "Installing necessary packages"
apt update
apt install -y xfce4 desktop-base xfce4-terminal tightvncserver wget sudo

echo "Setting up Chrome Remote Desktop"
echo "Installing Chrome Remote Desktop"
wget https://dl.google.com/linux/direct/chrome-remote-desktop_current_amd64.deb
dpkg --install chrome-remote-desktop_current_amd64.deb
apt install --assume-yes --fix-broken

echo "Installing Desktop Environment"
export DEBIAN_FRONTEND=noninteractive
apt install --assume-yes xfce4 desktop-base xfce4-terminal
echo "exec /etc/X11/Xsession /usr/bin/xfce4-session" | tee /etc/chrome-remote-desktop-session
apt remove --assume-yes gnome-terminal
apt install --assume-yes xscreensaver
systemctl disable lightdm.service

echo "Installing Google Chrome"
wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
dpkg --install google-chrome-stable_current_amd64.deb
apt install --assume-yes --fix-broken

# Prompt user for CRP value
read -p "Enter CRP value: " CRP

echo "Finalizing"
if [ "$Autostart" = true ]; then
    mkdir -p "/home/$username/.config/autostart"
    link="https://youtu.be/d9ui27vVePY?si=TfVDVQOd0VHjUt_b"
    colab_autostart="[Desktop Entry]\nType=Application\nName=Colab\nExec=sh -c 'sensible-browser $link'\nIcon=\nComment=Open a predefined notebook at session signin.\nX-GNOME-Autostart-enabled=true"
    echo -e "$colab_autostart" | tee "/home/$username/.config/autostart/colab.desktop"
    chmod +x "/home/$username/.config/autostart/colab.desktop"
    chown "$username:$username" "/home/$username/.config"
fi

adduser "$username" chrome-remote-desktop
command="$CRP --pin=$Pin"
su - "$username" -c "$command"
service chrome-remote-desktop start

echo "Finished Successfully"
while true; do sleep 10; done
