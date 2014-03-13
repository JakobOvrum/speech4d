Microsoft SAPI import library in OMF format
==============================
Included in this directory is an import library for the Microsoft SAPI in the OMF format, as required by OPTLINK, the linker used by DMD for the 32-bit Windows target. The Microsoft Speech API (SAPI) is the recommended *speech4d* backend for Windows targets.

For the 64-bit Windows target, DMD uses the MSVC linker, in which case the `sapi.lib` from the Windows SDK must be used instead.
