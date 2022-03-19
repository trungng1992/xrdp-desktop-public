#!/bin/bash
docker run --name vconsole \
    --privileged=true \
    --hostname=bms-vconsole \
    -p 33389:3389 \
    -e TZ="Asia/Ho_Chi_Minh" \
    -e USERNAME="trungng1992" \
    -e PASSWORD="trungng1992" \
    -dit \
    --restart unless-stopped \
    xrdp-desktop-public:stable