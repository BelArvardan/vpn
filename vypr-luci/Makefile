#
# Copyright (C) 2016 Promwad.com
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk
include $(INCLUDE_DIR)/kernel.mk

PKG_NAME:=vypr-luci
PKG_VERSION:=0.0.1
PKG_RELEASE:=1

include $(INCLUDE_DIR)/package.mk

define Package/luci-app-vypr
  SECTION:=luci
  CATEGORY:=LuCI
  SUBMENU:=3. Applications
  DEPENDS:=+luci +openvpn-openssl +wget +unzip
  TITLE:=VyprVPN configuration module
  URL:=https://www.goldenfrog.com/vyprvpn
endef

define Package/luci-app-vypr/conffiles
/etc/config/vypr
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

define Package/luci-app-vypr/install
	$(INSTALL_DIR) $(1)/usr/lib/lua/luci/controller
	$(INSTALL_DATA) ./files/vyprctl.lua $(1)/usr/lib/lua/luci/controller/
	$(INSTALL_DIR) $(1)/usr/lib/lua/luci/model/cbi/vypr
	$(INSTALL_DATA) ./files/vypr.lua $(1)/usr/lib/lua/luci/model/cbi/vypr/
	$(INSTALL_DIR) $(1)/usr/lib/lua/luci/view
	$(INSTALL_DATA) ./files/public_ip_vypr.htm $(1)/usr/lib/lua/luci/view/
	$(INSTALL_DIR) $(1)/etc/config
	$(INSTALL_DATA) ./files/vypr.config $(1)/etc/config/vypr
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) ./files/vypr_download.sh $(1)/usr/bin/vypr_download.sh
	$(INSTALL_BIN) ./files/vypr_delete.sh $(1)/usr/bin/vypr_delete.sh
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/vypr.init $(1)/etc/init.d/vypr
	$(INSTALL_DIR) $(1)/etc/uci-defaults
	$(INSTALL_BIN) ./files/luci-vypr $(1)/etc/uci-defaults
	$(INSTALL_BIN) ./files/vyprvpn $(1)/etc/uci-defaults
	$(INSTALL_DIR) $(1)/www/luci-static/resources
	$(INSTALL_DATA) ./files/vypr.png $(1)/www/luci-static/resources
endef

$(eval $(call BuildPackage,luci-app-vypr))
