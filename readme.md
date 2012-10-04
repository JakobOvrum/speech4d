speech4d - Speech Library for the D Programming Language
=========================================================
*speech4d* is a library aiming at providing comprehensive TTS (Text To Speech) and
voice recognition capabilities for the D programming language, in the form of both
low level bindings and higher level wrapper libraries.

Text To Speech
---------------------------------------------------------
*speech4d* currently includes bindings for the Windows Speech API (SAPI) and the cross-platform eSpeak API.
The goal is to provide a uniform high-level API for all supported backends, with
minimal effort required to support multiple platforms in the user application.

Voice Recognition
---------------------------------------------------------
No work has been done on voice recognition yet. The current focus is on the TTS libraries.

Directory Structure
---------------------------------------------------------

 * `speech` - the speech4d top package.
 * `visuald` - [VisualD](http://www.dsource.org/projects/visuald) project files.
 * `test` - test sources and binaries (when built).
 * `lib` - *speech4d* library files (when built).

Documentation
---------------------------------------------------------
Documentation for the wrapper libraries is coming soon.

Documentation for the [Windows Speech API](http://msdn.microsoft.com/en-us/library/ms723627.aspx) and the [eSpeak API](http://espeak.sourceforge.net/speak_lib.h) can be found at their respective websites.

License
---------------------------------------------------------
*speech4d* is licensed under the terms of the MIT license (see the [LICENSE.txt](https://github.com/JakobOvrum/speech4d/blob/master/LICENSE.txt) file for details).
