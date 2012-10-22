import speech.windows.synthesis;

version(speech4d_test) void main()
{
	auto voice = createSynthesizer();
	voice.speak("hello");

	auto voice2 = createSynthesizer();
	voice2.speak("world");
}
