/*
    SDL - Simple DirectMedia Layer
    Copyright (C) 1997, 1998, 1999, 2000, 2001  Sam Lantinga

    This library is free software; you can redistribute it and/or
    modify it under the terms of the GNU Library General Public
    License as published by the Free Software Foundation; either
    version 2 of the License, or (at your option) any later version.

    This library is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
    Library General Public License for more details.

    You should have received a copy of the GNU Library General Public
    License along with this library; if not, write to the Free
    Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA

    Sam Lantinga
    slouken@devolution.com
*/

/* Include file for SDL application focus event handling */

extern(C):

/* The available application states */
const uint SDL_APPMOUSEFOCUS	= 0x01;		/* The app has mouse coverage */
const uint SDL_APPINPUTFOCUS	= 0x02;		/* The app has input focus */
const uint SDL_APPACTIVE		= 0x04;		/* The application is active */

/* Function prototypes */
/*
 * This function returns the current state of the application, which is a
 * bitwise combination of SDL_APPMOUSEFOCUS, SDL_APPINPUTFOCUS, and
 * SDL_APPACTIVE.  If SDL_APPACTIVE is set, then the user is able to
 * see your application, otherwise it has been iconified or disabled.
 */
Uint8 SDL_GetAppState();
/*
    SDL - Simple DirectMedia Layer
    Copyright (C) 1997, 1998, 1999, 2000, 2001  Sam Lantinga

    This library is free software; you can redistribute it and/or
    modify it under the terms of the GNU Library General Public
    License as published by the Free Software Foundation; either
    version 2 of the License, or (at your option) any later version.

    This library is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
    Library General Public License for more details.

    You should have received a copy of the GNU Library General Public
    License along with this library; if not, write to the Free
    Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA

    Sam Lantinga
    slouken@devolution.com
*/

extern(C):

/* The calculated values in this structure are calculated by SDL_OpenAudio() */
struct SDL_AudioSpec {
	int freq;		/* DSP frequency -- samples per second */
	Uint16 format;		/* Audio data format */
	Uint8  channels;	/* Number of channels: 1 mono, 2 stereo */
	Uint8  silence;		/* Audio buffer silence value (calculated) */
	Uint16 samples;		/* Audio buffer size in samples (power of 2) */
	Uint16 padding;		/* Necessary for some compile environments */
	Uint32 size;		/* Audio buffer size in bytes (calculated) */
	/* This function is called when the audio device needs more data.
	   'stream' is a pointer to the audio data buffer
	   'len' is the length of that buffer in bytes.
	   Once the callback returns, the buffer will no longer be valid.
	   Stereo samples are stored in a LRLRLR ordering.
	*/
	void function(void *userdata, Uint8 *stream, int len) callback;
	void  *userdata;
}

/* Audio format flags (defaults to LSB byte order) */
const uint AUDIO_U8	= 0x0008;	/* Unsigned 8-bit samples */
const uint AUDIO_S8	= 0x8008;	/* Signed 8-bit samples */
const uint AUDIO_U16LSB	= 0x0010;	/* Unsigned 16-bit samples */
const uint AUDIO_S16LSB	= 0x8010;	/* Signed 16-bit samples */
const uint AUDIO_U16MSB	= 0x1010;	/* As above, but big-endian byte order */
const uint AUDIO_S16MSB	= 0x9010;	/* As above, but big-endian byte order */
const uint AUDIO_U16	= AUDIO_U16LSB;
const uint AUDIO_S16	= AUDIO_S16LSB;

/* Native audio byte ordering */
//const uint AUDIO_U16SYS	= AUDIO_U16LSB;
//const uint AUDIO_S16SYS	= AUDIO_S16LSB;
const uint AUDIO_U16SYS	= AUDIO_U16MSB;
const uint AUDIO_S16SYS	= AUDIO_S16MSB;


/* A structure to hold a set of audio conversion filters and buffers */
struct SDL_AudioCVT {
	int needed;			/* Set to 1 if conversion possible */
	Uint16 src_format;		/* Source audio format */
	Uint16 dst_format;		/* Target audio format */
	double rate_incr;		/* Rate conversion increment */
	Uint8 *buf;			/* Buffer to hold entire audio data */
	int    len;			/* Length of original audio buffer */
	int    len_cvt;			/* Length of converted audio buffer */
	int    len_mult;		/* buffer must be len*len_mult big */
	double len_ratio; 	/* Given len, final size is len*len_ratio */
	void function(SDL_AudioCVT *cvt, Uint16 format)[10] filters;
	int filter_index;		/* Current audio conversion function */
}


/* Function prototypes */

/* These functions are used internally, and should not be used unless you
 * have a specific need to specify the audio driver you want to use.
 * You should normally use SDL_Init() or SDL_InitSubSystem().
 */
int SDL_AudioInit(char *driver_name);
void SDL_AudioQuit();

/* This function fills the given character buffer with the name of the
 * current audio driver, and returns a pointer to it if the audio driver has
 * been initialized.  It returns NULL if no driver has been initialized.
 */
char *SDL_AudioDriverName(char *namebuf, int maxlen);

/*
 * This function opens the audio device with the desired parameters, and
 * returns 0 if successful, placing the actual hardware parameters in the
 * structure pointed to by 'obtained'.  If 'obtained' is NULL, the audio
 * data passed to the callback function will be guaranteed to be in the
 * requested format, and will be automatically converted to the hardware
 * audio format if necessary.  This function returns -1 if it failed
 * to open the audio device, or couldn't set up the audio thread.
 *
 * When filling in the desired audio spec structure,
 *  'desired->freq' should be the desired audio frequency in samples-per-second.
 *  'desired->format' should be the desired audio format.
 *  'desired->samples' is the desired size of the audio buffer, in samples.
 *     This number should be a power of two, and may be adjusted by the audio
 *     driver to a value more suitable for the hardware.  Good values seem to
 *     range between 512 and 8096 inclusive, depending on the application and
 *     CPU speed.  Smaller values yield faster response time, but can lead
 *     to underflow if the application is doing heavy processing and cannot
 *     fill the audio buffer in time.  A stereo sample consists of both right
 *     and left channels in LR ordering.
 *     Note that the number of samples is directly related to time by the
 *     following formula:  ms = (samples*1000)/freq
 *  'desired->size' is the size in bytes of the audio buffer, and is
 *     calculated by SDL_OpenAudio().
 *  'desired->silence' is the value used to set the buffer to silence,
 *     and is calculated by SDL_OpenAudio().
 *  'desired->callback' should be set to a function that will be called
 *     when the audio device is ready for more data.  It is passed a pointer
 *     to the audio buffer, and the length in bytes of the audio buffer.
 *     This function usually runs in a separate thread, and so you should
 *     protect data structures that it accesses by calling SDL_LockAudio()
 *     and SDL_UnlockAudio() in your code.
 *  'desired->userdata' is passed as the first parameter to your callback
 *     function.
 *
 * The audio device starts out playing silence when it's opened, and should
 * be enabled for playing by calling SDL_PauseAudio(0) when you are ready
 * for your audio callback function to be called.  Since the audio driver
 * may modify the requested size of the audio buffer, you should allocate
 * any local mixing buffers after you open the audio device.
 */
int SDL_OpenAudio(SDL_AudioSpec *desired, SDL_AudioSpec *obtained);

/*
 * Get the current audio state:
 */
alias int SDL_audiostatus;
enum {
	SDL_AUDIO_STOPPED = 0,
	SDL_AUDIO_PLAYING,
	SDL_AUDIO_PAUSED
}
SDL_audiostatus SDL_GetAudioStatus();

/*
 * This function pauses and unpauses the audio callback processing.
 * It should be called with a parameter of 0 after opening the audio
 * device to start playing sound.  This is so you can safely initialize
 * data for your callback function after opening the audio device.
 * Silence will be written to the audio device during the pause.
 */
void SDL_PauseAudio(int pause_on);

/*
 * This function loads a WAVE from the data source, automatically freeing
 * that source if 'freesrc' is non-zero.  For example, to load a WAVE file,
 * you could do:
 *	SDL_LoadWAV_RW(SDL_RWFromFile("sample.wav", "rb"), 1, ...);
 *
 * If this function succeeds, it returns the given SDL_AudioSpec,
 * filled with the audio data format of the wave data, and sets
 * 'audio_buf' to a malloc()'d buffer containing the audio data,
 * and sets 'audio_len' to the length of that audio buffer, in bytes.
 * You need to free the audio buffer with SDL_FreeWAV() when you are
 * done with it.
 *
 * This function returns NULL and sets the SDL error message if the
 * wave file cannot be opened, uses an unknown data format, or is
 * corrupt.  Currently raw and MS-ADPCM WAVE files are supported.
 */
SDL_AudioSpec *SDL_LoadWAV_RW(SDL_RWops *src, int freesrc,
		 SDL_AudioSpec *spec, Uint8 **audio_buf, Uint32 *audio_len);

/* Compatibility convenience function -- loads a WAV from a file */
SDL_AudioSpec *SDL_LoadWAV(char* file, SDL_AudioSpec* spec,
		Uint8 **audio_buf, Uint32 *audio_len)
{
	return SDL_LoadWAV_RW(SDL_RWFromFile(file, "rb"), 1, spec,
		audio_buf, audio_len);
}

/*
 * This function frees data previously allocated with SDL_LoadWAV_RW()
 */
void SDL_FreeWAV(Uint8 *audio_buf);

/*
 * This function takes a source format and rate and a destination format
 * and rate, and initializes the 'cvt' structure with information needed
 * by SDL_ConvertAudio() to convert a buffer of audio data from one format
 * to the other.
 * This function returns 0, or -1 if there was an error.
 */
int SDL_BuildAudioCVT(SDL_AudioCVT *cvt,
		Uint16 src_format, Uint8 src_channels, int src_rate,
		Uint16 dst_format, Uint8 dst_channels, int dst_rate);

/* Once you have initialized the 'cvt' structure using SDL_BuildAudioCVT(),
 * created an audio buffer cvt->buf, and filled it with cvt->len bytes of
 * audio data in the source format, this function will convert it in-place
 * to the desired format.
 * The data conversion may expand the size of the audio data, so the buffer
 * cvt->buf should be allocated after the cvt structure is initialized by
 * SDL_BuildAudioCVT(), and should be cvt->len*cvt->len_mult bytes long.
 */
int SDL_ConvertAudio(SDL_AudioCVT *cvt);

/*
 * This takes two audio buffers of the playing audio format and mixes
 * them, performing addition, volume adjustment, and overflow clipping.
 * The volume ranges from 0 - 128, and should be set to SDL_MIX_MAXVOLUME
 * for full audio volume.  Note this does not change hardware volume.
 * This is provided for convenience -- you can mix your own audio data.
 */
const uint SDL_MIX_MAXVOLUME = 128;
void SDL_MixAudio(Uint8 *dst, Uint8 *src, Uint32 len, int volume);

/*
 * The lock manipulated by these functions protects the callback function.
 * During a LockAudio/UnlockAudio pair, you can be guaranteed that the
 * callback function is not running.  Do not call these from the callback
 * function or you will cause deadlock.
 */
void SDL_LockAudio();
void SDL_UnlockAudio();

/*
 * This function shuts down audio processing and closes the audio device.
 */
void SDL_CloseAudio();
/*
    SDL - Simple DirectMedia Layer
    Copyright (C) 1997, 1998, 1999, 2000, 2001  Sam Lantinga

    This library is free software; you can redistribute it and/or
    modify it under the terms of the GNU Library General Public
    License as published by the Free Software Foundation; either
    version 2 of the License, or (at your option) any later version.

    This library is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
    Library General Public License for more details.

    You should have received a copy of the GNU Library General Public
    License along with this library; if not, write to the Free
    Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA

    Sam Lantinga
    slouken@devolution.com
*/

/* Macros for determining the byte-order of this platform */

/* The two types of endianness */
const uint SDL_LIL_ENDIAN =	1234;
const uint SDL_BIG_ENDIAN =	4321;

/* Pardon the mess, I'm trying to determine the endianness of this host.
   I'm doing it by preprocessor defines rather than some sort of configure
   script so that application code can use this too.  The "right" way would
   be to dynamically generate this file on install, but that's a lot of work.
 */
const uint SDL_BYTEORDER = SDL_LIL_ENDIAN;

/*
    SDL - Simple DirectMedia Layer
    Copyright (C) 1997, 1998, 1999, 2000, 2001  Sam Lantinga

    This library is free software; you can redistribute it and/or
    modify it under the terms of the GNU Library General Public
    License as published by the Free Software Foundation; either
    version 2 of the License, or (at your option) any later version.

    This library is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
    Library General Public License for more details.

    You should have received a copy of the GNU Library General Public
    License along with this library; if not, write to the Free
    Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA

    Sam Lantinga
    slouken@devolution.com
*/

/* This is the CD-audio control API for Simple DirectMedia Layer */

extern(C):

/* In order to use these functions, SDL_Init() must have been called
   with the SDL_INIT_CDROM flag.  This causes SDL to scan the system
   for CD-ROM drives, and load appropriate drivers.
*/

/* The maximum number of CD-ROM tracks on a disk */
const int SDL_MAX_TRACKS	= 99;

/* The types of CD-ROM track possible */
const uint SDL_AUDIO_TRACK	= 0x00;
const uint SDL_DATA_TRACK	= 0x04;

/* The possible states which a CD-ROM drive can be in. */
alias int CDstatus;
enum {
	CD_TRAYEMPTY,
	CD_STOPPED,
	CD_PLAYING,
	CD_PAUSED,
	CD_ERROR = -1
}

/* Given a status, returns true if there's a disk in the drive */
//bit CD_INDRIVE(int status) { return status > 0; }

struct SDL_CDtrack {
	Uint8 id;		/* Track number */
	Uint8 type;		/* Data or audio track */
	Uint16 unused;
	Uint32 length;		/* Length, in frames, of this track */
	Uint32 offset;		/* Offset, in frames, from start of disk */
}

/* This structure is only current as of the last call to SDL_CDStatus() */
struct SDL_CD {
	int id;			/* Private drive identifier */
	CDstatus status;	/* Current drive status */

	/* The rest of this structure is only valid if there's a CD in drive */
	int numtracks;		/* Number of tracks on disk */
	int cur_track;		/* Current track position */
	int cur_frame;		/* Current frame offset within current track */
	SDL_CDtrack[SDL_MAX_TRACKS+1] track;
}

/* Conversion functions from frames to Minute/Second/Frames and vice versa */
const uint CD_FPS	= 75;
void FRAMES_TO_MSF(int f, out int M, out int S, out int F)
{
	int value = f;
	F = value % CD_FPS;
	value /= CD_FPS;
	S = value % 60;
	value /= 60;
	M = value;
}

int MSF_TO_FRAMES(int M, int S, int F)
{
	return M * 60 * CD_FPS + S * CD_FPS + F;
}

/* CD-audio API functions: */

/* Returns the number of CD-ROM drives on the system, or -1 if
   SDL_Init() has not been called with the SDL_INIT_CDROM flag.
 */
int SDL_CDNumDrives();

/* Returns a human-readable, system-dependent identifier for the CD-ROM.
   Example:
	"/dev/cdrom"
	"E:"
	"/dev/disk/ide/1/master"
*/
char * SDL_CDName(int drive);

/* Opens a CD-ROM drive for access.  It returns a drive handle on success,
   or NULL if the drive was invalid or busy.  This newly opened CD-ROM
   becomes the default CD used when other CD functions are passed a NULL
   CD-ROM handle.
   Drives are numbered starting with 0.  Drive 0 is the system default CD-ROM.
*/
SDL_CD * SDL_CDOpen(int drive);

/* This function returns the current status of the given drive.
   If the drive has a CD in it, the table of contents of the CD and current
   play position of the CD will be stored in the SDL_CD structure.
*/
CDstatus SDL_CDStatus(SDL_CD *cdrom);

/* Play the given CD starting at 'start_track' and 'start_frame' for 'ntracks'
   tracks and 'nframes' frames.  If both 'ntrack' and 'nframe' are 0, play
   until the end of the CD.  This function will skip data tracks.
   This function should only be called after calling SDL_CDStatus() to
   get track information about the CD.
   For example:
	// Play entire CD:
	if ( CD_INDRIVE(SDL_CDStatus(cdrom)) )
		SDL_CDPlayTracks(cdrom, 0, 0, 0, 0);
	// Play last track:
	if ( CD_INDRIVE(SDL_CDStatus(cdrom)) ) {
		SDL_CDPlayTracks(cdrom, cdrom->numtracks-1, 0, 0, 0);
	}
	// Play first and second track and 10 seconds of third track:
	if ( CD_INDRIVE(SDL_CDStatus(cdrom)) )
		SDL_CDPlayTracks(cdrom, 0, 0, 2, 10);

   This function returns 0, or -1 if there was an error.
*/
int SDL_CDPlayTracks(SDL_CD *cdrom,
		int start_track, int start_frame, int ntracks, int nframes);

/* Play the given CD starting at 'start' frame for 'length' frames.
   It returns 0, or -1 if there was an error.
*/
int SDL_CDPlay(SDL_CD *cdrom, int start, int length);

/* Pause play -- returns 0, or -1 on error */
int SDL_CDPause(SDL_CD *cdrom);

/* Resume play -- returns 0, or -1 on error */
int SDL_CDResume(SDL_CD *cdrom);

/* Stop play -- returns 0, or -1 on error */
int SDL_CDStop(SDL_CD *cdrom);

/* Eject CD-ROM -- returns 0, or -1 on error */
int SDL_CDEject(SDL_CD *cdrom);

