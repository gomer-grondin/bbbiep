#include <stdio.h>
#include <unistd.h>

#include <prussdrv.h>
#include <pruss_intc_mapping.h>

int main(void) {

	/* Initialize the PRU */
	printf(">> Initializing PRU\n");
	tpruss_intc_initdata pruss_intc_initdata = PRUSS_INTC_INITDATA;
	prussdrv_init();

	if (prussdrv_open (PRU_EVTOUT_0)) {
		// Handle failure
		fprintf(stderr, ">> PRU0 open failed\n");
		return 1;
	}

	printf(">> PRU opened\n");
	/* Get the interrupt initialized */
	prussdrv_pruintc_init(&pruss_intc_initdata);

	/* Get pointers to PRU local memory */
	void *pruDataMem;
	prussdrv_map_prumem(PRUSS0_PRU0_DATARAM, &pruDataMem);
	unsigned int *pruData = (unsigned int *) pruDataMem;

	/* Execute code on PRU */

	printf(">> Executing 1Gclock code\n");
	prussdrv_exec_program(0, "1Gclock.bin");

	/* Get measurements */
	int pruval = 1;
	int prevpru = 0;
	float elapsed = 0;
	int count;
//	while ( pruval > 0) {
//	while (	1 ) {
	for( count = 64 ; count ; count-- ) {
		// Wait for the PRU interrupt
		
		prussdrv_pru_wait_event (PRU_EVTOUT_0);
		prussdrv_pru_clear_event(PRU_EVTOUT_0, PRU0_ARM_INTERRUPT);
		
		pruval = pruData[0];
		if ( pruval != prevpru ) {
			prevpru = pruval;
			elapsed += 1.072 * 2;
			printf("%#10x %f seconds elapsed\n", pruval, elapsed );
		}
	}

	/* Disable PRU and close memory mapping*/
	prussdrv_pru_disable(0);
	prussdrv_exit();
	printf(">> PRU Disabled.\r\n");
	
	return (0);

}
