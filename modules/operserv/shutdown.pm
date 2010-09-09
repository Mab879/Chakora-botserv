# operserv/shutdown by The Chakora Project. Adds SHUTDOWN to OperServ, will shutdown services.
#
# Copyright (c) 2010 The Chakora Project. All rights reserved.
# Released under The BSD License (docs/LICENSE - http://www.opensource.org/licenses/bsd-license.php)
use strict;
use warnings;

module_init("operserv/shutdown", "The Chakora Project", "0.1", \&init_os_shutdown, \&void_os_shutdown, "all");

sub init_os_shutdown {
	cmd_add("operserv/shutdown", "Shutdown services.", "Shuts down all of Chakora.", \&svs_os_shutdown);
}

sub void_os_shutdown {
	delete_sub 'init_os_shutdown';
	delete_sub 'svs_os_shutdown';
	cmd_del("operserv/shutdown");
}

sub svs_os_shutdown {
	my ($user, @sargv) = @_;
	if (is_soper($user)) {
		serv_notice("operserv", $user, "Shutting down.");
		svsilog("operserv", $user, "shutdown", "");
		svsflog("chakora", "Shutting down due to SHUTDOWN by ".uidInfo($user, 1));
		serv_quit("chanserv", "Shutting down");
		serv_squit(config('me', 'sid'), "Shutdown by ".uidInfo($user, 1));
		dbflush();
		exit;
	}
	else {
		serv_notice("operserv", $user, "Access denied.");
	}
}
1;
