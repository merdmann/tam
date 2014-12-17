-------------------------------------------------------------------------------
--                                                                           --
--  Filename        : $Source: /cvsroot/TAM/TAM/contrib/objects/util/util-dynamic_hashtable.adb,v $
--  Version         : $Revision: 1.3 $                                       --
--  Description     : Reseizable Hashtables                                  --
--  Author          : Michael Erdmann <Michael.Erdmann@snafu.de>             --
--  Created On      : 20-Oct-2006                                            --                                           --
--  Last Modified By: $Author: merdmann $				     --
--  Last Modified On: $Date: 2007/02/01 20:33:09 $                           --
--  Status          : $State: Exp $                                          --
--                                                                           --
--  Copyright (C) 2005 Michael Erdmann                                       --
--                                                                           --
--  ADB is free software;  you can redistribute it  and/or modify it under   --
--  terms of the  GNU General Public License as published  by the Free Soft- --
--  ware  Foundation;  either version 2,  or (at your option) any later ver- --
--  sion.  ADB is distributed in the hope that it will be useful, but WITH-  --
--  OUT ANY WARRANTY;  without even the  implied warranty of MERCHANTABILITY --
--  or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License --
--  for  more details.  You should have  received  a copy of the GNU General --
--  Public License  distributed with ADB;  see file COPYING.  If not, write  --
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
with Ada.Unchecked_Deallocation;
use  Ada;

with System.Storage_Elements;			use System.Storage_Elements;
with Util.Types;				use Util.Types;
with Util.Trace_Helper;
with Util.CAS;
use  Util;

