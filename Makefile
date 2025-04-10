# Makefile to create an installable IRAF package
# (C) Ole Streicher, 2024

RELEASE = $(shell git describe --match "v*" --always --tags | cut -c2-)

INSTDIR = $(shell pwd)/install
BUILDDIR = $(shell pwd)/build
BINDIR = $(shell pwd)/bin

MACARCH = $(shell uname -m)

export iraf = $(BUILDDIR)/iraf/
export IRAFARCH=

ifeq ($(MACARCH), arm64)
  MINVERSION = 11
  PKGBUILD_ARG = --min-os-version $(MINVERSION)
  OPT = -O2
else ifeq ($(MACARCH), x86_64)
  MINVERSION = 10.10
  PKGBUILD_ARG = --min-os-version $(MINVERSION)
  OPT = -O1
else # i386
  MINVERSION = 10.6
  PKGBUILD_ARG =
  OBT = -O2
endif

export MKPKG=$(iraf)unix/bin/mkpkg.e
export RMFILES=$(iraf)unix/bin/rmfiles.e

export CFLAGS = -mmacosx-version-min=$(MINVERSION) -arch $(MACARCH) $(OPT)
export LDFLAGS = -mmacosx-version-min=$(MINVERSION) -arch $(MACARCH) $(OPT)
export XC_CFLAGS = $(CFLAGS) -I$(BUILDDIR)/cfitsio
export XC_LFLAGS = $(LDFLAGS) -L$(BUILDDIR)/cfitsio/.libs

PATH += :$(BINDIR)

all: iraf-$(RELEASE)-$(MACARCH).pkg

PKGS = core.pkg ximtool.pkg xgterm.pkg ctio.pkg fitsutil.pkg mscred.pkg	\
       rvsao.pkg sptable.pkg st4gem.pkg xdimsum.pkg


core.pkg:
	mkdir -p $(BUILDDIR)/iraf
	curl -L https://github.com/iraf-community/iraf/archive/refs/tags/v2.18.1.tar.gz | \
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
		 $(PKGBUILD_ARG) \
		 --version 2.18.1 \
	         $@

ximtool.pkg: core.pkg
	mkdir -p $(BUILDDIR)/x11iraf
	curl -L https://github.com/iraf-community/x11iraf/archive/refs/tags/v2.2.tar.gz | \
	  tar xzf - -C $(BUILDDIR)/x11iraf --strip-components=1
	patch -d $(BUILDDIR)/x11iraf -p1 < \
	      xgterm/patches/0001-Force-setting-of-local-terminfo-database.patch
	$(MAKE) -C $(BUILDDIR)/x11iraf

	mkdir -p $(INSTDIR)/ximtool/XImtool.app/Contents/MacOS
	mkdir -p $(INSTDIR)/ximtool/XImtool.app/Contents/Resources/bin
	mkdir -p $(INSTDIR)/ximtool/XImtool.app/Contents/Resources/man
	install -m755 ximtool/XImtool $(INSTDIR)/ximtool/XImtool.app/Contents/MacOS
	install -m755 $(BUILDDIR)/x11iraf/ximtool/ximtool \
	        $(INSTDIR)/ximtool/XImtool.app/Contents/Resources/bin
	install -m755 $(BUILDDIR)/x11iraf/ximtool/clients/ism_wcspix.e \
	        $(INSTDIR)/ximtool/XImtool.app/Contents/Resources/bin
	install ximtool/Info.plist $(INSTDIR)/ximtool/XImtool.app/Contents/Info.plist
	mkdir $(BUILDDIR)/x11iraf/ximtool/XImtool.iconset
	for sz in 16 32 64 128 256 512 1024; do \
	    magick $(BUILDDIR)/x11iraf/ximtool/XImtool.xcf -background transparent -flatten \
	      -bordercolor transparent -border 5% -scale $${sz}x$${sz} \
	      $(BUILDDIR)/x11iraf/ximtool/XImtool.iconset/icon_$${sz}x$${sz}.png ; \
	    sz2=$$(expr $${sz} / 2) \
	    cp $(BUILDDIR)/x11iraf/ximtool/XImtool.iconset/icon_$${sz}x$${sz}.png \
	       $(BUILDDIR)/x11iraf/ximtool/XImtool.iconset/icon_$${sz2}x$${sz2}@2x.png ; \
	done
	iconutil --convert icns \
	         --output $(INSTDIR)/ximtool/XImtool.app/Contents/Resources/XImtool.icns \
	         $(BUILDDIR)/x11iraf/ximtool/XImtool.iconset/
	install $(BUILDDIR)/x11iraf/ximtool/ximtool.man \
	        $(INSTDIR)/ximtool/XImtool.app/Contents/Resources/man/ximtool.1
	codesign -s - -i community.iraf.ximtool $(INSTDIR)/ximtool/XImtool.app
	pkgbuild --identifier community.iraf.ximtool \
	         --root $(INSTDIR)/ximtool \
	         --install-location /Applications \
	         --scripts ximtool/scripts \
		 $(PKGBUILD_ARG) \
		 --version 2.2 \
	         ximtool.pkg

