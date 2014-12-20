with Ada.Strings.Unbounded;			use Ada.Strings.Unbounded;
with TAM.Persistent;

package String_Object is

   type Object is new TAM.Persistent.Object with record
      S : Unbounded_String := Null_Unbounded_String;
   end record;


   function Create( S : in String ) return Object;
   procedure Print( This : in Object );
   procedure Set( This : in out Object; S : in String );

   procedure Initialize(
      This : in out Object );

   procedure Finalize(
      This : in out Object );

end String_Object;
