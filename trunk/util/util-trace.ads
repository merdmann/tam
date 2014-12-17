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
package Util.Trace is
   type Level_Type is new Natural Range 0..99;

   Informative : constant Level_Type := 1;
   Flow        : constant Level_Type := 30;
   Functional  : constant Level_Type := 60;

   ---------------------------------------------------------------------------
   -- Description:
   --    Start a trace session for the current task
   -- Preconditions:
   --     None
   -- Postconditions:
   --     P.1 - Tracefile with name of the current thread created
   -- Exceptions:
   -- Notes:
   ---------------------------------------------------------------------------  
   procedure Start_Trace( 
      Trace_File : in String;
      Level      : in Level_Type := 0 );

   ---------------------------------------------------------------------------
   -- Description:
   --    Write a trace entry with the given trace level
   -- Preconditions:
   --    None
   -- Postconditions:
   --    P.1 - If a trace session has been created previously by means 
   --          of Start_Trace the entry is appended to the file
   -- Exceptions:
   -- Notes:
   --------------------------------------------------------------------------- 
   procedure Log(
      Level	 : in Level_Type := Flow;
      Text       : in String ) ;

   ---------------------------------------------------------------------------
   -- Description:
   --   Set the directory where the trace files are written.
   -- Preconditions:
   --   None 
   -- Postconditions:
   --   P.1 - Directory is changed.
   -- Exceptions:
   -- Notes:
   ---------------------------------------------------------------------------  
   procedure Directory( 
      Trace_Path : in String );

   ---------------------------------------------------------------------------
   -- Description:
   --    Set the global trace level. 
   -- Preconditions:
   --    None
   -- Postconditions:
   --    P.1 - All entries written via LOG with a trace level higher then
   --          the trace level given here is written into the trace.
   -- Exceptions:
   -- Notes:
   ---------------------------------------------------------------------------  
   procedure Trace_Level(
      Level : in Level_Type ); 
   
   ---------------------------------------------------------------------------
   -- Description:
   --    Stop the current trace.
   -- Preconditions:
   --    None
   -- Postconditions:
   --    P.1 - The current trace file is closed and no records are written
   --          into the trace file.
   -- Exceptions:
   -- Notes:
   ---------------------------------------------------------------------------  
   procedure Stop_Trace;

   ---------------------------------------------------------------------------
   -- Description:
   --    Flush the trace 
   -- Preconditions:
   --    None
   -- Postconditions:
   --    P.1 - All records are flushed from the write buffer into the file.
   -- Exceptions:
   -- Notes:
   --    This method should be used for example in the context of exception
   --    handlers in order to avoid that trace records are getting lost.
   ---------------------------------------------------------------------------  
   procedure Flush;

end Util.Trace;