package body Util.Dynamic_Hashtable is

   Version : constant String :=
      "$Id: util-dynamic_hashtable.adb,v 1.3 2007/02/01 20:33:09 merdmann Exp $";

   package Tracer is new Trace_Helper(
         Module => "Util.Dynamic_Hashtable",
         Level => 70
      );

   use Tracer;

   -------------------
   -- Key_List_Type --
   -------------------
   type Key_List_Type ;
   type Key_List_Access is access all Key_List_Type;


   type Key_List_Type is record
         Next     : Key_List_Access := null;
         Prev     : Key_List_Access := null;
	 Bucket   : Integer := -1;
	 HashKey  : Natural := 0;
	 SplitKey : Natural := 0;
	 Key      : Key_Access ;
	 Id       : Payload_Type ;
      end record;

   package Save_Key_Access is new CAS( Object_Type => Key_List_Access,
                                      Initial_Value => null );
   use Save_Key_Access;

   -------------------
   -- Iterator_Type --
   -------------------
   protected type Iterator_Type is
      procedure Reset( First : in Key_List_Access := null );
      function  First return Key_List_Access;
      function  Has_Next return Boolean;
      procedure Next( P : out Key_List_Access );
      procedure Prev( P : out Key_List_Access );
      function  Current return Key_List_Access ;
      procedure Insert( E : in Key_List_Access );
      procedure Append( E : in Key_List_Access );
      procedure Delete;

   private
      Head  : Key_List_Access := null;
      Tail  : Key_List_Access := null;
      Value : Key_List_Access := null;
   end Iterator_Type;

   -------------------
   -- Iterator_Type --
   -------------------
   protected body Iterator_Type is
      -- reset to any element
      procedure Reset(
         First : in Key_List_Access := null ) is
      begin
         if First /= null then
            Head := First ;
	 end if;

	 Value := Head;
      end Reset;

      function Has_Next return Boolean is
      begin
         return Value /= null and then Value.Next /= null;
      end Has_Next ;

      -- advance by one step.
      procedure Next(
         P : out Key_List_Access ) is
      begin
         if Value /= null then
            Value := Value.Next;
	    P     := Value;
	 else
	    P := null;
	 end if;

      end Next;

      -- go one step back
      procedure Prev(
         P : out Key_List_Access ) is
      begin
         if Value /= null then
            Value := Value.Prev;
	    P     := Value;
	 else
	    P := null;
	 end if;
      end Prev;

      -- get the first element in the list by traversing to the
      -- begin of the list.
      function First return Key_List_Access is
      begin
         return Head;
      end First;

      -- get the current pointer position
      function Current return Key_List_Access is
      begin
         return Value;
      end Current;

      --
      -- R.1 insert element after the current value
      --
      --  (P)->Q      	 (P)->E->Q
      --       |              |
      --  current 	  current
      --
      -- R.2 if reference pointer is null, reference = new element
      procedure Insert(
         E : in Key_List_Access ) is
         Q : Key_List_Access renames Value;
	 P : Key_List_Access := null;
      begin
         Enter("Insert");

	 if Value /= null then
	    P := Value.Prev;
	 end if;

         E.Next     := Q;
	 E.Prev     := P;

	 if Value /= null then	  			-- ** R.1 **
	    if P /= null then
	       P.Next := E ;
	    else
	       Head := E;
	    end if;

	    if Q /= null then
	       Q.Prev := E;
	    else
	       Tail := E;
	    end if;

	    Value := E;
	 else						-- ** R.2 **
	    Info("   First element" );
	    Value := E;
	    Head  := Value;
	    Tail  := Value;
	 end if;

	 Leave("Insert");
      end Insert;

      --
      -- R.1  if the cursor is already at the end we append directly
      -- R.2  if the cursor not at the end we line this up.
      --
      procedure Append(
         E : in Key_List_Access ) is
      begin
         Enter("Append");

	 if Value = null then
	    Value := E;
	    Tail  := E;
	    Head  := E;
	 elsif Value.Next = null then
	    Value.Next := E;
	    E.Prev := Value;
	    Value := E;
	    Tail  := E;
	 else
	    Tail.Next := E;
	    Tail := E;
	 end if;

	 Leave("Append");
      end Append;

      --
      -- R.1 - delete the current value
      --
      --   A -> P -> C    ===>  A -> C;
      --        |		|
      --      Current	      Current
      --
      -- R.2 - If this was a single element with out any prev. or next
      --       element the reference pointer is set to null.
      --
      -- R.3 - If we delete the first element correct the head
      --       pointer.
      --
      procedure Delete is
         P  : Key_List_Access := Value;
      begin
         Enter( "Delete");

         Value := null;			              	-- ** R.2 **

         if P.Prev /= null then                       	-- ** R.1 **
	    P.Prev.Next := P.Next;
	    Value := P.Prev;
	 else						-- ** R.3 **
	    Head := P.Next;
         end if;

	 if P.Next /= null then 		      	-- ** R.1 **
	    P.Next.Prev := P.Prev;
	    Value := P.Next;
	 else
	    Tail := P.Prev;
	 end if;

	 Leave("Delete");
      end Delete;

   end Iterator_Type;

   ----------
   -- Free --
   ----------
   procedure Free is
      new Unchecked_Deallocation( Key_List_Type, Key_List_Access );

   ---------------------
   -- Hash_Table_Type --
   ---------------------
   type Bucket_Array is array( Natural range <> ) of Save_Key_Access.Object;

   type Bucket_Array_Access is access all Bucket_Array ;

   Final_Bucket : constant Natural := 99999;

   ----------------------
   -- Object_Data_Type --
   ----------------------
   type Object_Data_Type is record
         Capacity : Natural := 2;
	 Bucket   : Bucket_Array_Access ;
	 Root     : Save_Key_Access.Object;
	 Nbr_Hops : Natural := 0;
	 Nbr_Ops  : Natural := 0;
      end record;

   --- :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: ---
   --- :::::::::::::: S U P P O R T    P R O C E D U R E S  ::::::::::::::: ---
   --- :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: ---


   --------------
   -- Get_Root --
   --------------
   function Get_Root(
      This : in Object ) return Key_List_Access is
      Data : Object_Data_Access renames This.Data;
      I    : Iterator_Type ;
   begin
      I.Reset( Get( Data.Root ) );

      return I.First;
   end Get_Root ;

   -----------
   -- Image --
   -----------
   function Key_Image(
      V      : in Natural ) return String is
      Result : String( 1..V'Size );
      N      : Natural := V;
   begin
      for i in 1..V'Size loop
         if  (N mod 2) = 1 then
	    Result(V'Size - (i-1) ) := '1';
	 else
	    Result(V'Size - (i-1) ) := '0';
	 end if;

	 N := N / 2;
      end loop;

      return " B'" & Result & "'" ;
   end Key_Image;

   ----------
   -- Dump --
   ----------
   procedure Dump(
      Data : Object_Data_Access ) is
      I    : Iterator_Type;
      P    : Key_List_Access := null;
   begin
      Enter("Dump, Cpacity=" & Natural'Image( Data.Capacity ) );
      I.Reset( Get( Data.Root ) );
      P := I.Current;
      while P /= null loop
         Info( Key_Image( P.Splitkey ) &
            ",(" & Natural'Image( P.Splitkey) & "), " & Integer'Image( P.Bucket) );

	 I.Next(P);
      end loop;
   end Dump;

   -----------------
   -- Bit_Reverse --
   -----------------
   function Bit_Reverse(
      V : in Natural ) return Natural is
      Result : Natural := 0;
      Base   : Natural := 2 ** (Natural'Size-1);
      N      : Natural := V;
   begin
      for i in reverse 0..(Natural'Size-1) loop
         if  (N mod 2) = 1 then
	    Result := Result + Base;
         end if;

	 N := N / 2;
	 Base := Base / 2;
       end loop;

       return Result;
   end Bit_Reverse;

   ----------------
   -- Is_Bit_Set --
   ----------------
   function Is_Bit_Set(
      V   : in Natural;
      Nbr : in Natural ) return Boolean is
      N   : Natural := V;
   begin
      return ( V / (2**Nbr) ) mod 2 = 1;
   end Is_Bit_Set;

   ------------------
   -- Is_Last_Node --
   ------------------
   function Is_Last_Node(
      E : in Key_List_Access ) return Boolean is
   begin
      return E /= null and then E.Bucket /= -1;
   end Is_Last_Node;

   --- :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: ---
   --- :::::::::::::: I N S T A N C E  M A N A G E M E N T  ::::::::::::::: ---
   --- :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: ---

   ----------------
   -- Initialize --
   ----------------
   procedure Initialize(
      This    : in out Object ) is
      Data    : Object_Data_Access := new Object_Data_Type;
      I       : Iterator_Type;
      Success : Boolean := False;
      Dummy   : Key_List_Access ;
   begin
      Enter("Initialize( Capacity=" & Natural'Image( This.Capacity ) & ")" );
      Data.Bucket := new Bucket_Array( 0..(This.Capacity-1) );
      Data.Capacity := This.Capacity;

      This.Data := Data;

      for B in Data.Bucket'Range loop
         Dummy := new Key_List_Type;
	 Dummy.Bucket := B;

         I.Append( Dummy );
	 CompareAndSet( Data.Bucket(B), null, Dummy, Success );
      end loop;

      Dummy := new Key_List_Type;
      Dummy.Bucket := Final_Bucket;
      I.Append( Dummy );

      CompareAndSet( Data.Root, null, I.First, Success );

      Dump(Data);
      Leave("Initialize");
   end Initialize;

   --------------
   -- Finalize --
   --------------
   procedure Finalize(
      This : in out Object ) is
      Data : Object_Data_Access renames This.Data;

      procedure XFree is new Unchecked_Deallocation(
          Object_Data_Type, Object_Data_Access );

      P : Key_List_Access := Get( Data.Root );
      N : Key_List_Access := null;
   begin
      Enter("Finalize");

      Dump( Data );

      while P /= null loop
         N := P.Next;
         Free(P);
         P := N;
      end loop;

      XFree( Data );
      Leave("Finalize");
   end Finalize;

   --- :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: ---
   --- :::::::::::::: K E Y S  / H A S H   H A N D L I N G  ::::::::::::::: ---
   --- :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: ---

   ----------
   -- Free --
   ----------
   procedure Free(
      Key : in out Key_Access ) is

      procedure XFree is
         new Ada.Unchecked_Deallocation( Key_Type, Key_Access);
   begin
      Enter("Free");
      XFree( Key );
   end Free;

   ----------------
   -- Create_Key --
   ----------------
   function Create_Key(
      Key : in Key_Type ) return Key_Access is
      Result : Key_Access := new Key_Type( 1..Key'Length );
      J : Storage_Offset := Result'First;
   begin
      for i in Key'Range loop
         Result(J) := Key(i);
         J := J + 1;
      end loop;

      return Result;
   end Create_Key;

   ----------
   -- Hash --
   ----------
   function Hash(
      Key    : in Key_Type ) return Natural is
      Result : Natural := 0;
      Exp    : Storage_Offset := 1;
   begin
      for i in Key'Range loop
         Result := Result + Natural(Exp) * ( Natural( Key(i) ) mod 2 ) ;
	 Exp := Exp * 2;
      end loop;

      return Result;
   end Hash;

   -----------
   --  Less --
   -----------
   function ">"(
      A, B   : in Key_Access ) return Boolean is
      Result : Boolean := False;
   begin
      Enter( ">" );
      if A'length > B'Length then
         Result := True;
      elsif A'Length = B'Length then
         Result := True;

         for i in reverse A'Range loop
	    Result := Result and ( A(i) > B(i) );

	    exit when Result = False;
	 end loop;
      else
         Result := False;
      end if;

      Leave("> yields " & Boolean'Image( Result ) );
      return Result;
   end ">";

   --- :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: ---
   --- :::::::::::::::::: T A B L E   F U N C T I O N S  :::::::::::::::::: ---
   --- :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: ---

   ------------
   -- Insert --
   ------------
   procedure Put(
      This : in out Object;
      Key  : in Key_Type;
      Id   : in Payload_Type ) is
      --
      -- add a new object id to the hash bucket calculated from the hash function.
      --
      Data    : Object_Data_Access renames This.Data;
      Hashkey : Natural := Hash( Key );
      B       : Natural := HashKey mod Data.Capacity;
      Item    : Key_List_Access := new Key_List_Type;
      I       : Iterator_Type ;
      Success : Boolean := False;

      -- insert the key in the list of the current bucket
      procedure Insert_Key(
         E   : in Key_List_Access ) is
         P   : Key_List_Access := null;
      begin
         I.Reset( Get( Data.Bucket(B) ) );

	 I.Next(P);   -- skip the dummy node

         while P /= null and (not Is_Last_Node(P)) loop
	    Data.Nbr_Hops := Data.Nbr_Hops + 1;

	    exit when E.Splitkey < P.Splitkey or E.Splitkey = P.Splitkey ;

	    I.Next(P);
	 end loop;
	 I.Insert(E);

      end Insert_Key;

   begin
      Enter("Insert(.., B=" & Natural'Image(B) & ")" );

      Data.Nbr_Ops := Data.Nbr_Ops + 1;

      Item.Key      := Create_Key( Key );
      Item.Id       := Id;
      Item.Hashkey  := Hashkey;
      Item.Splitkey := Bit_Reverse( HashKey );

      Info( "   Hashkey=" & Natural'Image( Item.Hashkey ) & Key_Image(Item.Hashkey) );

      Insert_Key( Item );

      Leave("Insert");
   end Put;

   ------------
   -- Delete --
   ------------
   procedure Delete(
      This : in out Object;
      Key  : in Key_Type ) is
      -- add item to the given bucket
      Data : Object_Data_Access renames This.Data;
      B    : Natural := hash( Key ) mod Data.Capacity;
      Old  : Key_List_Access := Get(Data.Bucket(B));
      I    : Iterator_Type ;
   begin
      Enter( "Delete(.. Hashcode " & Natural'Image(B) & ")" );

      I.Reset( Old );
      while I.Current /= null loop
         declare
            P : Key_List_Access := I.Current;
	    Success : Boolean := False;
	 begin
            if P.Key /= null and then (Key = P.Key.all) then
               declare
                  K : Key_Access := P.Key;
               begin
                  Free( K );
	          I.Delete;
	          CompareAndSet( Data.Bucket(B), Old, I.First, Success );
                  return;
               end;
	    end if;

	    I.Next( P );
	 end;
      end loop;

      raise Key_Not_Found;
   end Delete;

   ----------
   -- Find --
   ----------
   procedure Get(
      This : in Object;
      Key  : in Key_Type;
      Id   : out Payload_Type ) is
      -- add item to the given bucket
      Data : Object_Data_Access renames This.Data;
      B    : Natural := Hash( Key ) mod Data.Capacity;

      I    : Iterator_Type ;
      P    : Key_List_Access := null;
      Success : Boolean := False;
   begin
      Enter( "Find(.. Hashcode " & Natural'Image(B) & ")" );

      I.Reset( Get(Data.Bucket(B)) );
      I.Next(P);
      while P /= null loop
         exit when Is_Last_Node( P );

         if Key = P.Key.all then
	    Id := P.Id;
	    Success := True;
	    exit;
	 end if;

	 I.Next( P );
      end loop;

      Leave("Find success=" & Boolean'Image( Success ) );

      if not Success then
         raise Key_Not_Found;
      end if;
   end Get;

   --------------------
   -- Get_Statistics --
   --------------------
   function Get_Statistics(
      This   : in Object ) return Statistic_Type is
      Data   : Object_Data_Access renames This.Data;
      Result : Statistic_Type;
   begin
      Result.Nbr_Hops := Data.Nbr_Hops;
      Result.Nbr_Ops  := Data.Nbr_Ops;
      Result.Capacity := Data.Capacity;

      return Result;
   end Get_Statistics;

   ------------
   -- Extend --
   ------------
   procedure Extend(
     This   : in Object ) is
      -- extend the buckets by a factor 2 and reorganize the data
      Data     : Object_Data_Access renames This.Data;
      NB       : Bucket_Array_Access := null;

      Capacity : Natural := Data.Capacity * 2;

      -- calculate the new bucket position
      function Calculate_Bucket(
         P  : in Key_List_Access ) return Natural is
      begin
         if Is_Bit_Set(P.Splitkey, Natural'Size - Data.Capacity - 1 ) then
            return (P.Hashkey mod 2**Data.Capacity) + 2**Data.Capacity;
         else
            return 0;
         end if;
      end Calculate_Bucket;

      -- split a bucket
      procedure Split_Bucket(
         B  : Natural ) is
	 I  : Iterator_Type;
	 P  : Key_List_Access := null;
	 Success : Boolean    := False;
      begin
         Enter("Split_Bucket(" & Natural'Image(B) & ")" );
         I.Reset( Get( Data.Bucket(B) ) );

	 I.Next(P);
	 while P /= null and (not Is_Last_Node(P)) loop
	    declare
	       Target : Natural := Calculate_Bucket( P );
	       Dummy  : Key_List_Access := null;
	    begin
	       if Target > 0 then
	          Info("Moving " & Key_Image(P.Hashkey) & " to " & Natural'Image( Target ) );
		  Info("Hashkey points to " & Natural'Image(Hash(P.Key.all) mod (2**Capacity) ) );

		  Dummy := new Key_List_Type ;
		  Dummy.Bucket := Target;

	          CompareAndSet( NB(Target), null, Dummy, Success );
	          if Success then
	              I.Insert( Dummy );
	          else
                      Free( Dummy );
	          end if;

		  exit;
	       end if;

	       I.Next(P);
	    end ;
	 end loop;

	 CompareAndSet( NB(B)  , null, Get(Data.Bucket(B)), Success );

         Leave("Split_Bucket");
      end Split_Bucket;

   begin
      Enter("Extend" & Natural'Image( 2**Data.Capacity ) & " ->" & Natural'Image( 2**Capacity ) );

      Dump( Data );

      Info("------------ Splitting ------------" );
      NB := new Bucket_Array( 0..2**Capacity );

      for i in Data.Bucket'Range loop
         Split_Bucket(I);
      end loop;

      Data.Bucket := NB;
      Data.Capacity := Capacity;

      Info("------------ done ------------" );
      Dump(Data);
      Leave("Extend");
   end Extend;

package body Key_Iterator is

   ----------------------
   -- Object_Data_Type --
   ----------------------
   type Object_Data_Type is record
         I : Iterator_Type;
      end record;

   ----------------
   -- Initialize --
   ----------------
   procedure Initialize(
      This : in out Object ) is
      Data : Object_Data_Access := new Object_Data_Type;
   begin
      Enter("Key_Iterator.Initialize");

      This.Data := Data;

      Leave("Key_Iterator.Initialize");
   end Initialize;

   --------------
   -- Finalize --
   --------------
   procedure Finalize(
      This : in out Object ) is

      procedure XFree is new Unchecked_Deallocation(
          Object_Data_Type, Object_Data_Access );
   begin
      Enter("Key_Iterator.Finalize");

      Xfree( This.Data );

      Leave("Key_Iterator.Finalize");
   end Finalize;

   ------------
   -- Create --
   ------------
   procedure Create(
      This : in out Object;
      From : in Dynamic_Hashtable.Object ) is
      -- create a new iterator from a given hash table
      Data : Object_Data_Access renames This.Data;
   begin
      Enter("Create");

      Data.I.Reset( Get_Root(From) ) ;

      Leave("Create");
   end Create;

   -------------
   -- Get_Key --
   -------------
   function Get_Key(
      This   : in Object;
      Mode   : Get_Mode_Type := Next ) return Key_Access is
      Result : key_Access := null;
      Data   : Object_Data_Access renames This.Data;
      P      : Key_List_Access := null;
   begin
      Data.I.Next( P );

      Info("Get_Key(..," & Get_Mode_Type'Image( Mode ) & " ) => " & Image( P.Key ) );
      return P.Key;
   end Get_Key;

   --------------
   -- Has_Next --
   --------------
   function Has_Next(
      This   : in Object ) return Boolean is
      Data   : Object_Data_Access renames This.Data;
      Result : Boolean := False;
   begin
      Result := Data.I.Has_Next;
      Leave("Has_Next " & Boolean'Image( Result ) );

      return Result;
   end Has_Next;

end Key_Iterator;

end Util.Dynamic_Hashtable;
