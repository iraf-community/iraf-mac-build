export iraf=$(shell pwd)/iraf/
export IRAFARCH=macos64
export MKPKG=$(iraf)unix/bin/mkpkg.e
INSTDIR=$(shell pwd)/install

#export CFLAGS=
#export LDFLAGS=
PATH += :$(shell pwd)/bin

all: iraf.pkg

PKGS = iraf-core.pkg x11iraf.pkg ctio.pkg fitsutil.pkg mscred.pkg nfextern.pkg rvsao.pkg	\
       sptable.pkg st4gem.pkg xdimsum.pkg

iraf-core.pkg:
	git clone --depth 1 https://github.com/iraf-community/iraf.git
	$(MAKE) -C iraf
	mkdir -p $(INSTDIR)/iraf
	$(MAKE) -C iraf DESTDIR=$(INSTDIR)/iraf install
	mkdir -p bin
	ln -sf $(MKPKG) bin/mkpkg
	pkgbuild --identifier org.iraf-community.iraf.core \
	         --root $(INSTDIR)/iraf \
		 --install-location / \
	         $@ || touch $@

x11iraf.pkg: iraf-core.pkg
	git clone --depth 1 https://github.com/iraf-community/x11iraf.git
	$(MAKE) -C x11iraf
	mkdir -p $(INSTDIR)/x11/usr/local/bin $(INSTDIR)/x11/usr/local/man/man1
	install -m755 x11iraf/xgterm/xgterm $(INSTDIR)/x11/usr/local/bin
	install -m755 x11iraf/xgterm/xgterm.man $(INSTDIR)/x11/usr/local/man/man1/xgterm.1
	install -m755 x11iraf/ximtool/ximtool $(INSTDIR)/x11/usr/local/bin
	install -m755 x11iraf/ximtool/ximtool.man $(INSTDIR)/x11/usr/local/man/man1/ximtool.1
	install -m755 x11iraf/ximtool/clients/ism_wcspix.e $(INSTDIR)/x11/usr/local/bin ; \
	pkgbuild --identifier org.iraf-community.iraf.x11 \
	         --root $(INSTDIR)/x11 \
	         --install-location / \
	         $@ || touch $@

ctio.pkg: iraf-core.pkg
	mkdir ctio
	curl -L https://github.com/iraf-community/iraf-ctio/archive/refs/heads/main.tar.gz | \
	  tar xzf - -C ctio --strip-components=1
	( cd ctio && \
	  rm -rf bin* && \
	  mkdir -p bin.$(IRAFARCH) && \
	  ln -s bin.$(IRAFARCH) bin && \
	  ctio=$(shell pwd)/ctio/ $(MKPKG) -p ctio)
	pkgbuild --identifier org.iraf-community.iraf.ctio \
	         --root ctio \
	         --install-location /usr/local/lib/iraf/extern/ctio/ \
	         $@ || touch $@

fitsutil.pkg: iraf-core.pkg
	mkdir fitsutil
	curl -L https://github.com/iraf-community/iraf-fitsutil/archive/refs/heads/main.tar.gz | \
	  tar xzf - -C fitsutil --strip-components=1
	( cd fitsutil && \
	  rm -rf bin* && \
	  mkdir -p bin.$(IRAFARCH) && \
	  ln -s bin.$(IRAFARCH) bin && \
	  fitsutil=$(shell pwd)/fitsutil/ $(MKPKG) -p fitsutil HSI_LF="$(LDFLAGS)" HSI_CF="$(CFLAGS)")
	pkgbuild --identifier org.iraf-community.iraf.fitsutil \
	         --root fitsutil \
	         --install-location /usr/local/lib/iraf/extern/fitsutil/ \
	         $@ || touch $@

mscred.pkg: iraf-core.pkg
	mkdir mscred
	curl -L https://github.com/iraf-community/iraf-mscred/archive/refs/heads/main.tar.gz | \
	  tar xzf - -C mscred --strip-components=1
	( cd mscred && \
	  rm -rf bin* && \
	  mkdir -p bin.$(IRAFARCH) && \
	  ln -s bin.$(IRAFARCH) bin && \
	  mscred=$(shell pwd)/mscred/ $(MKPKG) -p mscred)
	pkgbuild --identifier org.iraf-community.iraf.mscred \
	         --root mscred \
	         --install-location /usr/local/lib/iraf/extern/mscred/ \
	         $@ || touch $@

