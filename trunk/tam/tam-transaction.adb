-- ------------------------------------------------------------------------- --
--                                                                           --
--  Filename        : $Source: /cvsroot/TAM/TAM/contrib/objects/tam/tam-transaction.adb,v $
--  Description     : Transaction Manager for objects                        --
--  Author          : Michael Erdmann <Michael.Erdmann@snafu.de>             --
--  Created On      : 27-Jan-2007                                            --
--  Last Modified By: $Author: merdmann $                                    --
--  Last Modified On: $Date: 2007/02/03 17:47:19 $                           --
--  Status          : $State: Exp $                                          --
--                                                                           --
--  Copyright (C) 2006-2007 Michael Erdmann                                  --
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
with Ada.Task_Identification;		use Ada.Task_Identification;
with Ada.Synchronous_Task_Control;	use Ada.Synchronous_Task_Control;
with Ada.Streams;               	use Ada.Streams;
with Ada.Streams.Stream_IO;     	use Ada.Streams.Stream_IO;

with Ada.Task_Attributes;
with Unchecked_Deallocation;

with Util.Lock;				use Util.Lock;
with Util.Memory_Streams;	use Util.Memory_Streams;
with Util.CAS;
with Util.Trace_Helper;
with Util.Thread_Save_List;
use  Util;

