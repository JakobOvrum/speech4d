module speech.windows.sapi;

import speech.windows.ObjIdl;

import core.sys.windows.windows;
import std.c.windows.com;
import std.bitmanip;

alias IID* REFIID;
alias CLSID* REFCLSID;
alias GUID* REFGUID;

extern(C) extern CLSID CLSID_SpVoice;
extern(C) extern IID IID_ISpVoice;

struct WAVEFORMATEX
{
    WORD    wFormatTag;        /* format type */
    WORD    nChannels;         /* number of channels (i.e. mono, stereo...) */
    DWORD   nSamplesPerSec;    /* sample rate */
    DWORD   nAvgBytesPerSec;   /* for buffer estimation */
    WORD    nBlockAlign;       /* block size of data */
    WORD    wBitsPerSample;    /* Number of bits per sample of mono data */
    WORD    cbSize;            /* The count in bytes of the size of
	extra information (after cbSize) */
}

alias WORD LANGID;

alias WCHAR SPPHONEID;
alias LPWSTR PSPPHONEID;      // Use this with NULL-terminated SPPHONEID strings.  This gives the proper SAL annotation.
alias LPCWSTR PCSPPHONEID;    // Use this with const NULL-terminated SPPHONEID strings.  This gives the proper SAL annotation.

//--- DataKey locations
enum
{
    SPDKL_DefaultLocation = 0,
	SPDKL_CurrentUser = 1,
	SPDKL_LocalMachine = 2,
	SPDKL_CurrentConfig = 5
}
alias typeof(SPDKL_DefaultLocation) SPDATAKEYLOCATION;

//--- ISpNotifyCallback -----------------------------------------------------

extern(C++) interface ISpNotifyCallback
{
	/+
	HRESULT STDMETHODCALLTYPE NotifyCallback(
		WPARAM wParam,
		LPARAM lParam);
	+/
}

alias extern(Windows) void function(WPARAM wParam, LPARAM lParam) SPNOTIFYCALLBACK;

//--- ISpNotifySource -------------------------------------------------------
interface ISpNotifySource : IUnknown
{
    HRESULT SetNotifySink(ISpNotifySink pNotifySink);
    HRESULT SetNotifyWindowMessage(
										   HWND hWnd, 
										   UINT Msg, 
										   WPARAM wParam, 
										   LPARAM lParam);
    HRESULT SetNotifyCallbackFunction(
											  SPNOTIFYCALLBACK pfnCallback, 
											  WPARAM wParam, 
											  LPARAM lParam);
    HRESULT SetNotifyCallbackInterface(
											   ISpNotifyCallback pSpCallback, 
											   WPARAM wParam, 
											   LPARAM lParam);
    HRESULT SetNotifyWin32Event();
    HRESULT WaitForNotifyEvent(DWORD dwMilliseconds);
    HANDLE  GetNotifyEventHandle();
}

//--- ISpNotifySink ---------------------------------------------------------
interface ISpNotifySink : IUnknown
{
    HRESULT Notify();
}

//--- ISpDataKey ------------------------------------------------------------
interface ISpDataKey : IUnknown
{
    HRESULT SetData( LPCWSTR pszValueName, ULONG cbData, const BYTE * pData);
    HRESULT GetData( LPCWSTR pszValueName, ULONG * pcbData, BYTE * pData);
    HRESULT SetStringValue( LPCWSTR pszValueName, LPCWSTR pszValue );
    HRESULT GetStringValue( LPCWSTR pszValueName, LPWSTR * ppszValue);
    HRESULT SetDWORD(LPCWSTR pszValueName, DWORD dwValue );
    HRESULT GetDWORD(LPCWSTR pszValueName, DWORD *pdwValue );
    HRESULT OpenKey(LPCWSTR pszSubKeyName, ISpDataKey * ppSubKey);
    HRESULT CreateKey(LPCWSTR pszSubKey, ISpDataKey * ppSubKey);
    HRESULT DeleteKey(LPCWSTR pszSubKey);
    HRESULT DeleteValue(LPCWSTR pszValueName);
    HRESULT EnumKeys(ULONG Index, LPWSTR * ppszSubKeyName);
    HRESULT EnumValues(ULONG Index, LPWSTR * ppszValueName);
};

