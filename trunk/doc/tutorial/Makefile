## ----------------------------------------------------------------------------
##                                                                           --
##                      GNADE  : GNu Ada Database Environment                --
##                                                                           --
##  Filename        : $Source: /cvsroot/gnade/gnade/contrib/objects/doc/tutorial/Makefile,v $
##  Description     : Top level makefile for the documentation               --
##  Author          : Michael Erdmann <michael.erdmann@snafu.de>             --
##  Created On      : 03-Oct-2002
##  Last Modified By: $Author: merdmann $
##  Last Modified On: $Date: 2007/01/21 08:48:35 $                           --
##  Status          : $State: Exp $                                          --
##                                                                           --
##  Copyright (C) 2002                                                       --
##                                                                           --
##  GNADE is copyrighted by the persons and institutions enumerated in the   --
##  AUTHORS file. This file is located in the root directory of the          --
##  GNADE distribution.                                                      --
##                                                                           --
##  GNADE is free software;  you can redistribute it  and/or modify it under --
##  terms of the  GNU General Public License as published  by the Free Soft- --
##  ware  Foundation;  either version 2,  or (at your option) any later ver- --
##  sion.  GNAT is distributed in the hope that it will be useful, but WITH- --
##  OUT ANY WARRANTY;  without even the  implied warranty of MERCHANTABILITY --
##  or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License --
##  for  more details.  You should have  received  a copy of the GNU General --
##  Public License  distributed with GNAT;  see file COPYING.  If not, write --
##  to  the Free Software Foundation,  59 Temple Place - Suite 330,  Boston, --
##  MA 02111-1307, USA.                                                      --
##                                                                           --
##  As a special exception,  if other files  instantiate  generics from      --
##  GNADE Ada units, or you link GNADE Ada units or libraries with other     --
##  files  to produce an executable, these  units or libraries do not by     --
##  itself cause the resulting  executable  to  be covered  by the  GNU      --
##  General  Public  License.  This exception does not however invalidate    --
##  any other reasons why  the executable file  might be covered by the      --
##  GNU Public License.                                                      --
##                                                                           --
##  GNADE is implemented to work with GNAT, the GNU Ada compiler.            --
##                                                                           --
## ----------------------------------------------------------------------------
##
##  Functional Description
##  ======================
##  This makefile builds the various documentation formats. The input 
##  is SGML docbook.
##
##  If the aspell utility is installed on the system, a gobal spell check
##  is done which summerizes all missspellings. If the number of 
##  errors is to large consider the execution of a real spellcheck 
##  run.
##
##  Restrictions
##  ============
##  - Spellcheck is based upon the aspell utility.
##
##  References
##  ==========
##  None
##
##
include ../../make.conf

##
## Logfiles of the docbuild run  
##     
LOG=docbuild.log
DOCBUILDER=../bin/docbuild.sh
docdir=../books

## Basename of the document
docbase=tutorial


parts=$(docbase).sgml gpl.sgml gfdl.sgml 

images=Datamodel.eps Relations.eps Components.eps
uml_path=../uml

## #############################################################################################
##                         N O N    C U S T I M I Z E D   P A R T
## #############################################################################################

## Targets to be build
targets=$(docdir)/html/$(docbase).html $(docdir)/$(docbase).ps $(docdir)/$(docbase).pdf 

## images to create
gif_images=$(subst .eps,.gif,$(images))

all :: $(images) $(targets)
	$(MAKE) $(docbase).tex $(targets)

$(images): $(gif_images)

$(gif_images):
	$(CP) $(uml_path)/$*.gif .

##
## Targets are the different file formats for the reference guide
##
$(docdir)/$(docbase).pdf :: $(docdir)/$(docbase).ps
#	$(DOCBUILDER) --pdf --log=$(LOG) --target=$@ $(docbase) 
	ps2pdf $(docdir)/$(docbase).ps $(docdir)/$(docbase).pdf

$(docdir)/$(docbase).ps :: $(docbase).tex
	$(DOCBUILDER) --ps --log=$(LOG) --target=$@ $(docbase) 

$(docdir)/html/$(docbase).html :: $(docbase).tex
	$(DOCBUILDER) --html --log=$(LOG) $(docbase)
	rm -rf $(docdir)/html
	-mkdir -p $(docdir)/html
	-mv *.html *.htm $(docdir)/html
	-cp *.gif $(docdir)/html

$(docbase).tex :: $(parts)
	$(DOCBUILDER) --tex $(docbase).sgml

##
## Build the directory for distribution. This target will also be 
## executed in the production of the target environment but the 
## result file shall never be mentioned in the MANIFEST.local.
##
dist ::	distclean
	tar cvf template.tar *.sgml
	gzip -f template.tar

##
## Install the distribution in the local environment.
##
install ::

##
##  clean up the directory
##
clean ::
	rm -f *.aux *.log *.tex *.dvi *.out *.pdf *.htm *.html *~ *.bak *.gz
	rm -f *.jpg *.eps
	rm -f $(LOG)	
##
##
##
distclean :: clean
	rm -f *.dvi *.ps *.pdf *.rtf *.eps *.gif
