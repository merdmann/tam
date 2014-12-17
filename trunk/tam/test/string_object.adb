with Ada.Text_IO;			use Ada.Text_IO;
with Util.Trace_Helper;


package body String_Object is

   package Tracer is new Util.Trace_Helper(Module=>"String_Object");
   use Tracer;

   ------------
   -- Create --
   ------------
   function Create( S : in String ) return Object is
      Result : Object;
   begin
      Enter("Create(" & S & ")" );

      Result.S := To_Unbounded_String(S);

      Leave("Create");
      return Result;
   end Create;

   -----------
   -- Print --
   -----------
   procedure Print( This : in Object ) is
   begin
      Enter("Print");
      Put_Line( To_String(This.S) );
      Leave("Print");
   end Print;

   ---------
   -- Set --
   ---------
   procedure Set( This : in out Object; S : in String ) is
   begin
      Enter("Set(" & S & ")" );
      This.S := To_Unbounded_String( S );
      Leave("Set");
   end Set;

   ----------------
   -- Initialize --
   ----------------
   procedure Initialize(
      This : in out Object ) is
   begin
      Enter("Initialize");

      Leave("Initialize");
   end Initialize;

   --------------
   -- Finalize --
   --------------
   procedure Finalize(
      This : in out Object ) is
   begin
      Enter("Finalize");

      Leave("Finalize");
   end Finalize;


end String_Object;
