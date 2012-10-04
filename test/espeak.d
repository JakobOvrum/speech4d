import speech.espeak.espeak;
import deimos.sndfile;

version(speech4d_test):

SNDFILE* f;

extern(C) int callback(short *wav, int numsamples, espeak_EVENT *events)
{
	sf_write_short(f, wav, numsamples);

	return 0;
}

void main()
{
	auto sampleRate = espeak_Initialize(AUDIO_OUTPUT_SYNCHRONOUS, 4096, null, 0);
	assert(sampleRate != EE_INTERNAL_ERROR);

	espeak_SetSynthCallback(&callback);

	SF_INFO info;
	info.samplerate = sampleRate;
	info.channels = 1;
	info.format = SF_FORMAT_WAV | SF_FORMAT_PCM_16;

	f = sf_open("espeak.wav", SFM_WRITE, &info);

	auto text = "hello, world";
	espeak_Synth(text.ptr, text.length + 1, 0, POS_CHARACTER, text.length, espeakCHARS_UTF8, null, null);

	sf_close(f);
	f = null;

	espeak_Terminate();
}
