-- ------------------------------------------------------------------------- --
--                                                                           --
--  Filename        : $Source: /cvsroot/TAM/TAM/contrib/objects/tam/tam-persistent.adb,v $
--  Description     : Base class for all persistent objects                  --
--  Author          : Michael Erdmann <Michael.Erdmann@snafu.de>             --
--  Created On      : 30-April-2005                                          --
--  Last Modified By: $Author: merdmann $                                    --
--  Last Modified On: $Date: 2007/02/03 14:59:52 $                           --
--  Status          : $State: Exp $                                          --
--                                                                           --
--  Copyright (C) 2006-2008 Michael Erdmann                                  --
--                                                                           --
--  TAM is copyrighted by the persons and institutions enumerated in the     --
--  AUTHORS file. This file is located in the root directory of the          --
--  TAM distribution.                                                        --
--                                                                           --
--  TAM is free software;  you can redistribute it  and/or modify it under   --
--  terms of the  GNU General Public License as published  by the Free Soft- --
--  ware  Foundation;  either version 2,  or (at your option) any later ver- --
--  sion.  GNAT is distributed in the hope that it will be useful, but WITH- --
--  OUT ANY WARRANTY;  without even the  implied warranty of MERCHANTABILITY --
--  or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License --
--  for  more details.  You should have  received  a copy of the GNU General --
--  Public License  distributed with TAM;  see file COPYING. If not, write   --
--  to  the Free Software Foundation,  59 Temple Place - Suite 330,  Boston, --
--  MA 02111-1307, USA.                                                      --
--                                                                           --
--  As a special exception,  if other files  instantiate  generics from      --
--  TAM Ada units, or you link TAM Ada units or libraries with other         --
--  files  to produce an executable, these  units or libraries do not by     --
--  itself cause the resulting  executable  to  be covered  by the  GNU      --
--  General  Public  License.  This exception does not however invalidate    --
--  any other reasons why  the executable file  might be covered by the      --
--  GNU Public License.                                                      --
--                                                                           --
-- ------------------------------------------------------------------------- --
with Ada.Calendar;			use Ada.Calendar;
with Ada.Unchecked_Conversion;
use  Ada;

with Util.Trace_Helper;
use  Util;

package body TAM.Persistent is

   Version : constant String :=
       "$Id: tam-persistent.adb,v 1.2 2007/02/03 14:59:52 merdmann Exp $";

   -- Trace facitlity package
   package Tracer is new Util.Trace_Helper( Module => "Persistent");
   use Tracer;

   ----------------
   -- Initialize --
   ----------------
   procedure Initialize(
      This : in out Object ) is
   begin
      Enter("Initialize");
      This.Self := This'Unchecked_Access;

      Leave("Initialize");
   end Initialize;

   --------------
   -- Finalize --
   --------------
   procedure Finalize(
      This : in out Object ) is
   begin
      Enter("Finalize( " & "ID=" & Integer'Image(This.ID) & ")" );

      This.Self := null;

      Leave("Finalize");
   end Finalize;

   -------------------
   -- New_Object_ID --
   -------------------
   function New_Object_ID return Integer is

      function To_Object_ID is
         new Unchecked_Conversion( Source => Time, Target => Integer );
   begin
      return To_Object_ID( clock );
   end New_Object_ID;

   ---------
   -- OID --
   ---------
   function OID(
      This : in Object'Class ) return Integer is
   begin
      return This.ID;
   end OID;

   ---------
   -- OID --
   ---------
   procedure OID(
       This : in out Object'Class;
       ID   : in Integer ) is
   begin
      This.ID := ID;
   end OID;

   ----------
   -- Self --
   ----------
   function Self(
      This : in Object'Class ) return Handle is
   begin
      return This.Self ;
   end Self;

   procedure Self(
      This : in out Object'Class ) is
   begin
      This.Self := This'Unchecked_Access;
   end Self;

end TAM.Persistent;
