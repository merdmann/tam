-- ------------------------------------------------------------------------- --
--                                                                           --
--  Filename        : $Source: /cvsroot/TAM/TAM/Makefile
--  Description     : Util base package                                      --
--  Author          : Michael Erdmann <Michael.Erdmann@snafu.de>             --
--  Created On      : 30-April-2005                                          --
--  Last Modified By: $Author: merdmann $                                    --
--  Last Modified On: $Date: 2007/01/21 08:48:35 $                           --
--  Status          : $State: Exp $                                          --
--                                                                           --
--  Copyright (C) 2005 Michael Erdmann                                       --
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
--  Public License  distributed with TAM;  see file COPYING.  If not, write  --
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
with System.Storage_Elements;           use System.Storage_Elements;
with System;				use System;
with System.Address_To_Access_Conversions;

with Ada.Strings.Unbounded;		use Ada.Strings.Unbounded;
with Ada.Streams;                       use Ada.Streams;
with Ada.Characters.Latin_1;		use Ada.Characters.Latin_1;
with Ada.Characters.Handling;		use Ada.Characters.Handling;
with Ada.Unchecked_Deallocation;

with Unchecked_Conversion;

with Util.Trace;			use Util.Trace;
with Util.Trace_Helper;
use  Util;

package body Util.Types is

   Verson : constant String := "$Id: util-types.adb,v 1.1 2007/01/21 08:48:35 merdmann Exp $";

   package Tracer is new Trace_Helper( Module => "Util.Types" );
   use Tracer;

   ----------
   -- Free --
   ----------
   procedure Free(
      Buffer : in out Buffer_Access ) is
      procedure XFree is new Ada.Unchecked_Deallocation( Storage_Array, Buffer_Access);
   begin
      XFree( Buffer );
   end Free;

   ----------
   -- Dump --
   ----------
   procedure Dump(
      Data   : in Buffer_Access;
      Length : in Natural;
      Level  : in Level_Type := Trace.Functional ) is
      ------------
      -- Encode --
      ------------
      function Encode(
         Value  : in Storage_Element ) return String is
         Hi     : Natural := ( Natural(Value) / 16 ) mod 16;
         Lo     : Natural :=   Natural(Value)  mod 16;
         HexVal : constant String := "0123456789ABCDEF";
      begin
         return HexVal( Hi+1 ) & HexVal( Lo+1 );
      end Encode;

      Hex  : Unbounded_String := Null_Unbounded_String;

   begin
      LOG( Level, "Buffer Length :" & Natural'Image( Length ) );

      if Data = null then
         LOG( Level, "*** No data available **** ");
	 return;
      end if;

      LOG( Level, "Buffer Data   :" );

      for i in 1..Length loop
         if Storage_Offset(i) in Data'Range then
            Hex := Hex & Encode( Data( Storage_Offset(i) ) ) & " ";
	 else
	    Hex := Hex & "**" ;
	 end if;

         if i > 0 and (i mod 16 = 0) then
            LOG( Level,  "   " & To_String(Hex) );
            Hex  := Null_Unbounded_String;
         end if;
      end loop;
      LOG( Level,  "   " & To_String(Hex) );
   end Dump;

   ----------
   -- Dump --
   ----------
   procedure Dump(
      Data  : in Stream_Element_Array;
      Level : in Level_Type := Trace.Functional ) is
      ------------
      -- Encode --
      ------------
      function Encode(
         Value  : in Stream_Element ) return String is
         Hi     : Natural := ( Natural(Value) / 16 ) mod 16;
         Lo     : Natural :=   Natural(Value)  mod 16;
	 HexVal : constant String := "0123456789ABCDEF";
      begin
         return HexVal( Hi+1 ) & HexVal( Lo+1 );
      end Encode;

      Hex : Unbounded_String := Null_Unbounded_String;
      Asc : Unbounded_String := Null_Unbounded_String;

      P   : Stream_Element_Offset := Data'First ;
      A   : Address ;
   begin
      LOG( Level, "Stream Object Length :" & Natural'Image( Data'Length ) );
      LOG( Level, "Stream Object Data   :" );
      while P in Data'Range loop
         A := Data(p)'Address;

         for i in 1..16 loop
            if P in Data'Range then
               Hex  := Hex & Encode( Data(P) ) & " ";
	       if Is_Graphic( Character'Val(Data(P)) ) then
	          Asc  := Asc & Character'Val( Data(p) ) ;
	       else
	          Asc  := Asc & ".";
	       end if;
	       P := P + 1;
	    else
	       Hex := Hex & "   " ;
	    end if;
         end loop;

	 LOG( Level, Image( A ) & "   " & To_String(Hex) & " | " &  To_String( Asc ) );

	 Hex := Null_Unbounded_String;
	 ASC := Null_Unbounded_String;
      end loop;

      LOG( Level,  "   " & To_String(Hex) );
   end Dump;

   -----------
   -- Image --
   -----------
   function Image(
     A : in Integer ) return String is

     T : constant String := "0123456789abcdef" ;
     R : String( 1..8 ) := ( others => ' ' );
     V : Integer := A;
     J : Natural := R'Last;
   begin
     while J in R'Range loop
        declare
           H  : Natural := V mod 256;
           HH : Natural := H / 16;
           HL : Natural := H mod 16;
        begin
           R( J ) := T( HL + 1 );
           J := J - 1;
           R( J ) := T( HH + 1 );
           J := J - 1;
        end ;

        V := V / 256 ;

     end loop;

     return "0x" & R;
   end Image;

   -----------
   -- Image --
   -----------
   function Image(
      A : in Address ) return String is

      function To_Integer is new Unchecked_Conversion(
         Source => Address,  Target => Integer );
   begin
      return Image( To_Integer( A ) );
   end Image;

   -----------
   -- Image --
   -----------
   function Image(
      A : in Buffer_Access ) return String is

      package Conversion is
         new Address_To_Access_Conversions( Object => Storage_Array );
      use Conversion;
   begin
      return Image( To_Address( Object_Pointer(A) ) );
   end Image;


   -----------
   -- Image --
   -----------
   function Image(
      Key : in Key_Access ) return String is
   begin
      if Key = null then
         return "** null **";
      else
         declare
            Result_Length : constant Natural := Key.all'Length * 2;
            Result : String( 1..Result_Length ) := ( others => ' ');
            L : Natural := Result'First;
            HexVal : constant String := "0123456789ABCDEF";
	 begin
            for i in Key.all'Range loop
               Result(L)   := HexVal( Natural(Key(i)) / 16 );
	       Result(L+1) := HexVal( Natural(Key(i)) mod 16 );

	       L := L + 2;
            end loop;

            return Result;
	 end ;
      end if;
   end Image;

end Util.Types;
