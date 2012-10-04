import speech.windows.tts;

version(speech4d_test) void main()
{
	auto voice = createVoice();
	voice.speak("hello");

	auto voice2 = createVoice();
	voice2.speak("world");
}
