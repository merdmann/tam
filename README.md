TAM
===

This the TAM project. The TAM project provides a small transaction
management system which can be used in cases where the same object 
is modified my several tasks in parallel.

In the example below we have a string object which can be manipulated
by multiple tasks. The methed Begin_Or_Join open the transaction; the 
method Add is used to associate the object S,U with the transaction and 
to create a save point. The operation Cancel rolls all changes which have 
been done by all tasks. If every thing is fine a Commit method is 
beeing called. Both the Commit and the Cancel operation will return
only after the _last_ process joining this transaction has complete 
by either commiting of canceling the operation.

.....

   T : TID_Type ;

   S : String_Object.Object := Create("Hallo Welt");
   U : String_Object.Object := Create("Ein String");
begin
   declare
      S : String_Object.Object := Create("Hallo Welt");
      U : String_Object.Object := Create("Ein String");
   begin

      T := Transaction.Begin_Or_Join;

      Add(S);
      Add(U);

      ..... do something ....

      if( Some_Error )
        Cancel;
      else 
        Commit;

   exception
      when others =>
         Cancel;
   end;

Installation
============

This is the source release which is either targets for environment like windows
having MinGW installed
 for linux environments.

Step 0 - Unpacking the release

[08:55 PM] MIchael@askar> gunzip -c *.gz | tar xvf -
tam-0.0.1/
tam-0.0.1/.gitignore
tam-0.0.1/AUTHORS
tam-0.0.1/COPYING
...........................


Step 2 - Compile

Execute in the installation directory the following  command(s):

08:55 PM] MIchael@askar> cd tam-0.0.1
[08:56 PM] MIchael@askar> cd trunk
[08:56 PM] MIchael@askar> make
mkdir -p ../build
gnatmake -P ../tam.gpr
gcc -c -I- -gnatA C:\users\MIchael\Downloads\tam-0.0.1\trunk\tam\tam-transaction.adb
......................
gcc -c -I- -gnatA C:\users\MIchael\Downloads\tam-0.0.1\trunk\tam\tam.ads
[08:56 PM] MIchael@askar>

This will create directory ../build where the static library and the include 
files (*.ads) files can be found.


Test
====

The directory ./test contains some test code which is compiled by running

$ make tamtest






