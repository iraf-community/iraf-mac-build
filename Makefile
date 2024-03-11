# Makefile to create an installable IRAF package
# (C) Ole Streicher, 2024

RELEASE = $(shell git describe --match "v*" --always --tags | cut -c2-)

INSTDIR=$(shell pwd)/install
BUILDDIR=$(shell pwd)/build
BINDIR=$(shell pwd)/bin

MINVERSION = 10.15
MACARCH=$(shell uname -m)

export iraf=$(BUILDDIR)/iraf/
ifeq ($(MACARCH), x86_64)
  export IRAFARCH=macintel
else
  export IRAFARCH=macos64
endif
export MKPKG=$(iraf)unix/bin/mkpkg.e
export RMFILES=$(iraf)unix/bin/rmfiles.e

export CFLAGS = -mmacosx-version-min=$(MINVERSION) -O2
export LDFLAGS = -mmacosx-version-min=$(MINVERSION) -O2
export XC_CFLAGS = $(CFLAGS)
export XC_LFLAGS = $(LDFLAGS)

PATH += :$(BINDIR)

all: iraf-$(RELEASE)-$(MACARCH).pkg

PKGS = iraf-core.pkg x11iraf.pkg ctio.pkg fitsutil.pkg mscred.pkg	\
       rvsao.pkg sptable.pkg st4gem.pkg xdimsum.pkg

iraf-core.pkg:
	mkdir -p $(BUILDDIR)/iraf
	curl -L https://github.com/iraf-community/iraf/archive/refs/heads/main.tar.gz | \
	  tar xzf - -C $(BUILDDIR)/iraf --strip-components=1
	$(MAKE) -C $(BUILDDIR)/iraf
	mkdir -p $(INSTDIR)/iraf
	$(MAKE) -C $(BUILDDIR)/iraf DESTDIR=$(INSTDIR)/iraf install
	find $(INSTDIR)/iraf -name \*.[eao] -type f \
	     -exec codesign -s - -i community.iraf.core {} \;
	mkdir -p bin
	ln -sf $(MKPKG) bin/mkpkg
	pkgbuild --identifier community.iraf.core \
	         --root $(INSTDIR)/iraf \
		 --install-location / \
		 --min-os-version $(MINVERSION) \
		 --version 2.17.1+ \
	         $@

x11iraf.pkg: iraf-core.pkg
	mkdir -p $(BUILDDIR)/x11iraf
	curl -L https://github.com/iraf-community/x11iraf/archive/refs/heads/main.tar.gz | \
	  tar xzf - -C $(BUILDDIR)/x11iraf --strip-components=1
	$(MAKE) -C $(BUILDDIR)/x11iraf
	mkdir -p $(INSTDIR)/x11/usr/local/bin $(INSTDIR)/x11/usr/local/man/man1 $(INSTDIR)/x11/usr/local/share/terminfo
	install -m755 $(BUILDDIR)/x11iraf/xgterm/xgterm $(INSTDIR)/x11/usr/local/bin
	install -m755 $(BUILDDIR)/x11iraf/xgterm/xgterm.man $(INSTDIR)/x11/usr/local/man/man1/xgterm.1
	install -m755 $(BUILDDIR)/x11iraf/ximtool/ximtool $(INSTDIR)/x11/usr/local/bin
	install -m755 $(BUILDDIR)/x11iraf/ximtool/ximtool.man $(INSTDIR)/x11/usr/local/man/man1/ximtool.1
	install -m755 $(BUILDDIR)/x11iraf/ximtool/clients/ism_wcspix.e $(INSTDIR)/x11/usr/local/bin
	TERMINFO=$(INSTDIR)/x11/usr/local/share/terminfo tic $(BUILDDIR)/x11iraf/xgterm/xgterm.terminfo
	find $(INSTDIR)/x11 -name \*.[eao] -type f \
	     -exec codesign -s - -i community.iraf.x11iraf {} \;
	pkgbuild --identifier community.iraf.x11iraf \
	         --root $(INSTDIR)/x11 \
	         --install-location / \
		 --min-os-version $(MINVERSION) \
		 --version 2.1+ \
	         $@

