# Ubuntu Package for diff-so-fancy

This repository builds Ubuntu source packages for
[diff-so-fancy](https://github.com/so-fancy/diff-so-fancy).
Launchpad builds the binary packages for the
[PPA](https://launchpad.net/~aos1/+archive/ubuntu/diff-so-fancy).

## Installation

```sh
sudo add-apt-repository ppa:aos1/diff-so-fancy
sudo apt update
sudo apt install diff-so-fancy
```

## Build a source package

Requirements:

- Docker
- Nix, or `devscripts`, `gnupg`, and `dput` installed on the host
- A signing key registered with your Launchpad account

```sh
nix develop
```

The shell uses your existing host GPG keyring. Docker must be installed and
running separately.

1. Update `debian/changelog` with the upstream version, a new package revision,
   and the target Ubuntu series. For example:

   ```sh
   dch --newversion 1.4.4-1ubuntu2~noble1 --distribution noble "Rebuild for Noble."
   ```

   The existing changelog targets `bionic`. Change it before publishing to a
   different series. Use distinct package versions for uploads to different
   series; never reuse an already published version.

2. Build the unsigned source package:

   ```sh
   ./build.sh
   ```

   The default image is `ubuntu:24.04` (Noble). Select another image to match
   your target series:

   ```sh
   ./build.sh -i docker.io/library/ubuntu:22.04
   ```

   The image does not change the changelog's target series or version.
   The build downloads the exact upstream version from the changelog, caches
   its original tarball in `tarballs/`, and overlays `debian/`. Source artifacts
   go into `build/`, owned by the output directory's owner.

3. Sign on the host using your primary key fingerprint:

   ```sh
   debsign -kYOUR_FINGERPRINT build/diff-so-fancy_1.4.4-1ubuntu2~noble1_source.changes
   ```

4. Upload the signed source package:

   ```sh
   dput ppa:aos1/diff-so-fancy build/diff-so-fancy_1.4.4-1ubuntu2~noble1_source.changes
   ```