//--- ISpRegDataKey ---------------------------------------------------------
interface ISpRegDataKey : ISpDataKey
{
    HRESULT SetKey(HKEY hkey, BOOL fReadOnly);
}

//--- ISpObjectTokenCategory ------------------------------------------------
interface ISpObjectTokenCategory : ISpDataKey
{
    HRESULT SetId(LPCWSTR pszCategoryId, BOOL fCreateIfNotExist);
    HRESULT GetId(LPWSTR * ppszCoMemCategoryId);
    HRESULT GetDataKey(SPDATAKEYLOCATION spdkl, ISpDataKey * ppDataKey);

    HRESULT EnumTokens(
					   LPCWSTR pzsReqAttribs, 
					   LPCWSTR pszOptAttribs, 
					   IEnumSpObjectTokens* ppEnum);

    HRESULT SetDefaultTokenId(LPCWSTR pszTokenId);
    HRESULT GetDefaultTokenId(LPWSTR * ppszCoMemTokenId);
};

//--- ISpObjectToken --------------------------------------------------------
interface ISpObjectToken : ISpDataKey
{
    HRESULT SetId(LPCWSTR pszCategoryId, LPCWSTR pszTokenId, BOOL fCreateIfNotExist);
    HRESULT GetId(LPWSTR * ppszCoMemTokenId);
    HRESULT GetCategory(ISpObjectTokenCategory * ppTokenCategory);

    HRESULT CreateInstance(
						   IUnknown pUnkOuter, 
						   DWORD dwClsContext,
						   REFIID riid, 
						   void ** ppvObject);

    HRESULT GetStorageFileName(
							   REFCLSID clsidCaller,
							   LPCWSTR pszValueName,
							   LPCWSTR pszFileNameSpecifier,
							   ULONG nFolder,       // Same as SHGetFolderPath -- If non-zero, must set CSIDL_FLAG_CREATE
							   LPWSTR * ppszFilePath);
    HRESULT RemoveStorageFileName(
								  REFCLSID clsidCaller,
								  LPCWSTR pszKeyName,
								  BOOL fDeleteFile);

    HRESULT Remove(const CLSID * pclsidCaller);

    HRESULT IsUISupported(
								  LPCWSTR pszTypeOfUI,
								  void * pvExtraData,
								  ULONG cbExtraData,
								  IUnknown punkObject,
								  BOOL *pfSupported);
    HRESULT DisplayUI(
							  HWND hwndParent,
							  LPCWSTR pszTitle,
							  LPCWSTR pszTypeOfUI,
							  void * pvExtraData,
							  ULONG cbExtraData,
							  IUnknown punkObject);
    HRESULT MatchesAttributes(
							  LPCWSTR pszAttributes, 
							  BOOL *pfMatches);
};

interface ISpObjectTokenInit : ISpObjectToken
{
    HRESULT InitFromDataKey(
							LPCWSTR pszCategoryId, 
							LPCWSTR pszTokenId, 
							ISpDataKey pDataKey);
};

//--- IEnumSpObjectTokens ---------------------------------------------------
// This interface is used to enumerate speech object tokens

interface IEnumSpObjectTokens : IUnknown
{
    HRESULT Next(ULONG celt,
                 ISpObjectToken * pelt,
                 ULONG *pceltFetched);
    HRESULT Skip(ULONG celt);

    HRESULT Reset();
    HRESULT Clone(IEnumSpObjectTokens *ppEnum);

    HRESULT Item(ULONG Index, ISpObjectToken * ppToken);

    HRESULT GetCount(ULONG* pCount);
};

//--- ISpEventSource --------------------------------------------------------
enum
{
    SPET_LPARAM_IS_UNDEFINED = 0,
	SPET_LPARAM_IS_TOKEN,
	SPET_LPARAM_IS_OBJECT,
	SPET_LPARAM_IS_POINTER,
	SPET_LPARAM_IS_STRING,
}
alias typeof(SPET_LPARAM_IS_UNDEFINED) SPEVENTLPARAMTYPE;

