# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5

inherit udev

DESCRIPTION="Bluetooth Tools and System Daemons for Linux"
HOMEPAGE="http://www.bluez.org"
SRC_URI="mirror://kernel/linux/bluetooth/${P}.tar.xz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64"
IUSE="client cups debug experimental monitor obex systemd tools udev"

RDEPEND="
	obex? ( >=dev-libs/libical-0.48 )
	>=dev-libs/glib-2.32.4-r1
	>=sys-apps/dbus-1.6.12
	udev? ( >=virtual/udev-204 )
	cups? ( >=net-print/cups-1.6.2-r5 )
	systemd? ( >=sys-apps/systemd-204-r1 )
	client? ( >=sys-libs/readline-6.2_p1 )
	tools? (
	    >=dev-libs/check-0.9.6
	    >=dev-python/dbus-python-1.2.0
	    >=dev-python/pygobject-2.28.6-r53
	)
"

DEPEND="${RDEPEND}"

src_configure() {
	econf --enable-optimization \
	    $(use_enable debug) \
	    --enable-pie \
	    --enable-threads \
	    --enable-library \
	    --disable-test \
	    $(use_enable tools) \
	    $(use_enable monitor) \
	    $(use_enable udev) \
	    $(use_enable cups) \
	    $(use_enable obex) \
	    $(use_enable client) \
	    $(use_enable systemd) \
	    --enable-datafiles \
	    $(use_enable experimental)
}

src_install() {
	emake DESTDIR="${D}" install

	insinto /etc/bluetooth

	local d
	for d in input network proximity; do
	    doins profiles/${d}/${d}.conf
	done

	doins src/main.conf
	doins src/bluetooth.conf

	insinto /usr/share/dbus-1/system-services
	doins src/org.bluez.service
	doins src/bluetooth.service

	udev_newrules tools/hid2hci.rules 97-hid2hci.rules

	newinitd "${FILESDIR}"/bluetooth-init.d bluetooth
}

pkg_postinst() {
	udevadm control --reload-rules
}
