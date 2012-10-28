BUILD ?= release
MODEL ?= $(shell getconf LONG_BIT)

ifneq ($(MODEL), 32)
	ifneq ($(MODEL), 64)
		$(error Unsupported architecture: $(MODEL))
	endif
endif

ifneq ($(BUILD), debug)
	ifneq ($(BUILD), release)
		$(error Unknown build mode: $(BUILD))
	endif
endif

DFLAGS = -lib -w -wi -property -m$(MODEL)

ifeq ($(BUILD), release)
	DFLAGS += -release -O -inline -noboundscheck
	LIBNAME = speech4d
else
	DFLAGS += -debug -g
	LIBNAME = speech4d-d
endif

ifeq ($(MODEL), 32)
	OUTDIR = lib32
else
	OUTDIR = lib
endif

# Add other backends here
SPEECH4D_SOURCES = $(wildcard speech/windows/*.d) $(wildcard speech/*.d)

all: $(OUTDIR)\$(LIBNAME).lib

.PHONY : clean

clean:
	-rm $(OUTDIR)\$(LIBNAME).lib

$(OUTDIR)\$(LIBNAME).lib: $(SPEECH4D_SOURCES)
	dmd $(DFLAGS) -of"$@" $^
