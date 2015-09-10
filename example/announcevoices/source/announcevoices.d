import std.stdio;

import speech.synthesis;

void main()
{
	auto synth = Synthesizer.create();

	auto voices = voiceList();

	int i = 0;
	foreach(voice; voices)
	{
		writefln("#%s: %s", i, voice.name);
		synth.voice = voice;
		synth.speak("Hello, world!");
		i++;
	}
}

