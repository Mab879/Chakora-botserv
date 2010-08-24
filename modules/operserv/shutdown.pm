# operserv/shutdown by The Chakora Project. Adds SHUTDOWN to OperServ, will shutdown services.
#
# Copyright (c) 2010 The Chakora Project. All rights reserved.
# Released under The BSD License (docs/LICENSE - http://www.opensource.org/licenses/bsd-license.php)
use strict;
use warnings;

module_init("operserv/shutdown", "The Chakora Project", "0.1", \&init_os_shutdown, \&void_os_shutdown, "all");

sub init_os_shutdown {
	cmd_add("operserv/shutdown", "Services shutdown", "Shuts down all of chakora.", \&svs_os_shutdown);
}

sub void_os_shutdown {
	delete_sub 'init_os_shutdown';
	delete_sub 'svs_os_shutdown';
	cmd_del("operserv/shutdown");
}

sub svs_os_shutdown {
	my ($raw) = @_;
	my @rex = split(' ', $raw);
	my $user = substr($rex[0], 1);
	if (is_soper($user)) {
		serv_notice("os", $user, "Shutting down.");
		svsilog("os", $user, "Shutdown", "");
		serv_quit("cs", "Shutting down");
		send_sock("SQUIT ".config('me', 'sid')." :Shutdown by ".uidInfo($user, 1));
		exit;
	}
	else {
		serv_notice("os", $user, "Access denied");
	}
}
1;
