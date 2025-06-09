# Define the package information
include $(TOPDIR)/rules.mk

PKG_NAME:=luci-app-mttl
PKG_VERSION:=1.2.b1
PKG_RELEASE:=2

PKG_MAINTAINER:=dotycat <support@dotycat.com>
PKG_LICENSE:=GPL-3.0

LUCI_TITLE:=TTL Changer
LUCI_DESCRIPTION:=This LuCI app provides TTL changer functionality in a web interface.
LUCI_DEPENDS:=+luci +nftables

PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)

include $(INCLUDE_DIR)/package.mk

define Package/$(PKG_NAME)
	SECTION:=luci
	CATEGORY:=LuCI
	SUBMENU:=3. Applications
	TITLE:=$(LUCI_TITLE)
	PKGARCH:=all
	DEPENDS:=$(LUCI_DEPENDS)
endef

define Package/$(PKG_NAME)/description
	$(LUCI_DESCRIPTION)
endef

define Build/Compile
endef

# Files to install
define Package/$(PKG_NAME)/install
	$(CP) ./files/* $(1)/
endef

# Build the package
$(eval $(call BuildPackage,$(PKG_NAME)))
