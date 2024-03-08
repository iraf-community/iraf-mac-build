## Source for the IRAF package build for macOS

The package can be downloaded as separate packages for Intel and ARM
Macs from the [Releases
page](https://github.com/iraf-community/iraf-mac-build/releases). It combines
the IRAF core package, x11iraf and a selection of common external
packages.

The packages are not signed and therefore may cause a security error
when downloaded. This can be avoided by right-clicking and then
selecting "Open" instead of double-clicking, or by removing the
quarantine attribute:

    % xattr -d com.apple.quarantine iraf-arm64.dmg

Alternatively, the file can be downloaded in the command line, f.e. with

    % curl -OL https://github.com/iraf-community/iraf-mac-build/releases/download/v2.17.1-1a1/iraf-arm64.pkg

Please keep in mind that this is an early pre-release and based on the
development versions of the software packages. See the release notes
for more information of the versions included.
