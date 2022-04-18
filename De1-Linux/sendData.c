/*
 * Test.c
 *
 *  Created on: Mar 15, 2022
 *      Author: Dylan Painter
 *        IMPORTANT <<<<<---------------------------------------------------------------------------------------------------------------------<<<<<<
 *        Modified from: https://github.com/Jambie82/CycloneV_HPS_FIFO commandOne.c
 */
///////////////////////////////////////
// commandOne
// this sends a 4 (32bit) word command thru an block transfer FIFO
//  from the HPS to the FPGA, then receives a 4 word response with the same data
//
// compiled in Eclipse using the arm9-linux-gnueabihf-gcc compiler
///////////////////////////////////////
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <unistd.h>
#include <fcntl.h>
#include <sys/types.h>
#include <sys/ipc.h>
#include <sys/shm.h>
#include <sys/mman.h>
#include <sys/time.h>
#include <math.h>
#include <getopt.h>
#include <unistd.h>

#include <stdint.h>

// main bus; scratch RAM
// used only for testing
#define FPGA_ONCHIP_BASE      0xC8000000
#define FPGA_ONCHIP_SPAN      0x00001000

// main bus; FIFO write address
#define FIFO_BASE            0xC0000000
#define FIFO_SPAN            0x00001000
// the read and write ports for the FIFOs
// you need to query the status ports before these operations
// PUSH the write FIFO
// POP the read FIFO
#define FIFO_WRITE             (*(FIFO_write_ptr))
#define FIFO_READ            (*(FIFO_read_ptr))

/// lw_bus; FIFO status address
#define HW_REGS_BASE          0xff200000
#define HW_REGS_SPAN          0x00005000
// WAIT looks nicer than just braces
#define WAIT {}
// FIFO status registers
// base address is current fifo fill-level
// base+1 address is status:
// --bit0 signals "full"
// --bit1 signals "empty"
#define WRITE_FIFO_FILL_LEVEL (*FIFO_write_status_ptr)
#define READ_FIFO_FILL_LEVEL  (*FIFO_read_status_ptr)
#define WRITE_FIFO_FULL          ((*(FIFO_write_status_ptr+1))& 1 )
#define WRITE_FIFO_EMPTY      ((*(FIFO_write_status_ptr+1))& 2 )
#define READ_FIFO_FULL          ((*(FIFO_read_status_ptr+1)) & 1 )
#define READ_FIFO_EMPTY          ((*(FIFO_read_status_ptr+1)) & 2 )
// arg a is data to be written
#define FIFO_WRITE_BLOCK(a)      {while (WRITE_FIFO_FULL){WAIT};FIFO_WRITE=a;}
// arg a is data to be written, arg b is success/fail of write: b==1 means success
#define FIFO_WRITE_NOBLOCK(a,b) {b=!WRITE_FIFO_FULL; if(!WRITE_FIFO_FULL)FIFO_WRITE=a; }
// arg a is data read
#define FIFO_READ_BLOCK(a)      {while (READ_FIFO_EMPTY){WAIT};a=FIFO_READ;}
// arg a is data read, arg b is success/fail of read: b==1 means success
#define FIFO_READ_NOBLOCK(a,b) {b=!READ_FIFO_EMPTY; if(!READ_FIFO_EMPTY)a=FIFO_READ;}

//#define dataToFPGASize 41


// the light weight buss base
void *h2p_lw_virtual_base;
// HPS_to_FPGA FIFO status address = 0
volatile unsigned int * FIFO_write_status_ptr = NULL ;
volatile unsigned int * FIFO_read_status_ptr = NULL ;

// RAM FPGA command buffer
// main bus addess 0x0800_0000
//volatile unsigned int * sram_ptr = NULL ;
//void *sram_virtual_base;

// HPS_to_FPGA FIFO write address
// main bus addess 0x0000_0000
void *h2p_virtual_base;
volatile unsigned int * FIFO_write_ptr = NULL ;
volatile unsigned int * FIFO_read_ptr = NULL ;

// /dev/mem file id
int fd;

// timer variables
struct timeval t1, t2;
double elapsedTime;

/* Flag set by '--verbose'. */
static int verbose_flag = 0;
int helpopt = 0;
int term_out = 0;  // default is not for terminal output


