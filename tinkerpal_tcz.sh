#!/bin/bash
# Create tinkerpal.tcz - All the required toolchains and BSPs for building
# TinkerPal based projects
# root dir provided at $1
# Requires tcztools - https://code.google.com/p/tcztools/
# Requires mksquashfs from squashfs-tools
if [ -z $1 ]; then
  echo "Usage $0 <root dir>";
  exit 1;
fi

tproot=$1
tp_src_dir=$tproot
tp_dst_dir=tinkerpal$tproot
pushd tmp
mkdir -p $tp_dst_dir
pushd $tp_dst_dir
echo "Creating the required links"
for d in sat stellarisware lm4tools stm32_f3; do
  ln -s $tp_src_dir/$d .
done
ls -l
popd
cp ../tinkerpal.tcz.info .
echo "Packing tinkerpal.tcz"
sudo tcz-pack tinkerpal
echo "Output file at /tmp/tcztools/tinkerpal.tcz"
popd
