# ***************************************************************************
# *  $Id: Makefile 163 2008-08-05 17:43:41Z merdmann $
# *
# *  Thu Nov 29 21:15:34 2007
# *  Copyright  2007,2008  Michael Erdmann
# *  Email: michael.erdmann@snafu.de
# ****************************************************************************/

#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.
#

#
# Targets
# =======
#
# default / all  --> builds the complete package
#
# clean			 --> cleanup the environemt by deleting all temporary files
#
# package        --> build a source package
#                    Please note, that after this has been executed the complete
#					 install tree can be found under $VARDIR/$(distname). 
#                    The inention is that this environment shall be used for 
#					 verification of the actual package.
#
include ./VERSION
include make.conf

version=$(VERSION_MAJOR).$(VERSION_MINOR).$(VERSION_PATCH)
distname=tam-$(version)-src
ROOT=.

.PHONY: dist package label publish 

## ################################################################
## create all directories all other environment stuff
all :: lib bin var

	
lib var bin:
	mkdir $@ 

## ################################################################
## clean / build the complete procject
all clean deps :: 
	$(MAKE) -C./util $@

clean :: 
	$(RM) -rf *~ *.bak 
	$(RM) -rf var lib bin

## ###############################################################
## build documentation
all docs ::
	$(MAKE) -C./doc all

clean :: 
	$(MAKE) -C./doc clean

## ################################################################
## prepare a dstribution and publish it at source forge
dist :: all
	$(MAKE) ROOT=./ package
	$(MAKE) label version=$(version)

package :: 
	tar cvf $(VARDIR)/gnade.tgz -z --files-from=MANIFEST
	-mkdir $(VARDIR)/$(distname) 
	( cd $(VARDIR)/$(distname) && tar xvf ../gnade.tgz )
	$(MAKE) -C$(VARDIR)/$(distname)/doc ROOT=$(ROOT) all 
	( cd $(VARDIR) && tar cvf ../$(distname).tgz -z $(distname) ) 


$(distname).tgz :: MANIFEST docs
	tar cvf $(distname).tgz -z --files-from=MANIFEST

label ::
	svn copy $(SVNROOT)/trunk $(SVNROOT)/tags/$(version) -m "release $(version)"

publish: dist
	scp  $(distname).tgz  merdmann@frs.sourceforge.net:uploads/$(distname).tgz


