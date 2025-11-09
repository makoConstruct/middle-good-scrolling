# Maintainer: Your Name <your.email@example.com>
pkgname=middle-good-scrolling
pkgver=1.0.0
pkgrel=1
pkgdesc="Middle mouse button scroll interceptor - hold middle click and drag to scroll"
arch=('any')
url="https://github.com/makoConstruct/middle-good-scrolling"
license=('MIT')
depends=('python' 'python-evdev' 'python-pyudev')
backup=('etc/middle-good-scrolling.conf')
install="${pkgname}.install"
source=("middle-good-scrolling"
        "middle-good-scrolling.service"
        "middle-good-scrolling.conf"
        "80-middle-good-scrolling.preset")
sha256sums=('SKIP'
            'SKIP'
            'SKIP'
            'SKIP')

package() {
    install -Dm755 "${srcdir}/middle-good-scrolling" "${pkgdir}/usr/bin/middle-good-scrolling"
    install -Dm644 "${srcdir}/middle-good-scrolling.service" "${pkgdir}/usr/lib/systemd/system/middle-good-scrolling.service"
    install -Dm644 "${srcdir}/80-middle-good-scrolling.preset" "${pkgdir}/usr/lib/systemd/system-preset/80-middle-good-scrolling.preset"
    install -Dm644 "${srcdir}/middle-good-scrolling.conf" "${pkgdir}/etc/middle-good-scrolling.conf"
}
