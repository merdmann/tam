-------------------------------------------------------------------------------
--                                                                           --
--  Filename        : $Source: /cvsroot/TAM/TAM/contrib/objects/util/util-cas.adb,v $
--  Version         : $Revision: 1.1 $                                       --
--  Description     : Compare an set operations                                  --
--  Author          : Michael Erdmann <Michael.Erdmann@snafu.de>             --
--  Created On      : 20-Oct-2006                                            --                                           --
--  Last Modified By: $Author: merdmann $				     --
--  Last Modified On: $Date: 2007/01/21 08:48:35 $                           --
--  Status          : $State: Exp $                                          --
--                                                                           --
--  Copyright (C) 2005-2008 Michael Erdmann                                       --
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
--  The functionality of compare an set operations may be used to implement  --
--  lock free concurrent algorithms.                                         --
--                                                                           --
--  Restrictions                                                             --
--  ============                                                             --
--                                                                           --
--  References                                                               --
--  ==========                                                               --
--  None                                                                     --
--                                                                           --
-------------------------------------------------------------------------------
package body Util.CAS is

  Version : constant String :=
     "$Id: util-cas.adb,v 1.1 2007/01/21 08:48:35 merdmann Exp $";

  ------------
  -- Object --
  ------------
  protected body Object is

      function Get return Object_Type is
      begin
         return Value;
      end Get;

      procedure CompareAndSet(
         Expected  : in Object_Type;
	 New_Value : in Object_Type;
	 Success   : out Boolean ) is
      begin
         Success := False;
         if Value = Expected then
	    Value   := New_Value;
	    Success := True;
	 end if;
      end CompareAndSet;

   end Object;

   -------------------
   -- CompareAndSet --
   -------------------
   procedure CompareAndSet(
      This      : in out Object;
      Expected  : in Object_Type ;
      New_Value : in Object_Type ;
      Success   : out Boolean ) is
   begin
      This.CompareAndSet( Expected, New_Value, Success );
   end CompareAndSet;

   ---------
   -- Get --
   ---------
   function Get(
      This : in Object ) return Object_Type is
   begin
      return This.Get;
   end Get;

end Util.CAS;