ctio.pkg: iraf-core.pkg
	mkdir -p $(BUILDDIR)/ctio
	curl -L https://github.com/iraf-community/iraf-ctio/archive/refs/heads/main.tar.gz | \
	  tar xzf - -C $(BUILDDIR)/ctio --strip-components=1
	( cd $(BUILDDIR)/ctio && \
	  rm -rf bin* && \
	  mkdir -p bin.$(IRAFARCH) && \
	  ln -s bin.$(IRAFARCH) bin && \
	  ctio=$(BUILDDIR)/ctio/ $(MKPKG) -p ctio && \
	  $(RMFILES) -f lib/strip.ctio )
	find $(BUILDDIR)/ctio -name \*.[eao] -type f \
	     -exec codesign -s - -i community.iraf.ctio {} \;
	pkgbuild --identifier community.iraf.ctio \
	         --root $(BUILDDIR)/ctio \
	         --install-location /usr/local/lib/iraf/extern/ctio/ \
		 --min-os-version $(MINVERSION) \
		 --version 0+2023-11-12 \
	         $@

fitsutil.pkg: iraf-core.pkg
	mkdir -p $(BUILDDIR)/fitsutil
	curl -L https://github.com/iraf-community/iraf-fitsutil/archive/refs/heads/main.tar.gz | \
	  tar xzf - -C $(BUILDDIR)/fitsutil --strip-components=1
	( cd $(BUILDDIR)/fitsutil && \
	  rm -rf bin* && \
	  mkdir -p bin.$(IRAFARCH) && \
	  ln -s bin.$(IRAFARCH) bin && \
	  fitsutil=$(BUILDDIR)/fitsutil/ $(MKPKG) -p fitsutil HSI_LF="$(LDFLAGS)" HSI_CF="$(CFLAGS)")
	find $(BUILDDIR)/fitsutil -name \*.[eao] -type f \
	     -exec codesign -s - -i community.iraf.fitsutil {} \;
	pkgbuild --identifier community.iraf.fitsutil \
	         --root $(BUILDDIR)/fitsutil \
	         --install-location /usr/local/lib/iraf/extern/fitsutil/ \
		 --min-os-version $(MINVERSION) \
		 --version 0+2024-02-04 \
	         $@

mscred.pkg: iraf-core.pkg
	mkdir -p $(BUILDDIR)/mscred
	curl -L https://github.com/iraf-community/iraf-mscred/archive/refs/heads/main.tar.gz | \
	  tar xzf - -C $(BUILDDIR)/mscred --strip-components=1
	( cd $(BUILDDIR)/mscred && \
	  rm -rf bin* && \
	  mkdir -p bin.$(IRAFARCH) && \
	  ln -s bin.$(IRAFARCH) bin && \
	  mscred=$(BUILDDIR)/mscred/ $(MKPKG) -p mscred)
	find $(BUILDDIR)/mscred -name \*.[eao] -type f \
	     -exec codesign -s - -i community.iraf.mscred {} \;
	pkgbuild --identifier community.iraf.mscred \
	         --root $(BUILDDIR)/mscred \
	         --install-location /usr/local/lib/iraf/extern/mscred/ \
		 --min-os-version $(MINVERSION) \
		 --version 0+2023-12-12 \
	         $@

rvsao.pkg: iraf-core.pkg
	mkdir -p $(BUILDDIR)/rvsao
	curl -L http://tdc-www.harvard.edu/iraf/rvsao/rvsao-2.8.5.tar.gz | \
	  tar xzf - -C $(BUILDDIR)/rvsao --strip-components=1
	patch -d $(BUILDDIR)/rvsao -p1 < patches/rvsao/0001-Add-NOAO-into-build-search-path.patch
	( cd $(BUILDDIR)/rvsao && \
	  rm -rf bin* && \
	  mkdir -p bin.$(IRAFARCH) && \
	  ln -s bin.$(IRAFARCH) bin && \
	  rvsao=$(BUILDDIR)/rvsao/ $(MKPKG) -p rvsao)
	find $(BUILDDIR)/rvsao -name \*.[eao] -type f \
	     -exec codesign -s - -i community.iraf.rvsao {} \;
	pkgbuild --identifier community.iraf.rvsao \
	         --root $(BUILDDIR)/rvsao \
	         --install-location /usr/local/lib/iraf/extern/rvsao/ \
		 --min-os-version $(MINVERSION) \
		 --version 2.8.5 \
	         $@

