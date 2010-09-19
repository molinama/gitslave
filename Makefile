prefix=/usr/local
bindir=${prefix}/bin
mandir=${prefix}/share/man
man1dir=${mandir}/man1

TARGETS=gits.1 README gits
JUNK=gits.1 checkdir

all: $(TARGETS)

gits.1: gits
	pod2man < $^ > $@

gits-checkup.1: gits-checkup
	pod2man < $^ > $@

install: $(TARGETS)
	mkdir -p $(DESTDIR)/$(man1dir) $(DESTDIR)/$(bindir)
	install -m 444 gits.1 $(DESTDIR)/$(man1dir)
	if [ -d .git ]; then							\
	  VERSION=`./gits --version`;						\
	  sed "s/{UNTAGGED}/$${VERSION}/" gits > $(DESTDIR)/$(bindir)/gits;	\
	  chmod 755 $(DESTDIR)/$(bindir)/gits;					\
	else									\
	  install -m 755 gits $(DESTDIR)/$(bindir)/;				\
	fi
	@perl -MTerm::ProgressBar -e 1 >/dev/null 2>&1 || echo Warning: Missing optional Term::ProgressBar
	@perl -MParallel::Iterator -e 1 >/dev/null 2>&1 || echo Warning: Missing optional Parallel::Iterator package
	@echo Consider: "cd contrib; make install"

README: gits
	pod2text < gits > README

release:
	@VERSION=`git describe --exact-match --match 'v[0-9]*' 2>/dev/null | sed 's/^v//'`;					\
	  if [ $$? -ne 0 -o "$$VERSION" = "" ]; then echo "Not a tagged version, you may not release"; exit 3; fi;		\
	  if [ `git status --porcelain | wc -l` -gt 0 ]; then echo "Uncommitted changes, you may not release"; exit 2; fi;	\
	  git checkout-index -a -f --prefix=/tmp/gitslave-$$VERSION/;								\
	  cd /tmp/gitslave-$$VERSION;												\
	  sed -i "s/{UNTAGGED}/$${VERSION}/" gits;										\
	  cd ..;														\
	  tar czf gitslave-$$VERSION.tar.gz gitslave-$$VERSION;									\
	  rm -rf /tmp/gitslave-$$VERSION;											\
	  echo /tmp/gitslave-$$VERSION.tar.gz

clean nuke:
	rm -rf $(JUNK) *~ core* \#*
	(cd contrib; make $@)

check test: clean
	./prep_gitscheck
