# /  __ \ |         | |
# | /  \/ |__   __ _| | _____  _ __ __ _ 
# | |   | '_ \ / _` | |/ / _ \| '__/ _` |
# | \__/\ | | | (_| |   < (_) | | | (_| |
#  \____/_| |_|\__,_|_|\_\___/|_|  \__,_|
#    Operserv Uptime Module
#          Modules::operserv::uptime
#
# Operserv Uptime module for Chakora
use strict;
use warnings;

module_init("operserv/uptime", "The Chakora Project", "0.1", \&init_os_uptime, "all");

sub init_os_uptime {
	cmd_add("operserv/uptime", "Uptime", "Display\nservices\nuptime", \&svs_os_uptime);
}

sub svs_os_uptime {
    my ($raw) = @_;
	my @rex = split(' ', $raw);
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
	my $user = substr($rex[0], 1);
	serv_notice("os", $user, "Services were started at: ".$sdate);
	serv_notice("os", $user, "Services have been up for: ".int($days)." days, ".int($hours).":".int($minutes).":".int($uptime)." seconds.");
}

1;
