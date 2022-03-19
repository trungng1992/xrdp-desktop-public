FROM ubuntu:20.04

ENV DEBIAN_FRONTEND noninteractive
ENV DBUS_SESSION_BUS_ADDRESS=/dev/null

RUN cd /root && \
    sed -i 's/^#\s*\(deb.*partner\)$/\1/g' /etc/apt/sources.list && \
    sed -i 's/^#\s*\(deb.*restricted\)$/\1/g' /etc/apt/sources.list && \ 
    apt-get update -y && \ 
    apt-get install -yqq locales  && \ 
    apt-get install -yqq \
        mate-desktop-environment-core \
        mate-themes \
        mate-accessibility-profiles \
        mate-applet-appmenu \
        mate-applet-brisk-menu \
        mate-applets \
        mate-applets-common \
        mate-dock-applet \
        mate-hud \
        mate-indicator-applet \
        mate-indicator-applet-common \
        mate-menu \
        mate-notification-daemon \
        mate-notification-daemon-common \
        mate-utils \
        mate-utils-common \
        mate-window-applets-common \
        mate-window-buttons-applet \
        mate-window-menu-applet \
        mate-window-title-applet \
        ubuntu-mate-icon-themes \
        ubuntu-mate-themes \
        tightvncserver \
        pulseaudio

# Setup common applycation
RUN apt-get install --no-install-recommends -yqq \
    supervisor \
    sudo \
    tzdata \
    ca-certificates \
    curl \
    wget \
    wmctrl \
    firefox

# Symbolink timezone
RUN ln -fs /usr/share/zoneinfo/UTC /etc/localtime && dpkg-reconfigure -f noninteractive tzdata

# Install libray for pulseaudio
RUN apt-get -y install \
        git \
        libxfont-dev \
        xserver-xorg-core \
        libx11-dev \
        libxfixes-dev \
        libssl-dev \
        libpam0g-dev \
        libtool \
        libjpeg-dev \
        flex \
        bison \
        gettext \
        autoconf \
        libxml-parser-perl \
        libfuse-dev \
        xsltproc \
        libxrandr-dev \
        python-libxml2 \
        nasm \
        xserver-xorg-dev \
        fuse \
        build-essential \
        pkg-config \
        libpulse-dev m4 intltool dpkg-dev \
        libfdk-aac-dev \
        libopus-dev \
        libmp3lame-dev
RUN git clone -b devel https://github.com/neutrinolabs/xrdp.git /root/xrdp
RUN git clone -b devel https://github.com/neutrinolabs/xorgxrdp.git /root/xorgxrdp
RUN cd /root/xrdp && \
    ./bootstrap && \
    ./configure --enable-jpeg --enable-vsock --enable-pixman && \
    make && make install && \
    cd /root/xorgxrdp  && \
    ./bootstrap && ./configure && make && make install && \
    cd /root && \
    rm -R /root/xrdp && \
    rm -R /root/xorgxrdp
RUN apt-get install -y  libu2f-udev libvulkan1 xdg-utils fonts-liberation

# Install google chrome
RUN cd /root && wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
RUN dpkg -i /root/google-chrome-stable_current_amd64.deb
RUN rm -rf /root/google-chrome-stable_current_amd64.deb
RUN mkdir -p /opt/google/chrome/plugins

# Install java oracle jdk8
# RUN cd /opt && wget https://xxx.xxx.xxx.xxx/trungn/jdk.tar.gz
# RUN cd /opt && tar -zxvf jdk.tar.gz
# RUN update-alternatives --install /usr/bin/java java /opt/jdk1.8.0_271/jre/bin/java 100
# RUN update-alternatives --install /usr/bin/javaws javaws /opt/jdk1.8.0_271/jre/bin/javaws 100

RUN apt-get -y purge \
    git \
    libxfont-dev \
    libx11-dev \
    libxfixes-dev \
    libssl-dev \
    libpam0g-dev \
    libtool \
    libjpeg-dev \
    flex \
    bison \
    gettext \
    autoconf \
    libxml-parser-perl \
    libfuse-dev \
    xsltproc \
    libxrandr-dev \
    python-libxml2 \
    nasm \
    xserver-xorg-dev \
    build-essential \
    pkg-config \
    libfdk-aac-dev \
    libopus-dev \
    libmp3lame-dev

