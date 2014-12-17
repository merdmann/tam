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

with Ada.Streams;			use Ada.Streams;
with Util.Trace;			use Util.Trace;
use  Util;

package Util.Types is

   type Buffer_Access is access all Storage_Array;

   procedure Free(
      Buffer : in out Buffer_Access );

   function Image(
      A : in Address ) return String;

   function Image(
      A : in Buffer_Access ) return String;

   function Image(
      A : in Integer ) return String;

   procedure Dump(
      Data   : in Buffer_Access;
      Length : in Natural;
      Level  : in Level_Type := Trace.Functional );

   procedure Dump(
      Data  : in Stream_Element_Array;
      Level : in Level_Type := Trace.Functional );

   subtype Key_Type is Storage_Array;
   type Key_Access is access Key_Type;

   function Image(
      Key : in Key_Access ) return String;

   Invalid_Parameters : exception;

end Util.Types;
