minirc - minimalistic init setup
===============================

A set of rc scripts for busybox init or sinit. It should also work with runit, s6, or dinit (though dinit isnt really meant
for single rc.sysinit style scripts), given you modify the setup procedure. Please read all files in shared/ to make sure they
do what you want.

Installing
----------

Dependencies: busybox or sinit, optionally eudev or systemd (for udev)

1. Run the setup.sh script with the proper options.

2. Remove "init=..." from your kernel parameters (if it is there) so that the
   default value "init=/sbin/init" is used.  Check the docs of your boot loader
   on how to change the kernel parameters.

3. Reboot


Shutdown & Reboot
-----------------

For sinit, USR1 is poweroff, INT is reboot, do NOT run the commands `poweroff` or `reboot` directly, they
will not unmount the filesystems cleanly or do anything except issue the reboot() syscall.

For busybox, you can just run `poweroff` or `reboot`. Or you can signal, USR2 for poweroff, TERM for reboot.
NOTE: halt and shutdown do not appear to power down the device at the ACPI level, use poweroff instead.


Dealing with services
---------------------

It's good practice to put service related code in /etc/rc/rc.local, feel free to use a process supervisor or whatever you want.


Further configuration
---------------------

1. udev

   You need to decide what to use to set up the devices and load the modules.
   minirc supports busybox's mdev, systemd's udev, and a fork of udev, eudev,
   by default.

   eudev and systemd's udev work out of the box, so they are recommended.  To
   set up mdev, you can use this as a reference:
   https://github.com/slashbeast/mdev-like-a-boss.

2. Local startup script

   Minirc will fork (i.e. use `&` in sh) /etc/rc/rc.local on boot if the file exists and has the
   executable bit set. This allows the user to run commands in addition to the
   basic startup that minirc provides. This is a good place to load modules if
   udev does not detect that they should be loaded on boot. 

3. Local shutdown script

   Minirc will run /etc/rc/rc.shutdown.local and wait for it to return 
   before shutting down if the file exists and has the 
   executable bit set. This allows the user to run commands before minirc kills all processes and
   unmounts the filesystems. This is a good place to shutdown "sensitive" programs that might take
   a while to shutdown properly (e.g. databases).


About
-----

* Authors: Roman Zimbelmann, Sam Stuewe
* License: GPL2


