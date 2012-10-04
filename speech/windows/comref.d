module speech.windows.comref;

import std.c.windows.com;
import core.sys.windows.windows;

class COMException : Exception
{
	immutable HRESULT error;

	this(HRESULT hr, string fn = __FILE__, size_t ln = __LINE__)
	{
		error = hr;
		super("error occured during COM call", fn, ln);
	}
}

void coEnforce(HRESULT result, string fn = __FILE__, size_t ln = __LINE__)
{
	if(result != S_OK)
		throw new COMException(result, fn, ln);
}

// Note: relies on being TLS.
// CoUninitialize must not be called
// if CoInitializeEx returned
// RPC_E_CHANGED_MODE.
private bool shouldUninitialize = true;

import std.stdio;

struct CoReference(T : IUnknown)
{
	private:
	T CoReference_object;
	
	public:
	T CoReference_get() @property
	{
		return CoReference_object;
	}

	alias CoReference_get this;

	@disable this();

	this(CLSID* clsid, IID* iid)
	{
		HRESULT hr = CoInitializeEx(null, COINIT_MULTITHREADED);
		if(hr < 0)
			throw new COMException(hr);
		
		shouldUninitialize = hr != RPC_E_CHANGED_MODE;

		coEnforce(CoCreateInstance(clsid, null, CLSCTX_ALL, iid, cast(void**)&CoReference_object));

		writefln("[%s] %s initialized, shouldUninitialize: %s", cast(void*)CoReference_object, T.stringof, shouldUninitialize);
	}

	this(this)
	{
		AddRef();
		writefln("[%s] copied", cast(void*)CoReference_object);
	}

	~this()
	{
		writefln("[%s] releasing", cast(void*)CoReference_object);
		if(Release() == 0)
		{
			writefln("[%s] reference is 0", cast(void*)CoReference_object);
			CoReference_object = null;
			if(shouldUninitialize)
				CoUninitialize();
		}
	}
}
