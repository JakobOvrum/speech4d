module speech.buffer;

import std.range.primitives;
import std.traits;

// TODO: try not to split SSML tags
// TODO: optimize for UTF-8/UTF-16 strings and ranges of char/wchar
// TODO: handle space / punctuation separator as grapheme cluster?
// TODO: prioritize punctuation over whitespace?
auto bufferSpeech(Range, C)(Range text, C[] buffer)
	if(isInputRange!Range && isSomeChar!(ElementType!Range) &&
		(is(C == char) || is(C == wchar)))
{
	import std.uni : unicode;
	import std.utf : encode;

	assert(buffer.length > 4 / C.sizeof);

	static if(is(Unqual!(ElementType!Range) == dchar))
		alias r = text;
	else
	{
		import std.utf : byDchar;
		auto r = text.byDchar();
	}

	static struct Result
	{
		private:
		typeof(r) range;
		C[] buffer;
		size_t postSeparatorIndex;
		size_t usedLength;

		public:
		C[] front() @property
		{
			assert(!empty);
			return buffer[0 .. postSeparatorIndex == buffer.length? usedLength : postSeparatorIndex];
		}

		bool empty() @property
		{
			return buffer == null;
		}

		void popFront()
		{
			import core.stdc.string : memmove;

			assert(!empty);
			if(range.empty)
			{
				buffer = null;
				return;
			}

			if(postSeparatorIndex != buffer.length) // include leftovers from previous iteration
			{
				immutable leftoverLength = usedLength - postSeparatorIndex;
				memmove(buffer.ptr, buffer.ptr + postSeparatorIndex, (leftoverLength) * C.sizeof);
				usedLength = leftoverLength;
				postSeparatorIndex = buffer.length;
			}
			else // otherwise simply start writing at the beginning
			{
				usedLength = 0;
			}

			do
			{
				auto codePoint = range.front;
				C[4 / C.sizeof] encodeBuffer;
				auto codeUnits = encodeBuffer[0 .. encode(encodeBuffer, codePoint)];
				buffer[usedLength .. usedLength + codeUnits.length] = codeUnits[];
				usedLength += codeUnits.length;

				static immutable sep = unicode.White_Space | unicode.Punctuation;

				if(sep[codePoint])
				{
					postSeparatorIndex = usedLength;
				}

				range.popFront();
			}
			while(!range.empty && buffer.length - usedLength >= 4 / C.sizeof);

			if(range.empty)
			{
				postSeparatorIndex = buffer.length;
			}
		}
	}

	auto result = Result(r, buffer, buffer.length, buffer.length);
	result.popFront();
	return result;
}

unittest
{
	import std.algorithm.comparison : equal;
	import std.meta : AliasSeq;

	static bool test(Char, size_t bufSize)(in Char[] text, in Char[][] expectedChunks)
	{
		Char[bufSize] buffer;
		return text.bufferSpeech(buffer[]).equal(expectedChunks);
	}

	foreach(i, Char; AliasSeq!(char, wchar))
	{
		enum smallSize = AliasSeq!(12, 10)[i];
		enum medSize = AliasSeq!(16, 14)[i];
		alias testSmall = test!(Char, smallSize);
		alias testMedium = test!(Char, medSize);

		assert(testSmall("te.te", ["te.te"])); // 5
		assert(testSmall("te.ttestte", ["te.", "ttestte"])); // 3 + 7
		assert(testSmall("te.ttestt.st", ["te.", "ttestt.st"])); // 3 + 9

		assert(testMedium("Hi friend, my friend.", ["Hi friend, ", "my friend."])); // 11 + 10
		assert(testMedium("Hi friend\nmy friend.", ["Hi friend\nmy ", "friend."])); // 13 + 7

		assert(testSmall("testtesttesttest", ["testtestt", "esttest"])); // 9 + 7
		assert(testSmall("testtesttes.test", ["testtestt", "es.test"])); // 9 + 7
		assert(testSmall("testtest.testtest", ["testtest.", "testtest"])); // 9 + 8
	}

	assert(test!(char, 12)("t。ttestt。t", ["t。", "ttestt。", "t"])); // 3 + 8 + 1
	assert(test!(wchar, 10)("t。ttestt。t", ["t。ttestt。", "t"])); // 9 + 1

	assert(test!(char, 12)("うん、ＯＫ", ["うん、", "ＯＫ"])); // 6 + 4
	assert(test!(wchar, 10)("うん、ＯＫ", ["うん、ＯＫ"])); // 5

	assert(test!(char, 12)("testtestte。test", ["testtestt", "e。test"])); // 9 + 7
	assert(test!(wchar, 10)("testtestte。test", ["testtestt", "e。test"])); // 9 + 6

	assert(test!(char, 12)("testtes。testtest", ["testtes。", "testtest"])); // 9 + 8
	assert(test!(wchar, 10)("testtes。testtest", ["testtes。", "testtest"])); // 8 + 8
}