enum
{
    SPEI_UNDEFINED           = 0,

	//--- TTS engine
	SPEI_START_INPUT_STREAM  = 1,
	SPEI_END_INPUT_STREAM    = 2,
	SPEI_VOICE_CHANGE        = 3,   // LPARAM_IS_TOKEN
	SPEI_TTS_BOOKMARK        = 4,   // LPARAM_IS_STRING
	SPEI_WORD_BOUNDARY       = 5,
	SPEI_PHONEME             = 6,
	SPEI_SENTENCE_BOUNDARY   = 7,
	SPEI_VISEME              = 8,
	SPEI_TTS_AUDIO_LEVEL     = 9,   // wParam contains current output audio level

	SPEI_TTS_PRIVATE         = 15, //--- Engine vendors use this reserved value.

	SPEI_MIN_TTS             = 1,
	SPEI_MAX_TTS             = 15,

	//--- Speech Recognition
	SPEI_END_SR_STREAM       = 34,      // LPARAM contains HRESULT, WPARAM contains flags (SPESF_xxx)
	SPEI_SOUND_START         = 35,
	SPEI_SOUND_END           = 36,
	SPEI_PHRASE_START        = 37,
	SPEI_RECOGNITION         = 38,
	SPEI_HYPOTHESIS          = 39,
	SPEI_SR_BOOKMARK         = 40,
	SPEI_PROPERTY_NUM_CHANGE   = 41,  // LPARAM points to a string, WPARAM is the attrib value
	SPEI_PROPERTY_STRING_CHANGE= 42,  // LPARAM pointer to buffer.  Two concatinated null terminated strings.
	SPEI_FALSE_RECOGNITION   = 43,  // apparent speech with no valid recognition
	SPEI_INTERFERENCE        = 44,  // LPARAM is any combination of SPINTERFERENCE flags
	SPEI_REQUEST_UI          = 45,  // LPARAM is string.  
	SPEI_RECO_STATE_CHANGE   = 46,  // wParam contains new reco state
	SPEI_ADAPTATION          = 47,  // we are now ready to accept the adaptation buffer
	SPEI_START_SR_STREAM     = 48,
	SPEI_RECO_OTHER_CONTEXT  = 49,  // Phrase finished and recognized, but for other context
	SPEI_SR_AUDIO_LEVEL      = 50,  // wParam contains current input audio level
	/+
	#if _SAPI_BUILD_VER >= 0x053
	SPEI_SR_RETAINEDAUDIO    = 51,
	#endif // _SAPI_BUILD_VER >= 0x053
	+/
	SPEI_SR_PRIVATE          = 52, // Engine vendors use this reserved value.
	/+
	#if _SAPI_BUILD_VER >= 0x053
	#if _SAPI_BUILD_VER >= 0x054
	SPEI_ACTIVE_CATEGORY_CHANGED = 53, // WPARAM and LPARAM are null.
	#else // _SAPI_BUILD_VER >= 0x054
	SPEI_RESERVED4           = 53, // Reserved for system use.
	#endif // _SAPI_BUILD_VER >= 0x054
	SPEI_RESERVED5           = 54, // Reserved for system use.
	SPEI_RESERVED6           = 55, // Reserved for system use.
	#endif // _SAPI_BUILD_VER >= 0x053
	+/

	SPEI_MIN_SR              = 34,
	/+
	#if _SAPI_BUILD_VER >= 0x053
	SPEI_MAX_SR              = 55,  // Value in SAPI 5.3
	#else 
	SPEI_MAX_SR              = 52,  // Value in SAPI 5.1
	#endif // _SAPI_BUILD_VER >= 0x053
	+/

	SPEI_RESERVED1           = 30,  // do not use
	SPEI_RESERVED2           = 33,  // do not use
	SPEI_RESERVED3           = 63   // do not use
}
alias typeof(SPEI_UNDEFINED) SPEVENTENUM;

//cpp_quote("#define SPFEI_FLAGCHECK ( (1ui64 << SPEI_RESERVED1) | (1ui64 << SPEI_RESERVED2) )")

