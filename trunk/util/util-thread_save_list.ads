-- ------------------------------------------------------------------------- --
--                                                                           --
--  Filename        : $Source: /cvsroot/TAM/TAM/Makefile
--  Description     : Util base package                                      --
--  Author          : Michael Erdmann <Michael.Erdmann@snafu.de>             --
--  Created On      : 30-April-2005                                          --
--  Last Modified By: $Author: merdmann $                                    --
--  Last Modified On: $Date: 2007/02/03 14:59:52 $                           --
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
with Ada.Finalization;			use Ada.Finalization;
with Util.Lock;				use Util.Lock;

generic
   type Element_Type is private;

package Util.Thread_Save_List is
   type Object is private;

   ---------------------------------------------------------------------------
   -- Description:
   --    Add an element to the list.
   -- Preconditions:
   --    None
   -- Postconditions:
   -- Exceptions:
   -- Notes:
   ---------------------------------------------------------------------------
   procedure Append(
      This : in out Object;
      Item : in Element_Type );

   ---------------------------------------------------------------------------
   -- Description:
   -- Preconditions:
   -- Postconditions:
   -- Exceptions:
   -- Notes:
   ---------------------------------------------------------------------------
   type Enumerator_Type is private;

   type Sharing_Mode_Type is ( Read_Only, Master, Dynamic );

   Not_Master : exception ;

   function Enumerator(
      This : Object;
      Mode : Sharing_Mode_Type := Read_Only ) return Enumerator_Type;

   function Is_End_Of_List(
      I : in Enumerator_Type ) return Boolean;

   procedure Get(
      I    : in out Enumerator_Type;
      Item : out Element_Type );

   procedure Put(
      I    : in out Enumerator_Type;
      Item : in Element_Type );

   procedure First(
      I : in out Enumerator_Type );

   procedure Delete(
      I : in out Enumerator_Type ) ;

   End_Of_List : exception;

private
   type Object_Data_Type;
   type Object_Data_Access is access Object_Data_Type;

   type Object is new Controlled with record
         Data : Object_Data_Access := null;
      end record;

   procedure Initialize(
      This : in out Object );

   procedure Finalize(
      This : in out Object );

   ---------------
   -- Node_Type --
   ---------------
   type Node_Type;
   type Node_Access is access all Node_Type;

   type Node_Type is record
         Next  : Node_Access := null;
         Prev  : Node_Access := null;
         Used  : Lock.Object;
         Value : Element_Type;
      end record;

   type Enumerator_Type is record
         Current : Node_Access := null;
         Mode    : Sharing_Mode_Type;
	 Data    : Object_Data_Access := null;
      end record;

end Util.Thread_Save_List;
