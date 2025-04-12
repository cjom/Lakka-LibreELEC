PKG_NAME="mame"
PKG_VERSION="d087eb20c521943155612420c900b501f302194b"
PKG_LICENSE="MAME"
# PKG_ARCH="x86_64 aarch64 i386"
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

  # remove bfm* drivers to save space
  find src/mame/bfm/ -type f | xargs grep -e 'GAME(\|GAMEL' | cut -f 2 -d "," | sort -bu | tr -d "[:blank:]" > games.list
  find src/mame/bfm/ -type f | xargs sed -i '/GAME[L]*(/d'
  # remove skeleton drivers to save space
  find src/mame/ -type f | xargs grep -e 'MACHINE_IS_SKELETON\|MACHINE_MECHANICAL\|MACHINE_FLAGS_MECHANICAL' | grep -v 'define' | grep -v 'setname' | cut -f 1 -d ":" | sort -u > machines1.list
  find src/mame/ -type f | xargs grep -e 'MACHINE_IS_SKELETON\|MACHINE_MECHANICAL\|MACHINE_FLAGS_MECHANICAL' | grep -v 'define' | grep -v 'setname' | cut -f 2 -d "," | sort -bu | tr -d "[:blank:]" >> games.list
  cat machines1.list | while read file ; do sed -i '/define.*MACHINE_IS_SKELETON/p;/setname.*MACHINE_IS_SKELETON/p;/MACHINE_IS_SKELETON/d' $$file ; done
  # do not remove '#define GAME_FLAGS' and other definition lines
  cat machines1.list | while read file ; do sed -i '/define.*MACHINE_MECHANICAL/p;/setname.*MACHINE_MECHANICAL/p;/MACHINE_MECHANICAL/d' $$file ; done
  cat machines1.list | while read file ; do sed -i '/define.*MACHINE_FLAGS_MECHANICAL/p;/setname.*MACHINE_FLAGS_MECHANICAL/p;/MACHINE_FLAGS_MECHANICAL/d' $$file ; done
  # remove remaining MECHANICAL games using 'GAME_FLAGS' label
  find src/mame/ -type f | xargs grep -e 'GAME_FLAGS.*MACHINE_MECHANICAL' | cut -f 1 -d ":" | sort -u > machines2.list
  cat machines2.list | while read file ; do grep 'GAME_FLAGS' $$file | grep -v 'define' | grep -v 'setname' | cut -f 2 -d "," | sort -bu | tr -d "[:blank:]" >> games.list; done
  cat machines2.list | while read file ; do sed -i '/define GAME_FLAGS/p;/setname.*GAME_FLAGS/p;/GAME_FLAGS/d' $$file ; done
        # remove remaining MECHANICAL games using 'GAME_CUSTOM' label
        find src/mame/ -type f | xargs grep -e 'GAME_CUSTOM' | cut -f 1 -d ":" | sort -u > machines3.list
        cat machines3.list | while read file ; do grep 'GAME_CUSTOM' $$file | grep 'CRC' | grep 'SHA' | cut -f 2 -d "," | sort -bu | tr -d "[:blank:]" >> games.list; done
  # Remove reference to skeleton|mechanical drivers in mame.lst
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
