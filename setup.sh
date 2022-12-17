#!/bin/sh

[ -z "$DESTDIR" ] && DESTDIR=
[ -z "$PREFIX" ] && PREFIX=/usr/sbin
[ -z "$RC_DIR" ] && RC_DIR=/etc/rc
[ -z "$BUSYBOX_CMDS" ] && BUSYBOX_CMDS="init halt poweroff reboot"

RC_FILES="rc.init rc.functions rc.shutdown rc.local rc.shutdown.local"

usage() {
	echo "setup.sh: --force --install|--uninstall sinit|busybox"
}

if [ "$1" != --force ]; then
    echo "Please read the setup script and confirm that it doesn't break your system or destroy valuable data."
    echo "Then run it with --force as the first argument"
    usage
    exit 1
fi

case "$2" in
	--install|--uninstall)
		true
		;;
	*)
		usage
		exit 1
		;;
esac

case "$3" in
	sinit|busybox)
		true
		;;
	*)
		usage
		exit 1
		;;
esac

if [ $(id -u) != 0 ]; then
	echo "you must run this script as root"
	exit 1
fi

if [ "$2" == --install ]; then
	for i in $RC_FILES; do	
		install -Dm755 shared/"$i" "${DESTDIR}${RC_DIR}"/"$i"
	done
	
	if [ "$3" == sinit ]; then
		cc sinit/reboot.c -o sinit/reboot
		cc sinit/poweroff.c -o sinit/poweroff
		install -Dm755 sinit/reboot "${DESTDIR}${PREFIX}"/reboot
		install -Dm755 sinit/poweorff "${DESTDIR}${PREFIX}"/poweorff
		echo "Please make sure your sinit is configured to use $RC_DIR/rc.init and $RC_DIR/rc.shutdown with the parameters reboot and poweroff"
		echo "Otherwise your system will fail to boot!"
		exit 0
	fi

	if [ "$3" == busybox ]; then
		install -Dm644 busybox/inittab /etc/inittab
		for i in $BUSYBOX_CMDS; do
			ln -sfv $(which busybox) "${DESTDIR}${PREFIX}"/"$i"
		done
	fi	
fi

if [ "$2" == --uninstall ]; then
	for i in $RC_FILES; do
		rm -fv "$RC_DIR"/"$i"
	done
	# if the directory is not empty that means the user has made some changes
	if ! rmdir "$RC_DIR"; then
		echo "$RC_DIR" has some files this script did not install, please remove it manually
	fi

	if [ "$3" == sinit ]; then
		rm -fv "${DESTDIR}${PREFIX}"/reboot "${DESTDIR}${PREFIX}"/poweroff
	fi

	if [ "$3" == busybox ]; then
		rm -fv /etc/inittab
		for i in $BUSYBOX_CMDS; do
			if [ $(basename $(readlink "${DESTDIR}${PREFIX}"/"$i")) = busybox ]; then
				rm -fv "${DESTDIR}${PREFIX}"/"$i"
			else
				echo $i is not a link to busybox, not removing
			fi
		done
	fi
fi
