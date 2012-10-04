import std.c.windows.com;
import core.sys.windows.windows;
import speech.windows.sapi;

import std.stdio;

version(speech4d_test) int main()
{
	if (FAILED(CoInitialize(null)))
		return 1;

	scope(exit) CoUninitialize();

	ISpVoice pVoice;
	HRESULT hr = CoCreateInstance(&CLSID_SpVoice, null, CLSCTX_ALL, &IID_ISpVoice, cast(void**)&pVoice);
	assert(hr == S_OK);
	hr = pVoice.Speak("Hello world", 0, null); // This speaks fine
	assert(hr == S_OK);

	ISpVoice pVoice2;
	hr = CoCreateInstance(&CLSID_SpVoice, null, CLSCTX_ALL, &IID_ISpVoice, cast(void**)&pVoice2);
	assert(hr == S_OK);
	hr = pVoice2.Speak("hello again", 0, null); // This returns immediately
	assert(hr == S_OK); // Yet it still returns S_OK

	hr = pVoice.Speak("first voice again", 0, null); // This speaks fine too, immediately after "hello world" finishes
	assert(hr == S_OK);

	// The two objects are indeed at different memory addresses
	writefln("voice 1: %s, voice 2: %s", cast(void*)pVoice, cast(void*)pVoice2);

	pVoice.Release();
	pVoice = null;

	pVoice2.Release();
	pVoice2 = null;
    
	return 0;
}
