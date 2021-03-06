##-*- Mode: GNUmakefile; coding: utf-8; -*-
## dummy comment: test jenkins SCM polling

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
	optgen.perl -u -l --no-handle-rcfile --no-handle-pod -F cmdline $<
REALCLEAN_FILES += cmdline.c cmdline.h cmdline.pod

##--
pod: cmdline.pod
cmdline.pod: cmdline.gog
	optgen.perl -u -l --no-handle-rcfile --nohfile --nocfile -F cmdline $<
#ln--.pod:  MANUAL EDITS
endif

##--------------------------------------------------------------
## Rules: compile
ln--.o: cmdline.c cmdline.h
cmdline.o: cmdline.c cmdline.h
%.o: %.c config.h
	$(CC) $(CFLAGS) -o $@ -c $<

ln--: ln--.o cmdline.o
	$(CC) $(LDFLAGS) -o $@ $^ $(LIBS)

##======================================================================
## Rules: test (dummy)

PROVE_OPTS ?=
TEST_DIR   ?= .
export TEST_DIR
test: ln--
	./ln-- --version
	prove $(PROVE_OPTS) t/

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
