# operserv/uptime by The Chakora Project. Adds UPTIME to OperServ, will return the uptime of services.
#
# Copyright (c) 2010 The Chakora Project. All rights reserved.
# This software is free software; rights to this code are stated in docs/LICENSE.
use strict;
use warnings;

module_init("operserv/uptime", "The Chakora Project", "0.1", \&init_os_uptime, \&void_os_uptime);

sub init_os_uptime {
	cmd_add("operserv/uptime", "Display services uptime.", "Display when services were started, and how long they've been running.", \&svs_os_uptime);
}

sub void_os_uptime {
	delete_sub 'init_os_uptime';
	delete_sub 'svs_os_uptime';
	cmd_del("operserv/uptime");
	delete_sub 'void_os_uptime';
}

sub svs_os_uptime {
    my ($user, @sargv) = @_;
    my $sdate = scalar(localtime($Chakora::SERVICES_STARTTIME));
	my $uptime = time() - $Chakora::SERVICES_STARTTIME;
	my $minutes = 0;
	my $hours = 0;
	my $days = 0;
	while ($uptime >= 60) {
		$uptime = $uptime - 60;
		$minutes = $minutes + 1;
	}
	while ($minutes >= 60) {
		$minutes = $minutes - 60;
		$hours = $hours + 1;
	}
	while ($hours >= 24) {
		$hours = $hours - 24;
		$days = $days + 1;
	}
	serv_notice("operserv", $user, "Services were started at: ".$sdate);
	serv_notice("operserv", $user, "Services have been up for: ".int($days)." days, ".int($hours).":".int($minutes).":".int($uptime));
}

1;