xgterm.pkg: ximtool.pkg # This re-uses the same build as ximtool
	mkdir -p $(INSTDIR)/xgterm/XGTerm.app/Contents/MacOS
	mkdir -p $(INSTDIR)/xgterm/XGTerm.app/Contents/Resources/bin
	mkdir -p $(INSTDIR)/xgterm/XGTerm.app/Contents/Resources/man
	mkdir -p $(INSTDIR)/xgterm/XGTerm.app/Contents/Resources/terminfo
	install -m755 $(BUILDDIR)/x11iraf/xgterm/xgterm \
	        $(INSTDIR)/xgterm/XGTerm.app/Contents/Resources/bin
	install -m755 xgterm/XGTerm $(INSTDIR)/xgterm/XGTerm.app/Contents/MacOS
	install xgterm/Info.plist $(INSTDIR)/xgterm/XGTerm.app/Contents/Info.plist
	mkdir $(BUILDDIR)/x11iraf/xgterm/XGTerm.iconset
	for sz in 16 32 64 128 256 512 1024; do \
	    magick $(BUILDDIR)/x11iraf/xgterm/XGTerm.xcf -background transparent -flatten \
	      -bordercolor transparent -border 5% -scale $${sz}x$${sz} \
	      $(BUILDDIR)/x11iraf/xgterm/XGTerm.iconset/icon_$${sz}x$${sz}.png ; \
	    sz2=$$(expr $${sz} / 2) ; \
	    cp $(BUILDDIR)/x11iraf/xgterm/XGTerm.iconset/icon_$${sz}x$${sz}.png \
	       $(BUILDDIR)/x11iraf/xgterm/XGTerm.iconset/icon_$${sz2}x$${sz2}@2x.png ; \
	done
	iconutil --convert icns \
	         --output $(INSTDIR)/xgterm/XGTerm.app/Contents/Resources/XGTerm.icns \
	         $(BUILDDIR)/x11iraf/xgterm/XGTerm.iconset/
	install $(BUILDDIR)/x11iraf/xgterm/xgterm.man \
	        $(INSTDIR)/xgterm/XGTerm.app/Contents/Resources/man/xgterm.1
	tic -v -o $(INSTDIR)/xgterm/XGTerm.app/Contents/Resources/terminfo \
	        $(BUILDDIR)/x11iraf/xgterm/xgterm.terminfo
	codesign -s - -i community.iraf.xgterm $(INSTDIR)/xgterm/XGTerm.app
	pkgbuild --identifier community.iraf.xgterm \
	         --root $(INSTDIR)/xgterm \
	         --install-location /Applications \
	         --scripts xgterm/scripts \
		 $(PKGBUILD_ARG) \
		 --version 2.2 \
	         xgterm.pkg


