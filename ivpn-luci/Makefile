#
# Copyright (C) 2016 Promwad.com
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk
include $(INCLUDE_DIR)/kernel.mk

PKG_NAME:=ivpn-luci
PKG_VERSION:=0.0.1
PKG_RELEASE:=1

include $(INCLUDE_DIR)/package.mk

define Package/luci-app-ivpn
  SECTION:=luci
  CATEGORY:=LuCI
  SUBMENU:=3. Applications
  DEPENDS:=+luci +openvpn-openssl +wget +unzip
  TITLE:=IVPN configuration module
  URL:=https://www.ivpn.net/aff.php?aff=1471
endef

define Package/luci-app-ivpn/conffiles
/etc/config/ivpn
endef

define Package/luci-app-vypr/description
 This package contains a graphical interface for VyprVPN management on OpenWrt.
endef

define Build/Prepare
	mkdir -p $(PKG_BUILD_DIR)
endef

define Build/Compile/Default
endef

define Build/Compile
	$(call Build/Compile/Default)
endef

define Package/luci-app-ivpn/install
	$(INSTALL_DIR) $(1)/usr/lib/lua/luci/controller
	$(INSTALL_DATA) ./files/ivpnctl.lua $(1)/usr/lib/lua/luci/controller/
	$(INSTALL_DIR) $(1)/usr/lib/lua/luci/model/cbi/ivpn
	$(INSTALL_DATA) ./files/ivpn.lua $(1)/usr/lib/lua/luci/model/cbi/ivpn/
	$(INSTALL_DIR) $(1)/usr/lib/lua/luci/view
	$(INSTALL_DATA) ./files/public_ip.htm $(1)/usr/lib/lua/luci/view/
	$(INSTALL_DIR) $(1)/etc/config
	$(INSTALL_DATA) ./files/ivpn.config $(1)/etc/config/ivpn
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) ./files/ivpn.sh $(1)/usr/bin/ivpn.sh
	$(INSTALL_BIN) ./files/ivpn.png $(1)//www/luci-static/resources/ivpn.png
	$(INSTALL_BIN) ./files/check_openvpn.sh $(1)/usr/bin/check_openvpn.sh
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/ivpn.init $(1)/etc/init.d/ivpn
	$(INSTALL_DIR) $(1)/etc/uci-defaults
	$(INSTALL_BIN) ./files/luci-ivpn $(1)/etc/uci-defaults
	$(INSTALL_BIN) ./files/ivpn $(1)/etc/uci-defaults
	$(INSTALL_DIR) $(1)/etc
	$(INSTALL_BIN) ./files/rc.local $(1)/etc/rc.local
endef

$(eval $(call BuildPackage,luci-app-ivpn))
