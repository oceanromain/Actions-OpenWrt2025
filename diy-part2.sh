#!/bin/bash
#
# Copyright (c) 2019-2020 P3TERX <https://p3terx.com>
#
# This is free software, licensed under the MIT License.
# See /LICENSE for more information.
#
# https://github.com/P3TERX/Actions-OpenWrt
# File name: diy-part2.sh
# Description: OpenWrt DIY script part 2 (After Update feeds)
#

# Modify default IP
#修改默认IP
sed -i 's/192.168.1.1/192.168.10.1/g' package/base-files/files/bin/config_generate
#修改主机名
sed -i "/uci commit system/i\uci set system.@system[0].hostname='StarNet'" package/lean/default-settings/files/zzz-default-settings
sed -i "s/hostname='OpenWrt'/hostname='OpenWrt'/g" ./package/base-files/files/bin/config_generate
#修改连接数
echo "net.netfilter.nf_conntrack_max=165535" >> package/base-files/files/etc/sysctl.conf
#sed -i '5i\uci set luci.main.mediaurlbase=/luci-static/openwrt2020' package/lean/default-settings/files/zzz-default-settings

rm -rf package/lean/autocore
echo " ____  _                        _      ___                __        __    _   " > package/base-files/files/etc/banner
echo "/ ___|| |_ __ _ _ __ _ __   ___| |_   / _ \ _ __   ___ _ _\ \      / / __| |_ " >> package/base-files/files/etc/banner
echo "\___ \| __/ _\` | '__| '_ \ / _ \ __| | | | | '_ \ / _ \ '_ \ \ /\ / / '__| __|" >> package/base-files/files/etc/banner
echo " ___) | || (_| | |  | | | |  __/ |_  | |_| | |_) |  __/ | | \ V  V /| |  | |_ " >> package/base-files/files/etc/banner
echo "|____/ \__\__,_|_|  |_| |_|\___|\__|  \___/| .__/ \___|_| |_|\_/\_/ |_|   \__|" >> package/base-files/files/etc/banner
echo "                                           |_|                                " >> package/base-files/files/etc/banner
echo "------------------------------------------------------------------------------" >> package/base-files/files/etc/banner
echo "                        %D %V %C                         " >> package/base-files/files/etc/banner
echo "------------------------------------------------------------------------------" >> package/base-files/files/etc/banner

#删除watchcat
rm -rf feeds/packages/lang/golang
rm -rf feeds/luci/applications/luci-app-mosdns
rm -rf rm -rf feeds/packages/net/{alist,adguardhome,mosdns,smartdns}
#rm -rf feeds/packages/net/{alist,adguardhome,mosdns,xray*,v2ray*,v2ray*,sing*,smartdns}
#rm -rf feeds/packages/utils/v2dat
rm -rf feeds/kenzo/mihomo


#增加插件

git clone https://github.com/KFERMercer/luci-app-tcpdump.git package/luci-app-tcpdump
#git clone https://github.com/sbwml/packages_lang_golang -b 25.x feeds/packages/lang/golang
git clone https://github.com/kenzok8/golang -b 1.26 feeds/packages/lang/golang
git clone https://github.com/oceanromain/luci-app-pushbot.git package/luci-app-pushbot

# 2026-09-14 pin gn to immortalwrt-verified 2026-01-14: helloworld/small ship gn 2026-09-02
# whose new starlark edit_subcommands.cc fails on clang-18 (lambda->Result<function> conversion)
for GN_MK in $(find feeds -path '*gn/Makefile' 2>/dev/null | grep -E '/(helloworld|small)/gn/Makefile'); do
  echo "pin gn to 2026-01-14 in $GN_MK"
  sed -i -E 's|^PKG_SOURCE_DATE:=.*|PKG_SOURCE_DATE:=2026-01-14|' "$GN_MK"
  sed -i -E 's|^PKG_SOURCE_VERSION:=.*|PKG_SOURCE_VERSION:=103f8b437f5e791e0aef9d5c372521a5d675fabb|' "$GN_MK"
  sed -i -E 's|^PKG_MIRROR_HASH:=.*|PKG_MIRROR_HASH:=e6d7fe0f41fbb64f3a5d96d32fdffcc4ad965e7de5ff29aa1439f8a279f167e0|' "$GN_MK"
  grep -E 'PKG_SOURCE_DATE|PKG_SOURCE_VERSION|PKG_MIRROR_HASH' "$GN_MK"
done
if ! find feeds -path '*gn/Makefile' 2>/dev/null | grep -qE '/(helloworld|small)/gn/Makefile'; then
  echo "WARNING: gn Makefile not found, skip pin"
fi
