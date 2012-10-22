module speech.windows.synthesis;

import std.utf;

import std.c.windows.com;

import speech.windows.sapi;
import speech.windows.comref;

struct Synthesizer
{
	private:
	CoReference!ISpVoice voice;

	public:
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
		auto hr = voice.Speak(text, 0, null);
	}
}

/// Create a new speech synthesis interface using the system default voice.
Synthesizer createSynthesizer()
{
	auto tts = Synthesizer(CoReference!ISpVoice(&CLSID_SpVoice, &IID_ISpVoice));
	return tts;
}
