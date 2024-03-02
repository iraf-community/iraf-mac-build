
export iraf=$(shell pwd)/iraf/
export IRAFARCH=macos64
export MKPKG=$(iraf)unix/bin/mkpkg.e
INSTDIR=$(shell pwd)/install

all: iraf.pkg

PKGS = iraf-core.pkg x11iraf.pkg

iraf-core.pkg:
	git clone --depth 1 https://github.com/iraf-community/iraf.git
	$(MAKE) -C iraf
	mkdir -p $(INSTDIR)/iraf
	$(MAKE) -C iraf DESTDIR=$(INSTDIR)/iraf install
	pkgbuild --identifier org.iraf-community.iraf.core \
	         --root $(INSTDIR)/iraf \
		 --install-location / \
	         $@

x11iraf.pkg: iraf-core.pkg
	git clone --depth 1 https://github.com/iraf-community/x11iraf.git
	$(MAKE) -C x11iraf
	mkdir -p $(INSTDIR)/x11
	$(MAKE) -C x11iraf DESTDIR=$(INSTDIR)/x11 install
	pkgbuild --identifier org.iraf-community.iraf.x11 \
	         --root $(INSTDIR)/x11 \
	         --install-location / \
	         $@

iraf.pkg: $(PKGS) \
	  iraf_distribution.plist conclusion.html welcome.html logo.png
	productbuild --distribution iraf_distribution.plist \
	             --resources . \
	             $@

clean:
	rm -rf install iraf x11iraf
