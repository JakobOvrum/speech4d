module speech.espeak.synthesis;

import speech.espeak.espeak;

private immutable int hzSampleRate;

private extern(C) int synthCallback(short* wav, int numSamples, espeak_EVENT* events)
{
	return 0;
}

shared static this()
{
	hzSampleRate = espeak_Initialize(AUDIO_OUTPUT_PLAYBACK, 0, null, 0);
	espeak_SetSynthCallback(&synthCallback);
}

shared static ~this()
{
	espeak_Terminate();
}

private uint synth(in char[] text)
{
	import std.string : toStringz;

	uint identifier;
	espeak_Synth(toStringz(text), text.length, 0, espeakEVENT_WORD, 0, espeakCHARS_UTF8 | espeakSSML, &identifier, null);
	return identifier;
}

struct Synthesizer
{
	/// Create a new speech synthesis interface using the system default voice.
	static Synthesizer create()
	{
		return Synthesizer();
	}

	void speak(in char[] text)
	{
		synth(text);
		espeak_Synchronize();
	}

	alias put = speak;

	void queue(in char[] text)
	{
		synth(text);
	}

	void voice(Voice newVoice) @property
	{
		espeak_SetVoiceByName(newVoice.voice.name);
	}

	Voice voice() @property
	{
		return Voice(espeak_GetCurrentVoice());
	}

	void volume(uint newVolume) @property
	{
		espeak_SetParameter(espeakVOLUME, newVolume, 0);
	}

	uint volume() @property
	{
		return espeak_GetParameter(espeakVOLUME, 1);
	}

	void rate(int newRate) @property
	{
		espeak_SetParameter(espeakRATE, newRate, 0);
	}

	int rate() @property
	{
		return espeak_GetParameter(espeakRATE, 1);
	}
}

struct Voice
{
	private const(espeak_VOICE)* voice;

	string name() @property
	{
		import std.string : fromStringz;
		return fromStringz(voice.name);
	}
}

auto voiceList()
{
	struct Result
	{
		private const(espeak_VOICE)** list;

		Voice front() @property
		{
			return Voice(*list);
		}

		bool empty() @property
		{
			return *list == null;
		}

		void popFront() @property
		{
			++list;
		}

		Result save() @property
		{
			return this;
		}
	}

	return Result(espeak_ListVoices(null));
}

