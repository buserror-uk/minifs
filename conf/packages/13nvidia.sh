
NVIDIA_VERSION=260.19.44
NVIDIA_NAME=NVIDIA-Linux-x86-${NVIDIA_VERSION}
PACKAGES+=" nvidia"
hset nvidia url "http://us.download.nvidia.com/XFree86/Linux-x86/$NVIDIA_VERSION/$NVIDIA_NAME.run"
hset nvidia depends "xorgserver linux-modules"

setup-nvidia() {
	ROOTFS_KEEPERS+="libvdpau.so:"
	ROOTFS_KEEPERS+="libvcuvid.so:"
	ROOTFS_KEEPERS+="libnvidia-glcore.so.$NVIDIA_VERSION:"
	ROOTFS_KEEPERS+="libnvidia-compiler.so.$NVIDIA_VERSION:"
	ROOTFS_KEEPERS+="libnvidia-cfg.so.$NVIDIA_VERSION:"
	ROOTFS_KEEPERS+="libnvidia-tls.so.$NVIDIA_VERSION:"
}
uncompress-nvidia() {
	echo nvidia: $*
	sh $2 -x
}

configure-nvidia() {
	configure echo Configure nvidia
}

compile-nvidia-local() {
	( pushd $NVIDIA_NAME/kernel
		set -x
		$MAKE \
			NVDEBUG=1 \
			SYSOUT="$BUILD/linux-obj" \
			SYSSRC="$BUILD/linux" \
			CC=$GCC \
			HOST_CC=gcc \
				$1 || exit 1
	) || exit 1
}

compile-nvidia() {
	compile compile-nvidia-local module
}

install-nvidia-local() {
	set -x
	pushd $NVIDIA_NAME/
	mkdir -p "$BUILD"/kernel/lib/modules/$(hget linux version)/kernel/drivers/video/
	cp kernel/nvidia.ko "$BUILD"/kernel/lib/modules/$(hget linux version)/kernel/drivers/video/
	sh "$PATCHES/patches/nvidia/nvidia-minifs-installer.sh" >../._nvidia_install.sh
	DESTDIR="$STAGING_USR" installwatch -o ../._dist_$PACKAGE.log bash ../._nvidia_install.sh
	ln -sf libGL.so.1 "$STAGING_USR"/lib/libGL.so.1.2
	popd
	set +x
}

install-nvidia() {
	log_install install-nvidia-local
}

deploy-nvidia() {
	mkdir -p "$ROOTFS"/etc/X11
	deploy cp $(get_installed_binaries) \
		"$ROOTFS"/usr/bin/
}
