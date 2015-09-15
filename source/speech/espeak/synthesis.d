module speech.espeak.synthesis;

import speech.espeak.espeak;
import speech.audio.portaudio;
import deimos.portaudio;

private immutable int hzSampleRate;

private extern(C) int synthCallback(short* wav, int numSamples, espeak_EVENT* events)
{
	if(wav && numSamples != 0)
	{
		auto stream = cast(PaStream*)events.user_data;
		Pa_WriteStream(stream, wav, numSamples); // Handle PaOutputUnderflowed result?
	}
	return 0;
}

shared static this()
{
	hzSampleRate = espeak_Initialize(AUDIO_OUTPUT_RETRIEVAL, 0, null, 0);
	espeak_SetSynthCallback(&synthCallback);
}

shared static ~this()
{
	espeak_Terminate();
}

struct Synthesizer
{
	private:
	PaStream* stream = null;

	this(Device outputDevice)
	{
		PaStreamParameters params;
		params.device = outputDevice.index;
		params.channelCount = 1;
		params.sampleFormat = paInt16;
		params.suggestedLatency = outputDevice.info.defaultLowInputLatency;

		paEnforce(Pa_IsFormatSupported(null, &params, hzSampleRate));

		paEnforce(Pa_OpenStream(&stream,
				null,
				&params,
				hzSampleRate,
				paFramesPerBufferUnspecified,
				paNoFlag,
				null,
				null));
	}

	uint synth(in char[] text)
	{
		uint identifier;
		espeak_Synth(text.ptr, text.length, 0, POS_CHARACTER, cast(uint)text.length, espeakCHARS_UTF8 | espeakSSML, &identifier, stream);
		return identifier;
	}

	public:
	/// Create a new speech synthesis interface using the system default voice.
	static Synthesizer create()
	{
		return Synthesizer(defaultOutputDevice);
	}

	static Synthesizer create(Device outputDevice)
	{
		return Synthesizer(outputDevice);
	}

	void speak(in char[] text)
	{
		Pa_StartStream(stream);
		synth(text);
		espeak_Synchronize();
		Pa_StopStream(stream);
	}

	alias put = speak;

	void queue(in char[] text)
	{
		synth(text);
	}

	void voice(Voice newVoice) @property
	{
		if(newVoice)
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
	private const(espeak_VOICE)* voice = null;

	bool opCast(T : bool)()
	{
		return voice != null;
	}

	string name() @property
	{
		import std.string : fromStringz;
		assert(this);
		return fromStringz(voice.name);
	}

	// ISO 639-1 2-letter code, with fallback to ISO 639-3 3-letter code
	string language() @property
	{
		import std.algorithm.searching : findSplit;
		import std.string : fromStringz;
		assert(this);
		//ubyte priority = cast(ubyte)*voice.languages;
		auto langSpec = fromStringz(voice.languages + 1);
		auto split = langSpec.findSplit("-");
		return split[0]; // ignore dialect for now
	}
}

auto voiceList()
{
	struct Result
	{
		private const(espeak_VOICE)** list;

		Voice front() @property
		{
			assert(!empty);
			return Voice(*list);
		}

		bool empty() @property
		{
			return *list == null;
		}

		void popFront() @property
		{
			assert(!empty);
			++list;
		}

		Result save() @property
		{
			return this;
		}
	}

	return Result(espeak_ListVoices(null));
}

