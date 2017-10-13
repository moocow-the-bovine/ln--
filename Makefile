##-*- Mode: GNUmakefile; coding: utf-8; -*-

##======================================================================
## Globals
SHELL ?= /bin/bash -o pipefail
.DELETE_ON_ERROR:

CC = gcc
CFLAGS ?= -Wall -DHAVE_CONFIG_H -O2
LDFLAGS ?= $(CFLAGS)
LIBS ?=

INSTDIR ?= /usr/local/bin

CLEAN_FILES ?= ln-- *.o

##======================================================================
## Rules: Top-Level
all: ln--

##--------------------------------------------------------------
## Rules: gog
ifneq ($(shell which optgen.perl),)
cmdline.c cmdline.h: cmdline.gog
	optgen.perl -u -l --nopod --no-handle-rcfile -F cmdline $<
REALCLEAN_FILES += cmdline.c cmdline.h
endif

ln--.o: cmdline.c cmdline.h
cmdline.o: cmdline.c cmdline.h
%.o: %.c config.h
	$(CC) $(CFLAGS) -o $@ -c $<

ln--: ln--.o cmdline.o
	$(CC) $(LDFLAGS) -o $@ $^ $(LIBS)

##======================================================================
## Rules: install

.PHONY: install
install: ln--
	install --mode=755 ln-- $(INSTDIR)

##======================================================================
## Rules: cleanup

.PHONY: clean realclean
clean:
	test -z "$(CLEAN_FILES)" || rm -f $(CLEAN_FILES)

realclean: clean
	test -z "$(REALCLEAN_FILES)" || rm -f $(REALCLEAN_FILES)
