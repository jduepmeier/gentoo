# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=6

inherit eutils qmake-utils

MY_PN="zyGrib"

DESCRIPTION="GRIB File Viewer - Weather data visualization"
HOMEPAGE="http://www.zygrib.org/"
# zygrib.org has a DDoS protection and only allowd interactive downloads,
# so we mirror the tarball...
#SRC_URI="http://www.zygrib.org/getfile.php?file=${MY_PN}-${PV}.tgz -> ${P}.tgz
SRC_URI="https://dev.gentoo.org/~mschiff/distfiles/${MY_PN}-${PV}.tgz -> ${P}.tgz
	https://dev.gentoo.org/~mschiff/distfiles/${PN}-icon.png
	maps?   (
		http://zygrib.org/getfile.php?file=zyGrib_maps2.4.tgz -> zygrib-maps2.4.tgz
		http://www.zygrib.org/getfile.php?file=cities_1k-3k.txt.gz -> zygrib-cities_1k-3k.txt.gz
		http://www.zygrib.org/getfile.php?file=cities_300-1k.txt.gz -> zygrib-cities_300-1k.txt.gz
		http://www.zygrib.org/getfile.php?file=cities_0-300.txt.gz -> zygrib-cities_0-300.txt.gz
	 )"

LICENSE="GPL-3
	public-domain"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="+maps"

DEPEND="app-arch/bzip2
	dev-qt/qtsvg:5
	media-libs/libpng:*
	sci-libs/libnova
	sci-libs/proj
	sys-libs/zlib
	x11-libs/qwt:6[qt5]"

RDEPEND="${DEPEND}"

S="${WORKDIR}/${MY_PN}-${PV}"

src_prepare() {
	sed -i 's,INSTALLDIR=$(HOME)/zyGrib,INSTALLDIR=$(DESTDIR)/opt/zyGrib,' Makefile
	sed -i "s,QMAKE=/usr/bin/qmake,QMAKE=$(qt5_get_bindir)/qmake," Makefile
	sed -i "/QWTDIR/d" Makefile
	#use jpeg2k || sed -i '/^DEFS=/ s/-DUSE_JPEG2000//' src/g2clib/makefile
	sed -i '/^DEFS=/ s/-DUSE_JPEG2000//' src/g2clib/makefile
	epatch "${FILESDIR}/${P}-libs.patch"
	default
}

src_install() {
	default
	rm zyGrib
	doicon -s 32 "${DISTDIR}/zygrib-icon.png"
	make_wrapper "${PN}" "./bin/${MY_PN}" "/opt/${MY_PN}"
	domenu "${FILESDIR}/zygrib.desktop"

	if use maps; then
		insinto "/opt/${MY_PN}"
		doins -r "${WORKDIR}/data"
		insinto "/opt/${MY_PN}/data/gis"
		gzip "${WORKDIR}"/*.txt
		doins "${WORKDIR}"/*.txt.gz
	fi
}