package body TAM.Transaction is

   Version : constant String :=
          "$Id: tam-transaction.adb,v 1.3 2007/02/03 17:47:19 merdmann Exp $" ;

   -- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ --
   -- ++++++++          P R I V A T E    D A T A                ++++++++++ --
   -- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ --

   -- each task votes about the success of an transaction by means of a
   -- cancel or commit.
   type Vote_Type is (
        Not_Used,       -- default
        Undefined,      -- the task is processing
        Failed,         -- the task execution as failed
        Success         -- the task has executed successfully
                     );

   package Save_Vote is new Util.CAS( Object_Type => Vote_Type,
                                    Initial_Value => Not_Used );

   type Collaboration_Type is record
         Vote  : Save_Vote.Object;
         Owner : Task_ID;
      end record;

   -- this array contains for all task involved in the transaction the task the
   -- vote information.
   type Collaboration_Array is array( 1..10 ) of Collaboration_Type;

   type Transaction_Member_Type is record
         Object_Stream : Stream_Access := null;
         Instance      : Persistent.Handle := null;
      end record;

   package Transaction_Member_List is
      new Util.Thread_Save_List( Element_Type => Transaction_Member_Type );

   --------------
   -- TCB_Type --
   --------------

   type TCB_Type is record
         Current_TID : TID_Type := 0;
         Pluscode    : Natural  := 0;
         Thread      : Collaboration_Array;
         Complete    : Suspension_Object;
         Vote_Lock   : Lock.Object;
         Members     : Transaction_Member_List.Object;
      end record;

   type TCB_Access is access TCB_Type;

   package Save_TCB_Access is new Util.CAS( Object_Type => TCB_Access,
                                          Initial_Value => null );

   -- The table of all ongoing transactions
   TT : array( 1..100 ) of Save_TCB_Access.Object;

   Pluscode : Natural := 0;

   --------------------
   -- Task_Info_Type --
   --------------------
   type Task_Info_Type is record
         State : TCB_Access := null;
      end record;

   Default_Task_Info : constant Task_Info_Type := ( State => null );

   package Task_Info is new Ada.Task_Attributes(
           Attribute => Task_Info_Type,
           Initial_Value => Default_Task_Info );

   ------------
   -- Tracer --
   ------------
   package Tracer is new Util.Trace_Helper( Module => "TAM.Transaction", Level=>50 );
   use Tracer;

   -- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ --
   -- ++++++++        P R I V A T E     M E T H O D S           ++++++++++ --
   -- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ --
   --                                                                      --
   --                                                                      --
   -- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ --

   --------------
   -- Allocate --
   --------------
   function Allocate return TCB_Access is
      Result  : TCB_Access := new TCB_Type ;
      Success : Boolean    := False;
      TID     : TID_Type   := Null_TID;
   begin
      Enter("Allocate");

      -- select a free transaction control block
      for i in TT'Range loop
         if Save_TCB_Access.Get( TT(i) ) = null then
            Save_TCB_Access.CompareAndSet( TT(i), null, Result, Success );
            TID := i;
            exit when Success;
         end if;
      end loop;

      Pluscode := Pluscode + 1;
      TID := TID + Pluscode * TT'Length;

      Result.Pluscode    := Pluscode ;
      Result.Current_TID := TID;
      Set_False( Result.Complete );

      Leave("Allocate returns" & TID_Type'Image(TID) );
      return Result;
   end Allocate;

   ----------------
   -- Deallocate --
   ----------------
   procedure Deallocate(
      TID      : in out TID_Type ) is
      Pluscode : Natural := TID / TT'Length;
      State    : TCB_Access := null;
      Success  : Boolean := False;

      procedure Free is new Unchecked_Deallocation(
            TCB_Type,
            TCB_Access);

      Offset   : Natural :=  TID mod TT'Length;
   begin
      Enter("Deallocate(" & TID_Type'Image( TID ) & ")" );

      State :=  Save_TCB_Access.Get( TT( Offset ) );
      Save_TCB_Access.CompareAndSet( TT( Offset ), State, null, Success );
      Free( State );

      Leave("Deallocate");
   end Deallocate;

   ---------------------
   -- Get_Transaction --
   ---------------------
   function Get_Transaction(
      TID    : in TID_Type ) return TCB_Access is
      Info   : Task_Info_Type := Task_Info.Value;
      Result : TCB_Access := null;
   begin
      Enter("Get_Transaction(" & TID_Type'Image( TID ) & ")" );
      if TID = Null_TID then
         Result := Info.State;
      else
         Result := Save_TCB_Access.Get( TT( TID mod TT'Length ) );
      end if;

      if Result = null then
         raise Invalid_Transaction;
      end if;

      Leave("Get_Transaction");
      return Result;
   end Get_Transaction;

   ----------------------
   -- Join_Transaction --
   ----------------------
   procedure Join_Transaction( TID : in TID_Type ) is
      State   : TCB_Access := Get_Transaction( TID );
      Success : Boolean := False;
   begin
      for i in State.Thread'Range loop
         if State.Thread(i).Vote.Get = Not_Used then
            Save_Vote.CompareAndSet( State.Thread(i).Vote,
               Not_Used,
               Undefined,
               Success );
            if Success then
               State.Thread(i).Owner := Current_Task;
            end if;
         end if;
      end loop;

      if not Success then
         raise To_Many_Transactions;
      end if;

   end Join_Transaction;

   --------------
   -- Fallback --
   --------------
   procedure Fallback(
      TCB : in TCB_Access ) is
      -- fall back to the original state for all objects stored in the
      -- transaction member list.
      use Transaction_Member_List;

      I : Enumerator_Type := Enumerator( TCB.Members, Master );
   begin
      Enter("Fallback( " & Natural'Image(TCB.Current_TID) & " )" );

      while not Is_End_Of_List(I) loop
         declare
            Member : Transaction_Member_Type ;
         begin
            Get(I, Member );
            Member.Instance.all := Persistent.Object'Class'Input( Member.Object_Stream );
            Destroy( Member.Object_Stream );
         end ;
      end loop;

      Leave("Fallback");
   end Fallback;

   -------------
   -- Release --
   -------------
   procedure Release( TCB : in TCB_Access ) is
      use Transaction_Member_List;

      I : Enumerator_Type := Enumerator( TCB.Members );
   begin
      while not Is_End_Of_List(I) loop
         declare
            Member : Transaction_Member_Type ;
         begin
            Get(I, Member );
            Destroy( Member.Object_Stream );
         end ;
      end loop;
   end Release;

   ----------
   -- Vote --
   ----------
   procedure Vote(
      TID    : in TID_Type;
      Result : in Vote_Type ) is
      -- R.1 The processing of votes has to be done strictly in sequence
      -- R.2 store the vote for the current task.
      -- R.3 if there are outstanding votes block this task
      --     else unblock all pending tasks (R.4)
      -- R.4 if we are the last outstanding task check the vote
      --     and intiate a fall back if the vote is failed, elese
      --     release all resources.

      TCB    : TCB_Access := Get_Transaction( TID );
      Final  : Boolean := True;
      Okay   : Boolean := True;
   begin
      Enter("Vote(" &
         TID_Type'Image(TID) & ", " &
         Vote_Type'Image(Result) & ")" );

      Claim( TCB.Vote_Lock );                            -- R.1

      for i in TCB.Thread'Range loop
         if TCB.Thread(i).Owner = Current_Task then      -- R.2
            declare
               Done : Boolean;
            begin
               Save_Vote.CompareAndSet(
                  TCB.Thread(i).Vote,
                  Save_Vote.Get(TCB.Thread(i).Vote),
                  Result,
                  Done );
            end;
         end if;

         Final := Final and (Save_Vote.Get(TCB.Thread(i).Vote) /= Undefined);
         Okay  := Okay and (Save_Vote.Get(TCB.Thread(i).Vote) = Success);
      end loop;

      Release( TCB.Vote_Lock );

      if not Final then                                 -- R.3
         Suspend_Until_True( TCB.Complete );
      else
         if Okay then                                   -- R.4
            null;
         else
            Fallback( TCB );
         end if;

         Set_True( TCB.Complete );
      end if;

      Leave("Vote with" &
         TID_Type'Image(TID) & ", " &
         Vote_Type'Image(Result) & ")" );
   end Vote;

   -- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ --
   -- ++++++++        P U B L I C     M E T H O D S             ++++++++++ --
   -- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ --

   -------------------
   -- Begin_Or_Join --
   -------------------
   function Begin_Or_Join(
      TID    : in TID_Type := Null_TID ) return TID_Type is
      Result : TID_Type := Null_TID;
   begin
      Enter( "Begin_Or_Join(" & TID_Type'Image(TID) & ")" );

      if TID /= Null_TID then
         Result := TID ;
      else
         declare
            TCB : TCB_Access := Allocate;
            Info : Task_Info_Type ;
         begin
            Info.State := TCB;
            Task_Info.Set_Value( Info );
            Result := TCB.Current_TID;
         end;
      end if;
      -- add the current task to the transaction block
      Join_Transaction( Result );

      Leave( "Begin_Or_Join returns =" & TID_Type'Image(TID) );
      return Result;
   end Begin_Or_Join;

   ------------
   -- Cancel --
   ------------
   procedure Cancel(
      TID : in TID_Type := Null_TID ) is
   begin
      Enter( "Cancel(" & TID_Type'Image(TID) & ")" );

      Vote( TID, Failed );

      Leave("Cancel");
   end Cancel;

   ------------
   -- Commit --
   ------------
   procedure Commit(
      TID : in TID_Type := Null_TID ) is
   begin
      Enter( "Commit(" & TID_Type'Image(TID) & ")" );

      Vote( TID, Success );

      Leave( "Commit" );
   end Commit;

   ---------
   -- Add --
   ---------
   procedure Add(
      Item   : in out Persistent.Object'Class;
      TID    : in TID_Type := Null_TID ) is
      TCB    : TCB_Access := Get_Transaction( TID );
      Member : Transaction_Member_Type ;
   begin
      Member.Object_Stream := Memory_Streams.Stream( 10_000 );
      Member.Instance := Item'Unchecked_Access;

      Persistent.Object'Class'Output(Member.Object_Stream, Item );

      Transaction_Member_List.Append( TCB.Members, Member );
   end Add;


end TAM.Transaction;
