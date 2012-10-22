import std.stdio;
import std.c.windows.com;

import speech.windows.synthesis;

version(speech4d_test) void main()
{
	CoInitializeEx(null, COINIT_MULTITHREADED);
	scope(exit) CoUninitialize();
	
	auto synth = Synthesizer.create();

	auto voices = voiceList();
	writefln("# of voices: %s", voices.length);

	int i = 0;
	foreach(voice; voices)
	{
		writefln("#%s: %s", i, voice.name);
		synth.setVoice(voice);
		synth.speak("Hello, world!");
		i++;
	}
}
