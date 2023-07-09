#include <stdio.h>
#include <fcntl.h>
#include <linux/fb.h>
#include <sys/mman.h>
#include <sys/ioctl.h>
#include <stdlib.h>
#include <errno.h>
#include <stdint.h>
#include <string.h>

/* Frame buffer code we're not going to try putting in assembly */
int fb_fd = -1;
uint64_t fbsize = 0;

void _getscreeninfo(struct fb_var_screeninfo* screen_info_mem, uint64_t buffer_number)
{
	/* sanity check */
	if (buffer_number > 99) {
		return;
	}
	/* Default option - fb0 */
	if (buffer_number == 0) {
		fb_fd = open("/dev/fb0", O_RDWR);
	} else {
		char fb_str[10];
		sprintf(fb_str, "/dev/fb%d", buffer_number);
		fb_fd = open(fb_str, O_RDWR);
	}
	if (fb_fd < 0) {
		printf("Failed to open, errno is %d\n", errno);
		exit(1);
	}

	/* Now populate structure */
	if (ioctl(fb_fd, FBIOGET_VSCREENINFO, screen_info_mem)) {
		printf("VSCREENINFO ioctl call failed.\n");
		exit(2);
	}
	printf("Operating on %d\n", screen_info_mem);
	return;
}

uint64_t* _memmapfb(struct fb_var_screeninfo* screen_info_mem, uint64_t* address)
{
	printf("Operating on %d\n", screen_info_mem);
	/* Calculate size of framebuffer */
	fbsize = screen_info_mem->xres * screen_info_mem->yres *
		(screen_info_mem->bits_per_pixel / 8);

	/* now memmap */
	address = mmap(0, fbsize, PROT_READ|PROT_WRITE, MAP_SHARED,
		fb_fd, 0);
	if ((uint64_t)address == 0xFFFFFFFFFFFFFFFF) {
		printf("Frame buffer memory mapping failed: errno %d\n", errno);
		exit(3);
	}
	return address;
}

void _clearfb(uint64_t* address)
{
	memset(address, 0x0, fbsize);
}

