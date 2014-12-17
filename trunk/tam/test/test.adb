with TAM.Transaction;				use TAM.Transaction;
use  TAM;

with Util.Trace;                		use Util.Trace;
with String_Object;				use String_Object;

procedure Test is
   T : TID_Type ;

   S : String_Object.Object := Create("Hallo Welt");
   U : String_Object.Object := Create("Ein String");
begin
   Start_Trace( "test", Level => 99 );

   declare
      S : String_Object.Object := Create("Hallo Welt");
      U : String_Object.Object := Create("Ein String");
   begin

      Print(S);

      T := Transaction.Begin_Or_Join;

      Add(S);
      Add(U);

      Set(S, "Test");

      Cancel;

      Print(S);
      Print(U);
   exception
      when others =>
         Cancel;
   end;


   Stop_Trace;
end Test;
