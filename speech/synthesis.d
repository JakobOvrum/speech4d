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
	alias speak put;

	/// Set the voice to use for speech synthesis.
	void setVoice(Voice voice);
}

/// Represents a single voice to use with speech synthesis.
struct Voice
{
	/// Name of this voice.
	string name() @property;
}

/// Get an $(D InputRange) of $(D Voice) enumerating all voices installed on the system.
auto voiceList() {}
