# Maintainer: ALEXPRO100

pkgname=linux_install-git
_reponame=linux_install
pkgver=0.5.0
pkgrel=1
pkgdesc="Install various distros from Linux to any architecture."
arch=('any')
url="https://github.com/alealexpro100/$_reponame"
license=('GPL3')
depends=('coreutils' 'util-linux' 'bash' 'wget' 'tar' 'zstd')
makedepends=('git')
optdepends=('debootstrap: debian support'
            'qemu-user-static: foreign architectures support'
            'squashfs-tools: live installer build support')
source=("git+file:///mnt/mirror/projects/linux_install")
md5sums=('SKIP')

pkgver() {
    cd "$srcdir/$_reponame"
    cat version_install
}

prepare() {
    for file in install_sys profile_gen; do
        echo -e "#!/bin/bash\n/usr/lib/$pkgname/$file.sh \"\$@\"" > "${srcdir}/$file"
    done
}

package() {
    cd "$srcdir/$_reponame"
    rm -rf "_config.yml" "bin/debootstrap-debian" "custom" "tests" "PKGBUILD"
    for file in TODO README.md CHANGES.md; do
        install -Dm644 "$file" "$pkgdir/usr/share/doc/$pkgname/$file"
        rm -rf "$file"
    done
    install -Dm644 LICENSE "$pkgdir/usr/share/licenses/$pkgname/LICENSE"
    rm -rf LICENSE
    install -m755 -d "$pkgdir/usr/lib/$pkgname"
    cp -r * "$pkgdir/usr/lib/$pkgname"
    for file in install_sys profile_gen; do
        install -Dm755 "${srcdir}/$file" "$pkgdir/usr/bin/$file"
    done
}

