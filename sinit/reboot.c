#include <sys/reboot.h>

int main(void)
{
	reboot(RB_AUTOBOOT);
	return 0;
}
