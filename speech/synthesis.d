module speech.synthesis;

version(Windows)
{
	public import speech.windows.synthesis;
}
else
{
	public import speech.espeak.synthesis;
}

version(speech4d_ddoc):

/// Speech synthesizer for Text To Speech.
struct Synthesizer
{
	/// Create a new speech synthesis interface using the system default voice.
	static Synthesizer create();

	/// Speak a string of text.
	void speak(in char[] text);
	
	/// Ditto
	void speak(in wchar[] text);

	/// Set the voice to use for speech synthesis.
	void setVoice(Voice voice);
}

/// Represents a single voice to use with speech synthesis.
struct Voice
{
	/// Name of this voice.
	string name() @property;
}

/// Get an $(D InputRange) of $(D Voice) containing all voices installed on the system.
auto voiceList() {}
