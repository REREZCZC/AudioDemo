

#define NON_INTERLEAVE_STRIDE   1
#define INTERLEAVE_STRIDE				2

//define wave file's I/O channel number
#define WAV_IN_CHN							1		// NR/Reverb function is mono
#define WAV_OUT_CHN							1



//#if 1==REVERB_MONO_EN	
//REVERB_MONO
	#define	DLY_FRAM_MAX					13	//256-25; 512-13
	#define	MIN_RVB_GAIN					0U
	#define	MAX_RVB_GAIN					8U

//#endif
