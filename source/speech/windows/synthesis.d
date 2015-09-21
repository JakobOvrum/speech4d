module speech.windows.synthesis;

import std.utf;
import std.conv;

import core.sys.windows.windows;
import core.sys.windows.com;

import speech.windows.sapi;
import speech.windows.sphelper;
import speech.windows.comref;
import speech.windows.localeinfo;

private inout(wchar)[] fromStringz(inout(wchar)* cStr) @system /* pure */
{
	import core.stdc.wchar_ : wcslen;
	return cStr[0 .. wcslen(cStr)];
}

version(speech4d_manualcominit) {}
else
{
	bool shouldUninitialize;

	static this()
	{
		HRESULT hr = CoInitializeEx(null, COINIT_MULTITHREADED);
		if(hr < 0 && hr != RPC_E_CHANGED_MODE)
			throw new COMException(hr);

		shouldUninitialize = hr != RPC_E_CHANGED_MODE;
	}

	static ~this()
	{
		if(shouldUninitialize)
			CoUninitialize();
	}
}

struct Synthesizer
{
	private:
	CoReference!ISpVoice synth;

	public:
	/// Create a new speech synthesis interface using the system default voice.
	static Synthesizer create()
	{
		return Synthesizer(CoReference!ISpVoice(&CLSID_SpVoice, &IID_ISpVoice));
	}

	void speak(in char[] text)
	{
		speakz(toUTFz!(const(wchar)*)(text));
	}

	void speak(in wchar[] text)
	{
		speakz(toUTFz!(const(wchar)*)(text));
	}

	void speakz(in wchar* text)
	{
		coEnforce(synth.Speak(text, SPF_DEFAULT, null));
	}

	alias speak put;

	void queue(in char[] text)
	{
		queuez(toUTFz!(const(wchar)*)(text));
	}

	void queue(in wchar[] text)
	{
		queuez(toUTFz!(const(wchar)*)(text));
	}

	void queuez(in wchar* text)
	{
		coEnforce(synth.Speak(text, SPF_ASYNC, null));
	}

	void voice(Voice newVoice) @property
	{
		coEnforce(synth.SetVoice(newVoice.cpVoiceToken));
	}

	Voice voice() @property
	{
		ISpObjectToken voiceToken;
		coEnforce(synth.GetVoice(&voiceToken));
		return Voice(CoReference!ISpObjectToken(voiceToken));
	}

	void volume(uint newVolume) @property
	{
		coEnforce(synth.SetVolume(cast(USHORT)newVolume));
	}

	uint volume() @property
	{
		USHORT vol;
		coEnforce(synth.GetVolume(&vol));
		return vol;
	}

	void rate(int newRate) @property
	{
		coEnforce(synth.SetRate(cast(long)newRate));
	}

	int rate() @property
	{
		long r;
		coEnforce(synth.GetRate(&r));
		return cast(int)r;
	}
}

struct Voice
{
	//BUG, TODO: causes weird access violation, workaround leaks
	//private ISpObjectToken cpVoiceToken;
	private CoReference!ISpObjectToken cpVoiceToken;

	string name() @property
	{
		LPWSTR name;
		coEnforce(cpVoiceToken.GetStringValue(null, &name));
		return to!string(fromStringz(name));
	}

	string language() @property
	{
		import std.algorithm.searching : findSplit;

		ISpDataKey attributes;
		coEnforce(cpVoiceToken.OpenKey("Attributes", &attributes));

		LPWSTR localeSpec;
		coEnforce(attributes.GetStringValue("Language", &localeSpec));
		auto split = fromStringz(localeSpec).findSplit(";");
		LCID locale = to!LCID(split[0], 16);

		// Note: use LOCALE_SISO639LANGNAME2 for ISO-639-2 three-letter codes
		wchar[16] langCodeBuffer;
		int nchars = GetLocaleInfoW(locale, LOCALE_SISO639LANGNAME, null, 0);
		assert(nchars < langCodeBuffer.length);
		GetLocaleInfoW(locale, LOCALE_SISO639LANGNAME, langCodeBuffer.ptr, nchars);

		return to!string(langCodeBuffer[0 .. nchars - 1]); // Don't include null terminator
	}
}

auto voiceList()
{
	IEnumSpObjectTokens cpEnum;
	coEnforce(SpEnumTokens(SPCAT_VOICES, null, null, &cpEnum));

	ISpObjectToken cpVoiceToken;
	coEnforce(cpEnum.Next(1, &cpVoiceToken, null));

	long remaining;

	struct Result
	{
		bool empty() @property
		{
			return remaining == -1;
		}

		Voice front() @property
		{
			return Voice(CoReference!ISpObjectToken(cpVoiceToken));
		}

		void popFront()
		{
			if(remaining > 0)
			{
				coEnforce(cpEnum.Next(1, &cpVoiceToken, null));
			}

			--remaining;
		}

		size_t length() @property
		{
			ULONG count;
			coEnforce(cpEnum.GetCount(&count));
			return cast(size_t)count;
		}

		Voice[] array()
		{
			if(remaining <= 1)
				return null;

			auto voiceArray = new ISpObjectToken[cast(size_t)remaining];
			voiceArray[0] = cpVoiceToken;

			ULONG fetched;
			coEnforce(cpEnum.Next(cast(ULONG)voiceArray.length - 1, &voiceArray[1], &fetched));
			return cast(Voice[])voiceArray;
		}
	}

	auto result = Result();
	remaining = cast(long)result.length - 1;

	return result;
}
