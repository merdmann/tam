-------------------------------------------------------------------------------
--                                                                           --
--  Filename        : $Source: /cvsroot/TAM/TAM/contrib/objects/util/util-cas.ads,v $
--  Version         : $Revision: 1.2 $                                       --
--  Description     : Compare and Set Package                                --
--  Author          : Michael Erdmann <Michael.Erdmann@snafu.de>             --
--  Created On      : 20-Oct-2006                                            --                                           --
--  Last Modified By: $Author: merdmann $				     --
--  Last Modified On: $Date: 2007/02/01 20:33:09 $                           --
--  Status          : $State: Exp $                                          --
--                                                                           --
--  Copyright (C) 2005 Michael Erdmann                                       --
--                                                                           --
--  ADB is free software;  you can redistribute it  and/or modify it under   --
--  terms of the  GNU General Public License as published  by the Free Soft- --
--  ware  Foundation;  either version 2,  or (at your option) any later ver- --
--  sion.  ODB is distributed in the hope that it will be useful, but WITH-  --
--  OUT ANY WARRANTY;  without even the  implied warranty of MERCHANTABILITY --
--  or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License --
--  for  more details.  You should have  received  a copy of the GNU General --
--  Public License  distributed with ADB;  see file COPYING.  If not, write  --
--  to  the Free Software Foundation,  59 Temple Place - Suite 330,  Boston, --
--  MA 02111-1307, USA.                                                      --
--                                                                           --
--  As a special exception,  if other files  instantiate  generics from this --
--  unit, or you link  this unit with other files  to produce an executable, --
--  this  unit  does not  by itself cause  the resulting  executable  to  be --
--  covered  by the  GNU  General  Public  License.  This exception does not --
--  however invalidate  any other reasons why  the executable file  might be --
--  covered by the  GNU Public License.                                      --
--                                                                           --
--  Functional Description                                                   --
--  ======================                                                   --
--                                                                           --
--  Restrictions                                                             --
--  ============                                                             --
--                                                                           --
--  References                                                               --
--  ==========                                                               --
--  None                                                                     --
--                                                                           --
-------------------------------------------------------------------------------
generic
   type Object_Type is private;
   Initial_Value : Object_Type ;

package Util.CAS is

   protected type Object is
      function Get return Object_Type ;

      procedure CompareAndSet(
         Expected  : in Object_Type;
	 New_Value : in Object_Type;
	 Success   : out Boolean);

   private
      Value : Object_Type := Initial_Value;
   end Object;

   procedure CompareAndSet(
      This      : in out Object;
      Expected  : in Object_Type ;
      New_Value : in Object_Type;
      Success   : out Boolean );

   function Get( This : in Object ) return Object_Type;


end Util.CAS;