/* Closes the handle for the CD-ROM drive */
void SDL_CDClose(SDL_CD *cdrom);
/*
    SDL - Simple DirectMedia Layer
    Copyright (C) 1997, 1998, 1999, 2000, 2001  Sam Lantinga

    This library is free software; you can redistribute it and/or
    modify it under the terms of the GNU Library General Public
    License as published by the Free Software Foundation; either
    version 2 of the License, or (at your option) any later version.

    This library is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
    Library General Public License for more details.

    You should have received a copy of the GNU Library General Public
    License along with this library; if not, write to the Free
    Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA

    Sam Lantinga
    slouken@devolution.com
*/
/*
    SDL - Simple DirectMedia Layer
    Copyright (C) 1997, 1998, 1999, 2000, 2001  Sam Lantinga

    This library is free software; you can redistribute it and/or
    modify it under the terms of the GNU Library General Public
    License as published by the Free Software Foundation; either
    version 2 of the License, or (at your option) any later version.

    This library is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
    Library General Public License for more details.

    You should have received a copy of the GNU Library General Public
    License along with this library; if not, write to the Free
    Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA

    Sam Lantinga
    slouken@devolution.com
*/

/* Functions for reading and writing endian-specific values */

/* These functions read and write data of the specified endianness,
   dynamically translating to the host machine endianness.

   e.g.: If you want to read a 16 bit value on big-endian machine from
         an open file containing little endian values, you would use:
		value = SDL_ReadLE16(rp);
         Note that the read/write functions use SDL_RWops pointers
         instead of FILE pointers.  This allows you to read and write
         endian values from large chunks of memory as well as files
         and other data sources.
*/

extern(C):

/* Use inline functions for compilers that support them, and static
   functions for those that do not.  Because these functions become
   static for compilers that do not support inline functions, this
   header should only be included in files that actually use them.
*/

Uint16 SDL_Swap16(Uint16 D) {
	return cast(Uint16)((D<<8)|(D>>8));
}

Uint32 SDL_Swap32(Uint32 D) {
	return cast(Uint32)((D<<24)|((D<<8)&0x00FF0000)|((D>>8)&0x0000FF00)|(D>>24));
}

Uint64 SDL_Swap64(Uint64 val) {
	Uint32 hi, lo;
	/* Separate into high and low 32-bit values and swap them */
	lo = cast(Uint32)(val&0xFFFFFFFF);
	val >>= 32;
	hi = cast(Uint32)(val&0xFFFFFFFF);
	val = SDL_Swap32(lo);
	val <<= 32;
	val |= SDL_Swap32(hi);
	return(val);
}

/* Byteswap item from the specified endianness to the native endianness */
//#define SDL_SwapLE16(X)	(X)
//#define SDL_SwapLE32(X)	(X)
//#define SDL_SwapLE64(X)	(X)
//#define SDL_SwapBE16(X)	SDL_Swap16(X)
//#define SDL_SwapBE32(X)	SDL_Swap32(X)
//#define SDL_SwapBE64(X)	SDL_Swap64(X)
Uint16 SDL_SwapLE16(Uint16 X) { return SDL_Swap16(X); }
Uint32 SDL_SwapLE32(Uint32 X) { return SDL_Swap32(X); }
Uint64 SDL_SwapLE64(Uint64 X) { return SDL_Swap64(X); }
Uint16 SDL_SwapBE16(Uint16 X) { return (X); }
Uint32 SDL_SwapBE32(Uint32 X) { return (X); }
Uint64 SDL_SwapBE64(Uint64 X) { return (X); }

/* Read an item of the specified endianness and return in native format */
Uint16 SDL_ReadLE16(SDL_RWops *src);
Uint16 SDL_ReadBE16(SDL_RWops *src);
Uint32 SDL_ReadLE32(SDL_RWops *src);
Uint32 SDL_ReadBE32(SDL_RWops *src);
Uint64 SDL_ReadLE64(SDL_RWops *src);
Uint64 SDL_ReadBE64(SDL_RWops *src);

/* Write an item of native format to the specified endianness */
int SDL_WriteLE16(SDL_RWops *dst, Uint16 value);
int SDL_WriteBE16(SDL_RWops *dst, Uint16 value);
int SDL_WriteLE32(SDL_RWops *dst, Uint32 value);
int SDL_WriteBE32(SDL_RWops *dst, Uint32 value);
int SDL_WriteLE64(SDL_RWops *dst, Uint64 value);
int SDL_WriteBE64(SDL_RWops *dst, Uint64 value);
/*
    SDL - Simple DirectMedia Layer
    Copyright (C) 1997, 1998, 1999, 2000, 2001  Sam Lantinga

    This library is free software; you can redistribute it and/or
    modify it under the terms of the GNU Library General Public
    License as published by the Free Software Foundation; either
    version 2 of the License, or (at your option) any later version.

    This library is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
    Library General Public License for more details.

    You should have received a copy of the GNU Library General Public
    License along with this library; if not, write to the Free
    Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA

    Sam Lantinga
    slouken@devolution.com
*/

/* Simple error message routines for SDL */

extern(C):

/* Public functions */
void SDL_SetError(char *fmt, ...);
char * SDL_GetError();
void SDL_ClearError();

/* Private error message function - used internally */
//#define SDL_OutOfMemory()	SDL_Error(SDL_ENOMEM)

alias int SDL_errorcode;
enum {
	SDL_ENOMEM,
	SDL_EFREAD,
	SDL_EFWRITE,
	SDL_EFSEEK,
	SDL_LASTERROR
}
extern void SDL_Error(SDL_errorcode code);

/*
    SDL - Simple DirectMedia Layer
    Copyright (C) 1997, 1998, 1999, 2000, 2001  Sam Lantinga

    This library is free software; you can redistribute it and/or
    modify it under the terms of the GNU Library General Public
    License as published by the Free Software Foundation; either
    version 2 of the License, or (at your option) any later version.

    This library is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
    Library General Public License for more details.

    You should have received a copy of the GNU Library General Public
    License along with this library; if not, write to the Free
    Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA

    Sam Lantinga
    slouken@devolution.com
*/

/* Include file for SDL event handling */

extern(C):

/* Event enumerations */
enum { SDL_NOEVENT = 0,			/* Unused (do not remove) */
       SDL_ACTIVEEVENT,			/* Application loses/gains visibility */
       SDL_KEYDOWN,			/* Keys pressed */
       SDL_KEYUP,			/* Keys released */
       SDL_MOUSEMOTION,			/* Mouse moved */
       SDL_MOUSEBUTTONDOWN,		/* Mouse button pressed */
       SDL_MOUSEBUTTONUP,		/* Mouse button released */
       SDL_JOYAXISMOTION,		/* Joystick axis motion */
       SDL_JOYBALLMOTION,		/* Joystick trackball motion */
       SDL_JOYHATMOTION,		/* Joystick hat position change */
       SDL_JOYBUTTONDOWN,		/* Joystick button pressed */
       SDL_JOYBUTTONUP,			/* Joystick button released */
       SDL_QUIT,			/* User-requested quit */
       SDL_SYSWMEVENT,			/* System specific event */
       SDL_EVENT_RESERVEDA,		/* Reserved for future use.. */
       SDL_EVENT_RESERVEDB,		/* Reserved for future use.. */
       SDL_VIDEORESIZE,			/* User resized video mode */
       SDL_VIDEOEXPOSE,			/* Screen needs to be redrawn */
       SDL_EVENT_RESERVED2,		/* Reserved for future use.. */
       SDL_EVENT_RESERVED3,		/* Reserved for future use.. */
       SDL_EVENT_RESERVED4,		/* Reserved for future use.. */
       SDL_EVENT_RESERVED5,		/* Reserved for future use.. */
       SDL_EVENT_RESERVED6,		/* Reserved for future use.. */
       SDL_EVENT_RESERVED7,		/* Reserved for future use.. */
       /* Events SDL_USEREVENT through SDL_MAXEVENTS-1 are for your use */
       SDL_USEREVENT = 24,
       /* This last event is only for bounding internal arrays
	  It is the number of bits in the event mask datatype -- Uint32
        */
       SDL_NUMEVENTS = 32
}

/* Predefined event masks */
uint SDL_EVENTMASK(uint X) { return 1 << (X); }
enum {
	SDL_ACTIVEEVENTMASK	= 1 << SDL_ACTIVEEVENT,
	SDL_KEYDOWNMASK		= 1 << SDL_KEYDOWN,
	SDL_KEYUPMASK		= 1 << SDL_KEYUP,
	SDL_MOUSEMOTIONMASK	= 1 << SDL_MOUSEMOTION,
	SDL_MOUSEBUTTONDOWNMASK	= 1 << SDL_MOUSEBUTTONDOWN,
	SDL_MOUSEBUTTONUPMASK	= 1 << SDL_MOUSEBUTTONUP,
	SDL_MOUSEEVENTMASK	= (1 << SDL_MOUSEMOTION) |
	                          (1 << SDL_MOUSEBUTTONDOWN)|
	                          (1 << SDL_MOUSEBUTTONUP),
	SDL_JOYAXISMOTIONMASK	= (1 << SDL_JOYAXISMOTION),
	SDL_JOYBALLMOTIONMASK	= (1 << SDL_JOYBALLMOTION),
	SDL_JOYHATMOTIONMASK	= (1 << SDL_JOYHATMOTION),
	SDL_JOYBUTTONDOWNMASK	= (1 << SDL_JOYBUTTONDOWN),
	SDL_JOYBUTTONUPMASK	= 1 << SDL_JOYBUTTONUP,
	SDL_JOYEVENTMASK	= (1 << SDL_JOYAXISMOTION)|
	                          (1 << SDL_JOYBALLMOTION)|
	                          (1 << SDL_JOYHATMOTION)|
	                          (1 << SDL_JOYBUTTONDOWN)|
	                          (1 << SDL_JOYBUTTONUP),
	SDL_VIDEORESIZEMASK	= 1 << SDL_VIDEORESIZE,
	SDL_VIDEOEXPOSEMASK	= 1 << SDL_VIDEOEXPOSE,
	SDL_QUITMASK		= 1 << SDL_QUIT,
	SDL_SYSWMEVENTMASK	= 1 << SDL_SYSWMEVENT
}
const uint SDL_ALLEVENTS	= 0xFFFFFFFF;

/* Application visibility event structure */
struct SDL_ActiveEvent {
	Uint8 type;	/* SDL_ACTIVEEVENT */
	Uint8 gain;	/* Whether given states were gained or lost (1/0) */
	Uint8 state;	/* A mask of the focus states */
}

/* Keyboard event structure */
struct SDL_KeyboardEvent {
	Uint8 type;	/* SDL_KEYDOWN or SDL_KEYUP */
	Uint8 which;	/* The keyboard device index */
	Uint8 state;	/* SDL_PRESSED or SDL_RELEASED */
	SDL_keysym keysym;
}

/* Mouse motion event structure */
struct SDL_MouseMotionEvent {
	Uint8 type;	/* SDL_MOUSEMOTION */
	Uint8 which;	/* The mouse device index */
	Uint8 state;	/* The current button state */
	Uint16 x, y;	/* The X/Y coordinates of the mouse */
	Sint16 xrel;	/* The relative motion in the X direction */
	Sint16 yrel;	/* The relative motion in the Y direction */
}

/* Mouse button event structure */
struct SDL_MouseButtonEvent {
	Uint8 type;	/* SDL_MOUSEBUTTONDOWN or SDL_MOUSEBUTTONUP */
	Uint8 which;	/* The mouse device index */
	Uint8 button;	/* The mouse button index */
	Uint8 state;	/* SDL_PRESSED or SDL_RELEASED */
	Uint16 x, y;	/* The X/Y coordinates of the mouse at press time */
}

/* Joystick axis motion event structure */
struct SDL_JoyAxisEvent {
	Uint8 type;	/* SDL_JOYAXISMOTION */
	Uint8 which;	/* The joystick device index */
	Uint8 axis;	/* The joystick axis index */
	Sint16 value;	/* The axis value (range: -32768 to 32767) */
}

/* Joystick trackball motion event structure */
struct SDL_JoyBallEvent {
	Uint8 type;	/* SDL_JOYBALLMOTION */
	Uint8 which;	/* The joystick device index */
	Uint8 ball;	/* The joystick trackball index */
	Sint16 xrel;	/* The relative motion in the X direction */
	Sint16 yrel;	/* The relative motion in the Y direction */
}

/* Joystick hat position change event structure */
struct SDL_JoyHatEvent {
	Uint8 type;	/* SDL_JOYHATMOTION */
	Uint8 which;	/* The joystick device index */
	Uint8 hat;	/* The joystick hat index */
	Uint8 value;	/* The hat position value:
				8   1   2
				7   0   3
				6   5   4
			   Note that zero means the POV is centered.
			*/
}

/* Joystick button event structure */
struct SDL_JoyButtonEvent {
	Uint8 type;	/* SDL_JOYBUTTONDOWN or SDL_JOYBUTTONUP */
	Uint8 which;	/* The joystick device index */
	Uint8 button;	/* The joystick button index */
	Uint8 state;	/* SDL_PRESSED or SDL_RELEASED */
}

/* The "window resized" event
   When you get this event, you are responsible for setting a new video
   mode with the new width and height.
 */
struct SDL_ResizeEvent {
	Uint8 type;	/* SDL_VIDEORESIZE */
	int w;		/* New width */
	int h;		/* New height */
}

/* The "screen redraw" event */
struct SDL_ExposeEvent {
	Uint8 type;	/* SDL_VIDEOEXPOSE */
}

/* The "quit requested" event */
struct SDL_QuitEvent {
	Uint8 type;	/* SDL_QUIT */
}

/* A user-defined event type */
struct SDL_UserEvent {
	Uint8 type;	/* SDL_USEREVENT through SDL_NUMEVENTS-1 */
	int code;	/* User defined event code */
	void *data1;	/* User defined data pointer */
	void *data2;	/* User defined data pointer */
}

/* If you want to use this event, you should include SDL_syswm.h */
struct SDL_SysWMEvent {
	Uint8 type;
	SDL_SysWMmsg *msg;
}

/* General event structure */
union SDL_Event {
	Uint8 type;
	SDL_ActiveEvent active;
	SDL_KeyboardEvent key;
	SDL_MouseMotionEvent motion;
	SDL_MouseButtonEvent button;
	SDL_JoyAxisEvent jaxis;
	SDL_JoyBallEvent jball;
	SDL_JoyHatEvent jhat;
	SDL_JoyButtonEvent jbutton;
	SDL_ResizeEvent resize;
	SDL_ExposeEvent expose;
	SDL_QuitEvent quit;
	SDL_UserEvent user;
	SDL_SysWMEvent syswm;
}

/* Function prototypes */

/* Pumps the event loop, gathering events from the input devices.
   This function updates the event queue and internal input device state.
   This should only be run in the thread that sets the video mode.
*/
void SDL_PumpEvents();

/* Checks the event queue for messages and optionally returns them.
   If 'action' is SDL_ADDEVENT, up to 'numevents' events will be added to
   the back of the event queue.
   If 'action' is SDL_PEEKEVENT, up to 'numevents' events at the front
   of the event queue, matching 'mask', will be returned and will not
   be removed from the queue.
   If 'action' is SDL_GETEVENT, up to 'numevents' events at the front
   of the event queue, matching 'mask', will be returned and will be
   removed from the queue.
   This function returns the number of events actually stored, or -1
   if there was an error.  This function is thread-safe.
*/
alias int SDL_eventaction;
enum {
	SDL_ADDEVENT,
	SDL_PEEKEVENT,
	SDL_GETEVENT
}
/* */
int SDL_PeepEvents(SDL_Event *events, int numevents,
		SDL_eventaction action, Uint32 mask);

/* Polls for currently pending events, and returns 1 if there are any pending
   events, or 0 if there are none available.  If 'event' is not NULL, the next
   event is removed from the queue and stored in that area.
 */
int SDL_PollEvent(SDL_Event *event);

/* Waits indefinitely for the next available event, returning 1, or 0 if there
   was an error while waiting for events.  If 'event' is not NULL, the next
   event is removed from the queue and stored in that area.
 */
int SDL_WaitEvent(SDL_Event *event);

/* Add an event to the event queue.
   This function returns 0, or -1 if the event couldn't be added to
   the event queue.  If the event queue is full, this function fails.
 */
int SDL_PushEvent(SDL_Event *event);

/*
  This function sets up a filter to process all events before they
  change internal state and are posted to the internal event queue.

  The filter is protypted as:
*/
alias int function(SDL_Event *event) SDL_EventFilter;
/*
  If the filter returns 1, then the event will be added to the internal queue.
  If it returns 0, then the event will be dropped from the queue, but the
  internal state will still be updated.  This allows selective filtering of
  dynamically arriving events.

  WARNING:  Be very careful of what you do in the event filter function, as
            it may run in a different thread!

  There is one caveat when dealing with the SDL_QUITEVENT event type.  The
  event filter is only called when the window manager desires to close the
  application window.  If the event filter returns 1, then the window will
  be closed, otherwise the window will remain open if possible.
  If the quit event is generated by an interrupt signal, it will bypass the
  internal queue and be delivered to the application at the next event poll.
*/
void SDL_SetEventFilter(SDL_EventFilter filter);

/*
  Return the current event filter - can be used to "chain" filters.
  If there is no event filter set, this function returns NULL.
*/
SDL_EventFilter SDL_GetEventFilter();

