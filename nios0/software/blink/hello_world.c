/*
 * "Hello World" example.
 *
 * This example prints 'Hello from Nios II' to the STDOUT stream. It runs on
 * the Nios II 'standard', 'full_featured', 'fast', and 'low_cost' example
 * designs. It runs with or without the MicroC/OS-II RTOS and requires a STDOUT
 * device in your system's hardware.
 * The memory footprint of this hosted application is ~69 kbytes by default
 * using the standard reference design.
 *
 * For a reduced footprint version of this template, and an explanation of how
 * to reduce the memory footprint for a given application, see the
 * "small_hello_world" template.
 *
 */

#include <stdio.h>
#include <unistd.h>
#include <stdint.h>

#include "altera_avalon_pio_regs.h"
#include "system.h"

int main()
{
	printf("Hello from Nios II!\n");

	uint8_t chen = 1;

	while(1)
	{
		IOWR_ALTERA_AVALON_PIO_DATA(PIO_0_BASE, chen);
		if (chen == 0x80)
		{
			chen = 1;
		}
		else
		{
			chen <<= 1;
		}

		usleep(100000);
	}

	return 0;
}