ctio.pkg: core.pkg
	mkdir -p $(BUILDDIR)/ctio
	curl -L https://github.com/iraf-community/iraf-ctio/archive/a6113fe.tar.gz | \
	  tar xzf - -C $(BUILDDIR)/ctio --strip-components=1
	( cd $(BUILDDIR)/ctio && \
	  rm -rf bin* && \
	  mkdir -p bin && \
	  ctio=$(BUILDDIR)/ctio/ $(MKPKG) -p ctio && \
	  $(RMFILES) -f lib/strip.ctio )
	find $(BUILDDIR)/ctio -name \*.[eao] -type f \
	     -exec codesign -s - -i community.iraf.ctio {} \;
	pkgbuild --identifier community.iraf.ctio \
	         --root $(BUILDDIR)/ctio \
	         --install-location /usr/local/lib/iraf/extern/ctio/ \
		 $(PKGBUILD_ARG) \
		 --version 0+2023-11-12 \
	         $@

# libcfitsio.a is required for fitsutil
$(BUILDDIR)/cfitsio/.libs/libcfitsio.a:
	mkdir -p $(BUILDDIR)/cfitsio
	curl -L https://heasarc.gsfc.nasa.gov/FTP/software/fitsio/c/cfitsio-4.5.0.tar.gz | \
	  tar xzf - -C $(BUILDDIR)/cfitsio --strip-components=1
	cd $(BUILDDIR)/cfitsio && ./configure --disable-curl --disable-shared --enable-static
	$(MAKE) -C $(BUILDDIR)/cfitsio

fitsutil.pkg: core.pkg $(BUILDDIR)/cfitsio/.libs/libcfitsio.a
	mkdir -p $(BUILDDIR)/fitsutil
	curl -L https://github.com/iraf-community/iraf-fitsutil/archive/refs/tags/v2024.07.06.tar.gz | \
	  tar xzf - -C $(BUILDDIR)/fitsutil --strip-components=1
	( cd $(BUILDDIR)/fitsutil && \
	  rm -rf bin* && \
	  mkdir -p bin && \
	  fitsutil=$(BUILDDIR)/fitsutil/ $(MKPKG) -p fitsutil )
	find $(BUILDDIR)/fitsutil -name \*.[eao] -type f \
	     -exec codesign -s - -i community.iraf.fitsutil {} \;
	pkgbuild --identifier community.iraf.fitsutil \
	         --root $(BUILDDIR)/fitsutil \
	         --install-location /usr/local/lib/iraf/extern/fitsutil/ \
		 $(PKGBUILD_ARG) \
		 --version 0+2024-02-04 \
	         $@

mscred.pkg: core.pkg
	mkdir -p $(BUILDDIR)/mscred
	curl -L https://github.com/iraf-community/iraf-mscred/archive/8c160e5.tar.gz | \
	  tar xzf - -C $(BUILDDIR)/mscred --strip-components=1
	( cd $(BUILDDIR)/mscred && \
	  rm -rf bin* && \
	  mkdir -p bin && \
	  mscred=$(BUILDDIR)/mscred/ $(MKPKG) -p mscred)
	find $(BUILDDIR)/mscred -name \*.[eao] -type f \
	     -exec codesign -s - -i community.iraf.mscred {} \;
	pkgbuild --identifier community.iraf.mscred \
	         --root $(BUILDDIR)/mscred \
	         --install-location /usr/local/lib/iraf/extern/mscred/ \
		 $(PKGBUILD_ARG) \
		 --version 0+2023-12-12 \
	         $@

rvsao.pkg: core.pkg
	mkdir -p $(BUILDDIR)/rvsao
	curl -L http://tdc-www.harvard.edu/iraf/rvsao/rvsao-2.8.5.tar.gz | \
	  tar xzf - -C $(BUILDDIR)/rvsao --strip-components=1
	patch -d $(BUILDDIR)/rvsao -p1 < rvsao/patches/0001-Add-NOAO-into-build-search-path.patch
	( cd $(BUILDDIR)/rvsao && \
	  rm -rf bin* && \
	  mkdir -p bin && \
	  rvsao=$(BUILDDIR)/rvsao/ $(MKPKG) -p rvsao)
	find $(BUILDDIR)/rvsao -name \*.[eao] -type f \
	     -exec codesign -s - -i community.iraf.rvsao {} \;
	pkgbuild --identifier community.iraf.rvsao \
	         --root $(BUILDDIR)/rvsao \
	         --install-location /usr/local/lib/iraf/extern/rvsao/ \
		 $(PKGBUILD_ARG) \
		 --version 2.8.5 \
	         $@