/*
  This function allows you to set the state of processing certain events.
  If 'state' is set to SDL_IGNORE, that event will be automatically dropped
  from the event queue and will not event be filtered.
  If 'state' is set to SDL_ENABLE, that event will be processed normally.
  If 'state' is set to SDL_QUERY, SDL_EventState() will return the
  current processing state of the specified event.
*/
const uint SDL_QUERY	= cast(uint) -1;
const uint SDL_IGNORE	= 0;
const uint SDL_DISABLE	= 0;
const uint SDL_ENABLE	= 1;
Uint8 SDL_EventState(Uint8 type, int state);
/* Not all environments have a working getenv()/putenv() */

extern(C):

/+
/* Put a variable of the form "name=value" into the environment */
int SDL_putenv(char *variable);
int putenv(char* X) { return SDL_putenv(X); }

/* Retrieve a variable named "name" from the environment */
char *SDL_getenv(char *name);
char *getenv(char* X) { return SDL_getenv(X); }
+/
extern (C) SDL_Surface* IMG_Load(const char *file);

/*
    SDL - Simple DirectMedia Layer
    Copyright (C) 1997, 1998, 1999, 2000, 2001  Sam Lantinga

    This library is free software; you can redistribute it and/or
    modify it under the terms of the GNU Library General Public
    License as published by the Free Software Foundation; either
    version 2 of the License, or (at your option) any later version.

    This library is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
    Library General Public License for more details.

    You should have received a copy of the GNU Library General Public
    License along with this library; if not, write to the Free
    Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA

    Sam Lantinga
    slouken@devolution.com
*/

/* Include file for SDL joystick event handling */

extern(C):

/* In order to use these functions, SDL_Init() must have been called
   with the SDL_INIT_JOYSTICK flag.  This causes SDL to scan the system
   for joysticks, and load appropriate drivers.
*/

/* The joystick structure used to identify an SDL joystick */
struct SDL_Joystick { }

/* Function prototypes */
/*
 * Count the number of joysticks attached to the system
 */
int SDL_NumJoysticks();

/*
 * Get the implementation dependent name of a joystick.
 * This can be called before any joysticks are opened.
 * If no name can be found, this function returns NULL.
 */
char *SDL_JoystickName(int device_index);

/*
 * Open a joystick for use - the index passed as an argument refers to
 * the N'th joystick on the system.  This index is the value which will
 * identify this joystick in future joystick events.
 *
 * This function returns a joystick identifier, or NULL if an error occurred.
 */
SDL_Joystick *SDL_JoystickOpen(int device_index);

/*
 * Returns 1 if the joystick has been opened, or 0 if it has not.
 */
int SDL_JoystickOpened(int device_index);

/*
 * Get the device index of an opened joystick.
 */
int SDL_JoystickIndex(SDL_Joystick *joystick);

/*
 * Get the number of general axis controls on a joystick
 */
int SDL_JoystickNumAxes(SDL_Joystick *joystick);

/*
 * Get the number of trackballs on a joystick
 * Joystick trackballs have only relative motion events associated
 * with them and their state cannot be polled.
 */
int SDL_JoystickNumBalls(SDL_Joystick *joystick);

/*
 * Get the number of POV hats on a joystick
 */
int SDL_JoystickNumHats(SDL_Joystick *joystick);

/*
 * Get the number of buttons on a joystick
 */
int SDL_JoystickNumButtons(SDL_Joystick *joystick);

/*
 * Update the current state of the open joysticks.
 * This is called automatically by the event loop if any joystick
 * events are enabled.
 */
void SDL_JoystickUpdate();

/*
 * Enable/disable joystick event polling.
 * If joystick events are disabled, you must call SDL_JoystickUpdate()
 * yourself and check the state of the joystick when you want joystick
 * information.
 * The state can be one of SDL_QUERY, SDL_ENABLE or SDL_IGNORE.
 */
int SDL_JoystickEventState(int state);

/*
 * Get the current state of an axis control on a joystick
 * The state is a value ranging from -32768 to 32767.
 * The axis indices start at index 0.
 */
Sint16 SDL_JoystickGetAxis(SDL_Joystick *joystick, int axis);

/*
 * Get the current state of a POV hat on a joystick
 * The return value is one of the following positions:
 */
const uint SDL_HAT_CENTERED	= 0x00;
const uint SDL_HAT_UP		= 0x01;
const uint SDL_HAT_RIGHT	= 0x02;
const uint SDL_HAT_DOWN		= 0x04;
const uint SDL_HAT_LEFT		= 0x08;
const uint SDL_HAT_RIGHTUP		= (SDL_HAT_RIGHT|SDL_HAT_UP);
const uint SDL_HAT_RIGHTDOWN	= (SDL_HAT_RIGHT|SDL_HAT_DOWN);
const uint SDL_HAT_LEFTUP		= (SDL_HAT_LEFT|SDL_HAT_UP);
const uint SDL_HAT_LEFTDOWN		= (SDL_HAT_LEFT|SDL_HAT_DOWN);
/*
 * The hat indices start at index 0.
 */
Uint8 SDL_JoystickGetHat(SDL_Joystick *joystick, int hat);

/*
 * Get the ball axis change since the last poll
 * This returns 0, or -1 if you passed it invalid parameters.
 * The ball indices start at index 0.
 */
int SDL_JoystickGetBall(SDL_Joystick *joystick, int ball, int *dx, int *dy);

/*
 * Get the current state of a button on a joystick
 * The button indices start at index 0.
 */
Uint8 SDL_JoystickGetButton(SDL_Joystick *joystick, int button);

/*
 * Close a joystick previously opened with SDL_JoystickOpen()
 */
void SDL_JoystickClose(SDL_Joystick *joystick);
/*
    SDL - Simple DirectMedia Layer
    Copyright (C) 1997, 1998, 1999, 2000, 2001  Sam Lantinga

    This library is free software; you can redistribute it and/or
    modify it under the terms of the GNU Library General Public
    License as published by the Free Software Foundation; either
    version 2 of the License, or (at your option) any later version.

    This library is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
    Library General Public License for more details.

    You should have received a copy of the GNU Library General Public
    License along with this library; if not, write to the Free
    Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA

    Sam Lantinga
    slouken@devolution.com
*/

/* Include file for SDL keyboard event handling */

extern(C):

/* Keysym structure
   - The scancode is hardware dependent, and should not be used by general
     applications.  If no hardware scancode is available, it will be 0.

   - The 'unicode' translated character is only available when character
     translation is enabled by the SDL_EnableUNICODE() API.  If non-zero,
     this is a UNICODE character corresponding to the keypress.  If the
     high 9 bits of the character are 0, then this maps to the equivalent
     ASCII character:
	char ch;
	if ( (keysym.unicode & 0xFF80) == 0 ) {
		ch = keysym.unicode & 0x7F;
	} else {
		An international character..
	}
 */
struct SDL_keysym {
	Uint8 scancode;			/* hardware specific scancode */
	SDLKey sym;			/* SDL virtual keysym */
	SDLMod mod;			/* current key modifiers */
	Uint16 unicode;			/* translated character */
}

/* This is the mask which refers to all hotkey bindings */
const uint SDL_ALL_HOTKEYS		= 0xFFFFFFFF;

/* Function prototypes */
/*
 * Enable/Disable UNICODE translation of keyboard input.
 * This translation has some overhead, so translation defaults off.
 * If 'enable' is 1, translation is enabled.
 * If 'enable' is 0, translation is disabled.
 * If 'enable' is -1, the translation state is not changed.
 * It returns the previous state of keyboard translation.
 */
int SDL_EnableUNICODE(int enable);

/*
 * Enable/Disable keyboard repeat.  Keyboard repeat defaults to off.
 * 'delay' is the initial delay in ms between the time when a key is
 * pressed, and keyboard repeat begins.
 * 'interval' is the time in ms between keyboard repeat events.
 */
const uint SDL_DEFAULT_REPEAT_DELAY		= 500;
const uint SDL_DEFAULT_REPEAT_INTERVAL	= 30;
/*
 * If 'delay' is set to 0, keyboard repeat is disabled.
 */
int SDL_EnableKeyRepeat(int delay, int interval);

/*
 * Get a snapshot of the current state of the keyboard.
 * Returns an array of keystates, indexed by the SDLK_* syms.
 * Used:
 * 	Uint8 *keystate = SDL_GetKeyState(NULL);
 *	if ( keystate[SDLK_RETURN] ) ... <RETURN> is pressed.
 */
Uint8 * SDL_GetKeyState(int *numkeys);

/*
 * Get the current key modifier state
 */
SDLMod SDL_GetModState();

/*
 * Set the current key modifier state
 * This does not change the keyboard state, only the key modifier flags.
 */
void SDL_SetModState(SDLMod modstate);

/*
 * Get the name of an SDL virtual keysym
 */
char * SDL_GetKeyName(SDLKey key);
/*
    SDL - Simple DirectMedia Layer
    Copyright (C) 1997, 1998, 1999, 2000, 2001  Sam Lantinga

    This library is free software; you can redistribute it and/or
    modify it under the terms of the GNU Library General Public
    License as published by the Free Software Foundation; either
    version 2 of the License, or (at your option) any later version.

    This library is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
    Library General Public License for more details.

    You should have received a copy of the GNU Library General Public
    License along with this library; if not, write to the Free
    Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA

    Sam Lantinga
    slouken@devolution.com
*/

/* What we really want is a mapping of every raw key on the keyboard.
   To support international keyboards, we use the range 0xA1 - 0xFF
   as international virtual keycodes.  We'll follow in the footsteps of X11...
   The names of the keys
 */

alias int SDLKey;
enum {
	/* The keyboard syms have been cleverly chosen to map to ASCII */
	SDLK_UNKNOWN		= 0,
	SDLK_FIRST		= 0,
	SDLK_BACKSPACE		= 8,
	SDLK_TAB		= 9,
	SDLK_CLEAR		= 12,
	SDLK_RETURN		= 13,
	SDLK_PAUSE		= 19,
	SDLK_ESCAPE		= 27,
	SDLK_SPACE		= 32,
	SDLK_EXCLAIM		= 33,
	SDLK_QUOTEDBL		= 34,
	SDLK_HASH		= 35,
	SDLK_DOLLAR		= 36,
	SDLK_AMPERSAND		= 38,
	SDLK_QUOTE		= 39,
	SDLK_LEFTPAREN		= 40,
	SDLK_RIGHTPAREN		= 41,
	SDLK_ASTERISK		= 42,
	SDLK_PLUS		= 43,
	SDLK_COMMA		= 44,
	SDLK_MINUS		= 45,
	SDLK_PERIOD		= 46,
	SDLK_SLASH		= 47,
	SDLK_0			= 48,
	SDLK_1			= 49,
	SDLK_2			= 50,
	SDLK_3			= 51,
	SDLK_4			= 52,
	SDLK_5			= 53,
	SDLK_6			= 54,
	SDLK_7			= 55,
	SDLK_8			= 56,
	SDLK_9			= 57,
	SDLK_COLON		= 58,
	SDLK_SEMICOLON		= 59,
	SDLK_LESS		= 60,
	SDLK_EQUALS		= 61,
	SDLK_GREATER		= 62,
	SDLK_QUESTION		= 63,
	SDLK_AT			= 64,
	/*
	   Skip uppercase letters
	 */
	SDLK_LEFTBRACKET	= 91,
	SDLK_BACKSLASH		= 92,
	SDLK_RIGHTBRACKET	= 93,
	SDLK_CARET		= 94,
	SDLK_UNDERSCORE		= 95,
	SDLK_BACKQUOTE		= 96,
	SDLK_a			= 97,
	SDLK_b			= 98,
	SDLK_c			= 99,
	SDLK_d			= 100,
	SDLK_e			= 101,
	SDLK_f			= 102,
	SDLK_g			= 103,
	SDLK_h			= 104,
	SDLK_i			= 105,
	SDLK_j			= 106,
	SDLK_k			= 107,
	SDLK_l			= 108,
	SDLK_m			= 109,
	SDLK_n			= 110,
	SDLK_o			= 111,
	SDLK_p			= 112,
	SDLK_q			= 113,
	SDLK_r			= 114,
	SDLK_s			= 115,
	SDLK_t			= 116,
	SDLK_u			= 117,
	SDLK_v			= 118,
	SDLK_w			= 119,
	SDLK_x			= 120,
	SDLK_y			= 121,
	SDLK_z			= 122,
	SDLK_DELETE		= 127,
	/* End of ASCII mapped keysyms */

	/* International keyboard syms */
	SDLK_WORLD_0		= 160,		/* 0xA0 */
	SDLK_WORLD_1		= 161,
	SDLK_WORLD_2		= 162,
	SDLK_WORLD_3		= 163,
	SDLK_WORLD_4		= 164,
	SDLK_WORLD_5		= 165,
	SDLK_WORLD_6		= 166,
	SDLK_WORLD_7		= 167,
	SDLK_WORLD_8		= 168,
	SDLK_WORLD_9		= 169,
	SDLK_WORLD_10		= 170,
	SDLK_WORLD_11		= 171,
	SDLK_WORLD_12		= 172,
	SDLK_WORLD_13		= 173,
	SDLK_WORLD_14		= 174,
	SDLK_WORLD_15		= 175,
	SDLK_WORLD_16		= 176,
	SDLK_WORLD_17		= 177,
	SDLK_WORLD_18		= 178,
	SDLK_WORLD_19		= 179,
	SDLK_WORLD_20		= 180,
	SDLK_WORLD_21		= 181,
	SDLK_WORLD_22		= 182,
	SDLK_WORLD_23		= 183,
	SDLK_WORLD_24		= 184,
	SDLK_WORLD_25		= 185,
	SDLK_WORLD_26		= 186,
	SDLK_WORLD_27		= 187,
	SDLK_WORLD_28		= 188,
	SDLK_WORLD_29		= 189,
	SDLK_WORLD_30		= 190,
	SDLK_WORLD_31		= 191,
	SDLK_WORLD_32		= 192,
	SDLK_WORLD_33		= 193,
	SDLK_WORLD_34		= 194,
	SDLK_WORLD_35		= 195,
	SDLK_WORLD_36		= 196,
	SDLK_WORLD_37		= 197,
	SDLK_WORLD_38		= 198,
	SDLK_WORLD_39		= 199,
	SDLK_WORLD_40		= 200,
	SDLK_WORLD_41		= 201,
	SDLK_WORLD_42		= 202,
	SDLK_WORLD_43		= 203,
	SDLK_WORLD_44		= 204,
	SDLK_WORLD_45		= 205,
	SDLK_WORLD_46		= 206,
	SDLK_WORLD_47		= 207,
	SDLK_WORLD_48		= 208,
	SDLK_WORLD_49		= 209,
	SDLK_WORLD_50		= 210,
	SDLK_WORLD_51		= 211,
	SDLK_WORLD_52		= 212,
	SDLK_WORLD_53		= 213,
	SDLK_WORLD_54		= 214,
	SDLK_WORLD_55		= 215,
	SDLK_WORLD_56		= 216,
	SDLK_WORLD_57		= 217,
	SDLK_WORLD_58		= 218,
	SDLK_WORLD_59		= 219,
	SDLK_WORLD_60		= 220,
	SDLK_WORLD_61		= 221,
	SDLK_WORLD_62		= 222,
	SDLK_WORLD_63		= 223,
	SDLK_WORLD_64		= 224,
	SDLK_WORLD_65		= 225,
	SDLK_WORLD_66		= 226,
	SDLK_WORLD_67		= 227,
	SDLK_WORLD_68		= 228,
	SDLK_WORLD_69		= 229,
	SDLK_WORLD_70		= 230,
	SDLK_WORLD_71		= 231,
	SDLK_WORLD_72		= 232,
	SDLK_WORLD_73		= 233,
	SDLK_WORLD_74		= 234,
	SDLK_WORLD_75		= 235,
	SDLK_WORLD_76		= 236,
	SDLK_WORLD_77		= 237,
	SDLK_WORLD_78		= 238,
	SDLK_WORLD_79		= 239,
	SDLK_WORLD_80		= 240,
	SDLK_WORLD_81		= 241,
	SDLK_WORLD_82		= 242,
	SDLK_WORLD_83		= 243,
	SDLK_WORLD_84		= 244,
	SDLK_WORLD_85		= 245,
	SDLK_WORLD_86		= 246,
	SDLK_WORLD_87		= 247,
	SDLK_WORLD_88		= 248,
	SDLK_WORLD_89		= 249,
	SDLK_WORLD_90		= 250,
	SDLK_WORLD_91		= 251,
	SDLK_WORLD_92		= 252,
	SDLK_WORLD_93		= 253,
	SDLK_WORLD_94		= 254,
	SDLK_WORLD_95		= 255,		/* 0xFF */

	/* Numeric keypad */
	SDLK_KP0		= 256,
	SDLK_KP1		= 257,
	SDLK_KP2		= 258,
	SDLK_KP3		= 259,
	SDLK_KP4		= 260,
	SDLK_KP5		= 261,
	SDLK_KP6		= 262,
	SDLK_KP7		= 263,
	SDLK_KP8		= 264,
	SDLK_KP9		= 265,
	SDLK_KP_PERIOD		= 266,
	SDLK_KP_DIVIDE		= 267,
	SDLK_KP_MULTIPLY	= 268,
	SDLK_KP_MINUS		= 269,
	SDLK_KP_PLUS		= 270,
	SDLK_KP_ENTER		= 271,
	SDLK_KP_EQUALS		= 272,

	/* Arrows + Home/End pad */
	SDLK_UP			= 273,
	SDLK_DOWN		= 274,
	SDLK_RIGHT		= 275,
	SDLK_LEFT		= 276,
	SDLK_INSERT		= 277,
	SDLK_HOME		= 278,
	SDLK_END		= 279,
	SDLK_PAGEUP		= 280,
	SDLK_PAGEDOWN		= 281,

