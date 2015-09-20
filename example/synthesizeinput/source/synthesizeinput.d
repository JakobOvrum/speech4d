import std.algorithm : copy, joiner;
import std.stdio : stdin;

import speech.synthesis;

void main(string[] args)
{
	if(args.length > 1)
		args[1 .. $]
			.joiner(" ")
			.copy(Synthesizer.create);
	else
		stdin
			.byLine
			.joiner(" ")
			.copy(Synthesizer.create);
}

