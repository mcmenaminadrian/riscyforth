#include <stdio.h>
#include <fcntl.h>
#include <linux/fb.h>
#include <sys/mman.h>
#include <sys/ioctl.h>
#include <stdlib.h>

/* Frame buffer code we're not going to try putting in assembly */

void _getscreeninfo(unsigned char* screen_info_mem)
{
	int fbfd;

	/* Open video memory first */
	if ((fbfd = open("/dev/fb0", O_RDWR)) < 0) {
		printf("Could not access video memory.\n");
		exit(1);
	}

	/* Now populate structure */
	if (ioctl(fbfd, FBIOGET_VSCREENINFO, &screen_info_mem)) {
		printf("VSCREENINFO ioctl call failed.\n");
		exit(2);
	}
	return;
}
		
