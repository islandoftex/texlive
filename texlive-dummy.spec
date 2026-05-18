Name:           texlive-dummy
Version:        1
Release:        0
Epoch:          99
Summary:        A dummy tex package

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
Provides:      tex-preview



License:        GPL
URL:            https://example.com

%description
This is a dummy tex package created for testing purposes.

%install
mkdir -p %{buildroot}/usr/bin
ln -s /usr/local/texlive/*/bin/*-linux/latex %{buildroot}/usr/bin
ln -s /usr/local/texlive/*/bin/*-linux/pdflatex %{buildroot}/usr/bin
ln -s /usr/local/texlive/*/bin/*-linux/texconfig-sys %{buildroot}/usr/bin


%files
/usr/bin/latex
/usr/bin/pdflatex
/usr/bin/texconfig-sys
