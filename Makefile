INSTDIR=$(shell pwd)/install
BUILDDIR=$(shell pwd)/build
BINDIR=$(shell pwd)/bin

export iraf=$(BUILDDIR)/iraf/
ifeq ($(shell uname -m), x86_64)
  export IRAFARCH=macintel
else
  export IRAFARCH=macos64
endif
export MKPKG=$(iraf)unix/bin/mkpkg.e

#export CFLAGS=
#export LDFLAGS=
PATH += :$(BINDIR)

all: iraf-$(IRAFARCH).pkg

PKGS = iraf-core.pkg x11iraf.pkg ctio.pkg fitsutil.pkg mscred.pkg	\
       nfextern.pkg rvsao.pkg sptable.pkg st4gem.pkg xdimsum.pkg

iraf-core.pkg:
	mkdir -p $(BUILDDIR)/iraf
	curl -L https://github.com/iraf-community/iraf/archive/refs/heads/main.tar.gz | \
	  tar xzf - -C $(BUILDDIR)/iraf --strip-components=1
	$(MAKE) -C $(BUILDDIR)/iraf
	mkdir -p $(INSTDIR)/iraf
	$(MAKE) -C $(BUILDDIR)/iraf DESTDIR=$(INSTDIR)/iraf install
	mkdir -p bin
	ln -sf $(MKPKG) bin/mkpkg
	pkgbuild --identifier org.iraf-community.iraf.core \
	         --root $(INSTDIR)/iraf \
		 --install-location / \
	         $@ || touch $@

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
	pkgbuild --identifier org.iraf-community.iraf.x11 \
	         --root $(INSTDIR)/x11 \
	         --install-location / \
	         $@ || touch $@

ctio.pkg: iraf-core.pkg
	mkdir -p $(BUILDDIR)/ctio
	curl -L https://github.com/iraf-community/iraf-ctio/archive/refs/heads/main.tar.gz | \
	  tar xzf - -C $(BUILDDIR)/ctio --strip-components=1
	( cd $(BUILDDIR)/ctio && \
	  rm -rf bin* && \
	  mkdir -p bin.$(IRAFARCH) && \
	  ln -s bin.$(IRAFARCH) bin && \
	  ctio=$(BUILDDIR)/ctio/ $(MKPKG) -p ctio)
	pkgbuild --identifier org.iraf-community.iraf.ctio \
	         --root $(BUILDDIR)/ctio \
	         --install-location /usr/local/lib/iraf/extern/ctio/ \
	         $@ || touch $@

fitsutil.pkg: iraf-core.pkg
	mkdir -p $(BUILDDIR)/fitsutil
	curl -L https://github.com/iraf-community/iraf-fitsutil/archive/refs/heads/main.tar.gz | \
	  tar xzf - -C $(BUILDDIR)/fitsutil --strip-components=1
	( cd $(BUILDDIR)/fitsutil && \
	  rm -rf bin* && \
	  mkdir -p bin.$(IRAFARCH) && \
	  ln -s bin.$(IRAFARCH) bin && \
	  fitsutil=$(BUILDDIR)/fitsutil/ $(MKPKG) -p fitsutil HSI_LF="$(LDFLAGS)" HSI_CF="$(CFLAGS)")
	pkgbuild --identifier org.iraf-community.iraf.fitsutil \
	         --root $(BUILDDIR)/fitsutil \
	         --install-location /usr/local/lib/iraf/extern/fitsutil/ \
	         $@ || touch $@

mscred.pkg: iraf-core.pkg
	mkdir -p $(BUILDDIR)/mscred
	curl -L https://github.com/iraf-community/iraf-mscred/archive/refs/heads/main.tar.gz | \
	  tar xzf - -C $(BUILDDIR)/mscred --strip-components=1
	( cd $(BUILDDIR)/mscred && \
	  rm -rf bin* && \
	  mkdir -p bin.$(IRAFARCH) && \
	  ln -s bin.$(IRAFARCH) bin && \
	  mscred=$(BUILDDIR)/mscred/ $(MKPKG) -p mscred)
	pkgbuild --identifier org.iraf-community.iraf.mscred \
	         --root $(BUILDDIR)/mscred \
	         --install-location /usr/local/lib/iraf/extern/mscred/ \
	         $@ || touch $@