sptable.pkg: core.pkg
	mkdir -p $(BUILDDIR)/sptable
	curl -L https://github.com/iraf-community/iraf-sptable/archive/refs/tags/1.0.pre20180612.tar.gz | \
	  tar xzf - -C $(BUILDDIR)/sptable --strip-components=1
	( cd $(BUILDDIR)/sptable && \
	  rm -rf bin* && \
	  mkdir -p bin && \
	  sptable=$(BUILDDIR)/sptable/ $(MKPKG) -p sptable && \
	  $(RMFILES) -f lib/strip.sptable )
	find $(BUILDDIR)/sptable -name \*.[eao] -type f \
	     -exec codesign -s - -f -i community.iraf.sptable {} \;
	pkgbuild --identifier community.iraf.sptable \
	         --root $(BUILDDIR)/sptable \
	         --install-location /usr/local/lib/iraf/extern/sptable/ \
		 $(PKGBUILD_ARG) \
		 --version 1.0.pre20180612 \
	         $@

st4gem.pkg: core.pkg
	mkdir -p $(BUILDDIR)/st4gem
	curl -L https://gitlab.com/nsf-noirlab/csdc/usngo/iraf/st4gem/-/archive/1.0/st4gem-1.0.tar.gz | \
	  tar xzf - -C $(BUILDDIR)/st4gem --strip-components=1
	patch -d $(BUILDDIR)/st4gem -p1 < st4gem/patches/0001-Add-missing-default-fourier-transform-coordinate-typ.patch
	( cd $(BUILDDIR)/st4gem && \
	  rm -rf bin* && \
	  mkdir -p bin && \
	  st4gem=$(BUILDDIR)/st4gem/ $(MKPKG) -p st4gem && \
	  $(RMFILES) -f lib/strip.st4gem )
	find $(BUILDDIR)/st4gem -name \*.[eao] -type f \
	     -exec codesign -s - -i community.iraf.st4gem {} \;
	pkgbuild --identifier community.iraf.st4gem \
	         --root $(BUILDDIR)/st4gem \
	         --install-location /usr/local/lib/iraf/extern/st4gem/ \
		 $(PKGBUILD_ARG) \
		 --version 1.0 \
	         $@

xdimsum.pkg: core.pkg
	mkdir -p $(BUILDDIR)/xdimsum
	curl -L https://github.com/iraf-community/iraf-xdimsum/archive/6dfc2de.tar.gz | \
	  tar xzf - -C $(BUILDDIR)/xdimsum --strip-components=1
	( cd $(BUILDDIR)/xdimsum && \
	  rm -rf bin* && \
	  mkdir -p bin && \
	  xdimsum=$(BUILDDIR)/xdimsum/ $(MKPKG) -p xdimsum && \
	  $(RMFILES) -f lib/strip.xdimsum )
	find $(BUILDDIR)/xdimsum -name \*.[eao] -type f \
	     -exec codesign -s - -i community.iraf.xdimsum {} \;
	pkgbuild --identifier community.iraf.xdimsum \
	         --root $(BUILDDIR)/xdimsum \
	         --install-location /usr/local/lib/iraf/extern/xdimsum/ \
		 $(PKGBUILD_ARG) \
		 --version 0+2024-02-01 \
	         $@

distribution-$(MACARCH).plist: distribution.plist
	sed "s/@@MACARCH@@/$(MACARCH)/g;s/@@RELEASE@@/$(RELEASE)/g;s/@@MINVERSION@@/$(MINVERSION)/g" $< > $@

iraf-$(RELEASE)-$(MACARCH).pkg: $(PKGS) distribution-$(MACARCH).plist
	productbuild --distribution distribution-$(MACARCH).plist --resources resources $@

clean:
	rm -rf $(PKGS) iraf-$(RELEASE)-$(MACARCH).pkg distribution-$(MACARCH).plist bin $(INSTDIR) $(BUILDDIR)
