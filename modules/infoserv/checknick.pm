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
	#Check to see if InfoServ exits
		if(!module_exist("infoserv/main") {
			module_load("infoserv/main");
	}

	#Check to see if NickServ Exists
		if (!module_exist("nickserv/main") {
			module_load("nickserv/main");
	} 
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
	 if (is_identified)$user) {
                  serv_notice("infoserv", $user, "Your nick, /002$user/002 is registerd and idnetifyied.");
	}	  

         if (defined($Chakora::DB_nick{lc(uidInfo($sargv[1], 1))}{account}) {
                  serv_notice("infoserv", $user, "The nick /002$sargv[1]/002 is registred.");
		}
         if (!defined($Chakora::DB_nick{lc(uidInfo($sargv[1], 1))}{account})) {
	                  serv_notice("infoserv", $user, "The user /002$sargv[1]/002 is not registed.");
	}
}
  
