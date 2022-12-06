minirc - minimalistic rc script
===============================

The script "rc" is a minimalistic init script made for use with busybox init.
It handles one time system initialization. You should customize the "rc" script
to your needs, at a minimum by changing the timezone if your timezone is not America/Los Angeles.

It was developed for arch linux to get rid of systemd, but it can probably run
on other distributions as well.

The "rc" script should also work as "1" for runit. 


Installing
----------

Dependencies: busybox, optionally eudev or systemd (for udev)

NOTE: The archlinux AUR package does step 1 for you.

1. There is a setup.sh script, but you should read it first.  If you don't use
   a package manager which does the sanity checks for you, please check for
   yourself that it doesn't break your system by overwriting essential files.
   Make backups as needed.

   When you are confident, run "./setup.sh --force"

2. Remove "init=..." from your kernel parameters (if it is there) so that the
   default value "init=/sbin/init" is used.  Check the docs of your boot loader
   on how to change the kernel parameters.

3. Reboot


Shutdown & Reboot
-----------------

You need to use busybox's version of the reboot command by either typing in
"busybox reboot" or by linking busybox to /bin/reboot and executing it.
The same goes for "halt" and "poweroff". NOTE: halt and shutdown do not appear to power down
the device at the ACPI level, use poweroff instead.

You can alternatively send the signals TERM for reboot, USR1 for halt or USR2
for poweroff to the process 1.


Dealing with services
---------------------

The original minirc was able to deal with services, this feature was removed to simplify the
"rc" script. If you want to manage services using a dedicated service manager such
as daemontools[-encore], runsv, or s6 is ideal. For example to add support for svscan from daemontools
you could add the following to the end of "rc".

```
# /etc/init.d/services is the directory where services are stored
# /run/services is where the services are copied to in order to have a clean state every reboot
mkdir -p /run/services
cp -r /etc/init.d/services /run/services
exec svscan /run/services
```

However for most desktop purposes a service manager is overkill and just using /etc/init.d/rc.local
should suffice.

In order to create a sort of network dependency for services that need internet access the following
can be added to rc.local.

```
while ! ping -c 1 example.com ; do sleep 1 ; done
# NETWORK DEPENDENT SERVICES GO HERE
/usr/bin/ntpd -q -n -g -u ntp:ntp # example ntpd service
```


Further configuration
---------------------

1. udev

   You need to decide what to use to set up the devices and load the modules.
   minirc supports busybox's mdev, systemd's udev, and a fork of udev, eudev,
   by default.  You can change the udev system by writing UDEV=busybox,
   UDEV=systemd, or UDEV=eudev respectively into /etc/minirc.conf.

   eudev and systemd's udev work out of the box, so they are recommended.  To
   set up mdev, you can use this as a reference:
   https://github.com/slashbeast/mdev-like-a-boss.

2. Local startup script

   Minirc will run /etc/init.d/rc.local on boot if the file exists and has the
   executable bit set. This allows the user to run commands in addition to the
   basic startup that minirc provides. This is a good place to load modules if
   udev does not detect that they should be loaded on boot.

3. Local shutdown script

   Minirc will run /etc/init.d/rc.shutdown before shutting down if the file exists and has the
   executable bit set. This allows the user to run commands before minirc kills all processes and
   umounts the filesystems. This is a good place to shutdown "sensitive" programs that might take
   a while to shutdown properly since init(8) will wait rc.shutdown to finish before continuing with
   the standard shutdown process.


About
-----

* Authors: Roman Zimbelmann, Sam Stuewe
* License: GPL2

Parts of the function on_boot() and the start/stop function of iptables were
taken from archlinux initscripts (http://www.archlinux.org).  I was unable to
determine the author or authors of those parts.

More information on the Arch Wiki: https://wiki.archlinux.org/index.php/Minirc

This fork was inspired by [void-runit](https://github.com/void-linux/void-runit) and primarily simplified the "rc" script along
with changing the location to a more init-y directory (/etc/init.d).
