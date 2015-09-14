void main()
{
	import std.algorithm.iteration : map;
	import std.algorithm.sorting : sort;
	import std.array : array;
	import std.stdio : writefln;

	import speech.synthesis;

	foreach(byLang; voiceList.array.sort!((a, b) => a.language < b.language).groupBy)
		writefln("%s: %-(%s%|, %)", byLang.front.language, byLang.map!(v => v.name));
}

