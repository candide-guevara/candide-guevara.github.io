---
title: ArchLinux, How to get debug symbols
date: 2021-03-12
categories: [quick_notes]
---

Contrary to other distributions Arch and Manjaro do not provide debug packages with symbols.

### Get PKGBUILD

> Note: the [`asp` package][0] is not available for Manjaro you have to clone manually.

* Clone the repository containing the package you want.
  * [core and extra][1] or [community][2]
* If this is a manjaro package [this is the repo][3]
  * Contrary to Arch each package has its own repo (like the AUR)
* `git checkout` to the version you want (likely the one in `pacman -Qii`)

### Build package tarball

* Add options `options=(debug strip)` to the PKGBUILD
  * this will create **2 packages** with the stripped binaries and the debug symbols separate.
* Run `makepkg` (add `--skippgpcheck` if signature verification fails)

If signature verification fails because of unknown public key. Try the following :

* Check this returns nothing `pacman-key --list-keys | grep <key_id>`
* Validate yourself by installing the key to a temp keyring
  * `gpg --homedir /tmp/gpg_test --keyserver keyserver.ubuntu.com <key_id>`
  * `gpg --homedir /tmp/gpg_test --verify <sign_file> <pkg_tar>`

> Note: Even validating manually may return `gpg: BAD signature from` no clue why. At least validate the hash against the upstream repo ...

### Install and remove after use

> Note: `pacman -Qem` can help to identify packages installed manually from tarballs.

* `pacman -U <pkg> <pkg-debug>`
* Once the debug package is not needed you can revert back to the official distribution version
  * `pacman -Rn <pkg-debug>`
  * `pacman -S <pkg>`

[0]:https://wiki.archlinux.org/index.php/Arch_Build_System#Retrieve_PKGBUILD_source_using_Git
[1]:https://github.com/archlinux/svntogit-packages
[2]:https://github.com/archlinux/svntogit-community
[3]:https://gitlab.manjaro.org/packages

