CC ?= gcc
DESTDIR ?= /usr/local
LD ?= gcc
C_COMMON_FLAGS ?= -fPIC -Wall -W -Wno-unused-parameter -Wno-unused-variable -Wno-pointer-sign -I./include -I./uthash -I./src
MAJOR_VERSION = 0
MINOR_VERSION = 1
VERSION = "$(MAJOR_VERSION).$(MINOR_VERSION)"
SONAME = libucl.so
SONAME_FULL = $(SONAME).$(MAJOR_VERSION)
OBJDIR ?= .obj
TESTDIR ?= tests
SRCDIR ?= src
MKDIR ?= mkdir
INSTALL ?= install
RM ?= rm
RMDIR ?= rmdir
LN ?= ln
LD_SHARED_FLAGS ?= -Wl,-soname,$(SONAME) -shared
COPT_FLAGS ?= -g -O0

all: $(OBJDIR) $(OBJDIR)/$(SONAME)

$(OBJDIR)/$(SONAME): $(OBJDIR)/$(SONAME_FULL)
	$(LN) -sf $(SONAME_FULL) $(OBJDIR)/$(SONAME)

$(OBJDIR)/$(SONAME_FULL): $(OBJDIR)/ucl_util.o $(OBJDIR)/ucl_parser.o $(OBJDIR)/ucl_emitter.o
	$(CC) -o $(OBJDIR)/$(SONAME_FULL) $(OBJDIR)/ucl_util.o $(OBJDIR)/ucl_parser.o $(OBJDIR)/ucl_emitter.o $(LD_SHARED_FLAGS) $(LDFLAGS) $(SSL_LIBS) $(FETCH_LIBS)

$(OBJDIR):
	@$(MKDIR) -p $(OBJDIR)

# Compile rules
$(OBJDIR)/ucl_util.o: $(SRCDIR)/ucl_util.c $(SRCDIR)/ucl_chartable.h $(SRCDIR)/ucl_internal.h
	$(CC) -o $(OBJDIR)/ucl_util.o $(CPPFLAGS) $(COPT_FLAGS) $(CFLAGS) $(C_COMMON_FLAGS) $(SSL_CFLAGS) $(FETCH_FLAGS) -c $(SRCDIR)/ucl_util.c
$(OBJDIR)/ucl_parser.o: $(SRCDIR)/ucl_parser.c $(SRCDIR)/ucl_chartable.h $(SRCDIR)/ucl_internal.h
	$(CC) -o $(OBJDIR)/ucl_parser.o $(CPPFLAGS) $(COPT_FLAGS) $(CFLAGS) $(C_COMMON_FLAGS) $(SSL_CFLAGS) $(FETCH_FLAGS) -c $(SRCDIR)/ucl_parser.c
$(OBJDIR)/ucl_emitter.o: $(SRCDIR)/ucl_emitter.c $(SRCDIR)/ucl_chartable.h $(SRCDIR)/ucl_internal.h
	$(CC) -o $(OBJDIR)/ucl_emitter.o $(CPPFLAGS) $(COPT_FLAGS) $(CFLAGS) $(C_COMMON_FLAGS) $(SSL_CFLAGS) $(FETCH_FLAGS) -c $(SRCDIR)/ucl_emitter.c

clean:
	$(RM) $(OBJDIR)/*.o $(OBJDIR)/$(SONAME_FULL) $(OBJDIR)/$(SONAME) $(OBJDIR)/chargen $(OBJDIR)/test_basic
	$(RMDIR) $(OBJDIR)
	
# Utils

chargen: $(OBJDIR) utils/chargen.c
	$(CC) -o $(OBJDIR)/chargen $(CPPFLAGS) $(COPT_FLAGS) $(CFLAGS) $(C_COMMON_FLAGS) $(SSL_CFLAGS) $(FETCH_FLAGS) $(LDFLAGS) utils/chargen.c

# Tests

test: $(OBJDIR)/test_basic
	TEST_DIR=$(TESTDIR) $(TESTDIR)/run_tests.sh $(OBJDIR)/test_basic
	
$(OBJDIR)/test_basic: $(TESTDIR)/test_basic.c $(OBJDIR)/$(SONAME) $(OBJDIR)
	$(CC) -o $(OBJDIR)/test_basic $(CPPFLAGS) $(COPT_FLAGS) $(CFLAGS) $(C_COMMON_FLAGS) $(SSL_CFLAGS) $(FETCH_FLAGS) $(LDFLAGS) $(TESTDIR)/test_basic.c -L$(OBJDIR) -Wl,-rpath,$(OBJDIR) -lucl

install: $(OBJDIR)/$(SONAME)
	$(INSTALL) -m0755 $(SONAME) $(DESTDIR)/lib/$(SONAME)
	$(INSTALL) -m0644 include/ucl.h $(DESTDIR)/include/ucl.h

.PHONY: clean $(OBJDIR)