//cpp_quote("#define SPFEI_ALL_TTS_EVENTS (0x000000000000FFFEui64 | SPFEI_FLAGCHECK)")
//cpp_quote("#define SPFEI_ALL_SR_EVENTS  (0x001FFFFC00000000ui64 | SPFEI_FLAGCHECK)")
//cpp_quote("#define SPFEI_ALL_EVENTS      0xEFFFFFFFFFFFFFFFui64")

// The SPFEI macro converts an SPEVENTENUM event value into a 64-bit value.
// Multiple values can then be OR-ed together and passed to SetInterest.
//cpp_quote("#define SPFEI(SPEI_ord) ((1ui64 << SPEI_ord) | SPFEI_FLAGCHECK)")

struct SPEVENT
{
	mixin(bitfields!(
		SPEVENTENUM, "eEventId", 16,
		SPEVENTLPARAMTYPE, "elParamType", 16
	));

    ULONG       ulStreamNum;
    ULONGLONG   ullAudioStreamOffset;
    WPARAM      wParam;
    LPARAM      lParam;
}

struct SPSERIALIZEDEVENT
{
	mixin(bitfields!(
		SPEVENTENUM, "eEventId", 16,
		SPEVENTLPARAMTYPE, "elParamType", 16
	));

    ULONG       ulStreamNum;
    ULONGLONG   ullAudioStreamOffset;
    ULONG       SerializedwParam;
    LONG        SerializedlParam;
}

struct SPSERIALIZEDEVENT64
{
	mixin(bitfields!(
		SPEVENTENUM, "eEventId", 16,
		SPEVENTLPARAMTYPE, "elParamType", 16
	));

    ULONG       ulStreamNum;
    ULONGLONG   ullAudioStreamOffset;
    ULONGLONG   SerializedwParam;
    LONGLONG    SerializedlParam;
}

/+
#if _SAPI_BUILD_VER >= 0x053
cpp_quote("#if 0")
typedef [restricted, hidden] struct SPEVENTEX
{
    WORD        eEventId;      //SPEVENTENUM
    WORD        elParamType;   //SPEVENTLPARAMTYPE
    ULONG       ulStreamNum;        // Input stream number this event is associated with
    ULONGLONG   ullAudioStreamOffset;
    WPARAM      wParam;
    LPARAM      lParam;
    ULONGLONG   ullAudioTimeOffset;
} SPEVENTEX;

cpp_quote("#else")
cpp_quote("typedef struct SPEVENTEX")
cpp_quote("{")
cpp_quote("    SPEVENTENUM        eEventId : 16;")
cpp_quote("    SPEVENTLPARAMTYPE  elParamType : 16;")
cpp_quote("    ULONG       ulStreamNum;")
cpp_quote("    ULONGLONG   ullAudioStreamOffset;")
cpp_quote("    WPARAM      wParam;")
cpp_quote("    LPARAM      lParam;")
cpp_quote("    ULONGLONG   ullAudioTimeOffset;")
cpp_quote("} SPEVENTEX;")
cpp_quote("#endif")
#endif // _SAPI_BUILD_VER >= 0x053
+/

//--- Types of interference
enum
{
    SPINTERFERENCE_NONE     = 0,
	SPINTERFERENCE_NOISE,
	SPINTERFERENCE_NOSIGNAL,
	SPINTERFERENCE_TOOLOUD,
	SPINTERFERENCE_TOOQUIET,
	SPINTERFERENCE_TOOFAST,
	SPINTERFERENCE_TOOSLOW
}
alias typeof(SPINTERFERENCE_NONE) SPINTERFERENCE;

//--- Flags for END_SR_STREAM event (in WPARAM)
enum
{
    SPESF_NONE              = 0,
	SPESF_STREAM_RELEASED   = (1 << 0)
	/+ TODO
	#if _SAPI_BUILD_VER >= 0x053
	, SPESF_EMULATED          = (1 << 1)
	#endif // _SAPI_BUILD_VER >= 0x053
	+/
}
alias typeof(SPESF_NONE) SPENDSRSTREAMFLAGS;

