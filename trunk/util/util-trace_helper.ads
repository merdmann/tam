-- ------------------------------------------------------------------------- --
--                                                                           --
--  Filename        : $Source: /cvsroot/TAM/TAM/contrib/objects/util/util-trace_helper.ads,v $
--  Description     : Trace Helper package                                   --
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
with Ada.Exceptions;				use Ada.Exceptions;
with Util.Trace;				use Util.Trace;

generic
    Module : String ;
    Level  : Level_Type := Trace.Flow;

package Util.Trace_Helper is

   procedure Enter( S : in String );
   procedure Leave( S : in String );
   procedure Error( S : in String );
   procedure Info( S : in String );

  procedure Trace_Exception(
      E      : in Exception_Occurrence; 
      Ignore : Boolean := True );


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

end Util.Trace_Helper;