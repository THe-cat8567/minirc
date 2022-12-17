#!/bin/sh
if [ "$1" != --force ]; then
    echo "Please read the setup script and confirm that it doesn't break your system."
    exit 1
fi

[ -z "$ROOT" ] && ROOT=
BUSYBOX_CMDS="init halt poweroff reboot runsv runsvdir sv svc svok"

if [ "$2" == --uninstall ]; then
	rm -rfv /etc/init.d /etc/inittab

	# seldom is /sbin/shutdown a .sh script unless it was installed by minirc
	if file "$ROOT"/sbin/shutdown | grep -q 'shell script'; then
		rm -fv "$ROOT"/sbin/shutdown
	fi

	for i in "$BUSYBOX_CMDS"; do
		if [ $(basename $(readlink $i)) == busybox ]; then
			rm -fv $i
		else
			echo "$i is not a symlink to busybox, not removing"
		fi
	exit 0	
fi	

echo "==> Installing /etc/init.d /etc/init.d/rc /etc/init.d/rc.local /etc/init.d/rc.shutdown /etc/inittab /etc/init.d/services"
mkdir -pv /etc/init.d/services
install -Dm755 rc "$ROOT"/etc/init.d/
install -Dm755 rc.local "$ROOT"/etc/init.d/
install -Dm755 rc.shutdown "$ROOT"/etc/init.d/
install -Dm644 inittab "$ROOT"/etc/inittab

echo "==> Installing shutdown.sh"
install -Dm755 shutdown.sh "$ROOT/sbin/shutdown"

echo "==> Linking busybox to /sbin/{init,halt,poweroff,reboot, runsv, runsvdir, sv, svc, svok}"
for i in "$BUSYBOX_CMDS"; do
    ln -sf $(which busybox) "$ROOT"/sbin/$i
done

# Run "./setup.sh --force [--uninstall]" to use the script