//--- Viseme features
enum
{
    SPVFEATURE_STRESSED = (1L << 0),
	SPVFEATURE_EMPHASIS = (1L << 1)
}
alias typeof(SPVFEATURE_STRESSED) SPVFEATURE;


//--- Viseme event groups
enum
{
	// English examples
	//------------------
    SP_VISEME_0 = 0,    // Silence
	SP_VISEME_1,        // AE, AX, AH
	SP_VISEME_2,        // AA
	SP_VISEME_3,        // AO
	SP_VISEME_4,        // EY, EH, UH
	SP_VISEME_5,        // ER
	SP_VISEME_6,        // y, IY, IH, IX
	SP_VISEME_7,        // w, UW
	SP_VISEME_8,        // OW
	SP_VISEME_9,        // AW
	SP_VISEME_10,       // OY
	SP_VISEME_11,       // AY
	SP_VISEME_12,       // h
	SP_VISEME_13,       // r
	SP_VISEME_14,       // l
	SP_VISEME_15,       // s, z
	SP_VISEME_16,       // SH, CH, JH, ZH
	SP_VISEME_17,       // TH, DH
	SP_VISEME_18,       // f, v
	SP_VISEME_19,       // d, t, n
	SP_VISEME_20,       // k, g, NG
	SP_VISEME_21,       // p, b, m
}
alias typeof(SP_VISEME_0) SPVISEMES;

struct SPEVENTSOURCEINFO
{
    ULONGLONG   ullEventInterest;
    ULONGLONG   ullQueuedInterest;
    ULONG       ulCount;
}

interface ISpEventSource : ISpNotifySource
{
    // It is neccessary to use the SPFEI macro to convert the
    // SPEVENTENUM values into ULONGULONG values.
    HRESULT SetInterest(
						ULONGLONG ullEventInterest, 
						ULONGLONG ullQueuedInterest);

    HRESULT GetEvents(
					  ULONG ulCount, 
					  SPEVENT* pEventArray,
					  ULONG *pulFetched);

    HRESULT GetInfo(SPEVENTSOURCEINFO * pInfo);
};

//--- ISpStreamFormat -------------------------------------------------------
interface ISpStreamFormat : IStream
{
    HRESULT GetFormat(GUID * pguidFormatId, WAVEFORMATEX ** ppCoMemWaveFormatEx);
}

enum
{
    SPFM_OPEN_READONLY,     // Open existing file, read-only
	SPFM_OPEN_READWRITE,    // (Not supported for wav files) Open existing file, read-write
	SPFM_CREATE,            // (Not supported for wav files) Open file if exists, else create if does not exist (opens read-write)    
	SPFM_CREATE_ALWAYS,     // Create file even if file exists.  Destroys old file.
	SPFM_NUM_MODES          // Used for limit checking
}
alias typeof(SPFM_OPEN_READONLY) SPFILEMODE;

//--- ISpStream -------------------------------------------------------------
interface ISpStream : ISpStreamFormat
{
    HRESULT SetBaseStream(IStream pStream, REFGUID rguidFormat, const WAVEFORMATEX * pWaveFormatEx);
    HRESULT GetBaseStream(IStream * ppStream);
    HRESULT BindToFile(LPCWSTR pszFileName, SPFILEMODE eMode,
                       const GUID * pFormatId, 
                       const WAVEFORMATEX * pWaveFormatEx, 
                       ULONGLONG ullEventInterest);
    HRESULT Close();
}

//--- ISpVoice --------------------------------------------------------------
//  These structures maintain the absolute state of the voice relative to
//  the voice's baseline XML state.
struct SPVPITCH
{
	long MiddleAdj;
	long RangeAdj;
}

enum
{
	SPVA_Speak = 0,
	SPVA_Silence,
	SPVA_Pronounce,
	SPVA_Bookmark,
	SPVA_SpellOut,
	SPVA_Section,
	SPVA_ParseUnknownTag
}
alias typeof(SPVA_Speak) SPVACTIONS;

