module speech.tts;

version(Windows)
{
	public import speech.windows.tts;
}
else
{
	public import speech.espeak.tts;
}
