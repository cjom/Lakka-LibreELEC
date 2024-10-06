# SPDX-License-Identifier: GPL-3.0-or-later
# 2021 Giovanni Cascione

PKG_NAME="cec_mini_kb"
PKG_VERSION="fea75efa52e73b1fc70750e308b153cfba84696f"
PKG_LICENSE="GPLv3"
PKG_SITE="https://github.com/spleen1981/cec-mini-kb"
PKG_URL="${PKG_SITE}/archive/${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain libcec"
PKG_LONGDESC="Small utility to use a CEC remote controller as a mini keyboard"
PKG_TOOLCHAIN="make"

makeinstall_target() {
  mkdir -p $INSTALL/usr/bin/
  cp -v cec-mini-kb ${INSTALL}/usr/bin/
}

post_install() {
  enable_service cec-mini-kb.service
}
