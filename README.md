tam
===

This is an Ada 95 project on a linux platform. It has been developed
using an standard framework for such developments. The build results
are stored localy in the directories:

   <arch>-lib
   <arch>-bin
   <arch>-include
   <arch>-install


Installation
============
This is the source release of the package which means before 
using the package you need to recompile the library and install
it on your system.

Step 0 - Unpacking the release
  gunzip -c adadba-src-<version>.tar.gz | tar xvf -


Step 1 - Configuration

  Check the correct settings in etc/site.conf.
  Run the configure utility

   ./configure


Step 2 - Compile

  Execute in the installation directory the following 
  command(s):

  gmake

Step 4 - Generate Documentation

  gmake documentation

  The documentation will be located under doc.

Step 5 - Systemwide installation

  su - ....
  gmake install


Test
====


Modify and adding components
============================


Examples
========





