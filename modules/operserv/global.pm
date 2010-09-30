# operserv/global by The Chakora Project. Adds GLOBAL to OperServ, sends a global to all users.
#
# Copyright (c) 2010 The Chakora Project. All rights reserved.
# Released under The BSD License (docs/LICENSE - http://www.opensource.org/licenses/bsd-license.php)
use strict;
use warnings;

module_init("operserv/global", "The Chakora Project", "0.1", \&init_os_global, \&void_os_global, "all");

sub init_os_global {
	cmd_add("operserv/global", "Sends a global", "Sends a notice to all users.", \&svs_os_global);
}

sub void_os_global {
	delete_sub 'init_os_global';
	delete_sub 'svs_os_global';
	cmd_del("operserv/global");
	delete_sub 'void_os_global';
}

sub svs_os_global {
	my ($user, @sargv) = @_;
	if (has_spower($user, 'operserv:global')) {
		if ($sargv[1]) {
			my $i;
			my $args = $sargv[1];
			for ($i = 2; $i < count(@sargv); $i++) { $args .= ' '.$sargv[$i]; }
			svsilog("operserv", $user, "global", $args);
			send_global("[Global - ".uidInfo($user, 1)."] ".$args);
		}
		else {
			serv_notice("operserv", $user, "Not enough parameters. Syntax: GLOBAL <message>");
		}
	}
	else {
		serv_notice("operserv", $user, "Permission denied.");
	}
}
1;