	/* Function keys */
	SDLK_F1			= 282,
	SDLK_F2			= 283,
	SDLK_F3			= 284,
	SDLK_F4			= 285,
	SDLK_F5			= 286,
	SDLK_F6			= 287,
	SDLK_F7			= 288,
	SDLK_F8			= 289,
	SDLK_F9			= 290,
	SDLK_F10		= 291,
	SDLK_F11		= 292,
	SDLK_F12		= 293,
	SDLK_F13		= 294,
	SDLK_F14		= 295,
	SDLK_F15		= 296,

	/* Key state modifier keys */
	SDLK_NUMLOCK		= 300,
	SDLK_CAPSLOCK		= 301,
	SDLK_SCROLLOCK		= 302,
	SDLK_RSHIFT		= 303,
	SDLK_LSHIFT		= 304,
	SDLK_RCTRL		= 305,
	SDLK_LCTRL		= 306,
	SDLK_RALT		= 307,
	SDLK_LALT		= 308,
	SDLK_RMETA		= 309,
	SDLK_LMETA		= 310,
	SDLK_LSUPER		= 311,		/* Left "Windows" key */
	SDLK_RSUPER		= 312,		/* Right "Windows" key */
	SDLK_MODE		= 313,		/* "Alt Gr" key */
	SDLK_COMPOSE		= 314,		/* Multi-key compose key */

	/* Miscellaneous function keys */
	SDLK_HELP		= 315,
	SDLK_PRINT		= 316,
	SDLK_SYSREQ		= 317,
	SDLK_BREAK		= 318,
	SDLK_MENU		= 319,
	SDLK_POWER		= 320,		/* Power Macintosh power key */
	SDLK_EURO		= 321,		/* Some european keyboards */
	SDLK_UNDO		= 322,		/* Atari keyboard has Undo */

	/* Add any other keys here */

	SDLK_LAST
}

/* Enumeration of valid key mods (possibly OR'd together) */
alias int SDLMod;
enum {
	KMOD_NONE  = 0x0000,
	KMOD_LSHIFT= 0x0001,
	KMOD_RSHIFT= 0x0002,
	KMOD_LCTRL = 0x0040,
	KMOD_RCTRL = 0x0080,
	KMOD_LALT  = 0x0100,
	KMOD_RALT  = 0x0200,
	KMOD_LMETA = 0x0400,
	KMOD_RMETA = 0x0800,
	KMOD_NUM   = 0x1000,
	KMOD_CAPS  = 0x2000,
	KMOD_MODE  = 0x4000,
	KMOD_RESERVED = 0x8000
}

const uint KMOD_CTRL	= (KMOD_LCTRL|KMOD_RCTRL);
const uint KMOD_SHIFT	= (KMOD_LSHIFT|KMOD_RSHIFT);
const uint KMOD_ALT		= (KMOD_LALT|KMOD_RALT);
const uint KMOD_META	= (KMOD_LMETA|KMOD_RMETA);
/*
  SDL_mixer:  An audio mixer library based on the SDL library
  Copyright (C) 1997, 1998, 1999, 2000, 2001  Sam Lantinga

  This library is free software; you can redistribute it and/or
  modify it under the terms of the GNU Library General Public
  License as published by the Free Software Foundation; either
  version 2 of the License, or (at your option) any later version.

  This library is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
  Library General Public License for more details.

  You should have received a copy of the GNU Library General Public
  License along with this library; if not, write to the Free
  Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA

  Sam Lantinga
  slouken@libsdl.org
*/

// convert to D by shinichiro.h

/* $Id: SDL_mixer.d,v 1.1.1.1 2004/11/10 13:45:22 kenta Exp $ */

extern (C) {

/* Printable format: "%d.%d.%d", MAJOR, MINOR, PATCHLEVEL
 */
	const int MIX_MAJOR_VERSION = 1;
	const int MIX_MINOR_VERSION = 2;
	const int MIX_PATCHLEVEL = 5;

/* This function gets the version of the dynamically linked SDL_mixer library.
   it should NOT be used to fill a version structure, instead you should
   use the MIX_VERSION() macro.
*/
	SDL_version * Mix_Linked_Version();


/* The default mixer has 8 simultaneous mixing channels */
	const int MIX_CHANNELS = 8;

/* Good default values for a PC soundcard */
	const int MIX_DEFAULT_FREQUENCY = 22050;
	version (LittleEndian) {
		const int MIX_DEFAULT_FORMAT = AUDIO_S16LSB;
	}
	version (BigEndian) {
		const int MIX_DEFAULT_FORMAT = AUDIO_S16MSB;
	}
	const int MIX_DEFAULT_CHANNELS = 2;
	const int MIX_MAX_VOLUME = 128; /* Volume of a chunk */

/* The internal format for an audio chunk */
	struct Mix_Chunk {
		int allocated;
		Uint8 *abuf;
		Uint32 alen;
		Uint8 volume;		/* Per-sample volume, 0-128 */
	}

/* The different fading types supported */
	alias int Mix_Fading;
	enum {
		MIX_NO_FADING,
		MIX_FADING_OUT,
		MIX_FADING_IN
	}

	alias int  Mix_MusicType;
	enum {
		MUS_NONE,
		MUS_CMD,
		MUS_WAV,
		MUS_MOD,
		MUS_MID,
		MUS_OGG,
		MUS_MP3
	}

/* The internal format for a music chunk interpreted via mikmod */
	/* it's mayby enough */
	struct Mix_Music {}

/* Open the mixer with a certain audio format */
	int Mix_OpenAudio(int frequency, Uint16 format, int channels,
					  int chunksize);

/* Dynamically change the number of channels managed by the mixer.
   If decreasing the number of channels, the upper channels are
   stopped.
   This function returns the new number of allocated channels.
*/
	int Mix_AllocateChannels(int numchans);

/* Find out what the actual audio device parameters are.
   This function returns 1 if the audio has been opened, 0 otherwise.
*/
	int Mix_QuerySpec(int *frequency,Uint16 *format,int *channels);

/* Load a wave file or a music (.mod .s3m .it .xm) file */
	Mix_Chunk * Mix_LoadWAV_RW(SDL_RWops *src, int freesrc);
	Mix_Chunk * Mix_LoadWAV(const(char) *file) {
		return Mix_LoadWAV_RW(SDL_RWFromFile(file, "rb"), 1);
	}
	Mix_Music * Mix_LoadMUS(const(char) *file);

/* Load a wave file of the mixer format from a memory buffer */
	Mix_Chunk * Mix_QuickLoad_WAV(Uint8 *mem);

/* Load raw audio data of the mixer format from a memory buffer */
	Mix_Chunk * Mix_QuickLoad_RAW(Uint8 *mem, Uint32 len);

/* Free an audio chunk previously loaded */
	void Mix_FreeChunk(Mix_Chunk *chunk);
	void Mix_FreeMusic(Mix_Music *music);

/* Find out the music format of a mixer music, or the currently playing
   music, if 'music' is NULL.
*/
	Mix_MusicType Mix_GetMusicType(Mix_Music *music);

/* Set a function that is called after all mixing is performed.
   This can be used to provide real-time visual display of the audio stream
   or add a custom mixer filter for the stream data.
*/
	void Mix_SetPostMix(void
						function(void *udata, Uint8 *stream, int len) mix_func, void *arg);

/* Add your own music player or additional mixer function.
   If 'mix_func' is NULL, the default music player is re-enabled.
*/
	void Mix_HookMusic(void function
					   (void *udata, Uint8 *stream, int len) mix_func, void *arg);

/* Add your own callback when the music has finished playing.
   This callback is only called if the music finishes naturally.
*/
	void Mix_HookMusicFinished(void function() music_finished);

/* Get a pointer to the user data for the current music hook */
	void * Mix_GetMusicHookData();

/*
 * Add your own callback when a channel has finished playing. NULL
 *  to disable callback. The callback may be called from the mixer's audio
 *  callback or it could be called as a result of Mix_HaltChannel(), etc.
 *  do not call SDL_LockAudio() from this callback; you will either be
 *  inside the audio callback, or SDL_mixer will explicitly lock the audio
 *  before calling your callback.
 */
	void Mix_ChannelFinished(void function(int channel) channel_finished);


/* Special Effects API by ryan c. gordon. (icculus@linuxgames.com) */

	const int MIX_CHANNEL_POST = -2;

/* This is the format of a special effect callback:
 *
 *   myeffect(int chan, void *stream, int len, void *udata);
 *
 * (chan) is the channel number that your effect is affecting. (stream) is
 *  the buffer of data to work upon. (len) is the size of (stream), and
 *  (udata) is a user-defined bit of data, which you pass as the last arg of
 *  Mix_RegisterEffect(), and is passed back unmolested to your callback.
 *  Your effect changes the contents of (stream) based on whatever parameters
 *  are significant, or just leaves it be, if you prefer. You can do whatever
 *  you like to the buffer, though, and it will continue in its changed state
 *  down the mixing pipeline, through any other effect functions, then finally
 *  to be mixed with the rest of the channels and music for the final output
 *  stream.
 *
 * DO NOT EVER call SDL_LockAudio() from your callback function!
 */
	alias void function(int chan, void *stream, int len, void *udata) Mix_EffectFunc_t;

/*
 * This is a callback that signifies that a channel has finished all its
 *  loops and has completed playback. This gets called if the buffer
 *  plays out normally, or if you call Mix_HaltChannel(), implicitly stop
 *  a channel via Mix_AllocateChannels(), or unregister a callback while
 *  it's still playing.
 *
 * DO NOT EVER call SDL_LockAudio() from your callback function!
 */
	alias void function(int chan, void *udata) Mix_EffectDone_t;


/* Register a special effect function. At mixing time, the channel data is
 *  copied into a buffer and passed through each registered effect function.
 *  After it passes through all the functions, it is mixed into the final
 *  output stream. The copy to buffer is performed once, then each effect
 *  function performs on the output of the previous effect. Understand that
 *  this extra copy to a buffer is not performed if there are no effects
 *  registered for a given chunk, which saves CPU cycles, and any given
 *  effect will be extra cycles, too, so it is crucial that your code run
 *  fast. Also note that the data that your function is given is in the
 *  format of the sound device, and not the format you gave to Mix_OpenAudio(),
 *  although they may in reality be the same. This is an unfortunate but
 *  necessary speed concern. Use Mix_QuerySpec() to determine if you can
 *  handle the data before you register your effect, and take appropriate
 *  actions.
 * You may also specify a callback (Mix_EffectDone_t) that is called when
 *  the channel finishes playing. This gives you a more fine-grained control
 *  than Mix_ChannelFinished(), in case you need to free effect-specific
 *  resources, etc. If you don't need this, you can specify NULL.
 * You may set the callbacks before or after calling Mix_PlayChannel().
 * Things like Mix_SetPanning() are just internal special effect functions,
 *  so if you are using that, you've already incurred the overhead of a copy
 *  to a separate buffer, and that these effects will be in the queue with
 *  any functions you've registered. The list of registered effects for a
 *  channel is reset when a chunk finishes playing, so you need to explicitly
 *  set them with each call to Mix_PlayChannel*().
 * You may also register a special effect function that is to be run after
 *  final mixing occurs. The rules for these callbacks are identical to those
 *  in Mix_RegisterEffect, but they are run after all the channels and the
 *  music have been mixed into a single stream, whereas channel-specific
 *  effects run on a given channel before any other mixing occurs. These
 *  global effect callbacks are call "posteffects". Posteffects only have
 *  their Mix_EffectDone_t function called when they are unregistered (since
 *  the main output stream is never "done" in the same sense as a channel).
 *  You must unregister them manually when you've had enough. Your callback
 *  will be told that the channel being mixed is (MIX_CHANNEL_POST) if the
 *  processing is considered a posteffect.
 *
 * After all these effects have finished processing, the callback registered
 *  through Mix_SetPostMix() runs, and then the stream goes to the audio
 *  device.
 *
 * DO NOT EVER call SDL_LockAudio() from your callback function!
 *
 * returns zero if error (no such channel), nonzero if added.
 *  Error messages can be retrieved from Mix_GetError().
 */
	int Mix_RegisterEffect(int chan, Mix_EffectFunc_t f,
						   Mix_EffectDone_t d, void *arg);


/* You may not need to call this explicitly, unless you need to stop an
 *  effect from processing in the middle of a chunk's playback.
 * Posteffects are never implicitly unregistered as they are for channels,
 *  but they may be explicitly unregistered through this function by
 *  specifying MIX_CHANNEL_POST for a channel.
 * returns zero if error (no such channel or effect), nonzero if removed.
 *  Error messages can be retrieved from Mix_GetError().
 */
	int Mix_UnregisterEffect(int channel, Mix_EffectFunc_t f);


/* You may not need to call this explicitly, unless you need to stop all
 *  effects from processing in the middle of a chunk's playback. Note that
 *  this will also shut off some internal effect processing, since
 *  Mix_SetPanning() and others may use this API under the hood. This is
 *  called internally when a channel completes playback.
 * Posteffects are never implicitly unregistered as they are for channels,
 *  but they may be explicitly unregistered through this function by
 *  specifying MIX_CHANNEL_POST for a channel.
 * returns zero if error (no such channel), nonzero if all effects removed.
 *  Error messages can be retrieved from Mix_GetError().
 */
	int Mix_UnregisterAllEffects(int channel);


	const char[] MIX_EFFECTSMAXSPEED = "MIX_EFFECTSMAXSPEED";

/*
 * These are the internally-defined mixing effects. They use the same API that
 *  effects defined in the application use, but are provided here as a
 *  convenience. Some effects can reduce their quality or use more memory in
 *  the name of speed; to enable this, make sure the environment variable
 *  MIX_EFFECTSMAXSPEED (see above) is defined before you call
 *  Mix_OpenAudio().
 */


/* Set the panning of a channel. The left and right channels are specified
 *  as integers between 0 and 255, quietest to loudest, respectively.
 *
 * Technically, this is just individual volume control for a sample with
 *  two (stereo) channels, so it can be used for more than just panning.
 *  If you want real panning, call it like this:
 *
 *   Mix_SetPanning(channel, left, 255 - left);
 *
 * ...which isn't so hard.
 *
 * Setting (channel) to MIX_CHANNEL_POST registers this as a posteffect, and
 *  the panning will be done to the final mixed stream before passing it on
 *  to the audio device.
 *
 * This uses the Mix_RegisterEffect() API internally, and returns without
 *  registering the effect function if the audio device is not configured
 *  for stereo output. Setting both (left) and (right) to 255 causes this
 *  effect to be unregistered, since that is the data's normal state.
 *
 * returns zero if error (no such channel or Mix_RegisterEffect() fails),
 *  nonzero if panning effect enabled. Note that an audio device in mono
 *  mode is a no-op, but this call will return successful in that case.
 *  Error messages can be retrieved from Mix_GetError().
 */
	int Mix_SetPanning(int channel, Uint8 left, Uint8 right);


/* Set the position of a channel. (angle) is an integer from 0 to 360, that
 *  specifies the location of the sound in relation to the listener. (angle)
 *  will be reduced as neccesary (540 becomes 180 degrees, -100 becomes 260).
 *  Angle 0 is due north, and rotates clockwise as the value increases.
 *  For efficiency, the precision of this effect may be limited (angles 1
 *  through 7 might all produce the same effect, 8 through 15 are equal, etc).
 *  (distance) is an integer between 0 and 255 that specifies the space
 *  between the sound and the listener. The larger the number, the further
 *  away the sound is. Using 255 does not guarantee that the channel will be
 *  culled from the mixing process or be completely silent. For efficiency,
 *  the precision of this effect may be limited (distance 0 through 5 might
 *  all produce the same effect, 6 through 10 are equal, etc). Setting (angle)
 *  and (distance) to 0 unregisters this effect, since the data would be
 *  unchanged.
 *
 * If you need more precise positional audio, consider using OpenAL for
 *  spatialized effects instead of SDL_mixer. This is only meant to be a
 *  basic effect for simple "3D" games.
 *
 * If the audio device is configured for mono output, then you won't get
 *  any effectiveness from the angle; however, distance attenuation on the
 *  channel will still occur. While this effect will function with stereo
 *  voices, it makes more sense to use voices with only one channel of sound,
 *  so when they are mixed through this effect, the positioning will sound
 *  correct. You can convert them to mono through SDL before giving them to
 *  the mixer in the first place if you like.
 *
 * Setting (channel) to MIX_CHANNEL_POST registers this as a posteffect, and
 *  the positioning will be done to the final mixed stream before passing it
 *  on to the audio device.
 *
 * This is a convenience wrapper over Mix_SetDistance() and Mix_SetPanning().
 *
 * returns zero if error (no such channel or Mix_RegisterEffect() fails),
 *  nonzero if position effect is enabled.
 *  Error messages can be retrieved from Mix_GetError().
 */
	int Mix_SetPosition(int channel, Sint16 angle, Uint8 distance);


/* Set the "distance" of a channel. (distance) is an integer from 0 to 255
 *  that specifies the location of the sound in relation to the listener.
 *  Distance 0 is overlapping the listener, and 255 is as far away as possible
 *  A distance of 255 does not guarantee silence; in such a case, you might
 *  want to try changing the chunk's volume, or just cull the sample from the
 *  mixing process with Mix_HaltChannel().
 * For efficiency, the precision of this effect may be limited (distances 1
 *  through 7 might all produce the same effect, 8 through 15 are equal, etc).
 *  (distance) is an integer between 0 and 255 that specifies the space
 *  between the sound and the listener. The larger the number, the further
 *  away the sound is.
 * Setting (distance) to 0 unregisters this effect, since the data would be
 *  unchanged.
 * If you need more precise positional audio, consider using OpenAL for
 *  spatialized effects instead of SDL_mixer. This is only meant to be a
 *  basic effect for simple "3D" games.
 *
 * Setting (channel) to MIX_CHANNEL_POST registers this as a posteffect, and
 *  the distance attenuation will be done to the final mixed stream before
 *  passing it on to the audio device.
 *
 * This uses the Mix_RegisterEffect() API internally.
 *
 * returns zero if error (no such channel or Mix_RegisterEffect() fails),
 *  nonzero if position effect is enabled.
 *  Error messages can be retrieved from Mix_GetError().
 */
	int Mix_SetDistance(int channel, Uint8 distance);


/* Causes a channel to reverse its stereo. This is handy if the user has his
 *  speakers hooked up backwards, or you would like to have a minor bit of
 *  psychedelia in your sound code.  :)  Calling this function with (flip)
 *  set to non-zero reverses the chunks's usual channels. If (flip) is zero,
 *  the effect is unregistered.
 *
 * This uses the Mix_RegisterEffect() API internally, and thus is probably
 *  more CPU intensive than having the user just plug in his speakers
 *  correctly. Mix_SetReverseStereo() returns without registering the effect
 *  function if the audio device is not configured for stereo output.
 *
 * If you specify MIX_CHANNEL_POST for (channel), then this the effect is used
 *  on the final mixed stream before sending it on to the audio device (a
 *  posteffect).
 *
 * returns zero if error (no such channel or Mix_RegisterEffect() fails),
 *  nonzero if reversing effect is enabled. Note that an audio device in mono
 *  mode is a no-op, but this call will return successful in that case.
 *  Error messages can be retrieved from Mix_GetError().
 */
	int Mix_SetReverseStereo(int channel, int flip);

/* end of effects API. --ryan. */


/* Reserve the first channels (0 -> n-1) for the application, i.e. don't allocate
   them dynamically to the next sample if requested with a -1 value below.
   Returns the number of reserved channels.
*/
	int Mix_ReserveChannels(int num);

/* Channel grouping functions */

/* Attach a tag to a channel. A tag can be assigned to several mixer
   channels, to form groups of channels.
   If 'tag' is -1, the tag is removed (actually -1 is the tag used to
   represent the group of all the channels).
   Returns true if everything was OK.
*/
	int Mix_GroupChannel(int which, int tag);
/* Assign several consecutive channels to a group */
	int Mix_GroupChannels(int from, int to, int tag);
/* Finds the first available channel in a group of channels,
   returning -1 if none are available.
*/
	int Mix_GroupAvailable(int tag);
/* Returns the number of channels in a group. This is also a subtle
   way to get the total number of channels when 'tag' is -1
*/
	int Mix_GroupCount(int tag);
/* Finds the "oldest" sample playing in a group of channels */
	int Mix_GroupOldest(int tag);
/* Finds the "most recent" (i.e. last) sample playing in a group of channels */
	int Mix_GroupNewer(int tag);

/* The same as above, but the sound is played at most 'ticks' milliseconds */
	int Mix_PlayChannelTimed(int channel, Mix_Chunk *chunk, int loops, int ticks);
/* Play an audio chunk on a specific channel.
   If the specified channel is -1, play on the first free channel.
   If 'loops' is greater than zero, loop the sound that many times.
   If 'loops' is -1, loop inifinitely (~65000 times).
   Returns which channel was used to play the sound.
*/
	int Mix_PlayChannel(int channel, Mix_Chunk* chunk, int loops) {
		return Mix_PlayChannelTimed(channel,chunk,loops,-1);
	}
	int Mix_PlayMusic(Mix_Music *music, int loops);

/* Fade in music or a channel over "ms" milliseconds, same semantics as the "Play" functions */
	int Mix_FadeInMusic(Mix_Music *music, int loops, int ms);
	int Mix_FadeInMusicPos(Mix_Music *music, int loops, int ms, double position);
	int Mix_FadeInChannelTimed(int channel, Mix_Chunk *chunk, int loops, int ms, int ticks);
	int Mix_FadeInChannel(int channel, Mix_Chunk* chunk, int loops, int ms) {
		return Mix_FadeInChannelTimed(channel,chunk,loops,ms,-1);
	}

/* Set the volume in the range of 0-128 of a specific channel or chunk.
   If the specified channel is -1, set volume for all channels.
   Returns the original volume.
   If the specified volume is -1, just return the current volume.
*/
	int Mix_Volume(int channel, int volume);
	int Mix_VolumeChunk(Mix_Chunk *chunk, int volume);
	int Mix_VolumeMusic(int volume);

/* Halt playing of a particular channel */
	int Mix_HaltChannel(int channel);
	int Mix_HaltGroup(int tag);
	int Mix_HaltMusic();

/* Change the expiration delay for a particular channel.
   The sample will stop playing after the 'ticks' milliseconds have elapsed,
   or remove the expiration if 'ticks' is -1
*/
	int Mix_ExpireChannel(int channel, int ticks);

/* Halt a channel, fading it out progressively till it's silent
   The ms parameter indicates the number of milliseconds the fading
   will take.
*/
	int Mix_FadeOutChannel(int which, int ms);
	int Mix_FadeOutGroup(int tag, int ms);
	int Mix_FadeOutMusic(int ms);

/* Query the fading status of a channel */
	Mix_Fading Mix_FadingMusic();
	Mix_Fading Mix_FadingChannel(int which);

/* Pause/Resume a particular channel */
	void Mix_Pause(int channel);
	void Mix_Resume(int channel);
	int Mix_Paused(int channel);

/* Pause/Resume the music stream */
	void Mix_PauseMusic();
	void Mix_ResumeMusic();
	void Mix_RewindMusic();
	int Mix_PausedMusic();

/* Set the current position in the music stream.
   This returns 0 if successful, or -1 if it failed or isn't implemented.
   This function is only implemented for MOD music formats (set pattern
   order number) and for OGG music (set position in seconds), at the
   moment.
*/
	int Mix_SetMusicPosition(double position);

/* Check the status of a specific channel.
   If the specified channel is -1, check all channels.
*/
	int Mix_Playing(int channel);
	int Mix_PlayingMusic();

/* Stop music and set external music playback command */
	int Mix_SetMusicCMD(const(char) *command);

/* Synchro value is set by MikMod from modules while playing */
	int Mix_SetSynchroValue(int value);
	int Mix_GetSynchroValue();

/* Get the Mix_Chunk currently associated with a mixer channel
   Returns NULL if it's an invalid channel, or there's no chunk associated.
*/
	Mix_Chunk * Mix_GetChunk(int channel);

/* Close the mixer, halting all playing audio */
	void Mix_CloseAudio();

/* We'll use SDL for reporting errors */
//	void Mix_SetError	SDL_SetError
	const(char) * Mix_GetError() {
		return SDL_GetError();
	}

}
/* end of SDL_mixer.h ... */

