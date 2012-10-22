module speech.queue;

import std.concurrency;

import windows = speech.windows.synthesis;
// import espeak = speech.espeak.synthesis;
import default_ = speech.synthesis;

enum SpeechEngine
{
	systemDefault,
	windows,
	espeak
}

class SpeechQueue(SpeechEngine engine = SpeechEngine.systemDefault)
{
	static if(engine == SpeechEngine.windows)
		alias windows.Synthesizer Synthesizer;
	//else static if(engine == SpeechEngine.espeak)
	//	alias espeak.Synthesizer Synthesizer;
	else
		alias default_.Synthesizer Synthesizer;

	Tid tid;

	private static void speaker()
	{
		Synthesizer synth = Synthesizer.create();
	
		for(;;)
		{
			string text = receiveOnly!string();
			synth.speak(text);
		}

	}

	this()
	{
		tid = spawn(&speaker);
	}

	void put(string text)
	{
		tid.send(text);
	}
}
