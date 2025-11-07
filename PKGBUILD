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
source=("middle-good-scrolling.py"
        "middle-good-scrolling.service"
        "middle-good-scrolling.conf")
sha256sums=('SKIP'
            'SKIP'
            'SKIP')

package() {
    # Install the main script (without .py extension)
    install -Dm755 "${srcdir}/middle-good-scrolling.py" "${pkgdir}/usr/bin/middle-good-scrolling"

    # Install systemd service
    install -Dm644 "${srcdir}/middle-good-scrolling.service" "${pkgdir}/usr/lib/systemd/system/middle-good-scrolling.service"

    # Install configuration file
    install -Dm644 "${srcdir}/middle-good-scrolling.conf" "${pkgdir}/etc/middle-good-scrolling.conf"
}