nfextern.pkg: iraf-core.pkg
	mkdir nfextern
	curl -L https://github.com/iraf-community/iraf-nfextern/archive/refs/heads/main.tar.gz | \
	  tar xzf - -C nfextern --strip-components=1
	( cd nfextern && \
	  rm -rf bin* && \
	  mkdir -p bin.$(IRAFARCH) && \
	  ln -s bin.$(IRAFARCH) bin && \
	  nfextern=$(shell pwd)/nfextern/ $(MKPKG) -p nfextern)
	pkgbuild --identifier org.iraf-community.iraf.nfextern \
	         --root nfextern \
	         --install-location /usr/local/lib/iraf/extern/nfextern/ \
	         $@ || touch $@

rvsao.pkg: iraf-core.pkg
	mkdir rvsao
	curl -L http://tdc-www.harvard.edu/iraf/rvsao/rvsao-2.8.5.tar.gz | \
	  tar xzf - -C rvsao --strip-components=1
	(cd rvsao && patch -p1 < ../Add-NOAO-into-build-search-path.patch)
	( cd rvsao && \
	  rm -rf bin* && \
	  mkdir -p bin.$(IRAFARCH) && \
	  ln -s bin.$(IRAFARCH) bin && \
	  rvsao=$(shell pwd)/rvsao/ $(MKPKG) -p rvsao)
	pkgbuild --identifier org.iraf-community.iraf.rvsao \
	         --root rvsao \
	         --install-location /usr/local/lib/iraf/extern/rvsao/ \
	         $@ || touch $@

sptable.pkg: iraf-core.pkg
	mkdir sptable
	curl -L https://github.com/iraf-community/iraf-sptable/archive/refs/tags/1.0.pre20180612.tar.gz | \
	  tar xzf - -C sptable --strip-components=1
	( cd sptable && \
	  rm -rf bin* && \
	  mkdir -p bin.$(IRAFARCH) && \
	  ln -s bin.$(IRAFARCH) bin && \
	  sptable=$(shell pwd)/sptable/ $(MKPKG) -p sptable)
	pkgbuild --identifier org.iraf-community.iraf.sptable \
	         --root sptable \
	         --install-location /usr/local/lib/iraf/extern/sptable/ \
	         $@ || touch $@

st4gem.pkg: iraf-core.pkg
	mkdir st4gem
	curl -L https://gitlab.com/nsf-noirlab/csdc/usngo/iraf/st4gem/-/archive/main/st4gem-main.tar.gz | \
	  tar xzf - -C st4gem --strip-components=1
	( cd st4gem && \
	  rm -rf bin* && \
	  mkdir -p bin.$(IRAFARCH) && \
	  ln -s bin.$(IRAFARCH) bin && \
	  st4gem=$(shell pwd)/st4gem/ $(MKPKG) -p st4gem)
	pkgbuild --identifier org.iraf-community.iraf.st4gem \
	         --root st4gem \
	         --install-location /usr/local/lib/iraf/extern/st4gem/ \
	         $@ || touch $@

xdimsum.pkg: iraf-core.pkg
	mkdir xdimsum
	curl -L https://github.com/iraf-community/iraf-xdimsum/archive/refs/heads/main.tar.gz | \
	  tar xzf - -C xdimsum --strip-components=1
	( cd xdimsum && \
	  rm -rf bin* && \
	  mkdir -p bin.$(IRAFARCH) && \
	  ln -s bin.$(IRAFARCH) bin && \
	  xdimsum=$(shell pwd)/xdimsum/ $(MKPKG) -p xdimsum)
	pkgbuild --identifier org.iraf-community.iraf.xdimsum \
	         --root xdimsum \
	         --install-location /usr/local/lib/iraf/extern/xdimsum/ \
	         $@ || touch $@

iraf.pkg: $(PKGS) \
	  iraf_distribution.plist conclusion.html welcome.html logo.png
	productbuild --distribution iraf_distribution.plist \
	             --resources . \
	             $@

clean:
	rm -rf $(PKGS) iraf.pkg
	rm -rf bin install iraf x11iraf ctio fitsutil mscred nfextern rvsao sptable st4gem xdimsum
