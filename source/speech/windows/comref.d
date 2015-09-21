module speech.windows.comref;

import std.algorithm : swap;

import std.c.windows.com;
import core.sys.windows.windows;
import std.string : format;

class COMException : Exception
{
	immutable HRESULT error;

	this(HRESULT hr, string fn = __FILE__, size_t ln = __LINE__)
	{
		error = hr;
		super(format("error occured during COM call (0x%X)", hr), fn, ln);
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
version(speech4d_autocominit) private bool shouldUninitialize = true;

struct CoReference(T : IUnknown)
{
	private:
	T CoReference_object = null;

	public:
	T CoReference_get() @property
	{
		return CoReference_object;
	}

	alias CoReference_get this;

	// @disable this();

	this(CLSID* clsid, IID* iid)
	{
		version(speech4d_autocom)
		{
			HRESULT hr = CoInitializeEx(null, COINIT_MULTITHREADED);
			if(hr < 0 && hr != RPC_E_CHANGED_MODE)
				throw new COMException(hr);

			shouldUninitialize = hr != RPC_E_CHANGED_MODE;
		}

		coEnforce(CoCreateInstance(clsid, null, CLSCTX_ALL, iid, cast(void**)&CoReference_object));
	}

	this(T object)
	{
		CoReference_object = object;
	}

	this(this)
	{
		if(CoReference_object !is null)
		{
			AddRef();
		}
	}

	void opAssign(typeof(this) rhs)
	{
		swap(CoReference_object, rhs.CoReference_object);
	}

	~this()
	{
		if(CoReference_object !is null && Release() == 0)
		{
			CoReference_object = null;
			version(speech4d_autocom) if(shouldUninitialize)
			{
				CoUninitialize();
			}
		}
	}
}
