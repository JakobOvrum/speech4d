module speech.synthesis;

version(Windows)
{
	public import speech.windows.synthesis;
}
else
{
	public import speech.espeak.synthesis;
}
