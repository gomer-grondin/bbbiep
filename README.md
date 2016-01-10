bbbiep

beaglebone black iep clock demo

question .. is this a 1Ghz clock?  spec in pru ICSS ref says 200Mhz 
		section 9.2

invocation: S0=`date +%s` ; ./1Gclock ; S1=`date +%s` ; expr $S1 - $S0

be sure that your pru has been enabled.


