/**
 * \file   .h
 * 
 * \brief: The macro definitions and function prototypes for
 */

/*******************************************
**  MACRO DEFINITIONS
*********************************************/
#define NON_INTERLEAVE_STRIDE       1
#define INTERLEAVE_STRIDE           2

#define WAV_OUT_CHN							2


#define WAV_IN_CHN							4

/*******************************************
**  VARIABLES DEFINITIONS
*********************************************/
#ifndef _CTRL_DSP
#define _CTRL_DSP
	//the parameters of project
	struct ctrlDSP
	{	
		int			funEnable;			// flag: control each block

		
	};
#endif
/***************************************************************
*   Get the quantity of the memory required by convolve 
*****************************************************************/
unsigned int  ym_9con_query();


/***********************************************
*   Get the quantity of the memory required 
************************************************/
int  ym_9con_open(void *p0, unsigned int	N);

/******************************************
*	Processing data of frame
********************************************/
void ym_proc_fram(int			*out,
									int			*read,
									unsigned int nRead,
									struct ctrlDSP *sParam,
									void		*p0);

/***************************************************************
* Get the parameters of the song which need to be processed 
* re-initialize some parameters when switching songs
*****************************************************************/
void ym_song_ini(unsigned int		nChnIn,
								 unsigned int		sampleStride,
								 void						*p0);
