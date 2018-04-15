/**
 * \file   .h
 * 
 * \brief: The macro definitions and function prototypes for
 */


/*******************************************
**  MACRO DEFINITIONS
*********************************************/
extern "C"{
#define NON_INTERLEAVE_STRIDE       1
#define INTERLEAVE_STRIDE           2

//DSP function enable
#define	DWN_MIX_ENABLE					1
#define	ROTATION_ENABLE					1<<1
#define	DIST_DRC_ENABLE					1<<2
#define	REVERB_ENABLE						1<<3

#define	MIN_DST									6				// the unit of distance is decimeter
#define	MAX_DST									30
#define	DEFT_DST								12			// default distance is 12 decimeter

/*
* the range of frameSize value
* MIN_FRAM_N<frameSize<MAX_FRAM_N
*/
#define DSP_FRAM_SIZ						256				//70<value<360

#define	DLY_FRAM_MAX						15
#define	MIN_RVB_GAIN						0U
#define	MAX_RVB_GAIN						8U

/*******************************************
**  VARIABLES DEFINITIONS
*********************************************/

//the parameters of project
struct param_DSP{	
	// flag: control each block
	int			funEnable;
	
	unsigned int framSize;	// framSize <= CONV_FRAM_SIZ

	// parameters for each DSP function
	int			angle;
	int			distance;			// unit centimeter

	int			gainRvb;		//[0, 8]
	int			dlyFramN;		//[0, DLY_FRAM_MAX]

	int			*outL;
	int			*outR;
	int			*readL;
	int			*readR;
	unsigned int sampleStride;

};
/***************************************************************
*   Get the quantity of the memory required by convolve 
*****************************************************************/
unsigned int  ym_9con_queryMem();


/***********************************************
*   Get the quantity of the memory required 
************************************************/
void  ym_9con_open(void *p0);

/******************************************
*	Processing data of frame
* param_DSP.angle: [0, 360]
* param_DSP.distance: [MIN_DST, MAX_DST]
* param_DSP.framSize: (70, CONV_FRAM_SIZ], '70' is a test value
********************************************/
void ym_proc_fram(struct param_DSP *sParam,
									void		*p0);

/***************************************************************
* Get the parameters of the song which need to be processed 
* re-initialize some parameters when switching songs
*****************************************************************/
void  ym_song_ini(unsigned int		input_chan_num,
										void			*p0); 
}
