speech4d - Speech Library for the D Programming Language
=========================================================
*speech4d* is a library aiming at providing comprehensive TTS (Text To Speech) and
voice recognition capabilities for the D programming language, in the form of a
cross-platform high level interface, as well as low level engine bindings.

Text To Speech
---------------------------------------------------------
The high level interface currently only has a Windows Speech API backend.

*speech4d* also includes bindings for the Windows Speech API (SAPI) and the cross-platform eSpeak API.

Voice Recognition
---------------------------------------------------------
No work has been done on voice recognition yet. The current focus is on the TTS libraries.

Directory Structure
---------------------------------------------------------

 * `speech` - the speech4d top package.
 * `visuald` - [VisualD](http://www.dsource.org/projects/visuald) project files.
 * `test` - test sources and binaries (when built).
 * `lib` - *speech4d* library files (when built).

[Documentation](http://jakobovrum.github.com/speech4d/)
---------------------------------------------------------
Documentation can be found on the [gh-pages branch](https://github.com/JakobOvrum/speech4d/tree/gh-pages), or read online [here](http://jakobovrum.github.com/speech4d/).

Documentation for the [Windows Speech API](http://msdn.microsoft.com/en-us/library/ms723627.aspx) and the [eSpeak API](http://espeak.sourceforge.net/speak_lib.h) can be found at their respective websites.

License
---------------------------------------------------------
*speech4d* is licensed under the terms of the MIT license (see the [LICENSE.txt](https://github.com/JakobOvrum/speech4d/blob/master/LICENSE.txt) file for details).
