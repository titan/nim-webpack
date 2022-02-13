include .config
NAME-LINK=$(subst _,-,$(NAME))

ESCAPED-BUILDDIR = $(shell echo '$(BUILDDIR)' | sed 's%/%\\/%g')
TARGET=$(BUILDDIR)/$(NAME-LINK)
BUILDSCRIPTS=$(NAME).nimble nim.cfg
DSTSCRIPTS=$(BUILDSCRIPTS:%=$(BUILDDIR)/%)
SRCS=$(wildcard src/*.nim)
DSTSRCS=$(SRCS:%=$(BUILDDIR)/%)

all: $(TARGET)

$(TARGET): $(DSTSCRIPTS) $(DSTSRCS)
	echo $(DSTSRCS)
	cd $(BUILDDIR); nimble build; cd -

$(DSTSCRIPTS): $(BUILDDIR)/%: % | prebuild
	cp $< $@

$(DSTSRCS): $(BUILDDIR)/%: % .config | prebuild
	sed 's/%%BUILDDIR%%/$(ESCAPED-BUILDDIR)/g' $< | \
	sed 's/%%NAME%%/$(NAME)/g' | \
	sed 's/%%NAME-LINK%%/$(NAME-LINK)/g' | \
	sed '/^ *info /s|$$|; flush_file(stdout)|' > $@

prebuild:
ifeq "$(wildcard $(BUILDDIR))" ""
	@mkdir -p $(BUILDDIR)/src
endif

clean:
	rm -rf $(BUILDDIR)

.PHONY: all clean install prebuild test
