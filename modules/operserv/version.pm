# operserv/version by The Chakora Project. Adds VERSION to OperServ, will return the current version.
#
# Copyright (c) 2010 The Chakora Project. All rights reserved.
# This software is free software; rights to this code are stated in docs/LICENSE.
use strict;
use warnings;

module_init("operserv/version", "The Chakora Project", "0.1", \&init_os_version, \&void_os_version, "all");

sub init_os_version {
	cmd_add("operserv/version", "Display services version", "Will return the current version of Chakora.", \&svs_os_version);
}

sub void_os_version {
	delete_sub 'init_os_version';
	delete_sub 'svs_os_version';
	cmd_del("operserv/version");
	delete_sub 'void_os_version';
}

sub svs_os_version {
	my ($user, @sargv) = @_;
	serv_notice("operserv", $user, $Chakora::SERVICES_VERSION." - Developed by ".$Chakora::DEVS);
}

1;
