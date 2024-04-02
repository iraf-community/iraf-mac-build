[![IRAF macOS build](https://github.com/iraf-community/iraf-mac-build/actions/workflows/build.yml/badge.svg)](https://github.com/iraf-community/iraf-mac-build/actions/workflows/build.yml)
[![IRAF@mac release](https://img.shields.io/github/release/iraf-community/iraf-mac-build.svg)](https://github.com/iraf-community/iraf-mac-build/releases/latest)

## IRAF package build for macOS

### Want to install IRAF on macOS?

Check out the [IRAF installation on
macOS](https://iraf-community.github.io/install.html#macos) web page.


### Software versions

* IRAF [2.18](https://github.com/iraf-community/iraf/releases/tag/v2.18),
* X11IRAF [2.1](https://github.com/iraf-community/x11iraf/releases/tag/v2.1),
* ctio [a6113fe](https://github.com/iraf-community/iraf-ctio/tree/a6113fe), 2023-11-12
* fitsutil [0858bbb](https://github.com/iraf-community/iraf-fitsutil/tree/0858bbb), 2024-03-12
* mscred [8c160e5](https://github.com/iraf-community/iraf-mscred/tree/8c160e5), 2023-12-12
* rvsao [2.8.5](http://tdc-www.harvard.edu/iraf/rvsao/rvsao-2.8.5.tar.gz)
* sptable [1.0.pre20180612](https://github.com/iraf-community/iraf-sptable/releases/tag/1.0.pre20180612)
* st4gem [1.0](https://gitlab.com/nsf-noirlab/csdc/usngo/iraf/st4gem/-/releases/1.0)
* xdimsum [6dfc2de](https://github.com/iraf-community/iraf-xdimsum/tree/6dfc2de), 2024-01-01


### Build installer from source

* install XCode tools (`xcode-select --install`)
* install [XQuartz](https://www.xquartz.org/)
* run 
   - `make` to build the host arch, 
   - `make MACARCH=x86_64` to build Intel/64bit installer on Apple Silicon
   - `make MACARCH=i386` to build Intel/32 bit on Intel (<= OS X 10.14)
* the executables are ad-hoc signed, the package is unsigned
