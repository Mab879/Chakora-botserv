# nickserv/logout by The Chakora Project. Allows users to logout from their services account.
#
# Copyright (c) 2010 The Chakora Project. All rights reserved.
# Released under The BSD License (docs/LICENSE - http://www.opensource.org/licenses/bsd-license.php)
use strict;
use warnings;

module_init("nickserv/logout", "The Chakora Project", "0.1", \&init_ns_logout, \&void_ns_logout, "all");

sub init_ns_logout {
	cmd_add("nickserv/logout", "Logs you out from services.", "LOGOUT unidentifies you from services\nSyntax: LOGOUT", \&svs_ns_logout);
}

sub void_ns_logout {
	delete_sub 'init_ns_logout';
	delete_sub 'svs_ns_logout';
	cmd_del("nickserv/logout");
}

sub svs_ns_logout {
	my ($user, @sargv) = @_;
	
	if (!defined(uidInfo($user,9))) {
		serv_notice("nickserv", $user, "You're not identified to an account");
	}
	else {
		event_logout($user, uidInfo($user,9));
		undef $Chakora::uid{$user}{'account'};
		serv_notice("nickserv", $user, "You have been logged out of services.");
		svsilog("nickserv", $user, "LOGOUT");
		serv_logout($user);
	}
}
