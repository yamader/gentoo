# Copyright 1999-2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit cmake

DESCRIPTION="Electronic Schematic and PCB design tools manuals"
HOMEPAGE="https://docs.kicad.org/"

if [[ ${PV} == 9999 ]]; then
	EGIT_REPO_URI="https://gitlab.com/kicad/services/kicad-doc.git"
	inherit git-r3
	# x11-misc-util/macros only required on live ebuilds
	LIVE_DEPEND=">=x11-misc/util-macros-1.18"
else
	MY_PV="${PV/_rc/-rc}"
	MY_P="${PN}-${MY_PV}"
	SRC_URI="https://gitlab.com/kicad/services/${PN}/-/archive/${MY_PV}/${MY_P}.tar.gz -> ${P}.tar.gz"
	S="${WORKDIR}/${PN}-${MY_PV}"
	KEYWORDS="~amd64 ~arm64 ~x86"
fi

LICENSE="|| ( GPL-3+ CC-BY-3.0 ) GPL-2"
SLOT="0"
# TODO: Change default back to +df once asciidoctor-pdf is packaged?
IUSE="+html pdf"

LANG_USE=" l10n_ca l10n_de l10n_en l10n_es l10n_fr l10n_id l10n_it l10n_ja l10n_pl l10n_ru l10n_zh"
IUSE+=${LANG_USE}
REQUIRED_USE="|| ( html pdf ) ^^ ( ${LANG_USE} )"
unset LANG_USE

# TODO: need asciidoctor-pdf for pdf
# bug #697450
BDEPEND="
	>=app-text/asciidoc-8.6.9
	>=app-text/dblatex-0.3.10
	>=app-text/po4a-0.45
	>=sys-devel/gettext-0.18
	dev-perl/Unicode-LineBreak
	dev-util/source-highlight
	l10n_ca? ( dev-texlive/texlive-langspanish )
	l10n_de? ( dev-texlive/texlive-langgerman )
	l10n_en? ( dev-texlive/texlive-langenglish )
	l10n_es? ( dev-texlive/texlive-langspanish )
	l10n_fr? ( dev-texlive/texlive-langfrench )
	l10n_it? ( dev-texlive/texlive-langitalian )
	l10n_ja? ( dev-texlive/texlive-langjapanese media-fonts/vlgothic )
	l10n_pl? ( dev-texlive/texlive-langpolish )
	l10n_ru? ( dev-texlive/texlive-langcyrillic )
	l10n_zh? ( dev-texlive/texlive-langchinese )"

src_configure() {
	local mycmakeargs=(
		# May not always work?
		# https://gitlab.com/kicad/services/kicad-doc/-/issues/808
		-DADOC_TOOLCHAIN="ASCIIDOC"
		# Note: need EAPI 8 usev here, not pre-EAPI 8 behaviour
		-DBUILD_FORMATS="$(usev html);$(usev pdf)"
		-DSINGLE_LANGUAGE="${L10N}"
		-DKICAD_DOC_PATH="${EPREFIX}"/usr/share/doc/${PF}/help
	)
	cmake_src_configure
}
