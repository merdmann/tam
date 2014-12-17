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
with Util.Trace;				use Util.Trace;

package body Util.Trace_Helper is

   Version : constant String :=
      "$Id: util-trace_helper.adb,v 1.1 2007/01/21 08:48:35 merdmann Exp $";

   procedure Enter( S : in String ) is
   begin
      LOG( Level, Module & "." & S );
   end Enter;

   procedure Leave( S : in String ) is
   begin
      LOG( Level, Module & "." & S & " finished" );
   end Leave;

   procedure Error( S : in String ) is
   begin
      LOG( Trace.Flow, Module & "." & S & " *** Error ***" );
   end Error;

   procedure Info( S : in String ) is
   begin
      LOG( Level, "    " & S );
   end Info;

   ----------------------
   -- Report_Excpetion --
   ----------------------
   procedure Trace_Exception(
      E      : in Exception_Occurrence;
      Ignore : in Boolean := True ) is
   begin
      LOG( Trace.Flow, "Exception *** " & Exception_Name( E ) & ":" & Exception_Message( E ) );
      Trace.Flush;

      if not Ignore then
         Reraise_Occurrence( E );
      end if;
   end Trace_Exception;

end Util.Trace_Helper;