/*
    SDL - Simple DirectMedia Layer
    Copyright (C) 1997, 1998, 1999, 2000, 2001  Sam Lantinga

    This library is free software; you can redistribute it and/or
    modify it under the terms of the GNU Library General Public
    License as published by the Free Software Foundation; either
    version 2 of the License, or (at your option) any later version.

    This library is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
    Library General Public License for more details.

    You should have received a copy of the GNU Library General Public
    License along with this library; if not, write to the Free
    Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA

    Sam Lantinga
    slouken@devolution.com
*/

/* Include file for SDL mouse event handling */

extern(C):

struct SDL_Cursor {
	SDL_Rect area;			/* The area of the mouse cursor */
	Sint16 hot_x, hot_y;		/* The "tip" of the cursor */
	Uint8 *data;			/* B/W cursor data */
	Uint8 *mask;			/* B/W cursor mask */
	Uint8*[2] save;			/* Place to save cursor area */
	void /*WMcursor*/ *wm_cursor;		/* Window-manager cursor */
}

/* Function prototypes */
/*
 * Retrieve the current state of the mouse.
 * The current button state is returned as a button bitmask, which can
 * be tested using the SDL_BUTTON(X) macros, and x and y are set to the
 * current mouse cursor position.  You can pass NULL for either x or y.
 */
Uint8 SDL_GetMouseState(int *x, int *y);

/*
 * Retrieve the current state of the mouse.
 * The current button state is returned as a button bitmask, which can
 * be tested using the SDL_BUTTON(X) macros, and x and y are set to the
 * mouse deltas since the last call to SDL_GetRelativeMouseState().
 */
Uint8 SDL_GetRelativeMouseState(int *x, int *y);

/*
 * Set the position of the mouse cursor (generates a mouse motion event)
 */
void SDL_WarpMouse(Uint16 x, Uint16 y);

/*
 * Create a cursor using the specified data and mask (in MSB format).
 * The cursor width must be a multiple of 8 bits.
 *
 * The cursor is created in black and white according to the following:
 * data  mask    resulting pixel on screen
 *  0     1       White
 *  1     1       Black
 *  0     0       Transparent
 *  1     0       Inverted color if possible, black if not.
 *
 * Cursors created with this function must be freed with SDL_FreeCursor().
 */
SDL_Cursor *SDL_CreateCursor
		(Uint8 *data, Uint8 *mask, int w, int h, int hot_x, int hot_y);

/*
 * Set the currently active cursor to the specified one.
 * If the cursor is currently visible, the change will be immediately
 * represented on the display.
 */
void SDL_SetCursor(SDL_Cursor *cursor);

/*
 * Returns the currently active cursor.
 */
SDL_Cursor * SDL_GetCursor();

/*
 * Deallocates a cursor created with SDL_CreateCursor().
 */
void SDL_FreeCursor(SDL_Cursor *cursor);

/*
 * Toggle whether or not the cursor is shown on the screen.
 * The cursor start off displayed, but can be turned off.
 * SDL_ShowCursor() returns 1 if the cursor was being displayed
 * before the call, or 0 if it was not.  You can query the current
 * state by passing a 'toggle' value of -1.
 */
int SDL_ShowCursor(int toggle);

/* Used as a mask when testing buttons in buttonstate
   Button 1:	Left mouse button
   Button 2:	Middle mouse button
   Button 3:	Right mouse button
 */
uint SDL_BUTTON(uint X) { return SDL_PRESSED << (X-1); }
const uint SDL_BUTTON_LEFT		= 1;
const uint SDL_BUTTON_MIDDLE	= 2;
const uint SDL_BUTTON_RIGHT		= 3;
const uint SDL_BUTTON_WHEELUP	= 4;
const uint SDL_BUTTON_WHEELDOWN	= 5;
const uint SDL_BUTTON_LMASK		= SDL_PRESSED << (SDL_BUTTON_LEFT - 1);
const uint SDL_BUTTON_MMASK		= SDL_PRESSED << (SDL_BUTTON_MIDDLE - 1);
const uint SDL_BUTTON_RMASK		= SDL_PRESSED << (SDL_BUTTON_RIGHT - 1);
/*
    SDL - Simple DirectMedia Layer
    Copyright (C) 1997, 1998, 1999, 2000, 2001  Sam Lantinga

    This library is free software; you can redistribute it and/or
    modify it under the terms of the GNU Library General Public
    License as published by the Free Software Foundation; either
    version 2 of the License, or (at your option) any later version.

    This library is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
    Library General Public License for more details.

    You should have received a copy of the GNU Library General Public
    License along with this library; if not, write to the Free
    Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA

    Sam Lantinga
    slouken@devolution.com
*/

/* Functions to provide thread synchronization primitives

	These are independent of the other SDL routines.
*/

extern(C):

/* Synchronization functions which can time out return this value
   if they time out.
*/
const uint SDL_MUTEX_TIMEDOUT	= 1;

/* This is the timeout value which corresponds to never time out */
const uint SDL_MUTEX_MAXWAIT	= 0xFFFFFFFF;


/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */
/* Mutex functions                                               */
/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */
struct SDL_mutex { }

/* Create a mutex, initialized unlocked */
SDL_mutex * SDL_CreateMutex();

/* Lock the mutex  (Returns 0, or -1 on error) */
int SDL_LockMutex(SDL_mutex *m) { return SDL_mutexP(m); }
int SDL_mutexP(SDL_mutex *mutex);

/* Unlock the mutex  (Returns 0, or -1 on error) */
int SDL_UnlockMutex(SDL_mutex* m) { return SDL_mutexV(m); }
int SDL_mutexV(SDL_mutex *mutex);

/* Destroy a mutex */
void SDL_DestroyMutex(SDL_mutex *mutex);


/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */
/* Semaphore functions                                           */
/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */
struct SDL_sem { }

/* Create a semaphore, initialized with value, returns NULL on failure. */
SDL_sem * SDL_CreateSemaphore(Uint32 initial_value);

/* Destroy a semaphore */
void SDL_DestroySemaphore(SDL_sem *sem);

/* This function suspends the calling thread until the semaphore pointed
 * to by sem has a positive count. It then atomically decreases the semaphore
 * count.
 */
int SDL_SemWait(SDL_sem *sem);

/* Non-blocking variant of SDL_SemWait(), returns 0 if the wait succeeds,
   SDL_MUTEX_TIMEDOUT if the wait would block, and -1 on error.
*/
int SDL_SemTryWait(SDL_sem *sem);

/* Variant of SDL_SemWait() with a timeout in milliseconds, returns 0 if
   the wait succeeds, SDL_MUTEX_TIMEDOUT if the wait does not succeed in
   the allotted time, and -1 on error.
   On some platforms this function is implemented by looping with a delay
   of 1 ms, and so should be avoided if possible.
*/
int SDL_SemWaitTimeout(SDL_sem *sem, Uint32 ms);

/* Atomically increases the semaphore's count (not blocking), returns 0,
   or -1 on error.
 */
int SDL_SemPost(SDL_sem *sem);

/* Returns the current count of the semaphore */
Uint32 SDL_SemValue(SDL_sem *sem);


/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */
/* Condition variable functions                                  */
/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */
struct SDL_cond { }

/* Create a condition variable */
SDL_cond * SDL_CreateCond();

/* Destroy a condition variable */
void SDL_DestroyCond(SDL_cond *cond);

/* Restart one of the threads that are waiting on the condition variable,
   returns 0 or -1 on error.
 */
int SDL_CondSignal(SDL_cond *cond);

/* Restart all threads that are waiting on the condition variable,
   returns 0 or -1 on error.
 */
int SDL_CondBroadcast(SDL_cond *cond);

/* Wait on the condition variable, unlocking the provided mutex.
   The mutex must be locked before entering this function!
   Returns 0 when it is signaled, or -1 on error.
 */
int SDL_CondWait(SDL_cond *cond, SDL_mutex *mut);

/* Waits for at most 'ms' milliseconds, and returns 0 if the condition
   variable is signaled, SDL_MUTEX_TIMEDOUT if the condition is not
   signaled in the allotted time, and -1 on error.
   On some platforms this function is implemented by looping with a delay
   of 1 ms, and so should be avoided if possible.
*/
int SDL_CondWaitTimeout(SDL_cond *cond, SDL_mutex *mutex, Uint32 ms);

/*
    SDL - Simple DirectMedia Layer
    Copyright (C) 1997, 1998, 1999, 2000, 2001  Sam Lantinga

    This library is free software; you can redistribute it and/or
    modify it under the terms of the GNU Library General Public
    License as published by the Free Software Foundation; either
    version 2 of the License, or (at your option) any later version.

    This library is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
    Library General Public License for more details.

    You should have received a copy of the GNU Library General Public
    License along with this library; if not, write to the Free
    Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA

    Sam Lantinga
    slouken@devolution.com
*/

/* Include file for SDL quit event handling */

/*
  An SDL_QUITEVENT is generated when the user tries to close the application
  window.  If it is ignored or filtered out, the window will remain open.
  If it is not ignored or filtered, it is queued normally and the window
  is allowed to close.  When the window is closed, screen updates will
  complete, but have no effect.

  SDL_Init() installs signal handlers for SIGINT (keyboard interrupt)
  and SIGTERM (system termination request), if handlers do not already
  exist, that generate SDL_QUITEVENT events as well.  There is no way
  to determine the cause of an SDL_QUITEVENT, but setting a signal
  handler in your application will override the default generation of
  quit events for that signal.
*/

/* There are no functions directly affecting the quit event */
bool SDL_QuitRequested()
{
	SDL_PumpEvents();
	return cast(bool)SDL_PeepEvents(null, 0, SDL_PEEKEVENT, SDL_QUITMASK);
}
/*
    SDL - Simple DirectMedia Layer
    Copyright (C) 1997, 1998, 1999, 2000, 2001  Sam Lantinga

    This library is free software; you can redistribute it and/or
    modify it under the terms of the GNU Library General Public
    License as published by the Free Software Foundation; either
    version 2 of the License, or (at your option) any later version.

    This library is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
    Library General Public License for more details.

    You should have received a copy of the GNU Library General Public
    License along with this library; if not, write to the Free
    Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA

    Sam Lantinga
    slouken@devolution.com
*/

/* This file provides a general interface for SDL to read and write
   data sources.  It can easily be extended to files, memory, etc.
*/

extern(C):

alias int function(SDL_RWops*, int, int) _seek_func_t;
alias int function(SDL_RWops *context, void *ptr, int size, int maxnum) _read_func_t;
alias int function(SDL_RWops *context, void *ptr, int size, int num) _write_func_t;
alias int function(SDL_RWops *context) _close_func_t;

