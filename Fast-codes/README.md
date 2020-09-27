Fast-codes

The codes rchproc_fast.m and hruproc_fast.m can be used in place of the original codes (e.g. rchproc.m) to speed up AMALGAM.
They create sim_daily.dat files all at once, instead of one at a time, which can make things 5-10x faster for big watersheds.

Place the rchproc_fast.m in the Mfiles folder. See the demo mcalib.m included here about their placement (called in lines 101 
and 102; deleted the original calls in lines 107 and 136).

In rchproc_fast.m, you can choose whether to do daily or monthly calibration, as well as the positioning of the FLOW_OUT
variable in output.rch.
