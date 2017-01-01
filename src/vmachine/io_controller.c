/*
 * io_controller.c
 *
 *  Created on: 19/12/2016
 *      Author: Miguel
 */
#include <mti.h>
#include <stdio.h>
#include "../vmachine/io_controller.h"
#include "../vmachine/address_space.h"
#include "../vmachine/defines.h"
#include "../vmachine/signal_conv.h"
#include "../vmachine/tinycthread/tinycthread.h"
#include "../vmachine/utils.h"

typedef struct {
	mtiSignalIdT clk;
	mtiDriverIdT int_en;
	mtiDriverIdT int_id;
	mtiDriverIdT int_type;
	mtiSignalIdT int_ack;
} ioctrl_t;

ioctrl_t * ip;

#define ALIGN_IOADDR(phys_addr) (phys_addr - IOSPACE)

char io_rd_dispatch_ret[MAX_INTEGER_SIZE+1];

volatile char io_controller_closing = 0;
volatile char is_ack = 0;

typedef struct iodev {
	int (*init)(void*);
	void (*deinit)(void);
	char (*write)(uint32_t local_ioaddr, uint64_t data, uint8_t access_width);
	uint64_t (*read)(uint32_t local_ioaddr, uint8_t access_width);
	const int space_addr;
	const int space_len;
} iodev_t;

iodev_t devices[] = {
	{timer_init, timer_deinit, timer_write, timer_read, 0, TIMER_IOSPACE}, /* Create Timer Device */
	{vga_init, vga_deinit, vga_write, vga_read, TIMER_IOSPACE, LINEAR_FRAMEBUFFER_SIZE}, /* Create VGA Device */
};

thrd_t io_threads[IODEVICE_COUNT];

char io_controller_init(void) {
	for(int i = 0; i < IODEVICE_COUNT; i++)
		if(thrd_create(&io_threads[i], devices[i].init, (void*)i) != thrd_success)
			return 0;
	return 1;
}

void io_controller_on_clk(void * param) {
	_Bool clk = sig_to_int(ip->clk);
	if(!clk) {
		mti_ScheduleDriver(ip->int_en, 2, 1, MTI_INERTIAL);
	} else {
		is_ack = sig_to_int(ip->int_ack);
	}
}

void io_controller_init_vhd(
	mtiRegionIdT region,
	char * param,
	mtiInterfaceListT * generics,
	mtiInterfaceListT * ports
) {
	ip           = (ioctrl_t *)mti_Malloc(sizeof(ioctrl_t));
	ip->clk      = mti_FindPort(ports, "clk");
	ip->int_en   = mti_CreateDriver(mti_FindPort(ports, "int_en"));
	ip->int_id   = mti_CreateDriver(mti_FindPort(ports, "int_id"));
	ip->int_type = mti_CreateDriver(mti_FindPort(ports, "int_type"));
	ip->int_ack  = mti_FindPort(ports, "int_ack");

	mtiProcessIdT io_proc_onclk = mti_CreateProcess("ioctrl_p_onclk", io_controller_on_clk, ip);
	mti_Sensitize(io_proc_onclk, ip->clk, MTI_EVENT);
}

char io_controller_deinit(void) {
	for(int i = 0; i < IODEVICE_COUNT; i++)
		devices[i].deinit();
	io_controller_closing = 1;
	for(int i = 0; i < IODEVICE_COUNT; i++)
		thrd_join(&io_threads[i], 0);
	return 1;
}

char io_wr_dispatch(uint32_t phys_addr, uint64_t data, uint8_t access_width) {
	uint32_t ioaddr = ALIGN_IOADDR(phys_addr);
	for(int i = 0; i < IODEVICE_COUNT; i++)
		if(ioaddr >= devices[i].space_addr && ioaddr < devices[i].space_addr + devices[i].space_len)
			return devices[i].write(ioaddr - devices[i].space_addr, data, access_width);
	return 1;
}

char * io_rd_dispatch(uint32_t phys_addr, uint8_t access_width) {
	uint32_t ioaddr = ALIGN_IOADDR(phys_addr);
	uint64_t ret = (uint64_t)-1;
	for(int i = 0; i < IODEVICE_COUNT; i++)
		if(ioaddr >= devices[i].space_addr && ioaddr < devices[i].space_addr + devices[i].space_len) {
			ret = devices[i].read(ioaddr - devices[i].space_addr, access_width);
			break;
		}

	int2bin64(ret, io_rd_dispatch_ret, 64);

	for(int i = 0; i < MAX_INTEGER_SIZE; i++)
		io_rd_dispatch_ret[i] = (io_rd_dispatch_ret[i]-'0') + 2;
	io_rd_dispatch_ret[MAX_INTEGER_SIZE] = 0;
	return io_rd_dispatch_ret;
}

char io_irq(uint8_t devid, enum INTERRUPT_TYPE type) {
	/* TODO: Since this function can be called from multiple threads, we must implement queueing for IRQ servicing */

	printf("\n> **** INTERRUPT (%s @ %d) ****\n", (type == INT_ERR) ? "EXC" : "IRQ", devid);
	fflush(stdout);

	mti_ScheduleDriver(ip->int_en,   3, 1, MTI_INERTIAL);
	mti_ScheduleDriver(ip->int_id,   (long)int_to_sigv(devid, 8), 1, MTI_INERTIAL);
	mti_ScheduleDriver(ip->int_type, (long)int_to_sigv(type,  2), 1, MTI_INERTIAL);

	/* This function should block the thread, and should only continue once the IRQ has been acknowledged */
	while(!is_ack)
		SDL_Delay(10);

	return 1;
}