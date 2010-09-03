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
}

sub svs_os_global {
	my ($raw) = @_;
	my @rex = split(' ', $raw);
	my $user = substr($rex[0], 1);
	if (is_soper($user)) {
		if ($rex[4]) {
			my $i;
			my $args = $rex[4];
			for ($i = 5; $i < count(@rex); $i++) { $args .= ' '.$rex[$i]; }
			svsilog("operserv", $user, "global", $args);
			send_global("[Global - ".uidInfo($user, 1)."] ".$args);
		}
		else {
			serv_notice("operserv", $user, "Not enough parameters. Syntax: GLOBAL <message>");
		}
	}
	else {
		serv_notice("operserv", $user, "Access denied.");
	}
}
1;
