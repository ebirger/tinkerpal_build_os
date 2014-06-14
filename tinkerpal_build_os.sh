#!/bin/bash

corelinux_base=http://www.tinycorelinux.net/4.x/x86

mkdir -p .mkcache

function fetch()
{
    file=.mkcache/$(basename $1)
    if [ ! -f $file ] ; then
        echo "Fetching $(basename $file)";
        wget $1 -q -O $file.part;
        mv $file.part $file
    fi
}

function install_package()
{
    fetch $1;
    cp .mkcache/$(basename $1) isoimage/cde/optional
    echo $(basename $1) >> isoimage/cde/onboot.lst
}

# Fetch ISO
iso=$corelinux_base/release/TinyCore-current.iso
fetch $iso

# Extract ISO
echo "Extracting Core Linux ISO"
echo "-------------------------"
mkdir -p mnt
mount -o loop .mkcache/TinyCore-current.iso mnt
rm -rf isoimage
mkdir -p isoimage
cp -r mnt/* isoimage
umount mnt

# Add additional packages
echo "Fetching required packages"
echo "--------------------------"

# each '<' denotes a dependency lever to the upper packages
corelinux_tcz=$corelinux_base/tcz
# Configure
install_package $corelinux_tcz/pkg-config.tcz
install_package $corelinux_tcz/popt.tcz # <
install_package $corelinux_tcz/glib2.tcz # <
install_package $corelinux_tcz/libffi.tcz # <<
install_package $corelinux_tcz/m4.tcz
install_package $corelinux_tcz/sed.tcz
install_package $corelinux_tcz/bison.tcz
install_package $corelinux_tcz/flex.tcz
# Build
install_package $corelinux_tcz/gcc-3.3.6.tcz
install_package $corelinux_tcz/gcc.tcz
install_package $corelinux_tcz/gcc_libs.tcz # <
install_package $corelinux_tcz/binutils.tcz # <
install_package $corelinux_tcz/libmpc.tcz # <<
install_package $corelinux_tcz/mpfr.tcz # <<<
install_package $corelinux_tcz/gmp.tcz # <<<<
install_package $corelinux_tcz/make.tcz
# Libc
install_package $corelinux_tcz/linux-3.0.1_api_headers.tcz
install_package $corelinux_tcz/eglibc_base-dev.tcz
# ncurses
install_package $corelinux_tcz/ncurses-dev.tcz
install_package $corelinux_tcz/ncurses.tcz # <
install_package $corelinux_tcz/ncurses-common.tcz # <<
# Runtime
install_package $corelinux_tcz/gperf.tcz
install_package $corelinux_tcz/screen.tcz
# Git
install_package $corelinux_tcz/git.tcz
install_package $corelinux_tcz/openssl-1.0.0.tcz # <
# Burn
install_package $corelinux_tcz/libusb-dev.tcz
install_package $corelinux_tcz/libusb.tcz

# Repackage ISO
echo "Repackaging"
echo "-----------"
bootdir=boot/isolinux
mkisofs -J -r -o image.iso -b $bootdir/isolinux.bin -c $bootdir/boot.cat -no-emul-boot -boot-load-size 4 -boot-info-table isoimage
