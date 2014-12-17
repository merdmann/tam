-------------------------------------------------------------------------------
--                                                                           --
--  Filename        : $Source: /cvsroot/TAM/TAM/contrib/objects/util/util-dynamic_hashtable.ads,v $
--  Version         : $Revision: 1.1 $                                       --
--  Description     : Resizeable Hash tables                                 --
--  Author          : Michael Erdmann <Michael.Erdmann@snafu.de>             --
--  Created On      : 21.10.2005                                             --
--  Last Modified By: $Author: merdmann $				     --
--  Last Modified On: $Date: 2007/01/21 08:48:35 $                           --
--  Status          : $State: Exp $                                          --
--                                                                           --
--  Copyright (C) 2005 Michael Erdmann                                       --
--                                                                           --
--  ODB is free software;  you can redistribute it  and/or modify it under   --
--  terms of the  GNU General Public License as published  by the Free Soft- --
--  ware  Foundation;  either version 2,  or (at your option) any later ver- --
--  sion.  ODB is distributed in the hope that it will be useful, but WITH-  --
--  OUT ANY WARRANTY;  without even the  implied warranty of MERCHANTABILITY --
--  or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License --
--  for  more details.  You should have  received  a copy of the GNU General --
--  Public License  distributed with GNAT;  see file COPYING.  If not, write --
--  to  the Free Software Foundation,  59 Temple Place - Suite 330,  Boston, --
--  MA 02111-1307, USA.                                                      --
--                                                                           --
--  As a special exception,  if other files  instantiate  generics from this --
--  unit, or you link  this unit with other files  to produce an executable, --
--  this  unit  does not  by itself cause  the resulting  executable  to  be --
--  covered  by the  GNU  General  Public  License.  This exception does not --
--  however invalidate  any other reasons why  the executable file  might be --
--  covered by the  GNU Public License.                                      --
--                                                                           --
--  Functional Description                                                   --
--  ======================                                                   --
--  This algorithm is inspired by [1].                                       --
--                                                                           --
--  Restrictions                                                             --
--  ============                                                             --
--                                                                           --
--  References                                                               --
--  ==========                                                               --
--  [1] Ori Shalev, Nir Shavit 					             --
--      Split-Ordered List: Lock-Free Extensiuble Hash Tables                --
--       PODC'03 July 13-19, 2003                                            --
--                                                                           --
-------------------------------------------------------------------------------
with System.Storage_Elements;			use System.Storage_Elements;
with Ada.Finalization;				use Ada.Finalization;

with Util.Types;				use Util.Types;


generic
   type Payload_Type is private;

package Util.Dynamic_Hashtable is

   type Object( Capacity : Positive ) is new Controlled with private;

   ---------------------------------------------------------------------------
   -- Description:
   -- Preconditions:
   -- Postconditions:
   -- Exceptions:
   -- Notes:
   ---------------------------------------------------------------------------
   procedure Put(
      This : in out Object;
      Key  : in Key_Type;
      Id   : in Payload_Type );

   ---------------------------------------------------------------------------
   -- Description:
   -- Preconditions:
   -- Postconditions:
   -- Exceptions:
   -- Notes:
   ---------------------------------------------------------------------------
   procedure Get(
      This : in Object;
      Key  : in Key_Type;
      Id   : out Payload_Type );

   ---------------------------------------------------------------------------
   -- Description:
   -- Preconditions:
   -- Postconditions:
   -- Exceptions:
   -- Notes:
   ---------------------------------------------------------------------------
   procedure Delete(
      This : in out Object;
      Key  : in Key_Type);

  ---------------------------------------------------------------------------
   -- Description:
   -- Preconditions:
   -- Postconditions:
   -- Exceptions:
   -- Notes:
   ---------------------------------------------------------------------------
   procedure Extend(
     This   : in Object );

   Key_Not_Found      : exception;
   Key_Already_Exists : exception;
   Invalid_Argument   : exception;

   type Statistic_Type is record
          Nbr_Hops : Natural := 0;
	  Nbr_Ops  : Natural := 0;
	  Capacity : Natural := 0;
       end record;

   function Get_Statistics(
       This : in Object ) return Statistic_Type ;

   package Key_Iterator is

      type Object is new Controlled with private;

      type Get_Mode_Type is ( First, Next );

      function Get_Key(
         This : in Object;
         Mode : Get_Mode_Type := Next ) return Key_Access;

      procedure Create(
         This : in out Object;
         From : in Dynamic_Hashtable.Object );

      function Has_Next(
         This : in Object ) return Boolean;

   private
      type Object_Data_Type;
      type Object_Data_Access is access all Object_Data_Type;

      type Object is new Controlled with record
            Data : Object_Data_Access := null;
         end record;

      procedure Initialize(
         This : in out Object );

      procedure Finalize(
         This : in out Object );

   end Key_Iterator;


private

   type Object_Data_Type;
   type Object_Data_Access is access all Object_Data_Type;

   type Object( Capacity : Positive ) is new Controlled with record
         Data : Object_Data_Access := null;
      end record;

   procedure Initialize(
      This : in out Object );

   procedure Finalize(
      This : in out Object );

end Util.Dynamic_Hashtable;
