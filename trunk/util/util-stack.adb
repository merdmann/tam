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
with Unchecked_Deallocation;

package body Util.Stack is

   Version : constant String := "$Id: util-stack.adb,v 1.1 2007/01/21 08:48:35 merdmann Exp $";

   ---------------
   -- Node_Type --
   ---------------
   type Node_Type;
   type Node_Access is access all Node_Type ;

   type Node_Type is record
         Next  : Node_Access := null;
	 Value : Element_Type;
      end record;
      
   procedure Free_Element is
      new Unchecked_Deallocation( Node_Type, Node_Access);

   ----------------------
   -- Object_Data_Type --
   ----------------------
   type Object_Data_Type is record
         Head : Node_Access := null;
      end record;

   procedure Free is
      new Unchecked_Deallocation( Object_Data_Type, Object);
   ------------
   -- Create --
   ------------
   function Create return Object is 
      Result : Object := new Object_Data_Type;
   begin
      return Result;
   end Create;

   -------------
   -- Destroy --
   -------------
   procedure Destroy( 
      This : in out Object ) is 
      -- destroy the complete stack
      P    : Node_Access := This.Head;
   begin
      while P /= null loop
         declare
	    Tmp : Node_Access := p;
	 begin
            P := P.Next;
	    Free_Element( Tmp );
	 end;
      end loop;
      Free( This );
   end Destroy;

   ----------
   -- Push --
   ----------
   procedure Push(
      This  : in out Object;
      Value : in Element_Type ) is 
      Node  : Node_Access := new Node_Type;
   begin
      Node.Value := Value;
      Node.Next  := This.Head;
      This.Head  := Node;
   end Push;

   ---------
   -- Pop --
   ---------
   procedure Pop(
      This  : in out Object;
      Value : out Element_Type ) is 
   begin
      if This.Head /= null then
         Value     := This.Head.Value;
         This.Head := This.Head.Next;
      else 
         raise Stack_Empty;
      end if;
   end Pop;

   ---------
   -- Top --
   ---------
   function Top(
      This : in Object ) return Element_Type is
   begin
      if This.Head /= null then
         return This.Head.Value;
      else
         raise Stack_Empty;
      end if;
   end Top;

   -------------
   -- Destroy --
   -------------
   function Size( 
      This   : in Object ) return Natural is 
      -- destroy the complete stack
      P      : Node_Access := This.Head;
      Result : Natural := 0;
   begin
      while P /= null loop
         Result := Result + 1;
         P := P.Next;
      end loop;

      return Result;
   end Size;

end Util.Stack;
