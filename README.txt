This Makefile can be used to build a pine64 u-boot with included crust
firmware  The toolchains can be downloaded from https://musl.cc/ or just
by running `make toolchains`. Make sure you export the paths if needed.
Also edit the variables on top of the Makefile if necessary.

u-boot can be flashed with:

	dd if=u-boot.bin of=/dev/mmcblk0 seek=8 bs=1024

boot.txt can be compiled with:

	mkimage -C none -A arm -T script -d boot.txt boot.scr
