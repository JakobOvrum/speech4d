/++
speech4d is a library aiming at providing comprehensive TTS (Text To Speech) and voice recognition capabilities for the D programming language, in the form of both low level bindings and higher level wrapper libraries.

See $(LINKMODULE synthesis) to get started with Text To Speech.

No work has been done on voice recognition yet.

See_Also:
Check out the $(LINK2 http://github.com/JakobOvrum/speech4d,github project page) for the full source code
and usage information.

Examples:
"Hello, world"
----------------------
import speech.synthesis;

void main()
{
	auto synth = Synthesizer.create();
	synth.speak("Hello, world");
}
----------------------
Voice Enumeration
----------------------
import speech.synthesis;

void main()
{
	auto synth = Synthesizer.create();

	foreach(voice; voiceList())
	{
		synth.voice = voice;
		synth.speak(voice.name);
	}
}
----------------------
Macros:
REPOSRCTREE = http://github.com/JakobOvrum/speech4d/tree/gh-pages
+/
module index;