int main (int argc, char *argv[]) {
  if (argc < 2) { // not enough arguments
    printf("Not enough arguments\n");
  }
  else if (argc > 2) { // too many arguments
    printf("Too many arguments\n"); 
  }
  else {
    char* unused_end_ptr;
    uint32_t command_id = strtoul(argv[1], &unused_end_ptr, 10); 
    // this is for testing, so manually test with different values
    if (command_id == 10) {
      uint32_t num_args_in = 2;
      uint32_t arguments[num_args_in];
      arguments[0] = 10;
      arguments[1] = 754; // Doesn't matter what this is, just needs to be here

      uint32_t num_args_out = 13;
      uint32_t arguments_out[num_args_out];

      sendData(num_args_in, arguments, num_args_out, arguments_out); 

      for(int i = 0; i < num_args_out; i++) {
        printf("arg %i: %i\n", i, arguments_out[i]);
      }
    }
    else if (command_id == 35) {
      uint32_t num_args_in = 61;
      uint32_t arguments[num_args_in];
      arguments[0] = 35;
      arguments[1] = 754; // Doesn't matter what this is, just needs to be here

      // map data
      arguments[2] = 0b0010001000100010; // row 0 - 0010_0010_0010_0010
      arguments[3] = 0;
      arguments[4] = 0; // row 1
      arguments[5] = 0;
      arguments[6] = 0b0001; // row 2
      arguments[7] = 0;
      arguments[8] = 0; // row 3
      arguments[9] = 0;
      arguments[10] = 0; // row 4  
      arguments[11] = 0;
      arguments[12] = 0; // row 5 0010_0000_0000_0000_0000
      arguments[13] = 0;
      arguments[14] = 0b01000000000000000000000000000000; // row 6 - 0100_0000_0000_0000_0000_0000_0000_0000
      arguments[15] = 0;
      arguments[16] = 0; // row 7
      arguments[17] = 0;
      arguments[18] = 0; // row 8
      arguments[19] = 0;
      arguments[20] = 0; // row 9
      arguments[21] = 0;
      arguments[22] = 0; // row 10
      arguments[23] = 0;
      arguments[24] = 0; // row 11
      arguments[25] = 0;
      arguments[26] = 0; // row 12
      arguments[27] = 0;
      arguments[28] = 0; // row 13
      arguments[29] = 0;

      // AI player num
      arguments[30] = 2;

      // piece 1
      arguments[31] = 0; // x
      arguments[32] = 0; // y
      arguments[33] = 1; // alive
      arguments[34] = 2; // move distance
      arguments[35] = 2; // attack distance
      arguments[36] = 2; // attack damage
      // piece 2
      arguments[37] = 4;
      arguments[38] = 5;
      arguments[39] = 1;
      arguments[40] = 2;
      arguments[41] = 2;
      arguments[42] = 2;
      // piece 3
      arguments[43] = 1;
      arguments[44] = 0;
      arguments[45] = 1;
      arguments[46] = 2;
      arguments[47] = 2;
      arguments[48] = 2;
      // piece 4
      arguments[49] = 2;
      arguments[50] = 0;
      arguments[51] = 1;
      arguments[52] = 2;
      arguments[53] = 2;
      arguments[54] = 2;
      // piece 5
      arguments[55] = 3;
      arguments[56] = 0;
      arguments[57] = 1;
      arguments[58] = 2;
      arguments[59] = 2;
      arguments[60] = 2;

      uint32_t num_args_out = 13;
      uint32_t arguments_out[num_args_out];

      sendData(num_args_in, arguments, num_args_out, arguments_out); 

      for(int i = 0; i < num_args_out; i++) {
        printf("arg %i: %i\n", i, arguments_out[i]);
      }
    }
    else {
      printf("unrecognized command\n");
    }
  }

} 

// Almost all the code here was gotten from https://github.com/Jambie82/CycloneV_HPS_FIFO, in the file commandOne.c
// I deleted much of it that I didn't need, and modified it to have variable amount of arguments in and out
int sendData(uint32_t num_args_in, uint32_t arguments[], uint32_t num_args_out, uint32_t arguments_out[])
{
  // === get FPGA addresses ==================
  // Open /dev/mem
    if( ( fd = open( "/dev/mem", ( O_RDWR | O_SYNC ) ) ) == -1 )
    {
      printf( "ERROR: could not open \"/dev/mem\"...\n" );
      return( 1 );
    }

  //============================================
  // get virtual addr that maps to physical
  // for light weight bus
  // FIFO status registers
  h2p_lw_virtual_base = mmap( NULL, HW_REGS_SPAN, ( PROT_READ | PROT_WRITE ), MAP_SHARED, fd, HW_REGS_BASE );
  if( h2p_lw_virtual_base == MAP_FAILED ) {
    printf( "ERROR: mmap1() failed...\n" );
    close( fd );
    return(1);
  }

  // the two status registers
  FIFO_write_status_ptr = (unsigned int *)(h2p_lw_virtual_base);
  // From Qsys, second FIFO is 0x20
  FIFO_read_status_ptr = (unsigned int *)(h2p_lw_virtual_base + 0x20); //0x20

  // FIFO write addr
  h2p_virtual_base = mmap( NULL, FIFO_SPAN, ( PROT_READ | PROT_WRITE ), MAP_SHARED, fd, FIFO_BASE);

  if( h2p_virtual_base == MAP_FAILED ) {
    printf( "ERROR: mmap3() failed...\n" );
    close( fd );
    return(1);
  }
  // Get the address that maps to the FIFO read/write ports
  FIFO_write_ptr =(unsigned int *)(h2p_virtual_base);
  FIFO_read_ptr = (unsigned int *)(h2p_virtual_base + 0x10); //0x10

  //============================================
  int i ;

  // ======================================
  // send array to FIFO and read entire block
  // ======================================

  // send array to FIFO and read block
  for (i=0; i<num_args_in; i++){
      // do the FIFO write
      printf("i:%i data:%i\n", i, arguments[i]);
      printf("write=%d read=%d\n\r", WRITE_FIFO_FILL_LEVEL, READ_FIFO_FILL_LEVEL); // ADDED
      FIFO_WRITE_BLOCK(arguments[i]);
  }
  usleep(100000);  // give the FPGA time to finish working

  // get array from FIFO, until required amount is read
  i=0;
  while (i < num_args_out) {
    while (!READ_FIFO_EMPTY) {
        arguments_out[i] = FIFO_READ;
        if (i>num_args_out) i=num_args_out;
        i++;
    }
    printf("waiting for data to be sent back\n");
    usleep(1000000);
  }

  return 0;
} 

