#
# platform.profile
#

### GCC + [LINUX or MACOSX]

# leave -Werror out of DEBUG BLDs
# only add when BLD=BLD is in the MAKE flags
CWARN=-Wall -Wno-long-long -Wformat-y2k -Winit-self \
	-Wmissing-include-dirs -Wswitch-default -Wunused-parameter \
	-Wextra -Wundef -Wshadow -Wpointer-arith \
	-Wwrite-strings -Wbad-function-cast -Wcast-qual -Wcast-align \
	-Waggregate-return -Wstrict-prototypes -Wold-style-definition \
	-Wmissing-prototypes -Wmissing-declarations \
	-Wpacked -Winvalid-pch \
	-Wredundant-decls -Wnested-externs -Winline -std=gnu99 -Werror


# -Wunreachable-code removed due to -O3
# -O3 changed to -O2 due to code bloat from inline functions

CDEFS=-DDEBUG -DLINUX -DGCC -DHAS_FLOAT 
CFLAGS=$(CDEFS) $(CWARN) -fPIC

# production (0) or debug (1) build
ifdef DEBUG
  CFLAGS += -ggdb3
else
  CFLAGS += -O2
endif

# memory leak debugging mode
ifdef MEMTRACE
  CFLAGS += -DMEMORY_DEBUG=1
endif

# free or SDK version
ifdef FREE
  CFLAGS += -DFREE_VERSION
endif


CINC=-I. -I../agt -I../mgr \
    -I../ncx -I../platform \
    -I/usr/include -I/usr/include/libxml2 \
    -I/usr/include/libxml2/libxml

# added /sw/include for MacOSX
ifdef MAC
# MACOSX version
  CINC +=-I/sw/include
  CFLAGS += -DMACOSX=1
else
# LINUX version
  CINC += -I/usr/local/include
endif

ifdef MAC
   GRP=
else
   GRP=--group=root
endif

CC=gcc
LINK=gcc
LINT=splint
LINTFLAGS= '-weak -macrovarprefix "m_"'
##LIBFLAGS=-lsocket

TBASE=../../target
LBASE=$(TBASE)/lib
LIBTOOL=ar
#LFLAGS=-v --no-as-needed
LFLAGS=-lm
LPATH=-L$(LBASE)

################ OBJS RULE #############
OBJS = $(patsubst %.c,$(TARGET)/%.o,$(wildcard *.c))

################ DEPS RULE #############
DEPS = $(patsubst %.c,%.D,$(wildcard *.c))

######################## PLATFORM DEFINITIONS #############
PLATFORM_CPP=

.PHONY: all superclean clean test install depend lint

######################### MAKE DEPENDENCIES ###############
COMPILE.c= $(CC) $(CFLAGS) $(CPPFLAGS) $(PLATFORM_CPP) \
           $(CINC) $(SUBDIR_CPP) $(TARGET_ARCH) -c


$(TARGET)/%.o: %.c
	$(CC) $(CFLAGS) $(CPPFLAGS) $(PLATFORM_CPP) \
        $(CINC) $(SUBDIR_CPP) $(TARGET_ARCH) -c -o $@ $< 



# Common library rule

$(LBASE)/lib%.a: $(OBJS)
	$(LIBTOOL) cr $@ $(OBJS)
	ranlib $@


#### common cleanup rules

lint:
	$(LINT) $(LINTFLAGS) $(CDEFS) $(CPPFLAGS) $(PLATFORM_CPP) \
	$(CINC) $(SUBDIR_CPP) *.c


# dependency rule to make temp .D files from .c sources
# all the .D files are collected and appended to the
# appropriate Makefile when 'make depend' is run
# this rule is kept here to make sure it matches COMPILE.c
%.D: %.c
	$(CC) -MM -MG -MT $(TARGET)/$(patsubst %.c,%.o,$<) \
	-Wall -Wcomment $(CPPFLAGS) $(PLATFORM_CPP) $(CINC) \
	$(SUBDIR_CPP) $(TARGET_ARCH) -c $< > $@

