module speech.windows.tts;

import std.utf;

import std.c.windows.com;

import speech.windows.sapi;
import speech.windows.comref;

import std.stdio;

struct Voice
{
	private:
	CoReference!ISpVoice voice;

	public:
	void speak(in wchar[] text)
	{
		speakz(toUTF16z(text));
	}
	
	void speakz(in wchar* text)
	{
		auto hr = voice.Speak(text, 0, null);
		writeln("speak result: ", hr);
	}
}

/// Create a new voice interface using the system default voice.
Voice createVoice()
{
	auto voice = Voice(CoReference!ISpVoice(&CLSID_SpVoice, &IID_ISpVoice));
	return voice;
}
