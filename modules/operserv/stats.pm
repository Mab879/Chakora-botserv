# operserv/stats by The Chakora Project. Adds STATS to OperServ, will return services stats.
#
# Copyright (c) 2010 The Chakora Project. All rights reserved.
# This software is free software; rights to this code are stated in docs/LICENSE.
use strict;
use warnings;

module_init("operserv/stats", "The Chakora Project", "0.1", \&init_os_stats, \&void_os_stats);

sub init_os_stats {
	cmd_add("operserv/stats", "Display services uptime.", "Display when services were started, and how long they've been running.", \&svs_os_stats);
}

sub void_os_stats {
	delete_sub 'init_os_stats';
	delete_sub 'svs_os_stats';
	cmd_del("operserv/stats");
	delete_sub 'void_os_stats';
}

sub svs_os_stats {
    	my ($user, @sargv) = @_;
	serv_notice("operserv", $user, "-Services stats-");
	serv_notice("operserv", $user, "Registered accounts: ".scalar(keys %Chakora::DB_account));
	serv_notice("operserv", $user, "Registered nicknames: ".scalar(keys %Chakora::DB_nick));
	serv_notice("operserv", $user, "Registered channels: ".scalar(keys %Chakora::DB_chan));
}

1;
