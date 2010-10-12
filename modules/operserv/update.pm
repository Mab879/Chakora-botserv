# operserv/update by The Chakora Project. Adds UPDATE to OperServ, will update the database.
#
# Copyright (c) 2010 The Chakora Project. All rights reserved.
# This software is free software; rights to this code are stated in docs/LICENSE.
use strict;
use warnings;

module_init("operserv/update", "The Chakora Project", "0.1", \&init_os_update, \&void_os_update);

sub init_os_update {
	cmd_add("operserv/update", "Updates the services database.", "UPDATE flushes the query of items waiting to\nbe written to the services database.", \&svs_os_update);
}

sub void_os_update {
	delete_sub 'init_os_update';
	delete_sub 'svs_os_update';
	cmd_del("operserv/update");
	delete_sub 'void_os_update';
}

sub svs_os_update {
	my ($user, @sargv) = @_;
	if (has_spower($user, 'operserv:update')) {
		serv_notice("operserv", $user, "Updating the services database.");
		svsilog("operserv", $user, "update", "");
		svsflog("commands", uidInfo($user, 1).": OperServ: UPDATE");
		dbflush();
	}
	else {
		serv_notice("operserv", $user, "Access denied.");
	}
}

1;