RUN apt-get -y autoclean && apt-get -y autoremove
RUN apt-get -y purge $(dpkg --get-selections | grep deinstall | sed s/deinstall//g) && \
    rm -rf /var/lib/apt/lists/*  && \
    echo "mate-session" > /etc/skel/.xsession && \
    sed -i '/TerminalServerUsers/d' /etc/xrdp/sesman.ini  && \
    sed -i '/TerminalServerAdmins/d' /etc/xrdp/sesman.ini  && \
    sed -i -e '/DisconnectedTimeLimit=/ s/=.*/=0/' /etc/xrdp/sesman.ini && \
    sed -i -e '/IdleTimeLimit=/ s/=.*/=0/' /etc/xrdp/sesman.ini && \
    xrdp-keygen xrdp auto  && \
    mkdir -p /var/run/xrdp && \
    chmod 2775 /var/run/xrdp  && \
    mkdir -p /var/run/xrdp/sockdir && \
    chmod 3777 /var/run/xrdp/sockdir && \
    touch /etc/skel/.Xauthority && \
    mkdir /run/dbus/ && chown messagebus:messagebus /run/dbus/ && \
    echo "[program:xrdp-sesman]" > /etc/supervisor/conf.d/xrdp.conf && \
    echo "command=/usr/local/sbin/xrdp-sesman --nodaemon" >> /etc/supervisor/conf.d/xrdp.conf && \
    echo "process_name = xrdp-sesman" >> /etc/supervisor/conf.d/xrdp.conf && \
    echo "[program:xrdp]" >> /etc/supervisor/conf.d/xrdp.conf && \
    echo "command=/usr/local/sbin/xrdp -nodaemon" >> /etc/supervisor/conf.d/xrdp.conf && \
    echo "process_name = xrdp" >> /etc/supervisor/conf.d/xrdp.conf

# Remove unneccessary application and library
RUN dpkg -P --force-depends mate-terminal \
    mate-terminal-common \
    mate-system-monitor \
    mate-system-monitor-common \
    mate-indicator-applet \
    mate-indicator-applet-common \
    libmatedict6 dictionaries-common \
    caja caja-common \
    mc mc-data \
    mate-control-center mate-control-center-common \
    mate-notification-daemon mate-notification-daemon-common \
    mate-media mate-media-common \
    mate-themes \
    mate-user-guide mate-media mate-media-common

RUN cd /usr/share/applications/ && rm -rf debian-* \
    mate-disk* \
    mate-about* \
    mate-screenshot.desktop \
    mate-color-select.desktop \
    mate-dictionary.desktop \
    mate-font-viewer.desktop \
    mate-search-tool.desktop \
    mate-keyboard.desktop \ 
    mate-keybinding.desktop \
    mate-network-properties.desktop \
    mate-settings-mouse.desktop \
    mate-system-log.desktop \
    mate-time-admin.desktop \
    mate-theme-installer.desktop \
    vim.desktop \
    mc.desktop \
    mate-default-applications-properties.desktop \
    mate-volume-control.desktop \
    mate-appearance-properties.desktop \
    mate-notification-properties.desktop \
    mate-session-properties.desktop \
    orca.desktop \
    mozo.desktop \
    python3.8.desktop

ADD etc/skel/ /etc/skel
ADD xrdp.ini /etc/xrdp/xrdp.ini

# For java zone
RUN echo -e "\napplication/x-java-jnlp-file=javaws.desktop" >> /usr/share/applications/mate-mimeapps.list
COPY usr/share/applications/javaws.desktop /usr/share/applications/javaws.desktop
COPY usr/share/applications/jcontrol.desktop /usr/share/applications/jcontrol.desktop
# End java zone

RUN copy img/conver-joker.jpeg /opt/desktop.jpg

# RUN sed  -i "s=firefox %u=firefox https://google.com.vn=g" /usr/share/applications/firefox.desktop
# RUN sed  -i "s=/usr/bin/google-chrome-stable %U=/usr/bin/google-chrome-stable https://google.com.vn=g" /usr/share/applications/google-chrome.desktop

ADD autostart/autostartup.sh /root/autostartup.sh
CMD ["/bin/bash", "/root/autostartup.sh"]
                                    
EXPOSE 3389