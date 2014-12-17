-- ------------------------------------------------------------------------- --
--                                                                           --
--  Filename        : $Source: /cvsroot/TAM/TAM/Makefile
--  Description     : Memory Stream                                          --
--  Author          : Michael Erdmann <Michael.Erdmann@snafu.de>             --
--  Created On      : 30-April-2005                                          --
--  Last Modified By: $Author: merdmann $                                    --
--  Last Modified On: $Date: 2007/02/01 20:33:09 $                           --
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
with Ada.Streams;               use Ada.Streams;
with Ada.Streams.Stream_IO;     use Ada.Streams.Stream_IO;

with System.Storage_Elements;	use System.Storage_Elements;
use  System;

package Util.Memory_Streams is

   type Memory_Stream_Type( Size : Natural ) is
      new Root_Stream_Type with private;

   ---------------------------------------------------------------------------
   -- Description:
   -- Preconditions:
   -- Postconditions:
   -- Exceptions:
   -- Notes:
   ---------------------------------------------------------------------------
   function Stream( 
      Size : Natural ) return Stream_Access ;

   ---------------------------------------------------------------------------
   -- Description:
   -- Preconditions:
   -- Postconditions:
   -- Exceptions:
   -- Notes:
   ---------------------------------------------------------------------------
   function Length( 
      Stream : Stream_Access ) return Natural;
 
  ---------------------------------------------------------------------------
   -- Description:
   -- Preconditions:
   -- Postconditions:
   -- Exceptions:
   -- Notes:
   ---------------------------------------------------------------------------
   procedure Set_Contents(
      Stream : in Stream_Access;
      Value  : in Storage_Array );
       
   ---------------------------------------------------------------------------
   -- Description:
   -- Preconditions:
   -- Postconditions:
   -- Exceptions:
   -- Notes:
   ---------------------------------------------------------------------------
   procedure Get_Contents(
      Stream : in Stream_Access;
      Result : in out Storage_Array;
      Length : out Natural );

   ---------------------------------------------------------------------------
   -- Description:
   -- Preconditions:
   -- Postconditions:
   -- Exceptions:
   -- Notes:
   ---------------------------------------------------------------------------
   procedure Destroy(
      Stream : in out Stream_Access );

   -- ========================================================================
private
   type Stream_Element_Array_Access is access Stream_Element_Array;
   function Initialize( Size : Natural ) return Stream_Element_Array_Access;

   type Memory_Stream_Type( Size : Natural ) is
      new Root_Stream_Type with record
         Write_Next : Stream_Element_Offset := 0;
         Read_Next  : Stream_Element_Offset := 0;
         Data       : Stream_Element_Array_Access := Initialize( Size );
      end record;

   type Memory_Stream_Access is access all Memory_Stream_Type;

   procedure Read(
      Stream : in out Memory_Stream_Type;
      Item   : out Stream_Element_Array;
      Last   : out Stream_Element_Offset);

   procedure Write(
      Stream : in out Memory_Stream_Type;
      Item   : in Stream_Element_Array);

end Util.Memory_Streams;
