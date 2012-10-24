module speech.windows.ObjIdl;

import core.sys.windows.windows;
import std.c.windows.com;

/****************************************************************************
*  Structured Storage Interfaces
****************************************************************************/
interface ISequentialStream : IUnknown
{
		/+ TODO
		HRESULT Read(
					 [annotation("__out_bcount_part(cb, *pcbRead)")]
					 void *pv,
					 [in] ULONG cb,
					 [annotation("__out_opt")] ULONG *pcbRead);

		HRESULT RemoteRead(
						   [out, size_is(cb), length_is(*pcbRead)]
						   byte *pv,
						   [in] ULONG cb,
						   [out] ULONG *pcbRead);

		HRESULT Write(
					  [annotation("__in_bcount(cb)")] void const *pv,
					  [in] ULONG cb,
					  [annotation("__out_opt")] ULONG *pcbWritten);

		HRESULT RemoteWrite(
							[in, size_is(cb)] byte const *pv,
							[in] ULONG cb,
							[out] ULONG *pcbWritten);
		+/
}

interface IStream : ISequentialStream
{
    alias IStream LPSTREAM;

	/+ TODO: ULARGE_INTEGER not found for GDC?
    /* Storage stat buffer */
	struct STATSTG
	{
		LPOLESTR pwcsName;
		DWORD type;
		ULARGE_INTEGER cbSize;
		FILETIME mtime;
		FILETIME ctime;
		FILETIME atime;
		DWORD grfMode;
		DWORD grfLocksSupported;
		CLSID clsid;
		DWORD grfStateBits;
		DWORD reserved;
	}
	+/

	/* Storage element types */
	enum
	{
		STGTY_STORAGE   = 1,
		STGTY_STREAM    = 2,
		STGTY_LOCKBYTES = 3,
		STGTY_PROPERTY  = 4
	}
	alias typeof(STGTY_STORAGE) STGTY;

	enum
	{
		STREAM_SEEK_SET = 0,
		STREAM_SEEK_CUR = 1,
		STREAM_SEEK_END = 2
	}
	alias typeof(STREAM_SEEK_SET) STREAM_SEEK;

	enum
	{
		LOCK_WRITE      = 1,
		LOCK_EXCLUSIVE  = 2,
		LOCK_ONLYONCE   = 4
	}
	alias typeof(LOCK_WRITE) LOCKTYPE;

	/+ TODO
	HRESULT Seek(
						[in] LARGE_INTEGER dlibMove,
						[in] DWORD dwOrigin,
						[annotation("__out_opt")] ULARGE_INTEGER *plibNewPosition);

	[call_as(Seek)]
		HRESULT RemoteSeek(
							[in] LARGE_INTEGER dlibMove,
							[in] DWORD dwOrigin,
							[out] ULARGE_INTEGER *plibNewPosition);

	HRESULT SetSize(
					[in] ULARGE_INTEGER libNewSize);

	[local]
		HRESULT CopyTo(
						[in, unique] IStream *pstm,
						[in] ULARGE_INTEGER cb,
						[annotation("__out_opt")] ULARGE_INTEGER *pcbRead,
						[annotation("__out_opt")] ULARGE_INTEGER *pcbWritten);

	[call_as(CopyTo)]
		HRESULT RemoteCopyTo(
								[in, unique] IStream *pstm,
								[in] ULARGE_INTEGER cb,
								[out] ULARGE_INTEGER *pcbRead,
								[out] ULARGE_INTEGER *pcbWritten);

	HRESULT Commit(
					[in] DWORD grfCommitFlags);

	HRESULT Revert();

	HRESULT LockRegion(
						[in] ULARGE_INTEGER libOffset,
						[in] ULARGE_INTEGER cb,
						[in] DWORD dwLockType);

	HRESULT UnlockRegion(
							[in] ULARGE_INTEGER libOffset,
							[in] ULARGE_INTEGER cb,
							[in] DWORD dwLockType);

	HRESULT Stat(
					[out] STATSTG *pstatstg,
					[in] DWORD grfStatFlag);

	HRESULT Clone(
					[out] IStream **ppstm);
	+/
}