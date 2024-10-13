PKG_NAME="mame"
PKG_VERSION="4ee35952a8fdb1332e970fa14c3e79c8c968050c"
# PKG_ARCH="aarch64 x86_64"
PKG_LICENSE="MAME"
PKG_SITE="https://github.com/libretro/mame"
PKG_URL="${PKG_SITE}.git"
PKG_DEPENDS_TARGET="toolchain expat zlib flac sqlite"
PKG_LONGDESC="MAME - Multiple Arcade Machine Emulator"
PKG_TOOLCHAIN="make"

PKG_MAKE_OPTS_TARGET="-f Makefile.libretro REGENIE=1 VERBOSE=1 NOWERROR=1 OPENMP=0 CROSS_BUILD=1 TOOLS=0 RETRO=1 PYTHON_EXECUTABLE=python3 CONFIG=libretro LIBRETRO_OS=unix TARGET=mame SUBTARGET=arcade OSD=retro USE_SYSTEM_LIB_EXPAT=1 USE_SYSTEM_LIB_ZLIB=1 USE_SYSTEM_LIB_FLAC=1 USE_SYSTEM_LIB_SQLITE3=1 LIBRETRO_CPU= ARCH= PROJECT="

case ${ARCH} in
  x86_64)
    PKG_MAKE_OPTS_TARGET+=" NOASM=0 PTR64=1 PLATFORM=x86_64"
    ;;
  i386)
    PKG_MAKE_OPTS_TARGET+=" NOASM=0 PTR64=0 PLATFORM=x86"
    ;;
  aarch64)
    PKG_MAKE_OPTS_TARGET+=" NOASM=0 PTR64=0 PLATFORM=arm64"
    ;;
  arm)
    PKG_MAKE_OPTS_TARGET+=" NOASM=1 PTR64=0 PLATFORM=arm"
    ;;
esac

pre_make_target() {
  PKG_MAKE_OPTS_TARGET+=" OVERRIDE_CC=${CC} OVERRIDE_CXX=${CXX} OVERRIDE_LD=${LD}"
  sed -i scripts/genie.lua \
      -e 's|-static-libstdc++||g'
  # remove skeleton drivers to save space
  find src/mame/ -type f | xargs grep MACHINE_IS_SKELETON | cut -f 1 -d ":" | sort -u > machines.list
  find src/mame/ -type f | xargs grep MACHINE_IS_SKELETON | cut -f 2 -d "," | sort -bu > games.list
  cat machines.list | while read file ; do sed -i '/MACHINE_IS_SKELETON/d' $$file ; done
  cat games.list | while read file ; do sed -i /$$file/d src/mame/mame.lst ; done
}

make_target() {
  unset DISTRO
  make ${PKG_MAKE_OPTS_TARGET}
}

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/lib/libretro
    cp -v mamearcade_libretro.so ${INSTALL}/usr/lib/libretro/

  mkdir -p ${INSTALL}/usr/share/retroarch/system/mame
    cp -vr artwork samples ${INSTALL}/usr/share/retroarch/system/mame
}
