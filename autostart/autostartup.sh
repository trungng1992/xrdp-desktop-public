#!/bin/bash

#Set Timezone
if [[ -z "${TZ}" ]]; then
   ln -fs /usr/share/zoneinfo/Asia/Ho_Chi_Minh /etc/localtime
   dpkg-reconfigure -f noninteractive tzdata
else
   ln -fs /usr/share/zoneinfo/${TZ} /etc/localtime
   dpkg-reconfigure -f noninteractive tzdata
fi

if [[ -z "${USERNAME}" ]]; then
    username="ubuntu"
else
    username=${USERNAME}
fi

if [[ -z ${PASSWORD} ]]; then
    password="ubuntu"
else
    password=${PASSWORD}
fi

if getent passwd ${username} > /dev/null 2>&1
  then
    echo "User Exists"
else
    useradd -ms /bin/bash ${username}
    usermod -aG audio ${username}
    usermod -aG input ${username}
    usermod -aG video ${username}
    mkdir -p /run/user/$(id -u ${username})/dbus-1/
    chmod -R 700 /run/user/$(id -u ${username})/
    chown -R "${username}" /run/user/$(id -u ${username})/
    echo "$username:$password" | chpasswd

    mkdir -p /home/"${username}"/.config/autostart
    cp /usr/share/applications/firefox.desktop  /home/"${username}"/.config/autostart/
    # echo "nameserver 10.10.60.110" >> /etc/resolv.conf
fi

startfile="/root/startup.sh"
if [ -f $startfile ]
  then
    sh $startfile
fi

echo "export QT_XKB_CONFIG_ROOT=/usr/share/X11/locale" >> /etc/profile
echo "nameserver 8.8.8.8" > /etc/resolv.conf

#This has to be the last command!
/usr/bin/supervisord -n