/* This is the read/write operation structure -- very basic */

struct SDL_RWops {
	/* Seek to 'offset' relative to whence, one of stdio's whence values:
		SEEK_SET, SEEK_CUR, SEEK_END
	   Returns the final offset in the data source.
	 */
	_seek_func_t seek;
//	int (*seek)(SDL_RWops *context, int offset, int whence);

	/* Read up to 'num' objects each of size 'objsize' from the data
	   source to the area pointed at by 'ptr'.
	   Returns the number of objects read, or -1 if the read failed.
	 */
	_read_func_t read;
//	int (*read)(SDL_RWops *context, void *ptr, int size, int maxnum);

	/* Write exactly 'num' objects each of size 'objsize' from the area
	   pointed at by 'ptr' to data source.
	   Returns 'num', or -1 if the write failed.
	 */
	_write_func_t write;
//	int (*write)(SDL_RWops *context, void *ptr, int size, int num);

	/* Close and free an allocated SDL_FSops structure */
	_close_func_t close;
//	int (*close)(SDL_RWops *context);

	Uint32 type;
	union {
	    struct {
			int autoclose;
		 	void *fp;	// was FILE
	    } // stdio;
	    struct {
			Uint8 *base;
		 	Uint8 *here;
			Uint8 *stop;
	    } // mem;
	    struct {
			void *data1;
	    } // unknown;
	} // hidden;
}


/* Functions to create SDL_RWops structures from various data sources */

SDL_RWops * SDL_RWFromFile(const(char) *file, const(char) *mode);

SDL_RWops * SDL_RWFromFP(void *fp, int autoclose);

SDL_RWops * SDL_RWFromMem(void *mem, int size);

SDL_RWops * SDL_AllocRW();
void SDL_FreeRW(SDL_RWops *area);

/* Macros to easily read and write from an SDL_RWops structure */
int SDL_RWseek(SDL_RWops *ctx, int offset, int whence)
{
	_seek_func_t seek;
//	int (*seek)(SDL_RWops *context, int offset, int whence);
	seek = ctx.seek;
	return (*seek)(ctx, offset, whence);
}

int SDL_RWtell(SDL_RWops *ctx)
{
	_seek_func_t seek;
//	int (*seek)(SDL_RWops *context, int offset, int whence);
	seek = ctx.seek;
	return (*seek)(ctx, 0, 1);
}

int SDL_RWread(SDL_RWops *ctx, void* ptr, int size, int n)
{
	_read_func_t read;
//	int (*read)(SDL_RWops *context, void *ptr, int size, int maxnum);
	read = ctx.read;
	return (*read)(ctx, ptr, size, n);
}

int SDL_RWwrite(SDL_RWops *ctx, void* ptr, int size, int n)
{
	_write_func_t write;
//	int (*write)(SDL_RWops *context, void *ptr, int size, int num);
	write = ctx.write;
	return (*write)(ctx, ptr, size, n);
}

int SDL_RWclose(SDL_RWops *ctx)
{
	_close_func_t close;
//	int (*close)(SDL_RWops *context);
	close = ctx.close;
	return (*close)(ctx);
}
/*
    SDL - Simple DirectMedia Layer
    Copyright (C) 1997, 1998, 1999, 2000, 2001  Sam Lantinga

    This library is free software; you can redistribute it and/or
    modify it under the terms of the GNU Library General Public
    License as published by the Free Software Foundation; either
    version 2 of the License, or (at your option) any later version.

    This library is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
    Library General Public License for more details.

    You should have received a copy of the GNU Library General Public
    License along with this library; if not, write to the Free
    Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA

    Sam Lantinga
    slouken@devolution.com
*/

/* Include file for SDL custom system window manager hooks */

extern(C):

/* Your application has access to a special type of event 'SDL_SYSWMEVENT',
   which contains window-manager specific information and arrives whenever
   an unhandled window event occurs.  This event is ignored by default, but
   you can enable it with SDL_EventState()
*/

alias void* HWND;
alias uint UINT;
alias uint WPARAM;
alias uint LPARAM;

/* The windows custom event structure */
struct SDL_SysWMmsg {
	SDL_version _version;	// !!! "version" is a D keyword
	HWND hwnd;				/* The window for the message */
	UINT msg;				/* The type of message */
	WPARAM wParam;			/* WORD message parameter */
	LPARAM lParam;			/* LONG message parameter */
}

/* The windows custom window manager information structure */
struct SDL_SysWMinfo {
	SDL_version _version;	// !!! "version" is a D keyword
	HWND window;			/* The Win32 display window */
}

/* Function prototypes */
/*
 * This function gives you custom hooks into the window manager information.
 * It fills the structure pointed to by 'info' with custom information and
 * returns 1 if the function is implemented.  If it's not implemented, or
 * the version member of the 'info' structure is invalid, it returns 0.
 */
int SDL_GetWMInfo(SDL_SysWMinfo *info);
/*
    SDL - Simple DirectMedia Layer
    Copyright (C) 1997, 1998, 1999, 2000, 2001  Sam Lantinga

    This library is free software; you can redistribute it and/or
    modify it under the terms of the GNU Library General Public
    License as published by the Free Software Foundation; either
    version 2 of the License, or (at your option) any later version.

    This library is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
    Library General Public License for more details.

    You should have received a copy of the GNU Library General Public
    License along with this library; if not, write to the Free
    Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA

    Sam Lantinga
    slouken@devolution.com
*/

/* Header for the SDL thread management routines

	These are independent of the other SDL routines.
*/

extern(C):

/* The SDL thread structure, defined in SDL_thread.c */
struct SDL_Thread { }

/* Create a thread */
SDL_Thread * SDL_CreateThread(int function(void *) fn, void *data);

/* Get the 32-bit thread identifier for the current thread */
Uint32 SDL_ThreadID();

/* Get the 32-bit thread identifier for the specified thread,
   equivalent to SDL_ThreadID() if the specified thread is NULL.
 */
Uint32 SDL_GetThreadID(SDL_Thread *thread);

/* Wait for a thread to finish.
   The return code for the thread function is placed in the area
   pointed to by 'status', if 'status' is not NULL.
 */
void SDL_WaitThread(SDL_Thread *thread, int *status);

/* Forcefully kill a thread without worrying about its state */
void SDL_KillThread(SDL_Thread *thread);
/*
    SDL - Simple DirectMedia Layer
    Copyright (C) 1997, 1998, 1999, 2000, 2001  Sam Lantinga

    This library is free software; you can redistribute it and/or
    modify it under the terms of the GNU Library General Public
    License as published by the Free Software Foundation; either
    version 2 of the License, or (at your option) any later version.

    This library is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
    Library General Public License for more details.

    You should have received a copy of the GNU Library General Public
    License along with this library; if not, write to the Free
    Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA

    Sam Lantinga
    slouken@devolution.com
*/

extern(C):

/* This is the OS scheduler timeslice, in milliseconds */
const uint SDL_TIMESLICE	= 10;

/* This is the maximum resolution of the SDL timer on all platforms */
const uint TIMER_RESOLUTION	= 10;	/* Experimentally determined */

/* Get the number of milliseconds since the SDL library initialization.
 * Note that this value wraps if the program runs for more than ~49 days.
 */
Uint32 SDL_GetTicks();

/* Wait a specified number of milliseconds before returning */
void SDL_Delay(Uint32 ms);

/* Function prototype for the timer callback function */
alias Uint32 function(Uint32 interval) SDL_TimerCallback;

/* Set a callback to run after the specified number of milliseconds has
 * elapsed. The callback function is passed the current timer interval
 * and returns the next timer interval.  If the returned value is the
 * same as the one passed in, the periodic alarm continues, otherwise a
 * new alarm is scheduled.  If the callback returns 0, the periodic alarm
 * is cancelled.
 *
 * To cancel a currently running timer, call SDL_SetTimer(0, NULL);
 *
 * The timer callback function may run in a different thread than your
 * main code, and so shouldn't call any functions from within itself.
 *
 * The maximum resolution of this timer is 10 ms, which means that if
 * you request a 16 ms timer, your callback will run approximately 20 ms
 * later on an unloaded system.  If you wanted to set a flag signaling
 * a frame update at 30 frames per second (every 33 ms), you might set a
 * timer for 30 ms:
 *   SDL_SetTimer((33/10)*10, flag_update);
 *
 * If you use this function, you need to pass SDL_INIT_TIMER to SDL_Init().
 *
 * Under UNIX, you should not use raise or use SIGALRM and this function
 * in the same program, as it is implemented using setitimer().  You also
 * should not use this function in multi-threaded applications as signals
 * to multi-threaded apps have undefined behavior in some implementations.
 */
int SDL_SetTimer(Uint32 interval, SDL_TimerCallback callback);

/* New timer API, supports multiple timers
 * Written by Stephane Peter <megastep@lokigames.com>
 */

/* Function prototype for the new timer callback function.
 * The callback function is passed the current timer interval and returns
 * the next timer interval.  If the returned value is the same as the one
 * passed in, the periodic alarm continues, otherwise a new alarm is
 * scheduled.  If the callback returns 0, the periodic alarm is cancelled.
 */
alias Uint32 function(Uint32 interval, void *param) SDL_NewTimerCallback;

/* Definition of the timer ID type */
alias void *SDL_TimerID;

/* Add a new timer to the pool of timers already running.
   Returns a timer ID, or NULL when an error occurs.
 */
SDL_TimerID SDL_AddTimer(Uint32 interval, SDL_NewTimerCallback callback, void *param);

/* Remove one of the multiple timers knowing its ID.
 * Returns a boolean value indicating success.
 */
SDL_bool SDL_RemoveTimer(SDL_TimerID t);
/*
    SDL - Simple DirectMedia Layer
    Copyright (C) 1997, 1998, 1999, 2000, 2001  Sam Lantinga

    This library is free software; you can redistribute it and/or
    modify it under the terms of the GNU Library General Public
    License as published by the Free Software Foundation; either
    version 2 of the License, or (at your option) any later version.

    This library is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
    Library General Public License for more details.

    You should have received a copy of the GNU Library General Public
    License along with this library; if not, write to the Free
    Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA

    Sam Lantinga
    slouken@devolution.com
*/

/* General data types used by the SDL library */

/* Basic data types */
alias int SDL_bool;
enum {
	SDL_FALSE = 0,
	SDL_TRUE  = 1
}
alias ubyte	Uint8;
alias byte	Sint8;
alias ushort	Uint16;
alias short	Sint16;
alias uint	Uint32;
alias int		Sint32;

alias ulong	Uint64;
alias long	Sint64;

/* General keyboard/mouse state definitions */
enum { SDL_PRESSED = 0x01, SDL_RELEASED = 0x00 };

/*
    SDL - Simple DirectMedia Layer
    Copyright (C) 1997, 1998, 1999, 2000, 2001  Sam Lantinga

    This library is free software; you can redistribute it and/or
    modify it under the terms of the GNU Library General Public
    License as published by the Free Software Foundation; either
    version 2 of the License, or (at your option) any later version.

    This library is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
    Library General Public License for more details.

    You should have received a copy of the GNU Library General Public
    License along with this library; if not, write to the Free
    Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA

    Sam Lantinga
    slouken@devolution.com
*/

/* This header defines the current SDL version */

extern(C):

/* Printable format: "%d.%d.%d", MAJOR, MINOR, PATCHLEVEL
*/
const uint SDL_MAJOR_VERSION	= 1;
const uint SDL_MINOR_VERSION	= 2;
const uint SDL_PATCHLEVEL		= 6;

struct SDL_version {
	Uint8 major;
	Uint8 minor;
	Uint8 patch;
}

/* This macro can be used to fill a version structure with the compile-time
 * version of the SDL library.
 */
void SDL_VERSION(SDL_version* X)
{
	X.major = SDL_MAJOR_VERSION;
	X.minor = SDL_MINOR_VERSION;
	X.patch = SDL_PATCHLEVEL;
}

/* This macro turns the version numbers into a numeric value:
   (1,2,3) -> (1203)
   This assumes that there will never be more than 100 patchlevels
*/
uint SDL_VERSIONNUM(Uint8 X, Uint8 Y, Uint8 Z)
{
	return X * 1000 + Y * 100 + Z;
}

/* This is the version number macro for the current SDL version */
const uint SDL_COMPILEDVERSION = SDL_MAJOR_VERSION * 1000 +
									SDL_MINOR_VERSION * 100 +
									SDL_PATCHLEVEL;

/* This macro will evaluate to true if compiled with SDL at least X.Y.Z */
bool SDL_VERSION_ATLEAST(Uint8 X, Uint8 Y, Uint8 Z)
{
	return (SDL_COMPILEDVERSION >= SDL_VERSIONNUM(X, Y, Z));
}

/* This function gets the version of the dynamically linked SDL library.
   it should NOT be used to fill a version structure, instead you should
   use the SDL_Version() macro.
 */
SDL_version * SDL_Linked_Version();
/*
    SDL - Simple DirectMedia Layer
    Copyright (C) 1997, 1998, 1999, 2000, 2001  Sam Lantinga

    This library is free software; you can redistribute it and/or
    modify it under the terms of the GNU Library General Public
    License as published by the Free Software Foundation; either
    version 2 of the License, or (at your option) any later version.

    This library is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
    Library General Public License for more details.

    You should have received a copy of the GNU Library General Public
    License along with this library; if not, write to the Free
    Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA

    Sam Lantinga
    slouken@devolution.com
*/

/* Header file for access to the SDL raw framebuffer window */

extern(C):

/* Transparency definitions: These define alpha as the opacity of a surface */
const uint SDL_ALPHA_OPAQUE = 255;
const uint SDL_ALPHA_TRANSPARENT = 0;

/* Useful data types */
struct SDL_Rect {
	Sint16 x, y;
	Uint16 w, h;
}

struct SDL_Color {
	Uint8 r;
	Uint8 g;
	Uint8 b;
	Uint8 unused;
}

struct SDL_Palette {
	int       ncolors;
	SDL_Color *colors;
}

/* Everything in the pixel format structure is read-only */
struct SDL_PixelFormat {
	SDL_Palette *palette;
	Uint8  BitsPerPixel;
	Uint8  BytesPerPixel;
	Uint8  Rloss;
	Uint8  Gloss;
	Uint8  Bloss;
	Uint8  Aloss;
	Uint8  Rshift;
	Uint8  Gshift;
	Uint8  Bshift;
	Uint8  Ashift;
	Uint32 Rmask;
	Uint32 Gmask;
	Uint32 Bmask;
	Uint32 Amask;

	/* RGB color key information */
	Uint32 colorkey;
	/* Alpha value information (per-surface alpha) */
	Uint8  alpha;
}

/* typedef for private surface blitting functions */
alias int function(SDL_Surface *src, SDL_Rect *srcrect,
			SDL_Surface *dst, SDL_Rect *dstrect) SDL_blit;

/* This structure should be treated as read-only, except for 'pixels',
   which, if not NULL, contains the raw pixel data for the surface.
*/
struct SDL_Surface {
	Uint32 flags;				/* Read-only */
	SDL_PixelFormat *format;		/* Read-only */
	int w, h;				/* Read-only */
	Uint16 pitch;				/* Read-only */
	void *pixels;				/* Read-write */
	int offset;				/* Private */

	/* Hardware-specific surface info */
	void /*private_hwdata*/ *hwdata;

	/* clipping information */
	SDL_Rect clip_rect;			/* Read-only */
	Uint32 unused1;				/* for binary compatibility */

	/* Allow recursive locks */
	Uint32 locked;				/* Private */

	/* info for fast blit mapping to other surfaces */
	void /*SDL_BlitMap*/ *map;		/* Private */

	/* format version, bumped at every change to invalidate blit maps */
	uint format_version;		/* Private */

	/* Reference count -- used when freeing surface */
	int refcount;				/* Read-mostly */
}

/* These are the currently supported flags for the SDL_surface */
/* Available for SDL_CreateRGBSurface() or SDL_SetVideoMode() */
const uint SDL_SWSURFACE	= 0x00000000;	/* Surface is in system memory */
const uint SDL_HWSURFACE	= 0x00000001;	/* Surface is in video memory */
const uint SDL_ASYNCBLIT	= 0x00000004;	/* Use asynchronous blits if possible */
/* Available for SDL_SetVideoMode() */
const uint SDL_ANYFORMAT	= 0x10000000;	/* Allow any video depth/pixel-format */
const uint SDL_HWPALETTE	= 0x20000000;	/* Surface has exclusive palette */
const uint SDL_DOUBLEBUF	= 0x40000000;	/* Set up double-buffered video mode */
const uint SDL_FULLSCREEN	= 0x80000000;	/* Surface is a full screen display */
const uint SDL_OPENGL		= 0x00000002;	/* Create an OpenGL rendering context */
const uint SDL_OPENGLBLIT	= 0x0000000A;	/* Create an OpenGL rendering context and use it for blitting */
const uint SDL_RESIZABLE	= 0x00000010;	/* This video mode may be resized */
const uint SDL_NOFRAME	= 0x00000020;	/* No window caption or edge frame */
/* Used internally (read-only) */
const uint SDL_HWACCEL	= 0x00000100;	/* Blit uses hardware acceleration */
const uint SDL_SRCCOLORKEY	= 0x00001000;	/* Blit uses a source color key */
const uint SDL_RLEACCELOK	= 0x00002000;	/* Private flag */
const uint SDL_RLEACCEL	= 0x00004000;	/* Surface is RLE encoded */
const uint SDL_SRCALPHA	= 0x00010000;	/* Blit uses source alpha blending */
const uint SDL_PREALLOC	= 0x01000000;	/* Surface uses preallocated memory */

