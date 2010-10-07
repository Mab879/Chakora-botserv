# nickserv/logout by The Chakora Project. Allows users to logout from their services account.
#
# Copyright (c) 2010 The Chakora Project. All rights reserved.
# This software is free software; rights to this code are stated in docs/LICENSE.
use strict;
use warnings;

module_init("nickserv/logout", "The Chakora Project", "0.1", \&init_ns_logout, \&void_ns_logout, "all");

sub init_ns_logout {
        if (!module_exists("nickserv/main")) {
                module_load("nickserv/main");
        }
	cmd_add("nickserv/logout", "Logs you out from services.", "LOGOUT unidentifies you from services\nSyntax: LOGOUT", \&svs_ns_logout);
}

sub void_ns_logout {
	delete_sub 'init_ns_logout';
	delete_sub 'svs_ns_logout';
	cmd_del("nickserv/logout");
	delete_sub 'void_ns_logout';
}

sub svs_ns_logout {
	my ($user, @sargv) = @_;
	
	if (!is_identified($user)) {
		serv_notice("nickserv", $user, "You're not identified to an account");
	}
	else {
		event_logout($user, uidInfo($user,9));
		svsflog('commands', uidInfo($user, 1).": NickServ: LOGOUT: as ".uidInfo($user, 9));
		serv_notice("nickserv", $user, "You have been logged out of services.");
		svsilog("nickserv", $user, "LOGOUT", "");
		serv_logout($user);
	}
}
