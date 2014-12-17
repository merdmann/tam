-- ------------------------------------------------------------------------- --
--                                                                           --
--  Filename        : $Source: /cvsroot/TAM/TAM/Makefile
--  Description     : Primitive Lock type                                    --
--  Author          : Michael Erdmann <Michael.Erdmann@snafu.de>             --
--  Created On      : 30-April-2005                                          --
--  Last Modified By: $Author: merdmann $                                    --
--  Last Modified On: $Date: 2006/12/09 20:28:38 $                           --
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

with Util.Trace;                        use Util.Trace;
use  Util;

package body Util.Lock is

   Version : constant String :=
      "$Id: util-lock.adb,v 1.11 2006/12/09 20:28:38 merdmann Exp $";

   Lock_ID : Natural := 1;

   Lock_Level : constant Level_Type := Trace.Functional + 20 ;

   ---------------
   -- Lock_Type --
   ---------------
   protected type Lock_Type( LID : Natural := 0) is
       entry Claim( Id : Task_ID );
       procedure Clear;
       procedure Set_Finalize;
       function  Current_Owner return Task_Id;
       entry Wait_Finalized;
   private
       Owner     : Task_ID := Null_Task_ID;
       Finalized : Boolean := False;
   end Lock_Type;

   protected body Lock_Type is

       entry Claim( Id : Task_ID ) when ( Owner = Null_Task_ID or Finalized ) is
       begin
          Owner := Id;

          if Finalized then
             raise Invalid_Lock;
          end if;
       end Claim;

       procedure Clear is
       begin
          if Owner = Current_Task then
             Owner := Null_Task_ID;
          elsif Owner /= Null_Task_ID and then Owner /= Null_Task_ID then
             raise Not_Lock_Owner;
          end if;
       end ;

       procedure Set_Finalize is
       begin
          Finalized := True;
       end Set_Finalize;

       entry Wait_Finalized when Lock_Type.Claim'Count = 0 is
       begin
          Owner := Null_Task_ID;
       end;

       function Current_Owner return Task_ID is
       begin
          return Owner;
       end Current_Owner;

   end Lock_Type;

   -----------
   -- Image --
   -----------
   function Image(
      This : in Object ) return String is
   begin
      return Natural'Image( This.Id ) & "#" ;
   end Image;

   ----------------
   -- Initialize --
   ----------------
   procedure Initialize( This : in out Object ) is
   begin
      This.Id   := Lock_ID;

      LOG( Lock_Level, "Util.Lock.Initialize( Id=>" & Image( This ) & ")" );

      This.Lock := new Lock_Type( This.ID ) ;

      Lock_Id := Lock_ID + 1;
   end Initialize;

   --------------
   -- Finalize --
   --------------
   procedure Finalize( This : in out Object ) is
      Lock : Lock_Type_Access renames This.Lock;
   begin
      LOG( Lock_Level, "Util.Lock.Finalize( Id=>" & Image( This ) & ")" );
      Lock.Set_Finalize;
      Lock.Wait_Finalized;
   end Finalize;

   -----------
   -- Claim --
   -----------
   procedure Claim(
      This : in out Object ) is
   begin
      LOG(Lock_Level, "Util.Lock.Claim( Id=>" & Image( This ) & ")" );
      Trace.Flush;
      This.Lock.Claim( Current_Task );
      LOG(Lock_Level, "Util.Lock.Claimed( Id=>" & Image( This ) & ")");
      Trace.Flush;

   exception
      when Invalid_Lock =>
         LOG(Lock_Level, "Util.Lock.Claime( Id=>" & Image( This ) & ") ** Invalid Lock **");
         raise;
   end Claim;

   -----------
   -- Owner --
   -----------
   function Owner(
      This : in Object ) return Task_ID is
   begin
      return This.Lock.Current_Owner;
   end Owner;

   -------------
   -- Release --
   -------------
   procedure Release(
      This : in out Object ) is
   begin
      LOG(Lock_Level,
         "Util.Lock.Release( Id=>" & Image( This ) &
         ", task=>" & Image( Current_task ) & ")" );

      if This.Lock /= null then
         LOG( Lock_Level, "     Owner=>" & Image( Owner( This ) ) );
         This.Lock.Clear;
      end if;
   end Release;

end Util.Lock;
