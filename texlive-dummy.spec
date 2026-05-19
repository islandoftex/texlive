# This is a placeholder package for a docker container in which the full techstack has been
# manually installed.  It is not meant for use outside this dedicated built docker container
# as it has no upgrade path.  As RedHat managed packages make use of the tex applications
# the ability to still load up these packages provides continued support for tools outside
# the texlive infrastructure.
#
# To build this into an rpm file use:
#
# $ rpmbuild -bb texlive-dummy.spec
#
# in the RedHat image of choice and an rpm will be built in the user's home folder.
Name:           texlive-dummy
Version:        1
Release:        0
Epoch:          99
Summary:        A dummy tex package to allow additional RedHat packages to be installed with a manual texlive full install.

Provides:      tex(dvips)
Provides:      tex(latex)
Provides:      tex(preview.sty)
Provides:      tex(url.sty)
Provides:      tex(adjustbox.sty)
Provides:      tex(alltt.sty)
Provides:      tex(amssymb.sty)
Provides:      tex(appendix.sty)
Provides:      tex(array.sty)
Provides:      tex(calc.sty)
Provides:      tex(caption.sty)
Provides:      tex(color.sty)
Provides:      tex(courier.sty)
Provides:      tex(dvips)
Provides:      tex(etoc.sty)
Provides:      tex(fancyhdr.sty)
Provides:      tex(fancyvrb.sty)
Provides:      tex(fixltx2e.sty)
Provides:      tex(float.sty)
Provides:      tex(fontenc.sty)
Provides:      tex(geometry.sty)
Provides:      tex(graphicx.sty)
Provides:      tex(hanging.sty)
Provides:      tex(helvet.sty)
Provides:      tex(hyperref.sty)
Provides:      tex(ifpdf.sty)
Provides:      tex(ifthen.sty)
Provides:      tex(ifxetex.sty)
Provides:      tex(import.sty)
Provides:      tex(inputenc.sty)
Provides:      tex(latex)
Provides:      tex(listings.sty)
Provides:      tex(makeidx.sty)
Provides:      tex(mathptmx.sty)
Provides:      tex(multicol.sty)
Provides:      tex(multirow.sty)
Provides:      tex(natbib.sty)
Provides:      tex(newunicodechar.sty)
Provides:      tex(pspicture.sty)
Provides:      tex(sectsty.sty)
Provides:      tex(stackengine.sty)
Provides:      tex(tabu.sty)
Provides:      tex(tabularx.sty)
Provides:      tex(textcomp.sty)
Provides:      tex(tocloft.sty)
Provides:      tex(ulem.sty)
Provides:      tex(varwidth.sty)
Provides:      tex(verbatim.sty)
Provides:      tex(wasysym.sty)
Provides:      tex(xcolor.sty)
Provides:      tex(xtab.sty)
Provides:      texlive-bibtex
Provides:      texlive-epstopdf
Provides:      texlive-makeindex
Provides:      tex(cm-super-t1.enc)
Provides:      tex(ecrm1000.tfm)
Provides:      tex(latex)
Provides:      tex(utf8x.def)
Provides:      tex(comment.sty)
Provides:      tex-preview
Provides:      tex-latex-bin
Provides:      tex-latex-bin-bin
Provides:      texlive-dvips
Provides:      texlive-latex-fonts

License:       GPL
URL:           https://github.com/islandoftex/texlive

%description
This is a dummy tex package created for testing purposes.

%install
mkdir -p %{buildroot}/usr/bin
ln -s /usr/local/texlive/*/bin/*-linux/dvips %{buildroot}/usr/bin
ln -s /usr/local/texlive/*/bin/*-linux/latex %{buildroot}/usr/bin
ln -s /usr/local/texlive/*/bin/*-linux/pdflatex %{buildroot}/usr/bin
ln -s /usr/local/texlive/*/bin/*-linux/texconfig-sys %{buildroot}/usr/bin

# Some of the RedHat packages "Require" direct file paths.  We'll make these available via symbolic links:
%files
/usr/bin/dvips
/usr/bin/latex
/usr/bin/pdflatex
/usr/bin/texconfig-sys
