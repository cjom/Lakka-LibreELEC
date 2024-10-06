PKG_NAME="stella2014"
PKG_VERSION="db6bee857f73138ae02755bf09e392b31fef4540"
PKG_LICENSE="GPLv2"
PKG_SITE="https://github.com/libretro/stella2014-libretro"
PKG_URL="${PKG_SITE}.git"
PKG_DEPENDS_TARGET="toolchain"
PKG_LONGDESC="Port of Stella to libretro."
PKG_TOOLCHAIN="make"

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/lib/libretro
    cp -v stella2014_libretro.so ${INSTALL}/usr/lib/libretro/
}
