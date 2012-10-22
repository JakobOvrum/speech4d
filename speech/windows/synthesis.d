module speech.windows.synthesis;

import std.utf;
import std.conv;

import core.sys.windows.windows;
import core.stdc.wchar_;
import std.c.windows.com;

import speech.windows.sapi;
import speech.windows.sphelper;
import speech.windows.comref;

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
		speakz(toUTF16z(text));
	}

	void speak(in wchar[] text)
	{
		speakz(toUTF16z(text));
	}
	
	void speakz(in wchar* text)
	{
		coEnforce(synth.Speak(text, 0, null));
	}

	void setVoice(Voice voice)
	{
		synth.SetVoice(voice.cpVoiceToken);
	}
}

struct Voice
{
	private CoReference!ISpObjectToken cpVoiceToken;

	string name() @property
	{
		LPWSTR name;
		coEnforce(cpVoiceToken.GetStringValue(null, &name));
		return to!string(name[0 .. wcslen(name)]);
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
	}

	auto result = Result();
	remaining = cast(long)result.length - 1;

	return result;
}
