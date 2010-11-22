# infoserv/nickcheck by Franklin IRC Services. Checks to see if your nick is registered.
#
# Copyright (c) 2010 The Chakora Project. All rights reserved.
# This software is free software; rights to this code are stated in docs/LICENSE.
use strict;
use warnings;

#Start the mdoule 
        module_inti("infoser/checknick", "Franklin IRC Services" "0.1", \&inti_is_nickcheck \&void_is_nickcheck);
#Add the command
sub inti_is_checknick {
         cmd_add("infoserv/checknick", "Tells if a nick is registered.", \&svs_is_checknick);
       }
sub void_is_checknick {
         delete_sub 'inti_is_checknick';
}
sub svs_is_checknick {
         my ($user, @sarfv) +@_;
	 (!defined($sargv[1])) {
	          serv_notice("infoserv", $user, "Not enough parameters. Syntax: CHECKNICK <nick>.");
			      }
	 if (is_identified)$user)) {
                  serv_notice("infoserv", $user, "Your nick, /002$user/002 is registerd and idnetifyied.");
	}	  

         if (is_identified($sargv[1])) {
                  serv_notice("infoserv
  
