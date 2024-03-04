# Makefile to create an installable IRAF package
# (C) Ole Streicher, 2024

INSTDIR=$(shell pwd)/install
BUILDDIR=$(shell pwd)/build
BINDIR=$(shell pwd)/bin

MACARCH=$(shell uname -m)

export iraf=$(BUILDDIR)/iraf/
ifeq ($(MACARCH), x86_64)
  export IRAFARCH=macintel
else
  export IRAFARCH=macos64
endif
export MKPKG=$(iraf)unix/bin/mkpkg.e
export RMFILES=$(iraf)unix/bin/rmfiles.e

#export CFLAGS=
#export LDFLAGS=
PATH += :$(BINDIR)

all: iraf-$(MACARCH).pkg

PKGS = iraf-core.pkg x11iraf.pkg ctio.pkg fitsutil.pkg mscred.pkg	\
       nfextern.pkg rvsao.pkg sptable.pkg st4gem.pkg xdimsum.pkg

iraf-core.pkg:
	mkdir -p $(BUILDDIR)/iraf
	curl -L https://github.com/iraf-community/iraf/archive/refs/heads/main.tar.gz | \
	  tar xzf - -C $(BUILDDIR)/iraf --strip-components=1
	$(MAKE) -C $(BUILDDIR)/iraf
	mkdir -p $(INSTDIR)/iraf
	$(MAKE) -C $(BUILDDIR)/iraf DESTDIR=$(INSTDIR)/iraf install
	find $(INSTDIR)/iraf -name \*.[eao] -type f \
	     -exec codesign -s - -i org.iraf-community.iraf {} \;
	mkdir -p bin
	ln -sf $(MKPKG) bin/mkpkg
	pkgbuild --identifier org.iraf-community.iraf \
	         --root $(INSTDIR)/iraf \
		 --install-location / \
	         $@

x11iraf.pkg: iraf-core.pkg
	mkdir -p $(BUILDDIR)/x11iraf
	curl -L https://github.com/iraf-community/x11iraf/archive/refs/heads/main.tar.gz | \
	  tar xzf - -C $(BUILDDIR)/x11iraf --strip-components=1
	$(MAKE) -C $(BUILDDIR)/x11iraf
	mkdir -p $(INSTDIR)/x11/usr/local/bin $(INSTDIR)/x11/usr/local/man/man1
	install -m755 $(BUILDDIR)/x11iraf/xgterm/xgterm $(INSTDIR)/x11/usr/local/bin
	install -m755 $(BUILDDIR)/x11iraf/xgterm/xgterm.man $(INSTDIR)/x11/usr/local/man/man1/xgterm.1
	install -m755 $(BUILDDIR)/x11iraf/ximtool/ximtool $(INSTDIR)/x11/usr/local/bin
	install -m755 $(BUILDDIR)/x11iraf/ximtool/ximtool.man $(INSTDIR)/x11/usr/local/man/man1/ximtool.1
	install -m755 $(BUILDDIR)/x11iraf/ximtool/clients/ism_wcspix.e $(INSTDIR)/x11/usr/local/bin
	find $(INSTDIR)/x11 -name \*.[eao] -type f \
	     -exec codesign -s - -i org.iraf-community.x11iraf {} \;
	pkgbuild --identifier org.iraf-community.x11iraf \
	         --root $(INSTDIR)/x11 \
	         --install-location / \
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
	     -exec codesign -s - -i org.iraf-community.ctio {} \;
	pkgbuild --identifier org.iraf-community.ctio \
	         --root $(BUILDDIR)/ctio \
	         --install-location /usr/local/lib/iraf/extern/ctio/ \
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
	     -exec codesign -s - -i org.iraf-community.fitsutil {} \;
	pkgbuild --identifier org.iraf-community.fitsutil \
	         --root $(BUILDDIR)/fitsutil \
	         --install-location /usr/local/lib/iraf/extern/fitsutil/ \
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
	     -exec codesign -s - -i org.iraf-community.mscred {} \;
	pkgbuild --identifier org.iraf-community.mscred \
	         --root $(BUILDDIR)/mscred \
	         --install-location /usr/local/lib/iraf/extern/mscred/ \
	         $@

nfextern.pkg: iraf-core.pkg
	mkdir -p $(BUILDDIR)/nfextern
	curl -L https://github.com/iraf-community/iraf-nfextern/archive/refs/heads/main.tar.gz | \
	  tar xzf - -C $(BUILDDIR)/nfextern --strip-components=1
	( cd $(BUILDDIR)/nfextern && \
	  rm -rf bin* && \
	  mkdir -p bin.$(IRAFARCH) && \
	  ln -s bin.$(IRAFARCH) bin && \
	  nfextern=$(BUILDDIR)/nfextern/ $(MKPKG) -p nfextern)
	find $(BUILDDIR)/nfextern -name \*.[eao] -type f \
	     -exec codesign -s - -i org.iraf-community.nfextern {} \;
	pkgbuild --identifier org.iraf-community.nfextern \
	         --root $(BUILDDIR)/nfextern \
	         --install-location /usr/local/lib/iraf/extern/nfextern/ \
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
	     -exec codesign -s - -i org.iraf-community.rvsao {} \;
	pkgbuild --identifier org.iraf-community.rvsao \
	         --root $(BUILDDIR)/rvsao \
	         --install-location /usr/local/lib/iraf/extern/rvsao/ \
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
	     -exec codesign -s - -f -i org.iraf-community.sptable {} \;
	pkgbuild --identifier org.iraf-community.sptable \
	         --root $(BUILDDIR)/sptable \
	         --install-location /usr/local/lib/iraf/extern/sptable/ \
	         $@

st4gem.pkg: iraf-core.pkg
	mkdir -p $(BUILDDIR)/st4gem
	curl -L https://gitlab.com/nsf-noirlab/csdc/usngo/iraf/st4gem/-/archive/main/st4gem-main.tar.gz | \
	  tar xzf - -C $(BUILDDIR)/st4gem --strip-components=1
	( cd $(BUILDDIR)/st4gem && \
	  rm -rf bin* && \
	  mkdir -p bin.$(IRAFARCH) && \
	  ln -s bin.$(IRAFARCH) bin && \
	  st4gem=$(BUILDDIR)/st4gem/ $(MKPKG) -p st4gem && \
	  $(RMFILES) -f lib/strip.st4gem )
	find $(BUILDDIR)/st4gem -name \*.[eao] -type f \
	     -exec codesign -s - -i org.iraf-community.st4gem {} \;
	pkgbuild --identifier org.iraf-community.st4gem \
	         --root $(BUILDDIR)/st4gem \
	         --install-location /usr/local/lib/iraf/extern/st4gem/ \
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
	     -exec codesign -s - -i org.iraf-community.xdimsum {} \;
	pkgbuild --identifier org.iraf-community.xdimsum \
	         --root $(BUILDDIR)/xdimsum \
	         --install-location /usr/local/lib/iraf/extern/xdimsum/ \
	         $@

distribution-$(MACARCH).plist: distribution.plist
	sed s/x86_64,arm64/$(MACARCH)/g $< > $@

iraf-$(MACARCH).pkg: $(PKGS) distribution-$(MACARCH).plist conclusion.html welcome.html logo.png
	productbuild --distribution distribution-$(MACARCH).plist --resources . $@

clean:
	rm -rf $(PKGS) iraf-$(MACARCH).pkg distribution-$(MACARCH).plist bin $(INSTDIR) $(BUILDDIR)
