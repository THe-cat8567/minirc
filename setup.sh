#!/bin/sh
if [ "$1" != --force ]; then
    echo "Please read the setup script and confirm that it doesn't break your system."
    exit 1
fi

[ -z "$ROOT" ] && ROOT=

echo "==> Installing /etc/init.d/rc /etc/inittab /etc/init.d/services"
mkdir -pv /etc/init.d/services
install -Dm755 rc "$ROOT"/etc/init.d/
install -Dm644 inittab "$ROOT"/etc/inittab

echo "==> Installing shutdown.sh"
install -Dm755 shutdown.sh "$ROOT/sbin/shutdown"

echo "==> Linking busybox to /sbin/{init,halt,poweroff,reboot}"
for i in init halt poweroff reboot runsv runsvdir; do
    ln -sf $(which busybox) "$ROOT"/sbin/$i
done

echo ":: Append 'init=/sbin/init' to your kernel line in your bootloader"
echo "   to replace your current init with minirc"

# Run "./setup.sh --force" to use the script
