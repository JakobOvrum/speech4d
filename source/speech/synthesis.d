/**
 * Cross-engine Text To Speech (TTS) interface.
 *
 * This module publicly imports the system default engine implementation of this interface.
 * Currently, the default engine is Microsoft Speech API (SAPI) on Windows, and eSpeak for
 * every other platform.
 *
 * Only cross-platform features are documented here. Documentation for implementation-specific
 * features can be found in their respective modules.
 */
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

	/// Synthesizer is an $(D OutputRange) of strings.
	alias put = speak;

	/// Voice to use for speech synthesis.
	void voice(Voice newVoice) @property;
	
	/// Ditto
	Voice voice() @property;
	
	/// Volume of speech playback in the range 0-100.
	void volume(uint newVolume) @property;
	
	/// Ditto
	uint volume() @property;
	
	/// Rate of speech synthesis.
	void rate(int newRate) @property;
	
	/// Ditto
	int rate() @property;
}

/// Represents a single voice to use with speech synthesis.
struct Voice
{
	/// Name of this voice.
	string name() @property;
}

/// Get an $(D InputRange) of $(D Voice) enumerating all voices installed on the system.
auto voiceList() {}