sptable.pkg: iraf-core.pkg
	mkdir -p $(BUILDDIR)/sptable
	curl -L https://github.com/iraf-community/iraf-sptable/archive/refs/tags/1.0.pre20180612.tar.gz | \
	  tar xzf - -C $(BUILDDIR)/sptable --strip-components=1
	( cd $(BUILDDIR)/sptable && \
	  rm -rf bin* && \
	  mkdir -p bin.$(IRAFARCH) && \
	  ln -s bin.$(IRAFARCH) bin && \
	  sptable=$(BUILDDIR)/sptable/ $(MKPKG) -p sptable && \
	  $(RMFILES) -f lib/strip.sptable )
	find $(BUILDDIR)/sptable -name \*.[eao] -type f \
	     -exec codesign -s - -f -i community.iraf.sptable {} \;
	pkgbuild --identifier community.iraf.sptable \
	         --root $(BUILDDIR)/sptable \
	         --install-location /usr/local/lib/iraf/extern/sptable/ \
		 --min-os-version $(MINVERSION) \
		 --version 1.0.pre20180612 \
	         $@

st4gem.pkg: iraf-core.pkg
	mkdir -p $(BUILDDIR)/st4gem
	curl -L https://gitlab.com/nsf-noirlab/csdc/usngo/iraf/st4gem/-/archive/1.0/st4gem-1.0.tar.gz | \
	  tar xzf - -C $(BUILDDIR)/st4gem --strip-components=1
	( cd $(BUILDDIR)/st4gem && \
	  rm -rf bin* && \
	  mkdir -p bin.$(IRAFARCH) && \
	  ln -s bin.$(IRAFARCH) bin && \
	  st4gem=$(BUILDDIR)/st4gem/ $(MKPKG) -p st4gem && \
	  $(RMFILES) -f lib/strip.st4gem )
	find $(BUILDDIR)/st4gem -name \*.[eao] -type f \
	     -exec codesign -s - -i community.iraf.st4gem {} \;
	pkgbuild --identifier community.iraf.st4gem \
	         --root $(BUILDDIR)/st4gem \
	         --install-location /usr/local/lib/iraf/extern/st4gem/ \
		 --min-os-version $(MINVERSION) \
		 --version 1.0 \
	         $@

xdimsum.pkg: iraf-core.pkg
	mkdir -p $(BUILDDIR)/xdimsum
	curl -L https://github.com/iraf-community/iraf-xdimsum/archive/refs/heads/main.tar.gz | \
	  tar xzf - -C $(BUILDDIR)/xdimsum --strip-components=1
	( cd $(BUILDDIR)/xdimsum && \
	  rm -rf bin* && \
	  mkdir -p bin.$(IRAFARCH) && \
	  ln -s bin.$(IRAFARCH) bin && \
	  xdimsum=$(BUILDDIR)/xdimsum/ $(MKPKG) -p xdimsum && \
	  $(RMFILES) -f lib/strip.xdimsum )
	find $(BUILDDIR)/xdimsum -name \*.[eao] -type f \
	     -exec codesign -s - -i community.iraf.xdimsum {} \;
	pkgbuild --identifier community.iraf.xdimsum \
	         --root $(BUILDDIR)/xdimsum \
	         --install-location /usr/local/lib/iraf/extern/xdimsum/ \
		 --min-os-version $(MINVERSION) \
		 --version 0+2024-02-01 \
	         $@

distribution-$(MACARCH).plist: distribution.plist
	sed "s/@@MACARCH@@/$(MACARCH)/g;s/@@RELEASE@@/$(RELEASE)/g;s/@@MINVERSION@@/$(MINVERSION)/g" $< > $@

iraf-$(RELEASE)-$(MACARCH).pkg: $(PKGS) distribution-$(MACARCH).plist conclusion.html welcome.html logo.png
	productbuild --distribution distribution-$(MACARCH).plist --resources . $@

clean:
	rm -rf $(PKGS) iraf-$(RELEASE)-$(MACARCH).pkg distribution-$(MACARCH).plist bin $(INSTDIR) $(BUILDDIR)
