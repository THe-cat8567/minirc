#!/bin/sh

case "$1" in
	-p*|p*)
		kill -s USR1 1
		;;
	-r*|r*)
		kill -s INT 1
		;;
	*)
		echo "shutdown: -p[oweroff]|-r[eboot]"
		;;
esac
