DESTDIR=

PACKAGE=runit-0.1.0
DIRS=doc man etc package src
MANPAGES=man/runit.8 man/runit-init.8 man/runit-halt.8 man/runit-reboot.8
DAEMONTOOLS_PD=daemontools-pd-0.76

all: clean .manpages $(DAEMONTOOLS_PD).tar.gz $(PACKAGE).tar.gz

.manpages:
	for i in $(MANPAGES); do \
	  rman -S -f html -r '' < $$i | \
	  sed -e 's}NAME="sect\([0-9]*\)" HREF="#toc[0-9]*">\(.*\)}NAME="sect\1">\2}g ; \
	  s}<A HREF="#toc">Table of Contents</A>}<a href="http://innominate.org/~pape/">G. Pape</a><br><A HREF="index.html">runit</A><hr>}g ; \
	  s}<!--.*-->}}g' \
	  > doc/`basename $$i`.html ; \
	done ; \
	touch .manpages

$(PACKAGE).tar.gz:
	rm -rf TEMP
	mkdir -p TEMP/admin/$(PACKAGE)
	make -C src clean
	cp -a $(DIRS) TEMP/admin/$(PACKAGE)/
	ln -s ../etc/debian TEMP/admin/$(PACKAGE)/doc/
	chmod -R g-ws TEMP/admin
	chmod +t TEMP/admin
	find TEMP -exec touch {} \;
	su -c 'chown -R root:root TEMP/admin ; \
		( cd TEMP ; tar cpfz ../$(PACKAGE).tar.gz admin --exclude CVS ) ; \
		rm -rf TEMP'

clean:
	find . -name \*~ -exec rm -f {} \;
	find . -name .??*~ -exec rm -f {} \;
	find . -name \#?* -exec rm -f {} \;

cleaner: clean
	rm -f $(PACKAGE).tar.gz
	for i in $(MANPAGES); do rm -f doc/`basename $$i`.html; done
	rm -f .manpages