/* Evaluates to true if the surface needs to be locked before access */
bool SDL_MUSTLOCK(SDL_Surface *surface)
{
	return surface.offset || ((surface.flags &
		(SDL_HWSURFACE | SDL_ASYNCBLIT | SDL_RLEACCEL)) != 0);
}

/* Useful for determining the video hardware capabilities */
struct SDL_VideoInfo {
	Uint32 flags;
//		Uint32 hw_available :1;	/* Flag: Can you create hardware surfaces? */
//		Uint32 wm_available :1;	/* Flag: Can you talk to a window manager? */
//		Uint32 UnusedBits1  :6;
//		Uint32 UnusedBits2  :1;
//		Uint32 blit_hw      :1;	/* Flag: Accelerated blits HW -. HW */
//		Uint32 blit_hw_CC   :1;	/* Flag: Accelerated blits with Colorkey */
//		Uint32 blit_hw_A    :1;	/* Flag: Accelerated blits with Alpha */
//		Uint32 blit_sw      :1;	/* Flag: Accelerated blits SW -. HW */
//		Uint32 blit_sw_CC   :1;	/* Flag: Accelerated blits with Colorkey */
//		Uint32 blit_sw_A    :1;	/* Flag: Accelerated blits with Alpha */
//		Uint32 blit_fill    :1;	/* Flag: Accelerated color fill */
//		Uint32 UnusedBits3  :16;
	Uint32 video_mem;	/* The total amount of video memory (in K) */
	SDL_PixelFormat *vfmt;	/* Value: The format of the video surface */
}


/* The most common video overlay formats.
   For an explanation of these pixel formats, see:
	http://www.webartz.com/fourcc/indexyuv.htm

   For information on the relationship between color spaces, see:
   http://www.neuro.sfc.keio.ac.jp/~aly/polygon/info/color-space-faq.html
 */
const uint SDL_YV12_OVERLAY = 0x32315659;	/* Planar mode: Y + V + U  (3 planes) */
const uint SDL_IYUV_OVERLAY = 0x56555949;	/* Planar mode: Y + U + V  (3 planes) */
const uint SDL_YUY2_OVERLAY = 0x32595559;	/* Packed mode: Y0+U0+Y1+V0 (1 plane) */
const uint SDL_UYVY_OVERLAY = 0x59565955;	/* Packed mode: U0+Y0+V0+Y1 (1 plane) */
const uint SDL_YVYU_OVERLAY = 0x55595659;	/* Packed mode: Y0+V0+Y1+U0 (1 plane) */

/* The YUV hardware video overlay */
struct SDL_Overlay {
	Uint32 format;				/* Read-only */
	int w, h;				/* Read-only */
	int planes;				/* Read-only */
	Uint16 *pitches;			/* Read-only */
	Uint8 **pixels;				/* Read-write */

	/* Hardware-specific surface info */
	void /*private_yuvhwfuncs*/ *hwfuncs;
	void /*private_yuvhwdata*/ *hwdata;

	/* Special flags */
	union
	{
		byte hw_overlay;
		Uint32 _dummy;
	}
//		Uint32 hw_overlay :1;	/* Flag: This overlay hardware accelerated? */
//		Uint32 UnusedBits :31;
}


/* Public enumeration for setting the OpenGL window attributes. */
alias int SDL_GLattr;
enum {
    SDL_GL_RED_SIZE,
    SDL_GL_GREEN_SIZE,
    SDL_GL_BLUE_SIZE,
    SDL_GL_ALPHA_SIZE,
    SDL_GL_BUFFER_SIZE,
    SDL_GL_DOUBLEBUFFER,
    SDL_GL_DEPTH_SIZE,
    SDL_GL_STENCIL_SIZE,
    SDL_GL_ACCUM_RED_SIZE,
    SDL_GL_ACCUM_GREEN_SIZE,
    SDL_GL_ACCUM_BLUE_SIZE,
    SDL_GL_ACCUM_ALPHA_SIZE
}

/* flags for SDL_SetPalette() */
const uint SDL_LOGPAL = 0x01;
const uint SDL_PHYSPAL = 0x02;

/* Function prototypes */

/* These functions are used internally, and should not be used unless you
 * have a specific need to specify the video driver you want to use.
 * You should normally use SDL_Init() or SDL_InitSubSystem().
 *
 * SDL_VideoInit() initializes the video subsystem -- sets up a connection
 * to the window manager, etc, and determines the current video mode and
 * pixel format, but does not initialize a window or graphics mode.
 * Note that event handling is activated by this routine.
 *
 * If you use both sound and video in your application, you need to call
 * SDL_Init() before opening the sound device, otherwise under Win32 DirectX,
 * you won't be able to set full-screen display modes.
 */
int SDL_VideoInit(char *driver_name, Uint32 flags);
void SDL_VideoQuit();

/* This function fills the given character buffer with the name of the
 * video driver, and returns a pointer to it if the video driver has
 * been initialized.  It returns NULL if no driver has been initialized.
 */
char *SDL_VideoDriverName(char *namebuf, int maxlen);

/*
 * This function returns a pointer to the current display surface.
 * If SDL is doing format conversion on the display surface, this
 * function returns the publicly visible surface, not the real video
 * surface.
 */
SDL_Surface * SDL_GetVideoSurface();

/*
 * This function returns a read-only pointer to information about the
 * video hardware.  If this is called before SDL_SetVideoMode(), the 'vfmt'
 * member of the returned structure will contain the pixel format of the
 * "best" video mode.
 */
SDL_VideoInfo * SDL_GetVideoInfo();

/*
 * Check to see if a particular video mode is supported.
 * It returns 0 if the requested mode is not supported under any bit depth,
 * or returns the bits-per-pixel of the closest available mode with the
 * given width and height.  If this bits-per-pixel is different from the
 * one used when setting the video mode, SDL_SetVideoMode() will succeed,
 * but will emulate the requested bits-per-pixel with a shadow surface.
 *
 * The arguments to SDL_VideoModeOK() are the same ones you would pass to
 * SDL_SetVideoMode()
 */
int SDL_VideoModeOK(int width, int height, int bpp, Uint32 flags);

/*
 * Return a pointer to an array of available screen dimensions for the
 * given format and video flags, sorted largest to smallest.  Returns
 * NULL if there are no dimensions available for a particular format,
 * or (SDL_Rect **)-1 if any dimension is okay for the given format.
 *
 * If 'format' is NULL, the mode list will be for the format given
 * by SDL_GetVideoInfo().vfmt
 */
SDL_Rect ** SDL_ListModes(SDL_PixelFormat *format, Uint32 flags);

/*
 * Set up a video mode with the specified width, height and bits-per-pixel.
 *
 * If 'bpp' is 0, it is treated as the current display bits per pixel.
 *
 * If SDL_ANYFORMAT is set in 'flags', the SDL library will try to set the
 * requested bits-per-pixel, but will return whatever video pixel format is
 * available.  The default is to emulate the requested pixel format if it
 * is not natively available.
 *
 * If SDL_HWSURFACE is set in 'flags', the video surface will be placed in
 * video memory, if possible, and you may have to call SDL_LockSurface()
 * in order to access the raw framebuffer.  Otherwise, the video surface
 * will be created in system memory.
 *
 * If SDL_ASYNCBLIT is set in 'flags', SDL will try to perform rectangle
 * updates asynchronously, but you must always lock before accessing pixels.
 * SDL will wait for updates to complete before returning from the lock.
 *
 * If SDL_HWPALETTE is set in 'flags', the SDL library will guarantee
 * that the colors set by SDL_SetColors() will be the colors you get.
 * Otherwise, in 8-bit mode, SDL_SetColors() may not be able to set all
 * of the colors exactly the way they are requested, and you should look
 * at the video surface structure to determine the actual palette.
 * If SDL cannot guarantee that the colors you request can be set,
 * i.e. if the colormap is shared, then the video surface may be created
 * under emulation in system memory, overriding the SDL_HWSURFACE flag.
 *
 * If SDL_FULLSCREEN is set in 'flags', the SDL library will try to set
 * a fullscreen video mode.  The default is to create a windowed mode
 * if the current graphics system has a window manager.
 * If the SDL library is able to set a fullscreen video mode, this flag
 * will be set in the surface that is returned.
 *
 * If SDL_DOUBLEBUF is set in 'flags', the SDL library will try to set up
 * two surfaces in video memory and swap between them when you call
 * SDL_Flip().  This is usually slower than the normal single-buffering
 * scheme, but prevents "tearing" artifacts caused by modifying video
 * memory while the monitor is refreshing.  It should only be used by
 * applications that redraw the entire screen on every update.
 *
 * If SDL_RESIZABLE is set in 'flags', the SDL library will allow the
 * window manager, if any, to resize the window at runtime.  When this
 * occurs, SDL will send a SDL_VIDEORESIZE event to you application,
 * and you must respond to the event by re-calling SDL_SetVideoMode()
 * with the requested size (or another size that suits the application).
 *
 * If SDL_NOFRAME is set in 'flags', the SDL library will create a window
 * without any title bar or frame decoration.  Fullscreen video modes have
 * this flag set automatically.
 *
 * This function returns the video framebuffer surface, or NULL if it fails.
 *
 * If you rely on functionality provided by certain video flags, check the
 * flags of the returned surface to make sure that functionality is available.
 * SDL will fall back to reduced functionality if the exact flags you wanted
 * are not available.
 */
SDL_Surface *SDL_SetVideoMode
			(int width, int height, int bpp, Uint32 flags);

/*
 * Makes sure the given list of rectangles is updated on the given screen.
 * If 'x', 'y', 'w' and 'h' are all 0, SDL_UpdateRect will update the entire
 * screen.
 * These functions should not be called while 'screen' is locked.
 */
void SDL_UpdateRects
		(SDL_Surface *screen, int numrects, SDL_Rect *rects);
void SDL_UpdateRect
		(SDL_Surface *screen, Sint32 x, Sint32 y, Uint32 w, Uint32 h);

/*
 * On hardware that supports double-buffering, this function sets up a flip
 * and returns.  The hardware will wait for vertical retrace, and then swap
 * video buffers before the next video surface blit or lock will return.
 * On hardware that doesn not support double-buffering, this is equivalent
 * to calling SDL_UpdateRect(screen, 0, 0, 0, 0);
 * The SDL_DOUBLEBUF flag must have been passed to SDL_SetVideoMode() when
 * setting the video mode for this function to perform hardware flipping.
 * This function returns 0 if successful, or -1 if there was an error.
 */
int SDL_Flip(SDL_Surface *screen);

/*
 * Set the gamma correction for each of the color channels.
 * The gamma values range (approximately) between 0.1 and 10.0
 *
 * If this function isn't supported directly by the hardware, it will
 * be emulated using gamma ramps, if available.  If successful, this
 * function returns 0, otherwise it returns -1.
 */
int SDL_SetGamma(float red, float green, float blue);

/*
 * Set the gamma translation table for the red, green, and blue channels
 * of the video hardware.  Each table is an array of 256 16-bit quantities,
 * representing a mapping between the input and output for that channel.
 * The input is the index into the array, and the output is the 16-bit
 * gamma value at that index, scaled to the output color precision.
 *
 * You may pass NULL for any of the channels to leave it unchanged.
 * If the call succeeds, it will return 0.  If the display driver or
 * hardware does not support gamma translation, or otherwise fails,
 * this function will return -1.
 */
int SDL_SetGammaRamp(Uint16 *red, Uint16 *green, Uint16 *blue);

/*
 * Retrieve the current values of the gamma translation tables.
 *
 * You must pass in valid pointers to arrays of 256 16-bit quantities.
 * Any of the pointers may be NULL to ignore that channel.
 * If the call succeeds, it will return 0.  If the display driver or
 * hardware does not support gamma translation, or otherwise fails,
 * this function will return -1.
 */
int SDL_GetGammaRamp(Uint16 *red, Uint16 *green, Uint16 *blue);

/*
 * Sets a portion of the colormap for the given 8-bit surface.  If 'surface'
 * is not a palettized surface, this function does nothing, returning 0.
 * If all of the colors were set as passed to SDL_SetColors(), it will
 * return 1.  If not all the color entries were set exactly as given,
 * it will return 0, and you should look at the surface palette to
 * determine the actual color palette.
 *
 * When 'surface' is the surface associated with the current display, the
 * display colormap will be updated with the requested colors.  If
 * SDL_HWPALETTE was set in SDL_SetVideoMode() flags, SDL_SetColors()
 * will always return 1, and the palette is guaranteed to be set the way
 * you desire, even if the window colormap has to be warped or run under
 * emulation.
 */
int SDL_SetColors(SDL_Surface *surface,
			SDL_Color *colors, int firstcolor, int ncolors);

/*
 * Sets a portion of the colormap for a given 8-bit surface.
 * 'flags' is one or both of:
 * SDL_LOGPAL  -- set logical palette, which controls how blits are mapped
 *                to/from the surface,
 * SDL_PHYSPAL -- set physical palette, which controls how pixels look on
 *                the screen
 * Only screens have physical palettes. Separate change of physical/logical
 * palettes is only possible if the screen has SDL_HWPALETTE set.
 *
 * The return value is 1 if all colours could be set as requested, and 0
 * otherwise.
 *
 * SDL_SetColors() is equivalent to calling this function with
 *     flags = (SDL_LOGPAL|SDL_PHYSPAL).
 */
int SDL_SetPalette(SDL_Surface *surface, int flags,
				   SDL_Color *colors, int firstcolor,
				   int ncolors);

/*
 * Maps an RGB triple to an opaque pixel value for a given pixel format
 */
Uint32 SDL_MapRGB
			(SDL_PixelFormat *format, Uint8 r, Uint8 g, Uint8 b);

/*
 * Maps an RGBA quadruple to a pixel value for a given pixel format
 */
Uint32 SDL_MapRGBA(SDL_PixelFormat *format,
				   Uint8 r, Uint8 g, Uint8 b, Uint8 a);

/*
 * Maps a pixel value into the RGB components for a given pixel format
 */
void SDL_GetRGB(Uint32 pixel, SDL_PixelFormat *fmt,
				Uint8 *r, Uint8 *g, Uint8 *b);

/*
 * Maps a pixel value into the RGBA components for a given pixel format
 */
void SDL_GetRGBA(Uint32 pixel, SDL_PixelFormat *fmt,
				 Uint8 *r, Uint8 *g, Uint8 *b, Uint8 *a);

/*
 * Allocate and free an RGB surface (must be called after SDL_SetVideoMode)
 * If the depth is 4 or 8 bits, an empty palette is allocated for the surface.
 * If the depth is greater than 8 bits, the pixel format is set using the
 * flags '[RGB]mask'.
 * If the function runs out of memory, it will return NULL.
 *
 * The 'flags' tell what kind of surface to create.
 * SDL_SWSURFACE means that the surface should be created in system memory.
 * SDL_HWSURFACE means that the surface should be created in video memory,
 * with the same format as the display surface.  This is useful for surfaces
 * that will not change much, to take advantage of hardware acceleration
 * when being blitted to the display surface.
 * SDL_ASYNCBLIT means that SDL will try to perform asynchronous blits with
 * this surface, but you must always lock it before accessing the pixels.
 * SDL will wait for current blits to finish before returning from the lock.
 * SDL_SRCCOLORKEY indicates that the surface will be used for colorkey blits.
 * If the hardware supports acceleration of colorkey blits between
 * two surfaces in video memory, SDL will try to place the surface in
 * video memory. If this isn't possible or if there is no hardware
 * acceleration available, the surface will be placed in system memory.
 * SDL_SRCALPHA means that the surface will be used for alpha blits and
 * if the hardware supports hardware acceleration of alpha blits between
 * two surfaces in video memory, to place the surface in video memory
 * if possible, otherwise it will be placed in system memory.
 * If the surface is created in video memory, blits will be _much_ faster,
 * but the surface format must be identical to the video surface format,
 * and the only way to access the pixels member of the surface is to use
 * the SDL_LockSurface() and SDL_UnlockSurface() calls.
 * If the requested surface actually resides in video memory, SDL_HWSURFACE
 * will be set in the flags member of the returned surface.  If for some
 * reason the surface could not be placed in video memory, it will not have
 * the SDL_HWSURFACE flag set, and will be created in system memory instead.
 */
SDL_Surface *SDL_CreateRGBSurface
			(Uint32 flags, int width, int height, int depth,
			Uint32 Rmask, Uint32 Gmask, Uint32 Bmask, Uint32 Amask);
SDL_Surface *SDL_CreateRGBSurfaceFrom(void *pixels,
			int width, int height, int depth, int pitch,
			Uint32 Rmask, Uint32 Gmask, Uint32 Bmask, Uint32 Amask);
void SDL_FreeSurface(SDL_Surface *surface);

SDL_Surface *SDL_AllocSurface
			(Uint32 flags, int width, int height, int depth,
			Uint32 Rmask, Uint32 Gmask, Uint32 Bmask, Uint32 Amask)
{
	return SDL_CreateRGBSurface(flags, width, height, depth,
		Rmask, Gmask, Bmask, Amask);
}