struct SPVCONTEXT
{
	LPCWSTR pCategory;
	LPCWSTR pBefore;
	LPCWSTR pAfter;
}

struct SPVSTATE
{
	//--- Action
	SPVACTIONS  eAction;

	//--- Running state values
	LANGID		  LangID;
	WORD			wReserved;
	long			EmphAdj;
	long			RateAdj;
	ULONG		   Volume;
	SPVPITCH		PitchAdj;
	ULONG		   SilenceMSecs;
	SPPHONEID*	  pPhoneIds;			  // NULL terminated array of phone ids
	SPPARTOFSPEECH  ePartOfSpeech;
	SPVCONTEXT	  Context;
}

enum
{
	SPRS_DONE		= (1L << 0),		   // The voice is done rendering all queued phrases
	SPRS_IS_SPEAKING = (1L << 1)			// The SpVoice currently has the audio queue claimed
}
alias typeof(SPRS_DONE) SPRUNSTATE;

enum 
{
	SPMIN_VOLUME =   0,
	SPMAX_VOLUME = 100,
	SPMIN_RATE   = -10,
	SPMAX_RATE   =  10
}
alias typeof(SPMIN_VOLUME) SPVLIMITS;

enum
{
	SPVPRI_NORMAL = 0,
	SPVPRI_ALERT  = (1L << 0),
	SPVPRI_OVER   = (1L << 1)
}
alias typeof(SPVPRI_NORMAL) SPVPRIORITY;

struct SPVOICESTATUS
{
	ULONG	   ulCurrentStream;		// Current stream being rendered
	ULONG	   ulLastStreamQueued;	 // Number of the last stream queued
	HRESULT	 hrLastResult;		   // Result of last speak
	DWORD	   dwRunningState;		 // SPRUNSTATE
	ULONG	   ulInputWordPos;		 // Input position of current word being rendered
	ULONG	   ulInputWordLen;		 // Length of current word being rendered
	ULONG	   ulInputSentPos;		 // Input position of current sentence being rendered
	ULONG	   ulInputSentLen;		 // Length of current sentence being rendered
	LONG		lBookmarkId;			// Current bookmark converted to a long integer
	SPPHONEID   PhonemeId;			  // Current phoneme id
	SPVISEMES   VisemeId;			   // Current viseme
	DWORD	   dwReserved1;			// Reserved for future expansion
	DWORD	   dwReserved2;			// Reserved for future expansion
}

enum
{
	//--- SpVoice flags
	SPF_DEFAULT			= 0,			 // Synchronous, no purge, xml auto detect
	SPF_ASYNC			  = (1L << 0),	 // Asynchronous call
	SPF_PURGEBEFORESPEAK   = (1L << 1),	 // Purge current data prior to speaking this
	SPF_IS_FILENAME		= (1L << 2),	 // The string passed to Speak() is a file name
	SPF_IS_XML			 = (1L << 3),	 // The input text will be parsed for XML markup
	SPF_IS_NOT_XML		 = (1L << 4),	 // The input text will not be parsed for XML markup
	SPF_PERSIST_XML		= (1L << 5),	 // Persists XML global state changes

	//--- Normalizer flags
	SPF_NLP_SPEAK_PUNC	 = (1L << 6),	 // The normalization processor should speak the punctuation
	
	/+ TODO
	#if _SAPI_BUILD_VER >= 0x053
	//--- TTS Format 
	SPF_PARSE_SAPI		 = (1L << 7),	 // Force XML parsing as MS SAPI
	SPF_PARSE_SSML		 = (1L << 8),	 // Force XML parsing as W3C SSML
	SPF_PARSE_AUTODETECT   = 0,			 // No set flag in bits 7 or 8 results in autodetection
	#endif // _SAPI_BUILD_VER >= 0x053
	+/

	//--- Masks
	SPF_NLP_MASK		   = (SPF_NLP_SPEAK_PUNC),
	
