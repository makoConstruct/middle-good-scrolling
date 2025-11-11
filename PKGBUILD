# Maintainer: mako yass <m.arcus.yass@gmail.com>
pkgname=defter-scrolling
pkgver=0.8.0
pkgrel=1
pkgdesc="A better way of scrolling, for mice"
arch=('any')
url="https://github.com/makoConstruct/middle-good-scrolling"
license=('0BSD')
depends=('python' 'python-evdev' 'python-pyudev')
backup=('etc/defter-scrolling.conf')
install="${pkgname}.install"
source=("defter-scrolling"
        "defter-scrolling.service"
        "defter-scrolling.conf"
        "80-defter-scrolling.preset")
sha256sums=('SKIP'
            'SKIP'
            'SKIP'
            'SKIP')

package() {
    install -Dm755 "${srcdir}/defter-scrolling" "${pkgdir}/usr/bin/defter-scrolling"
    install -Dm644 "${srcdir}/defter-scrolling.service" "${pkgdir}/usr/lib/systemd/system/defter-scrolling.service"
    install -Dm644 "${srcdir}/80-defter-scrolling.preset" "${pkgdir}/usr/lib/systemd/system-preset/80-defter-scrolling.preset"
    install -Dm644 "${srcdir}/defter-scrolling.conf" "${pkgdir}/etc/defter-scrolling.conf"
}
