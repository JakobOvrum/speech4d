void main()
{
	import std.exception;
	import std.stdio;
	import speech.synthesis;
	import speech.audio;

	foreach(dev; outputDevices)
	{
		Synthesizer synth;
		auto ex = collectException!AudioException(synth = Synthesizer.create(dev));

		if(ex is null)
		{
			writefln(`Speaking on "%s"...`, dev.name);
			synth.speak("hello, world");
		}
	}
}

