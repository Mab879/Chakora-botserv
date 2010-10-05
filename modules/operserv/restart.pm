# operserv/restart by The Chakora Project. Adds RESTART to OperServ, will write data about identified users to disk, then restart.
#
# Copyright (c) 2010 The Chakora Project. All rights reserved.
# Released under The BSD License (docs/LICENSE - http://www.opensource.org/licenses/bsd-license.php)
use strict;
use warnings;

module_init("operserv/restart", "The Chakora Project", "0.1", \&init_os_restart, \&void_os_restart, "all");

sub init_os_restart {
	cmd_add("operserv/restart", "Restart services.", "RESTART will save data about identified users to disk,\nsave services data to disk, restart, then relink and\nre-identify appropriate users.\n[T]\nSyntax: RESTART", \&svs_os_restart);
}

sub void_os_restart {
	delete_sub 'init_os_restart';
	delete_sub 'svs_os_restart';
	cmd_del("operserv/restart");
	delete_sub 'void_os_restart';
}

sub svs_os_restart {
	my ($user, @sargv) = @_;

	if (!has_spower($user, 'operserv:svs:run')) {
		serv_notice("operserv", $user, "Permission denied.");
		return;
	}
	
	serv_notice("operserv", $user, "Restarting services NOW!");
	svsilog("operserv", $user, "RESTART", "");
	svsflog('commands', uidInfo($user, 1)." (".uidInfo($user, 9)."): OperServ: RESTART");
	svsflog("chakora", "Restarting on request of ".uidInfo($user, 1)." (".uidInfo($user, 9).")");
	
	if (module_exists("chanserv/main")) {
		serv_quit("chanserv", "Restarting");
	}
	
	idflush();
	dbflush();
	serv_squit(config('me', 'sid'), "Restart by ".uidInfo($user, 1));
	if ($Chakora::IN_DEUBG) {
	`$Chakora::ROOT_SRC/../bin/chakora --debug`;
	}
	else {
	`$Chakora::ROOT_SRC/../bin/chakora`;
	}
	exit;
}

1;
