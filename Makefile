#
# Copyright (C) 2019 Xingwang Liao
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=frp
PKG_VERSION:=0.37.0
PKG_RELEASE:=1

PKG_SOURCE_PROTO:=git
PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://github.com/fatedier/frp.git
PKG_SOURCE_SUBDIR:=$(PKG_NAME)-$(PKG_VERSION)
PKG_SOURCE_VERSION:=cfd1a3128aa81e0a6c1103c1f2cbed345aa858de
PKG_MIRROR_HASH:=c5797e2087583877fb5a0ecf06ecb28b69a4bbfadfa57b2e384ae172b29b06e6

PKG_LICENSE:=Apache-2.0
PKG_LICENSE_FILES:=LICENSE
PKG_MAINTAINER:=Xingwang Liao <kuoruan@gmail.com>

PKG_BUILD_DEPENDS:=golang/host
PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_SOURCE_SUBDIR)
PKG_BUILD_PARALLEL:=1
PKG_USE_MIPS16:=0

GO_PKG:=github.com/fatedier/frp
GO_PKG_BUILD_PKG:=github.com/fatedier/frp/cmd/...

GO_PKG_LDFLAGS:=-s -w

include $(INCLUDE_DIR)/package.mk
include $(TOPDIR)/feeds/packages/lang/golang/golang-package.mk

define frp/templates
  define Package/$(1)
    TITLE:=A fast reverse proxy ($(1))
    URL:=https://github.com/fatedier/frp
    SECTION:=net
    CATEGORY:=Network
    SUBMENU:=Web Servers/Proxies
    DEPENDS:=$$(GO_ARCH_DEPENDS)
  endef

  define Package/$(1)/description
  frp is a fast reverse proxy to help you expose a local server behind a NAT or firewall
  to the internet. As of now, it supports tcp & udp, as well as httpand https protocols,
  where requests can be forwarded to internal services by domain name.

  This package contains the $(1).
  endef

  define Package/$(1)/install
	$$(call GoPackage/Package/Install/Bin,$$(PKG_INSTALL_DIR))

	$$(INSTALL_DIR) $$(1)/usr/bin
	$$(INSTALL_BIN) $$(PKG_INSTALL_DIR)/usr/bin/$(1) $$(1)/usr/bin/
	
	$(STAGING_DIR_HOST)/bin/upx --lzma --best $$(1)/usr/bin/$(1) || true
	$$(INSTALL_DIR) $$(1)/etc
	$$(INSTALL_DIR) $$(1)/etc/init.d
	$$(INSTALL_BIN) ./files/$(1) $$(1)/etc/init.d/$(1)
  endef
endef

FRP_COMPONENTS:=frpc frps

$(foreach component,$(FRP_COMPONENTS), \
  $(eval $(call frp/templates,$(component))) \
  $(eval $(call GoBinPackage,$(component))) \
  $(eval $(call BuildPackage,$(component))) \
)