nfextern.pkg: iraf-core.pkg
	mkdir -p $(BUILDDIR)/nfextern
	curl -L https://github.com/iraf-community/iraf-nfextern/archive/refs/heads/main.tar.gz | \
	  tar xzf - -C $(BUILDDIR)/nfextern --strip-components=1
	( cd $(BUILDDIR)/nfextern && \
	  rm -rf bin* && \
	  mkdir -p bin.$(IRAFARCH) && \
	  ln -s bin.$(IRAFARCH) bin && \
	  nfextern=$(BUILDDIR)/nfextern/ $(MKPKG) -p nfextern)
	pkgbuild --identifier org.iraf-community.iraf.nfextern \
	         --root $(BUILDDIR)/nfextern \
	         --install-location /usr/local/lib/iraf/extern/nfextern/ \
	         $@ || touch $@

rvsao.pkg: iraf-core.pkg
	mkdir -p $(BUILDDIR)/rvsao
	curl -L http://tdc-www.harvard.edu/iraf/rvsao/rvsao-2.8.5.tar.gz | \
	  tar xzf - -C $(BUILDDIR)/rvsao --strip-components=1
	patch -d $(BUILDDIR)/rvsao -p1 < Add-NOAO-into-build-search-path.patch
	( cd $(BUILDDIR)/rvsao && \
	  rm -rf bin* && \
	  mkdir -p bin.$(IRAFARCH) && \
	  ln -s bin.$(IRAFARCH) bin && \
	  rvsao=$(BUILDDIR)/rvsao/ $(MKPKG) -p rvsao)
	pkgbuild --identifier org.iraf-community.iraf.rvsao \
	         --root $(BUILDDIR)/rvsao \
	         --install-location /usr/local/lib/iraf/extern/rvsao/ \
	         $@ || touch $@

sptable.pkg: iraf-core.pkg
	mkdir -p $(BUILDDIR)/sptable
	curl -L https://github.com/iraf-community/iraf-sptable/archive/refs/tags/1.0.pre20180612.tar.gz | \
	  tar xzf - -C $(BUILDDIR)/sptable --strip-components=1
	( cd $(BUILDDIR)/sptable && \
	  rm -rf bin* && \
	  mkdir -p bin.$(IRAFARCH) && \
	  ln -s bin.$(IRAFARCH) bin && \
	  sptable=$(BUILDDIR)/sptable/ $(MKPKG) -p sptable)
	pkgbuild --identifier org.iraf-community.iraf.sptable \
	         --root $(BUILDDIR)/sptable \
	         --install-location /usr/local/lib/iraf/extern/sptable/ \
	         $@ || touch $@

st4gem.pkg: iraf-core.pkg
	mkdir -p $(BUILDDIR)/st4gem
	curl -L https://gitlab.com/nsf-noirlab/csdc/usngo/iraf/st4gem/-/archive/main/st4gem-main.tar.gz | \
	  tar xzf - -C $(BUILDDIR)/st4gem --strip-components=1
	( cd $(BUILDDIR)/st4gem && \
	  rm -rf bin* && \
	  mkdir -p bin.$(IRAFARCH) && \
	  ln -s bin.$(IRAFARCH) bin && \
	  st4gem=$(BUILDDIR)/st4gem/ $(MKPKG) -p st4gem)
	pkgbuild --identifier org.iraf-community.iraf.st4gem \
	         --root st4gem \
	         --install-location /usr/local/lib/iraf/extern/st4gem/ \
	         $@ || touch $@

xdimsum.pkg: iraf-core.pkg
	mkdir -p $(BUILDDIR)/xdimsum
	curl -L https://github.com/iraf-community/iraf-xdimsum/archive/refs/heads/main.tar.gz | \
	  tar xzf - -C $(BUILDDIR)/xdimsum --strip-components=1
	( cd $(BUILDDIR)/xdimsum && \
	  rm -rf bin* && \
	  mkdir -p bin.$(IRAFARCH) && \
	  ln -s bin.$(IRAFARCH) bin && \
	  xdimsum=$(BUILDDIR)/xdimsum/ $(MKPKG) -p xdimsum)
	pkgbuild --identifier org.iraf-community.iraf.xdimsum \
	         --root $(BUILDDIR)/xdimsum \
	         --install-location /usr/local/lib/iraf/extern/xdimsum/ \
	         $@ || touch $@

iraf-$(IRAFARCH).pkg: $(PKGS) \
	  iraf_distribution.plist conclusion.html welcome.html logo.png
	productbuild --distribution iraf_distribution.plist \
	             --resources . \
	             $@

clean:
	rm -rf $(PKGS) iraf.pkg bin $(INSTDIR) $(BUILDDIR)
