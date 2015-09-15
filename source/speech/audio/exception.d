module speech.audio.exception;

class AudioException : Exception
{
	this(string msg, string file = __FILE__, uint line = __LINE__, Exception next = null)
	{
		super(msg, file, line, next);
	}
}