/*
 * SDL_LockSurface() sets up a surface for directly accessing the pixels.
 * Between calls to SDL_LockSurface()/SDL_UnlockSurface(), you can write
 * to and read from 'surface.pixels', using the pixel format stored in
 * 'surface.format'.  Once you are done accessing the surface, you should
 * use SDL_UnlockSurface() to release it.
 *
 * Not all surfaces require locking.  If SDL_MUSTLOCK(surface) evaluates
 * to 0, then you can read and write to the surface at any time, and the
 * pixel format of the surface will not change.  In particular, if the
 * SDL_HWSURFACE flag is not given when calling SDL_SetVideoMode(), you
 * will not need to lock the display surface before accessing it.
 *
 * No operating system or library calls should be made between lock/unlock
 * pairs, as critical system locks may be held during this time.
 *
 * SDL_LockSurface() returns 0, or -1 if the surface couldn't be locked.
 */
int SDL_LockSurface(SDL_Surface *surface);
void SDL_UnlockSurface(SDL_Surface *surface);

/*
 * Load a surface from a seekable SDL data source (memory or file.)
 * If 'freesrc' is non-zero, the source will be closed after being read.
 * Returns the new surface, or NULL if there was an error.
 * The new surface should be freed with SDL_FreeSurface().
 */
SDL_Surface * SDL_LoadBMP_RW(SDL_RWops *src, int freesrc);

/* Convenience macro -- load a surface from a file */
SDL_Surface * SDL_LoadBMP(const(char)* file)
{
	return SDL_LoadBMP_RW(SDL_RWFromFile(file, "rb"), 1);
}

/*
 * Save a surface to a seekable SDL data source (memory or file.)
 * If 'freedst' is non-zero, the source will be closed after being written.
 * Returns 0 if successful or -1 if there was an error.
 */
int SDL_SaveBMP_RW
		(SDL_Surface *surface, SDL_RWops *dst, int freedst);

/* Convenience macro -- save a surface to a file */
int SDL_SaveBMP(SDL_Surface *surface, const(char)* file)
{
	return SDL_SaveBMP_RW(surface, SDL_RWFromFile(file, "wb"), 1);
}

/*
 * Sets the color key (transparent pixel) in a blittable surface.
 * If 'flag' is SDL_SRCCOLORKEY (optionally OR'd with SDL_RLEACCEL),
 * 'key' will be the transparent pixel in the source image of a blit.
 * SDL_RLEACCEL requests RLE acceleration for the surface if present,
 * and removes RLE acceleration if absent.
 * If 'flag' is 0, this function clears any current color key.
 * This function returns 0, or -1 if there was an error.
 */
int SDL_SetColorKey
			(SDL_Surface *surface, Uint32 flag, Uint32 key);

/*
 * This function sets the alpha value for the entire surface, as opposed to
 * using the alpha component of each pixel. This value measures the range
 * of transparency of the surface, 0 being completely transparent to 255
 * being completely opaque. An 'alpha' value of 255 causes blits to be
 * opaque, the source pixels copied to the destination (the default). Note
 * that per-surface alpha can be combined with colorkey transparency.
 *
 * If 'flag' is 0, alpha blending is disabled for the surface.
 * If 'flag' is SDL_SRCALPHA, alpha blending is enabled for the surface.
 * OR:ing the flag with SDL_RLEACCEL requests RLE acceleration for the
 * surface; if SDL_RLEACCEL is not specified, the RLE accel will be removed.
 */
int SDL_SetAlpha(SDL_Surface *surface, Uint32 flag, Uint8 alpha);

/*
 * Sets the clipping rectangle for the destination surface in a blit.
 *
 * If the clip rectangle is NULL, clipping will be disabled.
 * If the clip rectangle doesn't intersect the surface, the function will
 * return SDL_FALSE and blits will be completely clipped.  Otherwise the
 * function returns SDL_TRUE and blits to the surface will be clipped to
 * the intersection of the surface area and the clipping rectangle.
 *
 * Note that blits are automatically clipped to the edges of the source
 * and destination surfaces.
 */
SDL_bool SDL_SetClipRect(SDL_Surface *surface, SDL_Rect *rect);

/*
 * Gets the clipping rectangle for the destination surface in a blit.
 * 'rect' must be a pointer to a valid rectangle which will be filled
 * with the correct values.
 */
void SDL_GetClipRect(SDL_Surface *surface, SDL_Rect *rect);

/*
 * Creates a new surface of the specified format, and then copies and maps
 * the given surface to it so the blit of the converted surface will be as
 * fast as possible.  If this function fails, it returns NULL.
 *
 * The 'flags' parameter is passed to SDL_CreateRGBSurface() and has those
 * semantics.  You can also pass SDL_RLEACCEL in the flags parameter and
 * SDL will try to RLE accelerate colorkey and alpha blits in the resulting
 * surface.
 *
 * This function is used internally by SDL_DisplayFormat().
 */
SDL_Surface *SDL_ConvertSurface
			(SDL_Surface *src, SDL_PixelFormat *fmt, Uint32 flags);

/*
 * This performs a fast blit from the source surface to the destination
 * surface.  It assumes that the source and destination rectangles are
 * the same size.  If either 'srcrect' or 'dstrect' are NULL, the entire
 * surface (src or dst) is copied.  The final blit rectangles are saved
 * in 'srcrect' and 'dstrect' after all clipping is performed.
 * If the blit is successful, it returns 0, otherwise it returns -1.
 *
 * The blit function should not be called on a locked surface.
 *
 * The blit semantics for surfaces with and without alpha and colorkey
 * are defined as follows:
 *
 * RGBA.RGB:
 *     SDL_SRCALPHA set:
 * 	alpha-blend (using alpha-channel).
 * 	SDL_SRCCOLORKEY ignored.
 *     SDL_SRCALPHA not set:
 * 	copy RGB.
 * 	if SDL_SRCCOLORKEY set, only copy the pixels matching the
 * 	RGB values of the source colour key, ignoring alpha in the
 * 	comparison.
 *
 * RGB.RGBA:
 *     SDL_SRCALPHA set:
 * 	alpha-blend (using the source per-surface alpha value);
 * 	set destination alpha to opaque.
 *     SDL_SRCALPHA not set:
 * 	copy RGB, set destination alpha to opaque.
 *     both:
 * 	if SDL_SRCCOLORKEY set, only copy the pixels matching the
 * 	source colour key.
 *
 * RGBA.RGBA:
 *     SDL_SRCALPHA set:
 * 	alpha-blend (using the source alpha channel) the RGB values;
 * 	leave destination alpha untouched. [Note: is this correct?]
 * 	SDL_SRCCOLORKEY ignored.
 *     SDL_SRCALPHA not set:
 * 	copy all of RGBA to the destination.
 * 	if SDL_SRCCOLORKEY set, only copy the pixels matching the
 * 	RGB values of the source colour key, ignoring alpha in the
 * 	comparison.
 *
 * RGB.RGB:
 *     SDL_SRCALPHA set:
 * 	alpha-blend (using the source per-surface alpha value).
 *     SDL_SRCALPHA not set:
 * 	copy RGB.
 *     both:
 * 	if SDL_SRCCOLORKEY set, only copy the pixels matching the
 * 	source colour key.
 *
 * If either of the surfaces were in video memory, and the blit returns -2,
 * the video memory was lost, so it should be reloaded with artwork and
 * re-blitted:
	while ( SDL_BlitSurface(image, imgrect, screen, dstrect) == -2 ) {
		while ( SDL_LockSurface(image) < 0 )
			Sleep(10);
		-- Write image pixels to image.pixels --
		SDL_UnlockSurface(image);
	}
 * This happens under DirectX 5.0 when the system switches away from your
 * fullscreen application.  The lock will also fail until you have access
 * to the video memory again.
 */
/* You should call SDL_BlitSurface() unless you know exactly how SDL
   blitting works internally and how to use the other blit functions.
*/

/* This is the public blit function, SDL_BlitSurface(), and it performs
   rectangle validation and clipping before passing it to SDL_LowerBlit()
*/
int SDL_UpperBlit
			(SDL_Surface *src, SDL_Rect *srcrect,
			 SDL_Surface *dst, SDL_Rect *dstrect);
/* This is a semi-private blit function and it performs low-level surface
   blitting only.
*/
int SDL_LowerBlit
			(SDL_Surface *src, SDL_Rect *srcrect,
			 SDL_Surface *dst, SDL_Rect *dstrect);

int SDL_BlitSurface
			(SDL_Surface *src, SDL_Rect *srcrect,
			 SDL_Surface *dst, SDL_Rect *dstrect)
{
	return SDL_UpperBlit(src, srcrect, dst, dstrect);
}

/*
 * This function performs a fast fill of the given rectangle with 'color'
 * The given rectangle is clipped to the destination surface clip area
 * and the final fill rectangle is saved in the passed in pointer.
 * If 'dstrect' is NULL, the whole surface will be filled with 'color'
 * The color should be a pixel of the format used by the surface, and
 * can be generated by the SDL_MapRGB() function.
 * This function returns 0 on success, or -1 on error.
 */
int SDL_FillRect
		(SDL_Surface *dst, SDL_Rect *dstrect, Uint32 color);

/*
 * This function takes a surface and copies it to a new surface of the
 * pixel format and colors of the video framebuffer, suitable for fast
 * blitting onto the display surface.  It calls SDL_ConvertSurface()
 *
 * If you want to take advantage of hardware colorkey or alpha blit
 * acceleration, you should set the colorkey and alpha value before
 * calling this function.
 *
 * If the conversion fails or runs out of memory, it returns NULL
 */
SDL_Surface * SDL_DisplayFormat(SDL_Surface *surface);

/*
 * This function takes a surface and copies it to a new surface of the
 * pixel format and colors of the video framebuffer (if possible),
 * suitable for fast alpha blitting onto the display surface.
 * The new surface will always have an alpha channel.
 *
 * If you want to take advantage of hardware colorkey or alpha blit
 * acceleration, you should set the colorkey and alpha value before
 * calling this function.
 *
 * If the conversion fails or runs out of memory, it returns NULL
 */
SDL_Surface * SDL_DisplayFormatAlpha(SDL_Surface *surface);


/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */
/* YUV video surface overlay functions                                       */
/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */

/* This function creates a video output overlay
   Calling the returned surface an overlay is something of a misnomer because
   the contents of the display surface underneath the area where the overlay
   is shown is undefined - it may be overwritten with the converted YUV data.
*/
SDL_Overlay *SDL_CreateYUVOverlay(int width, int height,
				Uint32 format, SDL_Surface *display);

/* Lock an overlay for direct access, and unlock it when you are done */
int SDL_LockYUVOverlay(SDL_Overlay *overlay);
void SDL_UnlockYUVOverlay(SDL_Overlay *overlay);

/* Blit a video overlay to the display surface.
   The contents of the video surface underneath the blit destination are
   not defined.
   The width and height of the destination rectangle may be different from
   that of the overlay, but currently only 2x scaling is supported.
*/
int SDL_DisplayYUVOverlay(SDL_Overlay *overlay, SDL_Rect *dstrect);

/* Free a video overlay */
void SDL_FreeYUVOverlay(SDL_Overlay *overlay);


/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */
/* OpenGL support functions.                                                 */
/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */

/*
 * Dynamically load a GL driver, if SDL is built with dynamic GL.
 *
 * SDL links normally with the OpenGL library on your system by default,
 * but you can compile it to dynamically load the GL driver at runtime.
 * If you do this, you need to retrieve all of the GL functions used in
 * your program from the dynamic library using SDL_GL_GetProcAddress().
 *
 * This is disabled in default builds of SDL.
 */
int SDL_GL_LoadLibrary(char *path);

/*
 * Get the address of a GL function (for extension functions)
 */
void *SDL_GL_GetProcAddress(const char* proc);

/*
 * Set an attribute of the OpenGL subsystem before intialization.
 */
int SDL_GL_SetAttribute(SDL_GLattr attr, int value);

/*
 * Get an attribute of the OpenGL subsystem from the windowing
 * interface, such as glX. This is of course different from getting
 * the values from SDL's internal OpenGL subsystem, which only
 * stores the values you request before initialization.
 *
 * Developers should track the values they pass into SDL_GL_SetAttribute
 * themselves if they want to retrieve these values.
 */
int SDL_GL_GetAttribute(SDL_GLattr attr, int* value);

/*
 * Swap the OpenGL buffers, if double-buffering is supported.
 */
void SDL_GL_SwapBuffers();

/*
 * Internal functions that should not be called unless you have read
 * and understood the source code for these functions.
 */
void SDL_GL_UpdateRects(int numrects, SDL_Rect* rects);
void SDL_GL_Lock();
void SDL_GL_Unlock();

/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */
/* These functions allow interaction with the window manager, if any.        */
/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */

/*
 * Sets/Gets the title and icon text of the display window
 */
void SDL_WM_SetCaption(const char *title, char *icon);
void SDL_WM_GetCaption(char **title, char **icon);

/*
 * Sets the icon for the display window.
 * This function must be called before the first call to SDL_SetVideoMode().
 * It takes an icon surface, and a mask in MSB format.
 * If 'mask' is NULL, the entire icon surface will be used as the icon.
 */
void SDL_WM_SetIcon(SDL_Surface *icon, Uint8 *mask);

/*
 * This function iconifies the window, and returns 1 if it succeeded.
 * If the function succeeds, it generates an SDL_APPACTIVE loss event.
 * This function is a noop and returns 0 in non-windowed environments.
 */
int SDL_WM_IconifyWindow();

/*
 * Toggle fullscreen mode without changing the contents of the screen.
 * If the display surface does not require locking before accessing
 * the pixel information, then the memory pointers will not change.
 *
 * If this function was able to toggle fullscreen mode (change from
 * running in a window to fullscreen, or vice-versa), it will return 1.
 * If it is not implemented, or fails, it returns 0.
 *
 * The next call to SDL_SetVideoMode() will set the mode fullscreen
 * attribute based on the flags parameter - if SDL_FULLSCREEN is not
 * set, then the display will be windowed by default where supported.
 *
 * This is currently only implemented in the X11 video driver.
 */
int SDL_WM_ToggleFullScreen(SDL_Surface *surface);

/*
 * This function allows you to set and query the input grab state of
 * the application.  It returns the new input grab state.
 */
alias int SDL_GrabMode;
enum {
	SDL_GRAB_QUERY = -1,
	SDL_GRAB_OFF = 0,
	SDL_GRAB_ON = 1,
	SDL_GRAB_FULLSCREEN	/* Used internally */
}
/*
 * Grabbing means that the mouse is confined to the application window,
 * and nearly all keyboard input is passed directly to the application,
 * and not interpreted by a window manager, if any.
 */
SDL_GrabMode SDL_WM_GrabInput(SDL_GrabMode mode);

/* Not in public API at the moment - do not use! */
int SDL_SoftStretch(SDL_Surface *src, SDL_Rect *srcrect,
                                    SDL_Surface *dst, SDL_Rect *dstrect);
/*
    SDL - Simple DirectMedia Layer
    Copyright (C) 1997, 1998, 1999, 2000, 2001  Sam Lantinga

    This library is free software; you can redistribute it and/or
    modify it under the terms of the GNU Library General Public
    License as published by the Free Software Foundation; either
    version 2 of the License, or (at your option) any later version.

    This library is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
    Library General Public License for more details.

    You should have received a copy of the GNU Library General Public
    License along with this library; if not, write to the Free
    Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA

    Sam Lantinga
    slouken@devolution.com
*/

extern(C):

/* As of version 0.5, SDL is loaded dynamically into the application */

/* These are the flags which may be passed to SDL_Init() -- you should
   specify the subsystems which you will be using in your application.
*/
const uint SDL_INIT_TIMER		= 0x00000001;
const uint SDL_INIT_AUDIO		= 0x00000010;
const uint SDL_INIT_VIDEO		= 0x00000020;
const uint SDL_INIT_CDROM		= 0x00000100;
const uint SDL_INIT_JOYSTICK	= 0x00000200;
const uint SDL_INIT_NOPARACHUTE	= 0x00100000;	/* Don't catch fatal signals */
const uint SDL_INIT_EVENTTHREAD	= 0x01000000;	/* Not supported on all OS's */
const uint SDL_INIT_EVERYTHING	= 0x0000FFFF;

/* This function loads the SDL dynamically linked library and initializes
 * the subsystems specified by 'flags' (and those satisfying dependencies)
 * Unless the SDL_INIT_NOPARACHUTE flag is set, it will install cleanup
 * signal handlers for some commonly ignored fatal signals (like SIGSEGV)
 */
int SDL_Init(Uint32 flags);

/* This function initializes specific SDL subsystems */
int SDL_InitSubSystem(Uint32 flags);

/* This function cleans up specific SDL subsystems */
void SDL_QuitSubSystem(Uint32 flags);

/* This function returns mask of the specified subsystems which have
   been initialized.
   If 'flags' is 0, it returns a mask of all initialized subsystems.
*/
Uint32 SDL_WasInit(Uint32 flags);

/* This function cleans up all initialized subsystems and unloads the
 * dynamically linked library.  You should call it upon all exit conditions.
 */
void SDL_Quit();

/+
void SDL_SetModuleHandle(void *hInst);
extern(Windows) void* GetModuleHandle(char*);

static this()
{
	/* Load SDL dynamic link library */
	if (SDL_Init(SDL_INIT_NOPARACHUTE) < 0)
		throw new Error("Error loading SDL");
	SDL_SetModuleHandle(GetModuleHandle(null));
}

static ~this()
{
	SDL_Quit();
}
+/


// SDL_gfx
void boxColor(SDL_Surface* s, int x1, int y1, int x2, int x2, uint c);
void boxRGBA(SDL_Surface* s, int x1, int y1, int x2, int x2, int r, int g, int b, int a);
void lineRGBA(SDL_Surface* s, int x1, int y1, int x2, int y2, int r, int g, int b, int a);
