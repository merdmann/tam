#!/bin/sh
## ----------------------------------------------------------------------------
##                                                                           --
##  Filename        : $Source: /cvsroot/gnade/odb/bin/docbuild.sh.in,v $
##  Description     : build a docbook document on a redhat/suse system       --
##  Author          : Michael Erdmann <Michael.Erdmann@snafu.de>
##  Created On      : 27-Dec-2002
##  Last Modified By: $Author: merdmann $
##  Last Modified On: $Date: 2003/06/23 07:35:00 $
##  Status          : $State: Exp $
##
##  Copyright (C) 2000-2002 Michael Erdmann                                  --
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
##  GNADE Ada units, or you link GNADE  Ada units or libraries with other    --
##  files  to produce an executable, these  units or libraries do not by     --
##  itself cause the resulting  executable  to  be covered  by the  GNU      --
##  General  Public  License.  This exception does not however invalidate    --
##  any other reasons why  the executable file  might be covered by the      --
##  GNU Public License.                                                      --
##                                                                           --
## ----------------------------------------------------------------------------

CATALOG="CATALOG.docbook_4 CATALOG.jade_dsl CATALOG.docbk30"
JADE=jade

styles=/usr/share/sgml/docbook/dsssl-stylesheets/

DSLhtml=$styles/html/docbook.dsl
DSLprint=$styles/print/docbook.dsl

JADE_OPT="-D /usr/share/sgml -w all "
for c in $CATALOG ; do
   JADE_OPT="$JADE_OPT -c $c"
done

target=""
format="pdf"
log="/dev/null"
##
## Scan the arguments of the doc builder
##
for i in $* ;do
   case "$1" in
    -*=*) optarg=`echo "$1" | sed 's/[-_a-zA-Z0-9]*=//'` ;;
       *) optarg= ;;
   esac

   case $1 in
      --target=*)
	 target=$optarg
	 ;;

      --tex|--pdf|--ps|--html)
	 format=$1
	 ;;

      --log=*)
	 log=$optarg
	 ;;

      -help|--help|-h)
	 echo "docbuild.sh option(s) file(s)]" 
	 echo
	 echo "options:"
	 echo "   --tex             Create an tex result file"
	 echo "   --help            this message"
	 echo "   --target          the resultfile(s)"
	 echo
	 echo "The following formats may be given, provided, that in the "
	 echo "previous run, the tex file has been generated. Please note "
	 echo "that only one format is possbile per command invokation."
	 echo
	 echo "   --pdf             Adobe PDF format"
	 echo "   --ps              Postscript format"
	 echo "   --html            HTML format"

	 echo 
	 exit 0 
	 ;;

      *) 
	 files="$files $1"
	 ;;
   esac

   shift;
done

if [ "x$target" != "x" ] ; then
   JADE_OPT="$JADE_OPT -o $target"
fi

if [ "x$log" != "x" ] ; then
   JADE_OPT="$JADE_OPT -f $log"
fi

date >> $log

for f in $files; do
   case $format in
      --tex )
	 $JADE $JADE_OPT -t tex -d $DSLprint $f 
	 ;;

      --pdf )
	 pdfjadetex $f.tex >> $log
	 if [ "x$target" != "x" ]; then
	    mv $f.pdf $target
	 fi
	 ;;   

       --ps )
	 jadetex  $f.tex >> $log
	 jadetex  $f.tex >> $log
	 jadetex  $f.tex >> $log
	 echo "$target"
	 if [ "x$target" = "x" ]; then
	    target="$f.ps"
	 fi
	 dvips -o $target $f.dvi >> $log
	 ;;   
      
       --html )
	 $JADE $JADE_OPT -t sgml -d $DSLhtml $f.sgml 
	 ;;

       --rtf)
	 $JADE $JADE_OPT -t rtf  -d $DSLhtml $f.sgml 
	 ;;    
   esac
done ;
