-- ------------------------------------------------------------------------- --
--                                                                           --
--  Filename        : $Source: /cvsroot/TAM/TAM/Makefile
--  Description     : Memory Stream                                          --
--  Author          : Michael Erdmann <Michael.Erdmann@snafu.de>             --
--  Created On      : 24-Aug.-2008                                           --
--  Last Modified By: $Author: merdmann $                                    --
--  Last Modified On: $Date: 2007/02/01 20:33:09 $                           --
--  Status          : $State: Exp $                                          --
--                                                                           --
--  Copyright (C) 2008 Michael Erdmann                                       --
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
with Ada.Streams;               use Ada.Streams;
with Ada.Text_IO;		use Ada.Text_IO;
use  Ada;

with Unchecked_Deallocation;

package body Util.Memory_Streams is

   Version : constant String :=
      "$Id: util-memory_streams.adb,v 1.1 2007/02/01 20:33:09 merdmann Exp $";

   procedure Free is
      new Unchecked_Deallocation( Stream_Element_Array, Stream_Element_Array_Access);

   ----------------
   -- Initialize --
   ----------------
   function Initialize( Size : Natural ) return Stream_Element_Array_Access is
   begin
      return new Stream_Element_Array(1..Stream_Element_Offset(Size));
   end ;

   ------------
   -- Stream --
   ------------
   function Stream( Size : Natural ) return Stream_Access is
      Result : Memory_Stream_Access := new Memory_Stream_Type( Size );
   begin
      Result.Read_Next := Result.Data'First;

      return Stream_Access( Result );
   end Stream;

   -------------
   -- Destroy --
   -------------
   procedure Destroy(
      Stream : in out Stream_Access ) is

      procedure Free is
         new Unchecked_Deallocation( Memory_Stream_Type, Memory_Stream_Access );

   begin
      Free( Memory_Stream_Access( Stream ) );
   end Destroy;

   ----------
   -- Read --
   ----------
   procedure Read(
      Stream : in out Memory_Stream_Type;
      Item   : out Stream_Element_Array;
      Last   : out Stream_Element_Offset) is
   begin
      Last := 0;
      for I in Item'Range loop
         exit when Stream.Read_Next > Stream.Write_Next ;

         Item( I ) := Stream.Data( Stream.Read_Next );
         Last := I;
         Stream.Read_Next := Stream.Read_Next + 1;
      end loop;
   end Read;

   -----------
   -- Write --
   -----------
   procedure Write(
      Stream : in out Memory_Stream_Type;
      Item   : in Stream_Element_Array) is
   begin
      for I in Item'Range loop
	 Stream.Write_Next := Stream.Write_Next + 1;
	 if not ( Stream.Write_Next in Stream.Data'Range ) then
	    declare
	       Tmp : Stream_Element_Array_Access := Stream.Data ;
	    begin
	       Stream.Data := new Stream_Element_Array( 1..Stream.Write_Next + 2000 );

	       for i in Tmp'Range loop
	          Stream.Data(i) := Tmp(i);
	       end loop;

	       Free( Tmp );
	    end ;
	 end if;

         Stream.Data(Stream.Write_Next) := Item(I);

      end loop;
   end Write;

   ------------
   -- Length --
   ------------
   function Length(
      Stream : in Stream_Access ) return Natural is
      Mem    : Memory_Stream_Access := Memory_Stream_Access( Stream );
   begin
      return Natural( Mem.Write_Next );
   end Length;

   ------------------
   -- Get_Contents --
   ------------------
   procedure Get_Contents(
      Stream : in Stream_Access;
      Result : in out Storage_Array;
      Length : out Natural ) is
      Mem    : Memory_Stream_Access := Memory_Stream_Access( Stream );
      Tmp    : Stream_Element_Offset := Mem.Data'First;
   begin
      Length := 0;
      for i in Result'Range loop
         Length := Length + 1;
         Result(i) :=  Storage_Element( Mem.Data( Tmp ) );
	 Tmp := Tmp + 1;
	 exit when Tmp > Mem.Write_Next;
      end loop;

   end Get_Contents;

   ------------------
   -- Set_Contents --
   ------------------
   procedure Set_Contents(
      Stream : in Stream_Access;
      Value  : in Storage_Array ) is
      Mem    : Memory_Stream_Access := Memory_Stream_Access( Stream );
      Tmp    : Stream_Element_Offset;
   begin
      if Mem.Data /= null then
         Free( Mem.Data );
      end if;

      Mem.Data := Initialize( Value'Length );
      Tmp := Mem.Data'First;

      for i in Value'Range loop
         Mem.Data( Tmp ) := Stream_Element( Value(i) );
	 Tmp := Tmp + 1;
      end loop;

      Mem.Write_Next := Value'Length;
      Mem.Read_Next  := Mem.Data'First;

   end Set_Contents;

end Util.Memory_Streams;
