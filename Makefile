#
# Makefile for PUAE (C) rofl0r
#
# Use config.mak to override any of the following variables.
# Do not make changes here.
#
prefix = /usr/local
exec_prefix = $(prefix)
bindir = $(exec_prefix)/bin
includedir = $(prefix)/include
libdir = $(prefix)/lib

#UAE_VERSION = 260
#UAE_VERSION = 270
UAE_VERSION = 270b8
UAE_VERSION = 280

TARGET = unix
ARCHIVERS = dms

BACKENDS = src/$(GFX_BACKEND)/*.c src/$(GUI_BACKEND)/*.c src/$(THREAD_BACKEND)/*.c src/$(MACHINE_BACKEND)/*.c \
	   src/$(SOUND_BACKEND)/*.c src/$(OS_BACKEND)/*.c src/$(JOYSTICK_BACKEND)/*.c
MAIN_OBJS = main.o \
newcpu.o \
memory.o \
rommgr.o \
custom.o \
serial.o \
dongle.o \
cia.o \
blitter.o \
autoconf.o \
traps.o \
keybuf.o \
expansion.o \
inputrecord.o \
diskutil.o \
zfile.o \
zfile_archive.o \
cfgfile.o \
picasso96.o \
inputdevice.o \
gfxutil.o \
audio.o \
sinctable.o \
statusline.o \
drawing.o \
consolehook.o \
native2amiga.o \
disk.o \
crc32.o \
savestate.o \
arcadia.o \
cdtv.o \
cd32_fmv.o \
uaeexe.o \
uaelib.o \
uaeresource.o \
uaeserial.o \
fdi2raw.o \
hotkeys.o \
amax.o \
ar.o \
driveclick.o \
enforcer.o \
misc.o \
uaenet.o \
a2065.o \
gayle.o \
blkdev.o \
blkdev_cdimage.o \
scsi.o \
ncr_scsi.o \
missing.o \
readcpu.o  \
hrtmon.rom.o \
events.o \
calc.o \
aros.rom.o \
specialmonitors.o \
writelog.o \
filesys.o \
fsdb.o \
fsusage.o \
hardfile.o \
filesys_unix.o \
fsdb_unix.o \
hardfile_unix.o \
bsdsocket-posix-new.o \
bsdsocket.o \
scsiemul.o \
a2091.o \
cdrom.o \
akiko.o \
debug.o \
uaenet.o \
identify.o

ifneq ($(UAE_VERSION), 260)
MAIN_OBJS += scsitape.o sana2.o gfxboard.o
SRCDIRS = src/qemuvga/*.c
CPU_12_OR_13 = 13
ifneq ($(UAE_VERSION), 270)
MAIN_OBJS += newcpu_common.o
endif
else
CPU_12_OR_13 = 12
endif

CPUGEN_HDRS = src/cputbl.h
CPUGEN_SRCS = src/cpustbl.c src/cpuemu_0.c src/cpuemu_11.c src/cpuemu_$(CPU_12_OR_13).c src/cpuemu_20.c src/cpuemu_21.c \
	      src/cpuemu_22.c src/cpuemu_31.c src/cpuemu_32.c src/cpuemu_33.c
CPU_SRCS = $(CPUGEN_SRCS) src/cpummu.c src/cpummu30.c src/fpp.c
TOOLGEN_SRCS = src/blitfunc.c src/blittable.c src/tools/cpudefs.c

OBJCPPFLAGS = -DCPUEMU_0 -DCPUEMU_11 -DCPUEMU_$(CPU_12_OR_13) -DCPUEMU_20 -DCPUEMU_21 -DCPUEMU_22 \
	    -DCPUEMU_31 -DCPUEMU_32 -DCPUEMU_33 -DMMUEMU -DFULLMMU -DFPUEMU -DAMAX \
	    -DGAYLE -DNCR -DAGA -DAUTOCONFIG -DFILESYS -DSCSIEMU -DSCSIEMU_LINUX_IOCTL \
	    -DA2091 -DCDTV -DCD32 -DBSDSOCKET -DSUPPORT_THREADS -DFDI2RAW \
	    -DDEBUGGER -DSAVESTATE -DENFORCER -DACTION_REPLAY -DXARCADE -DDRIVESOUND \
	    -DSERIAL_PORT -DECS_DENISE

ifeq (dms,$(findstring dms,$(ARCHIVERS)))
	OBJCPPFLAGS += -DA_DMS
endif

ARCHIVERS_SRCS = $(sort $(wildcard $(ARCHIVERS:%=src/archivers/%/*.c)))
ARCHVIERS_OBJS = $(ARCHIVERS_SRCS:.c=.o)
MAIN_SRCS = $(MAIN_OBJS:.o=.c)
TOOLS_SRCS = $(sort $(wildcard src/tools/*.c))
SRCDIRS += $(BACKENDS) $(MAIN_SRCS:%=src/%) src/keymap/*.c src/qemuvga/*.c
SRCS = $(sort $(wildcard $(SRCDIRS))) $(CPU_SRCS) $(TOOLGEN_SRCS) $(ARCHIVERS_SRCS)
OBJS = $(SRCS:.c=.o)
GUI_SRCS = src/$(GUI_BACKEND)/*.c
GUI_OBJS = $(GUI_SRCS:.c=.o)

INC = -Isrc/include -Isrc

# -I src/$(MACHINE_BACKEND) -I src/$(GFX_BACKEND) \
#  -I src/$(OS_BACKEND) -I src/$(THREAD_BACKEND) -I src/$(SOUND_BACKEND)

TOOLS = src/tools/genblitter src/tools/genlinetoscr src/tools/build68k src/tools/gencomp src/tools/gencpu
PROGS = uae $(TOOLS)
GENFILES = src/blit.h src/blitfunc.h $(TOOLGEN_SRCS) $(CPUGEN_SRCS) $(CPUGEN_HDRS) \
           src/linetoscr.c cpugen.stamp comptbl.stamp
UAE_CFLAGS += -Wall -std=gnu99 -D_GNU_SOURCE -pipe -Wno-unused-variable -Wno-unused-but-set-variable -Wno-pointer-sign -Wno-unused-function -Wno-missing-braces
UAE_LDFLAGS += -lz -lm

AR      = $(CROSS_COMPILE)ar
RANLIB  = $(CROSS_COMPILE)ranlib

-include config.mak

ifeq ($(GUI_BACKEND),gui-gtk)
	GUI_CFLAGS = `pkg-config --cflags gtk+-2.0`
	GUI_LDFLAGS = `pkg-config --libs gtk+-2.0`
else
ifeq ($(GUI_BACKEND),gui-sdl)
	UAE_LDFLAGS += -lSDL_ttf -lSDL_image
else
	$(error gui $(GUI_BACKEND) support in Makefile lacking)
endif
endif

ifeq ($(findstring $(GFX_BACKEND)$(GUI_BACKEND)$(THREAD_BACKEND)$(SOUND_BACKEND)$(JOYSTICK_BACKEND),sdl),sdl)
	OBJCPPFLAGS += -DUSE_SDL
	UAE_LDFLAGS += -lSDL
endif

ifeq ($(THREAD_BACKEND),td-posix)
	UAE_LDFLAGS += -lpthread
	UAE_CPPFLAGS += -DTHREAD_POSIX
else
ifeq ($(THREAD_BACKEND),td-sdl)
	UAE_LDFLAGS += -lSDL
	UAE_CPPFLAGS += -DTHREAD_SDL
endif
endif

ifeq ($(SOUND_BACKEND),sd-alsa)
	UAE_LDFLAGS += -lasound
	UAE_CPPFLAGS += -DSOUND_ALSA
else
ifeq ($(SOUND_BACKEND),sd-none)
	UAE_CPPFLAGS += -DSOUND_NONE
else
ifeq ($(SOUND_BACKEND),sd-sdl)
	UAE_CPPFLAGS += -DSOUND_SDL
	UAE_LDFLAGS += -lSDL_sound
else
$(error sound $(SOUND_BACKEND) support in Makefile lacking)
endif
endif
endif

ifeq ($(OS_BACKEND),od-generic)
	UAE_CPPFLAGS += -DOS_GENERIC
else
ifeq ($(OS_BACKEND),od-linux)
	UAE_CPPFLAGS += -DOS_LINUX
else
	$(error OS $(OS_BACKEND) support in Makefile lacking)
endif
endif

ifeq ($(MACHINE_BACKEND),md-generic)
	UAE_CPPFLAGS += -DMACHINE_GENERIC
else
ifeq ($(MACHINE_BACKEND),md-x86-gcc)
	UAE_CPPFLAGS += -DMACHINE_X86_GCC
else
ifeq ($(MACHINE_BACKEND),md-amd64-gcc)
	UAE_CPPFLAGS += -DMACHINE_AMD64_GCC
else
	$(error machine $(MACHINE_BACKEND) support in Makefile lacking)
endif
endif
endif

ifeq ($(GFX_BACKEND),gfx-sdl)
	UAE_CPPFLAGS += -DGFX_SDL
else
ifeq ($(GFX_BACKEND),gfx-x11)
	UAE_CPPFLAGS += -DGFX_X11
else
	$(error gfx $(GFX_BACKEND) support in Makefile lacking)
endif
endif

ifeq ($(WANT_NET), 1)
OBJCPPFLAGS += -DUAENET -DA2065
UAE_LDFLAGS += -lpcap
endif

ifeq ($(WANT_JIT), 1)
OBJCPPFLAGS += -DJIT
CPU_SRCS += src/compemu_support.c src/compemu_fpp.c
CPUGEN_SRCS += src/compstbl.c src/compemu.c
endif

LDFLAGS = $(GUI_LDFLAGS) $(UAE_LDFLAGS) $(USER_LDFLAGS)
CFLAGS = $(USER_CFLAGS) $(UAE_CFLAGS)
CPPFLAGS = $(USER_CPPFLAGS) $(OBJCPPFLAGS) $(UAE_CPPFLAGS)

all: src/uae

src/blit.h: src/tools/genblitter
	src/tools/genblitter i > src/blit.h
src/blitfunc.h: src/tools/genblitter
	src/tools/genblitter h > src/blitfunc.h
src/blitfunc.c: src/tools/genblitter src/blitfunc.h
	src/tools/genblitter f > src/blitfunc.c
src/blittable.c: src/tools/genblitter src/blitfunc.h
	src/tools/genblitter t > src/blittable.c
src/linetoscr.c: src/tools/genlinetoscr
	src/tools/genlinetoscr > src/linetoscr.c
src/tools/cpudefs.c: src/tools/build68k src/table68k
	src/tools/build68k < src/table68k > src/tools/cpudefs.c
src/blitter.c: src/blit.h
src/drawing.o: src/linetoscr.c

src/tools/genblitter.c: src/genblitter.c
	ln -sf ../genblitter.c src/tools/
src/tools/blitops.c: src/blitops.c
	ln -sf ../blitops.c src/tools/
src/tools/writelog.c: src/writelog.c
	ln -sf ../writelog.c src/tools/
src/tools/missing.c: src/missing.c
	ln -sf ../missing.c src/tools/
src/tools/genlinetoscr.c: src/genlinetoscr.c
	ln -sf ../genlinetoscr.c src/tools/
src/tools/gencpu.c: src/gencpu.c
	ln -sf ../gencpu.c src/tools/
src/tools/readcpu.c: src/readcpu.c
	ln -sf ../readcpu.c src/tools/
src/tools/build68k.c: src/build68k.c
	ln -sf ../build68k.c src/tools/

src/tools/writelog.o: CPPFLAGS+=-DHOSTGEN

src/tools/genblitter: src/tools/genblitter.o src/tools/blitops.o src/tools/writelog.o
	$(CC) -O0 -g0 $^ -o $@
src/tools/build68k:  src/tools/build68k.o src/tools/writelog.o
	$(CC) -O0 -g0 $^ -o $@
src/tools/genlinetoscr: src/tools/genlinetoscr.o
	$(CC) -O0 -g0 $^ -o $@
src/tools/gencomp: src/gencomp.o src/tools/readcpu.o src/tools/missing.o src/tools/cpudefs.o src/tools/writelog.o
	$(CC) -O0 -g0 $^ -o $@
src/tools/gencpu: src/tools/gencpu.o src/tools/readcpu.o src/tools/cpudefs.o src/tools/missing.o src/tools/writelog.o
	$(CC) -O0 -g0 $^ -o $@
comptbl.stamp: src/tools/gencomp
	cd src && ./tools/gencomp && touch ../comptbl.stamp && cd ..
src/comptbl.h: comptbl.stamp
src/compstbl.c: comptbl.stamp
src/compemu.c: comptbl.stamp

$(CPUGEN_HDRS) $(CPUGEN_SRCS): cpugen.stamp src/comptbl.h
cpugen.stamp: src/tools/gencpu
	cd src && ./tools/gencpu && touch ../cpugen.stamp && cd ..

src/uae: $(OBJS) $(CPUGEN_SRCS)
	$(CC) -o $@ $(OBJS) $(UAE_LDFLAGS) $(LDFLAGS)

foo:
	@echo $(OBJCPPFLAGS) #$(GUI_OBJS)

tools: $(TOOLS)
install: $(PROGS:src%=$(DESTDIR)$(bindir)/%)

$(DESTDIR)$(bindir)/%: $(PROGS)
	install -D -m 755 $< $@
clean:
	rm -f $(OBJS)
	rm -f src/*.o src/tools/*.o
	rm -f $(PROGS)
	rm -f $(GENFILES)

src/$(GUI_BACKEND)/%.o: src/$(GUI_BACKEND)/%.c
	$(CC) $(INC) $(CPPFLAGS) $(CFLAGS) $(GUI_CFLAGS) -c -o $@ $<

%.o: %.c
	$(CC) $(INC) $(CPPFLAGS) $(CFLAGS) -c -o $@ $<

.PHONY: all clean install

