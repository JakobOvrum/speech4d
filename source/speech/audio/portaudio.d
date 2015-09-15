module speech.audio.portaudio;

import speech.audio.exception : AudioException;
import deimos.portaudio;

shared static this()
{
	paEnforce(Pa_Initialize());
}

shared static ~this()
{
	paEnforce(Pa_Terminate());
}

class PortaudioException : AudioException
{
	immutable PaError code;

	this(PaError err, string file = __FILE__, uint line = __LINE__, Exception next = null)
	{
		import std.string : fromStringz;
		this.code = err;
		super(fromStringz(Pa_GetErrorText(err)).idup, file, line, next);
	}
}

void paEnforce(PaError err, string file = __FILE__, uint line = __LINE__)
{
	import std.string : fromStringz;
	if(err != paNoError)
		throw new PortaudioException(err, file, line);
}

struct Device
{
	package(speech):
	PaDeviceIndex index;
	const(PaDeviceInfo)* info;

	this(PaDeviceIndex index)
	{
		this.index = index;
		this.info = Pa_GetDeviceInfo(index);
	}

	public:
	string name() @property
	{
		import std.string : fromStringz;
		return fromStringz(info.name).idup;
	}

	int maxInputChannels() @property
	{
		return info.maxInputChannels;
	}

	int maxOutputChannels() @property
	{
		return info.maxOutputChannels;
	}
}

auto outputDevices()
{
	import std.algorithm.iteration : filter, map;
	import std.range : iota;
	return iota(0, Pa_GetDeviceCount()).map!(devIndex => Device(devIndex)).filter!(dev => dev.maxOutputChannels > 0);
}

Device defaultOutputDevice()
{
	return Device(Pa_GetDefaultOutputDevice());
}

