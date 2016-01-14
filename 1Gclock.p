// Define the entry point of the program
.origin 0
.entrypoint START

// PRU interrupt for PRU0
#define PRU0_ARM_INTERRUPT 19
#define DEVICE_ID_SPAD0 10
#define DEVICE_ID_SPAD1 11
#define DEVICE_ID_SPAD2 10
#define DEVICE_ID_PRU0_CORE 14

#define counter r24

// not true 1Ghz clock, 
// using 1Ghz definitions, 7.2% slower than actual
//
#define ns2   		0x00000001
#define ns4   		0x00000003
#define ns8   		0x00000007
#define ns16   		0x0000000F

#define ns32   		0x0000001F
#define ns64   		0x0000003F
#define ns128  		0x0000007F
#define ns256  		0x000000FF

#define ns512 		0x000001FF
#define us1		0x000003FF
#define us2 		0x000007FF
#define us4 		0x00000FFF

#define us8		0x00001FFF
#define us16		0x00003FFF
#define us32		0x00007FFF
#define us64		0x0000FFFF

#define us128		0x0001FFFF
#define us256		0x0003FFFF
#define us512		0x0007FFFF
#define ms1		0x000FFFFF

#define ms2		0x001FFFFF
#define ms4		0x003FFFFF
#define ms8		0x007FFFFF
#define ms16		0x00FFFFFF

#define ms32		0x01FFFFFF
#define ms64		0x03FFFFFF
#define ms128		0x07FFFFFF
#define ms256		0x0FFFFFFF

#define ms512		0x1FFFFFFF
#define ms1024		0x3FFFFFFF
#define ms2048		0x7FFFFFFF
#define ms4096		0xFFFFFFFF

#define sec1  		0x3FFFFFFF
#define sec2  		0x7FFFFFFF
#define sec4		0xFFFFFFFF

#define persec1024	0x000FFFFF
#define persec512	0x001FFFFF
#define persec256	0x003FFFFF
#define persec128	0x007FFFFF
#define persec64	0x00FFFFFF
#define persec32	0x01FFFFFF
#define persec16	0x03FFFFFF
#define persec8		0x07FFFFFF
#define persec4		0x0FFFFFFF
#define persec2		0x1FFFFFFF
#define persec1		0x3FFFFFFF

#define us1024		0x000FFFFF
#define us2048		0x001FFFFF
#define us4096		0x003FFFFF
#define us8192		0x007FFFFF

#define IEP_GLOBAL_CFG	0x0002E000
#define IEP_CNT 	0x0002E00C

START:

	// Clear the STANDBY_INIT bit in the SYSCFG register
	// otherwise the PRU will not be able to write outside the PRU memory space
	// and to the Beaglebone pins
	LBCO r0, C4, 4, 4
	CLR r0, r0, 4
	SBCO r0, C4, 4, 4
	
	// Make constant 24 (c24) point to the beginning of PRU0 data ram
	MOV r0, 0x00000000
	MOV r1, 0x22020
	SBBO r0, r1, 0, 4

// turn on IEP timer .. section 9.3.1 PRU_ICSS reference guide
	MOV r3, IEP_GLOBAL_CFG
	LBBO counter, r3, 0, 4
	MOV r4, 0xFFFFFF0F    // blank out increment variable
	AND counter, counter, r4 
	MOV r4, 0x00000051    // increment by 5, turn on IEP
	OR counter, counter, r4 
	SBBO counter, r3, 0, 4
	
	MOV r3, IEP_CNT
	MOV r2, 0  // store prev counter
	MOV r4, 0xFFFFFF00 // blunt lower bits
	MOV r6, sec2  // report every 2 sec
	AND r7, r6, r4  // modified mask
READ:	
	LBBO counter, r3, 0, 4
	AND counter, counter, r4
	QBEQ READ, counter, r2 // prev value
	AND r8, counter, r7
	AND r8, r8, r6
	QBNE READ, r8, r7 
	JAL r30.w0, REPORT
	MOV r2, counter
	JMP READ
	HALT

REPORT:
        // Store the counter in the PRU's data ram
        //   so C program can read it
        SBCO counter, c24, 0, 4

        // Trigger the PRU0 interrupt (C program gets the event)
        MOV r31.b0, PRU0_ARM_INTERRUPT+16
        RET
