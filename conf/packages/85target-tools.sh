PACKAGES+=" syslinux"
hset syslinux url "http://www.kernel.org/pub/linux/utils/boot/syslinux/syslinux-4.04.tar.bz2"
#hset syslinux depends "linux-modules"
hset syslinux phases "deploy"

compile-syslinux() {
	compile-generic \
		CC="$CC" LD="$LD" \
		CFLAGS="$CFLAGS" \
		LDFLAGS="$LDFLAGS_RLINK"
}

install-syslinux() {
	install-generic \
		CC="$CC" LD="$LD" \
		CFLAGS="$CFLAGS" \
		LDFLAGS="$LDFLAGS_RLINK"
}

deploy-syslinux() {
	deploy echo Done
}

PACKAGES+=" targettools"
hset targettools url "none"
hset targettools dir "."
hset targettools destdir "$STAGING_USR"
hset targettools tools "all"
hset targettools depends "syslinux"

configure-targettools() {
	configure echo Done
}
compile-targettools() {
	local tools=$(hget targettools tools)
	local ldflags=$(hget targetools ldflags)
	compile-generic \
		-C $CONF_BASE/target-tools \
		STAGING="$STAGING_USR" \
		LDFLAGS="$LDFLAGS_BASE $ldflags" \
		TOOLS="$tools"
}
install-targettools() {
	log_install echo Done
}
deploy-targettools() {
	local tools=$(hget targettools tools)
	deploy make \
		-C $CONF_BASE/target-tools \
		STAGING="$STAGING_USR" \
		ROOT="$ROOTFS" \
		TOOLS="$tools" \
		deploy
}

