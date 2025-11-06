# Maintainer: makoConstruct
pkgname=middle-good-scrolling
pkgver=1.0.0
pkgrel=1
pkgdesc="Middle mouse button scroll interceptor - hold middle click and drag to scroll (Rust)"
arch=('x86_64' 'aarch64')
url="https://github.com/makoConstruct/middle-good-scrolling"
license=('MIT')
depends=('systemd-libs')
makedepends=('rust' 'cargo')
backup=('etc/middle-good-scrolling.conf')
install="${pkgname}.install"
source=("${pkgname}::git+${url}.git"
        "middle-good-scrolling.service"
        "middle-good-scrolling.conf")
sha256sums=('SKIP'
            'SKIP'
            'SKIP')

build() {
    cd "${srcdir}/${pkgname}"
    cargo build --release --locked
}

package() {
    cd "${srcdir}/${pkgname}"

    # Install the compiled binary
    install -Dm755 "target/release/middle-good-scrolling" "${pkgdir}/usr/bin/middle-good-scrolling"

    # Install systemd service
    install -Dm644 "middle-good-scrolling.service" "${pkgdir}/usr/lib/systemd/system/middle-good-scrolling.service"

    # Install configuration file
    install -Dm644 "middle-good-scrolling.conf" "${pkgdir}/etc/middle-good-scrolling.conf"

    # Install LICENSE
    install -Dm644 "LICENSE" "${pkgdir}/usr/share/licenses/${pkgname}/LICENSE"
}