	/+ TODO
	#if _SAPI_BUILD_VER >= 0x053
	SPF_PARSE_MASK		 = (SPF_PARSE_SAPI|SPF_PARSE_SSML),
	SPF_VOICE_MASK		 = (SPF_ASYNC|SPF_PURGEBEFORESPEAK|SPF_IS_FILENAME|SPF_IS_XML|SPF_IS_NOT_XML|SPF_NLP_MASK|SPF_PERSIST_XML|SPF_PARSE_MASK),
	#else
	SPF_VOICE_MASK		 = (SPF_ASYNC|SPF_PURGEBEFORESPEAK|SPF_IS_FILENAME|SPF_IS_XML|SPF_IS_NOT_XML|SPF_NLP_MASK|SPF_PERSIST_XML),
	#endif // _SAPI_BUILD_VER >= 0x053

	SPF_UNUSED_FLAGS	   = ~(SPF_VOICE_MASK)
	+/
}
alias typeof(SPF_DEFAULT) SPEAKFLAGS;

interface ISpVoice : ISpEventSource
{
	HRESULT SetOutput( IUnknown pUnkOutput, BOOL fAllowFormatChanges );
	HRESULT GetOutputObjectToken( ISpObjectToken * ppObjectToken );
	HRESULT GetOutputStream( ISpStreamFormat * ppStream );

	HRESULT Pause();
	HRESULT Resume();

	HRESULT SetVoice( ISpObjectToken pToken);
	HRESULT GetVoice( ISpObjectToken *ppToken);

	HRESULT Speak(
				  LPCWSTR pwcs, 
				  DWORD dwFlags, 
				  ULONG * pulStreamNumber);
	HRESULT SpeakStream(
						IStream pStream,  // If not ISpStreamFormat supported then SPDFID_Text assumed
						DWORD dwFlags, 
						ULONG * pulStreamNumber);

	HRESULT GetStatus(
					  SPVOICESTATUS *pStatus, 
					  LPWSTR * ppszLastBookmark);

	HRESULT Skip( LPCWSTR pItemType, long lNumItems, ULONG* pulNumSkipped );

	HRESULT SetPriority( SPVPRIORITY ePriority );
	HRESULT GetPriority( SPVPRIORITY* pePriority );

	HRESULT SetAlertBoundary( SPEVENTENUM eBoundary );
	HRESULT GetAlertBoundary( SPEVENTENUM* peBoundary );

	HRESULT SetRate( long RateAdjust );
	HRESULT GetRate( long* pRateAdjust);

	HRESULT SetVolume( USHORT usVolume );
	HRESULT GetVolume( USHORT* pusVolume );

	HRESULT WaitUntilDone( ULONG msTimeout );

	HRESULT SetSyncSpeakTimeout( ULONG msTimeout );
	HRESULT GetSyncSpeakTimeout( ULONG * pmsTimeout );

	HANDLE SpeakCompleteEvent();

	HRESULT IsUISupported(
								  LPCWSTR pszTypeOfUI,
								  void * pvExtraData,
								  ULONG cbExtraData,
								  BOOL *pfSupported);
	HRESULT DisplayUI(
							  HWND hwndParent,
							  LPCWSTR pszTitle,
							  LPCWSTR pszTypeOfUI,
							  void * pvExtraData,
							  ULONG cbExtraData);

}

//--- ISpLexicon ------------------------------------------------------------
enum
{
    //--- SAPI5 public POS category values (bits 28-31)
    SPPS_NotOverriden  = -1,
	SPPS_Unknown       = 0,
	SPPS_Noun          = 0x1000,
	SPPS_Verb          = 0x2000,
	SPPS_Modifier      = 0x3000,
	SPPS_Function      = 0x4000,
	SPPS_Interjection  = 0x5000
		/+ TODO
		#if _SAPI_BUILD_VER >= 0x053
		,
		SPPS_Noncontent    = 0x6000,     
		SPPS_LMA           = 0x7000,    // Words learned through LMA
		SPPS_SuppressWord  = 0xF000,    // Special flag to indicate this word should not be recognized
		#endif // _SAPI_BUILD_VER >= 0x053
		+/
}
// WTF? TODO
//alias typeof(SPPS_NotOverriden) SPPARTOFSPEECH;
alias uint SPPARTOFSPEECH;
