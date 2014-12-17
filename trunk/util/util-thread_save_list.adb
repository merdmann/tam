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
--  Copyright (C) 2005,2007 Michael Erdmann                                  --
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
with Ada.Task_Identification;		use Ada.Task_Identification;
with Ada.Unchecked_Deallocation;

package body Util.Thread_Save_List is

   Version : constant String :=
       "$Id: util-thread_save_list.adb,v 1.2 2007/02/03 14:59:52 merdmann Exp $";

   ----------------------
   -- Object_Data_Type --
   ----------------------
   protected type Object_Data_Type is
      procedure Append( Item : Element_Type );
      function  First return Node_Access;
      procedure First( item : in Node_Access );
      function  Last  return Node_Access;
      procedure Last( Item : in Node_Access );
      entry Claim( Id : in Task_ID );
      procedure Release;

      private
          Head  : Node_Access := null;
          Tail  : Node_Access := null;
          Owner : Task_ID := Null_Task_ID;

   end Object_Data_Type;

   protected body Object_Data_Type is

      procedure Append( Item : Element_Type ) is
          Node : Node_Access := new Node_Type;
      begin
         Node.Value := Item;
         if Tail /= null then
            Tail.Next := Node;
            Node.Prev := Tail;
	 else
	     Head := Node;
         end if;

         Tail := Node;
      end Append;

      function First return Node_Access is
      begin
         return Head;
      end;

      function Last return Node_Access is
      begin
         return Tail;
      end;

      procedure First( Item : Node_Access ) is
      begin
         Head := Item;
      end First;

      procedure Last( Item : in Node_Access ) is
      begin
         Tail := Item ;
      end Last;

      entry Claim( Id : in Task_ID ) when Owner = Null_Task_ID is
      begin
         Owner := Id;
      end Claim;

      procedure Release is
      begin
         Owner := Null_Task_ID;
      end Release;

   end Object_Data_Type;

   ----------
   -- Free --
   ----------
   procedure Free is new Ada.Unchecked_Deallocation(
       Object_Data_Type, Object_Data_Access );

   procedure Free is new Ada.Unchecked_Deallocation(
       Node_Type, Node_Access );

   ----------------
   -- Initialize --
   ----------------
   procedure Initialize(
      This : in out Object ) is
   begin
      This.Data := new Object_Data_Type;
   end Initialize;

   --------------
   -- Finalize --
   --------------
   procedure Finalize(
      This : in out Object ) is
      Data : Object_Data_Access renames This.Data;
      P,Q  : Node_Access := null;
   begin
      P := Data.First;
      while P /= Data.Last loop
	 exit when P = null;
	 Q := P;
         P := P.Next;
	 Free( Q );
      end loop;

      Free( This.Data );
   end Finalize;

   ------------
   -- Append --
   ------------
   procedure Append(
      This : in out Object;
      Item : in Element_Type ) is
      Data : Object_Data_Access renames This.Data;
   begin
      Data.Append( Item );
   end Append;

   --------------
   -- Enumerator --
   --------------
   function Enumerator(
      This   : in Object;
      Mode   : in Sharing_Mode_Type := Read_Only ) return Enumerator_Type is
      Result : Enumerator_Type;
   begin
      Result.Data    := This.Data;
      Result.Current := This.Data.First;

      case Mode is
         when Master =>
            Result.Data.Claim( Current_Task );
         when others =>
            null;
      end case;
      Result.Mode := Mode;

      return Result;
   end Enumerator;

   -----------
   -- First --
   -----------
   procedure First(
      I : in out Enumerator_Type ) is
      Current : Node_Access renames I.Current;
   begin
      if I.Mode = Master and then Current /= null then
         Release( Current.Used );
      end if;

      Current := I.Data.First ;
   end First;

   ---------
   -- Get --
   ---------
   procedure Get(
      I    : in out Enumerator_Type;
      Item : out Element_Type ) is
      Current : Node_Access renames I.Current;
   begin
      if Current = null then
         raise End_Of_List;
      end if;

      if I.Mode = Master then
         Claim( Current.Used );
      end if;
      Item := Current.Value;

      Current := Current.Next;
   end Get;

   ------------
   -- Delete --
   ------------
   procedure Delete(
      I       : in out Enumerator_Type ) is
      Current : Node_Access renames I.Current;
      TMP     : Node_Access := null;
   begin

      if I.Mode /= Master then
         raise Not_Master;
      end if;

      if Current = null then
         raise End_Of_List;
      end if;

      TMP := Current;
      Claim( TMP.Used );

      if Current.Prev /= null then
         Current.Prev.Next := Current.Next;
      else
         I.Data.First( Current.Next );
      end if;

      if Current.Next /= null then
         Current.Next.Prev := Current.Prev;
      else
         I.Data.Last( Current.Prev );
      end if;

      -- adjusting the cursor
      if Current.Next /= null then
         Current := Current.Next;
      else
         Current := Current.Prev;
      end if;

      Release( TMP.Used );

      Free( TMP );
   end Delete;

   ---------
   -- Put --
   ---------
   procedure Put(
      I       : in out Enumerator_Type;
      Item    : in Element_Type ) is
      Current : Node_Access renames I.Current;
      TMP     : Node_Access := new Node_Type;
   begin
      if I.Mode /= Master then
         raise Not_Master;
      end if;

      if Current = null then
         I.Data.Append( Item );
      else
         Claim( Current.Used );

         TMP.Prev := Current;
         TMP.Next := Current.Next;

         if Current.Next = null then
            I.Data.Last( TMP );
         end if;

         Current.Next := TMP;

         Release( Current.Used );
      end if;
   end Put;

   --------------------
   -- Is_End_Of_List --
   --------------------
   function Is_End_Of_List(
      I : in Enumerator_Type ) return Boolean is
   begin
      return I.Current = null;
   end Is_End_Of_List;

end Util.Thread_Save_List;
